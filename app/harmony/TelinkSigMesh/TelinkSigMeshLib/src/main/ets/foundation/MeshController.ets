/********************************************************************************************************
 * @file MeshController.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2017
 *
 * @par Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/
import { GattConnection } from "../ble/GattConnection";
import { BindingController } from "../core/access/BindingController";
import { NetworkingBridge } from "../core/networking/NetworkingBridge";
import { NetworkingController } from "../core/networking/NetworkingController";
import { ProvisioningBridge } from "../core/provisioning/ProvisioningBridge";
import { ProvisioningController } from "../core/provisioning/ProvisioningController";
import { ArrayList, HashMap, HashSet } from "@kit.ArkTS";
import { access, ble, constant } from "@kit.ConnectivityKit";
import { MeshConfiguration } from "./MeshConfiguration";
import AccessBridge, { ACCESS_MODE_BINDING } from "../core/access/AccessBridge";
import { BusinessError } from "@kit.BasicServicesKit";
import {
    aesEcb,
    decryptOnlineStatus,
    generateBeaconKey,
    generateIdentityKey,
    generateNodeIdentityHash,
    generatePrivateBeaconKey,
    generatePrivateNodeIdentityHash,
    k3
} from "../utils/Encipher";
import { logd, loge, logw } from "../utils/MeshLogger";
import { ScanParameters } from "./parameter/ScanParameters";
import { ActionParameters } from "./parameter/ActionParameters";
import { ProvisioningDevice } from "../entity/ProvisioningDevice";
import { bytesEquals, bytesToHexString, num2Hex } from "../utils/ArrayUtils";
import { BindingParameters } from "./parameter/BindingParameters";
import { currentTimeMillis, LOCAL_MESSAGE_ADDRESS, validUnicastAddress } from "../utils/MeshUtils";
import { BindingDevice } from "../entity/BindingDevice";
import { BindingBearer } from "../core/access/BindingBearer";
import { AutoConnectParameters } from "./parameter/AutoConnectParameters";
import { MeshEvent } from "./event/MeshEvent";
import { BluetoothEvent } from "./event/BluetoothEvent";
import { ReliableMessageProcessEvent } from "./event/ReliableMessageProcessEvent";
import { Event } from "./Event";
import { AutoConnectEvent } from "./event/AutoConnectEvent";
import { ExtendBearerMode } from "../core/networking/ExtendBearerMode";
import { MeshMessage } from "../core/message/MeshMessage";
import { OnlineStatusEvent } from "./event/OnlineStatusEvent";
import { ProxyPDU } from "../core/proxy/ProxyPDU";
import { SecureNetworkBeacon } from "../core/networking/beacon/SecureNetworkBeacon";
import { GattNotificationEvent } from "./event/GattNotificationEvent";
import { NodeIdentitySetMessage } from "../core/message/config/NodeIdentitySetMessage";
import { NodeIdentity } from "../core/message/config/NodeIdentity";
import { CHARACTERISTIC_ONLINE_STATUS, CHARACTERISTIC_PB_OUT, CHARACTERISTIC_PROXY_OUT } from "../ble/UuidInfo";
import { ScanEvent } from "./event/ScanEvent";
import { MeshScanRecord } from "../ble/MeshScanRecord";
import { ProvisioningEvent } from "./event/ProvisioningEvent";
import { NetworkInfoUpdateEvent } from "./event/NetworkInfoUpdateEvent";
import { NotificationMessage } from "../core/message/NotificationMessage";
import { Opcode } from "../core/message/Opcode";
import { StatusMessage } from "../core/message/StatusMessage";
import { StatusNotificationEvent } from "./event/StatusNotificationEvent";
import { BindingEvent } from "./event/BindingEvent";
import { EventCallback } from "./EventCallback";
import { BleScanner } from "../ble/BleScanner";
import { ProvisioningParameters } from "./parameter/ProvisioningParameters";


/**
 * Created by kee on 2018/12/11.
 */


/**
 * Event callback
 *
 * @see Event
 */
export class MeshController implements ProvisioningBridge, NetworkingBridge, AccessBridge {
    /**
     * log tag
     */
    private static readonly LOG_TAG = "MeshController";
    /**
     * proxy node advertising networkId
     */
    private static readonly PROXY_ADV_TYPE_NETWORK_ID = 0x00;
    /**
     * proxy node advertising nodeIdentity
     */
    private static readonly PROXY_ADV_TYPE_NODE_IDENTITY = 0x01;
    /**
     * proxy node advertising private network id
     */
    private static readonly PROXY_ADV_TYPE_PRIVATE_NETWORK_ID = 0x02;
    /**
     * proxy node advertising private node identity
     */
    private static readonly PROXY_ADV_TYPE_PRIVATE_NODE_IDENTITY = 0x03;
    /**
     * period of scanning for node identity when binding
     */
    private static readonly BINDING_NODE_IDENTITY_SCAN_PERIOD = 8 * 1000;
    /**
     * scanning controller for bluetooth device scan
     */
    private mBleScanner: BleScanner;
    /**
     * gatt controller for gatt connection
     */
    private mGattConnection: GattConnection;
    /*
     * controllers
     */
    private mProvisioningController: ProvisioningController
    // mesh network
    private mNetworkingController: NetworkingController;
    // key binding
    private mBindingController: BindingController
    /**
     * current active action
     */
    private actionMode = Mode.IDLE;
    /**
     * parameters for different action
     */
    private mActionParams?: ActionParameters
    /**
     * is disconnecting when reconnect
     */
    private isDisconnectWaiting = false;
    /**
     * flag of bluetooth scanning
     */
    private isScanning = false;
    /**
     * cache of bluetooth scanning records+
     */
    private advDevices: HashMap<string, ble.ScanResult> = new HashMap();
    /**
     * current mesh configs
     */
    private meshConfiguration: MeshConfiguration = new MeshConfiguration()
    /**
     * networkId, networkIdentityKey, networkBeaconKey and privateBeaconKey are calculated by networkKey in {@link #meshConfiguration}
     */
    private networkId: Uint8Array = new Uint8Array()
    private networkIdentityKey: Uint8Array = new Uint8Array()
    private networkBeaconKey: Uint8Array = new Uint8Array()
    private privateBeaconKey: Uint8Array = new Uint8Array()
    private isLogin = false;
    /**
     * action started flag when provisioning, binding, ota,  mesh-updating
     */
    private isActionStarted = false;
    /**
     * max connection retry count if gatt connect failed
     */
    private static readonly MAX_CONNECT_RETRY = 3;
    /**
     * current connection retry index
     */
    private connectRetry = 0;
    /**
     * event callback
     */
    private eventCallback?: (event: Event) => void;
    /**
     * direct connected device unicast address
     */
    private directDeviceAddress = 0;
    /**
     * reconnect target proxy node by node identity
     */
    private static readonly TARGET_PROXY_CONNECT_TIMEOUT = 60 * 1000;
    /**
     * binding target valued when device scanned
     */
    private reconnectTargetDeviceId?: string;
    /**
     * for binding on flex bearer
     */
    private bindingStartTick = 0;

    /**
     * In this method, the following steps are performed:
     * 1. Create and start A new HandlerThread named "Mesh-Controller".
     * 2. Create handler based on HandlerThread .
     * 3. Various controllers are initialized using the handlerThread:
     * a. ScanningController is initialized.
     * b. GattConnection is initialized.
     * c. GattOtaController is initialized.
     * d. ProvisioningController is initialized.
     * e. NetworkingController is initialized.
     * f. AccessController is initialized.
     * 5. An IntentFilter is created and configured to listen for BluetoothAdapter state changes.
     * 6. The mBluetoothReceiver is registered as a broadcast receiver to receive the BluetoothAdapter state change broadcasts.
     * <p>
     *
     * @param context
     */

    constructor() {
        this.mGattConnection = new GattConnection(this.connectionStateCallback, this.gattNotify);
        this.mProvisioningController = new ProvisioningController();
        this.mProvisioningController.setProvisioningBridge(this);
        this.mNetworkingController = new NetworkingController(this);

        this.mBindingController = new BindingController(this);
        this.mBleScanner =
            new BleScanner(this.onScanStartFail, this.onScanStarted, this.onScanTimeout, this.onScanDeviceFound);
    }

    start(): void {
        try {
            access.on('stateChange', this.onReceiveEvent);
        } catch (err) {
            console.error('errCode: ' + (err as BusinessError).code + ', errMessage: ' +
            (err as BusinessError).message);
        }
    }


    /**
     * clear network busy state and cache
     */
    clearNetworkCache() {
        if (this.mNetworkingController) {
            this.mNetworkingController.clear();
        }
    }

    // 定义蓝牙开关状态变化函数回调
    onReceiveEvent(st: access.BluetoothState) {
        this.onBluetoothStateUpdate(st);
    }


    /**
     * Used to listen for changes in the Bluetooth state of the device.
     * <p>
     * The onReceive() method is called when the BroadcastReceiver receives a broadcast intent. It checks the action of the received intent and if it matches the BluetoothAdapter.ACTION_STATE_CHANGED action, it retrieves the current state of the Bluetooth adapter from the intent and calls the onBluetoothStateUpdate() method with the state as a parameter.
     */
    // private BroadcastReceiver mBluetoothReceiver = new BroadcastReceiver() {
    //     @Override
    //     public void onReceive(Context context, Intent intent) {
    //         String action = intent.getAction();
    //         if (action == null) return;
    //         if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
    //             int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, 0);
    //             onBluetoothStateUpdate(state);
    //         }
    //     }
    // };


    /**
     * This method is used to stop the current operation and reset all the variables and controllers. It performs the following actions:
     * <p>
     * 1. Sets the action mode to IDLE.
     * 2. Resets the direct device address to 0.
     * 3. Sets the login status to false.
     * 4. Calls the stopScan() method to stop scanning for devices.
     * 5. Clears the list of advertised devices.
     * 6. Disconnects the GATT connection if it is not null and sets the connection callback to null.
     * 7. Clears the provisioning controller if it is not null.
     * 8. Clears the networking controller if it is not null and resets the direct address.
     * 9. Clears the binding controller if it is not null.
     * 10. Clears the firmware updating controller if it is not null. (This part is commented out in the code)
     * 11. Removes all callbacks and messages from the delay handler if it is not null.
     * 12. Quits the handler thread safely if it is not null.
     * 13. Unregisters the Bluetooth receiver from the context.
     * <p>
     */
    stop() {
        this.actionMode = Mode.IDLE;
        this.directDeviceAddress = 0;
        this.isLogin = false;
        this.stopScan();
        if (this.advDevices) {
            this.advDevices.clear();
        }

        if (this.mGattConnection) {
            this.mGattConnection.disconnectAndClear();
        }

        if (this.mProvisioningController) {
            this.mProvisioningController.clear();
        }

        if (this.mNetworkingController) {
            this.mNetworkingController.clear();
            this.mNetworkingController.resetDirectAddress();
        }

        if (this.mBindingController) {
            this.mBindingController.clear();
        }

        /*if (mFirmwareUpdatingController != null) {
            mFirmwareUpdatingController.clear();
            mFirmwareUpdatingController = null;
        }*/

        access.off('stateChange', this.onReceiveEvent);
    }

    /**
     * The returned value represents the mode in which the program is currently operating.
     */
    getMode(): Mode {
        return this.actionMode;
    }

    /**
     * Check the state of the Bluetooth adapter.
     */
    checkBluetoothState() {
        this.onBluetoothStateUpdate(access.getState());
    }

    /**
     * It handles different Bluetooth states and performs necessary actions accordingly.
     *
     * @param state The updated Bluetooth state.
     */
    private onBluetoothStateUpdate(state: access.BluetoothState) {
        let stateInfo = '';
        switch (state) {
            case access.BluetoothState.STATE_OFF:
                stateInfo += 'STATE_OFF';
                break;
            case access.BluetoothState.STATE_TURNING_ON:
                stateInfo += 'STATE_TURNING_ON';
                break;
            case access.BluetoothState.STATE_ON:
                stateInfo += 'STATE_ON';
                break;
            case access.BluetoothState.STATE_TURNING_OFF:
                stateInfo += 'STATE_TURNING_OFF';
                break;
            case access.BluetoothState.STATE_BLE_TURNING_ON:
                stateInfo += 'STATE_BLE_TURNING_ON';
                break;
            case access.BluetoothState.STATE_BLE_ON:
                stateInfo += 'STATE_BLE_ON';
                break;
            case access.BluetoothState.STATE_BLE_TURNING_OFF:
                stateInfo += 'STATE_BLE_TURNING_OFF';
                break;
            default:
                stateInfo += 'unknown state';
                break;
        }
        console.info('bluetooth state: ' + stateInfo);
        this.onBluetoothEvent(state, stateInfo);
    }

    /**
     * This function sets up a mesh network using the provided configuration.
     * It initializes various keys required for network communication and sets up the networking controller with the provided configuration.
     *
     * @param configuration config
     */
    setupMeshNetwork(configuration: MeshConfiguration) {
        logd(`setupMeshNetwork : ${configuration.toString()}`)
        this.meshConfiguration = configuration;
        this.networkId = k3(configuration.networkKey);
        this.networkIdentityKey = generateIdentityKey(configuration.networkKey);
        this.networkBeaconKey = generateBeaconKey(configuration.networkKey);
        this.privateBeaconKey = generatePrivateBeaconKey(configuration.networkKey);
        this.mNetworkingController.setup(configuration);
    }

    /**
     * This method removes a device from the mesh network configuration. First, it removes the device key associated with the given mesh address from the device key map in the mesh configuration. Then, it calls the networking controller to remove the device key as well.
     * <p>
     * If the action mode is set to AUTO_CONNECT, it then validates the auto connect targets to ensure they are still valid after the removal of the device.
     * <p>
     * Overall, this method is responsible for removing a device from the mesh network and updating the necessary components accordingly.
     *
     * @param meshAddress target mesh address of the device
     */
    removeDevice(meshAddress: number) {
        this.meshConfiguration.removeDeviceKey(meshAddress);
        this.mNetworkingController!.removeDeviceKey(meshAddress);
        if (this.actionMode == Mode.AUTO_CONNECT) {
            this.validateAutoConnectTargets();
        }
    }

    /**
     * Returns a boolean value indicating whether the provisioner is logged in as a proxy.
     *
     * @return true if the provisioner is logged in as a proxy, false otherwise.
     */
    isProxyLogin(): boolean {
        return this.isLogin;
    }

    /**
     * Returns the direct connected address of a node.
     */
    getDirectNodeAddress(): number {
        return this.directDeviceAddress;
    }

    /**
     * This method is used to put the service in an idle state.
     * It takes a boolean parameter "disconnect" which indicates whether the device should be disconnected or not.
     * It stops the ongoing scan by calling the "stopScan()" method.
     *
     * @param disconnect true if need to disconnect the currenct gatt connection, false otherwise
     */
    public idle(disconnect: boolean) {
        logd("---idle--- , disconnect=" + disconnect);
        this.validateActionMode(Mode.IDLE);
        this.clearNetworkCache();
        if (disconnect) {
            this.mGattConnection.disconnect();
        }
        this.stopScan();
    }

    /**
     * Checks if Bluetooth is enabled on the device.
     *
     * @return true if Bluetooth is enabled, false otherwise.
     */
    public isBluetoothEnabled(): boolean {
        return access.getState() == access.BluetoothState.STATE_ON
    }

    /**
     * This method enables Bluetooth on the device
     * by using the BluetoothAdapter class and calling the enable() method.
     */
    public enableBluetooth() {
        access.enableBluetooth()
    }

    /**
     * This method retrieves the MAC address of the current device.
     * If the Gatt connection is established, it returns the MAC address
     * obtained from the Gatt connection. Otherwise, it returns null.
     *
     * @return The MAC address of the current device, or null if not connected.
     */
    public getCurDeviceMac(): string | undefined {
        if (this.mGattConnection.isConnected()) {
            return this.mGattConnection.getDeviceId();
        }
        return undefined;
    }

    /**
     * Stops the scanning process.
     * Sets the "isScanning" flag to false and calls the stopScan() method of the mBleScanner object.
     */
    public stopScan() {
        this.isScanning = false;
        this.mBleScanner.stopScan();
    }

    /**
     * This code snippet connects to a Bluetooth device by stopping any ongoing scans
     * and initiating a GATT connection.
     *
     * @param device target BluetoothDevice
     */
    public connect(deviceId: string) {
        this.stopScan();
        this.mGattConnection.connect(deviceId);
    }

    /**
     * Disconnects the Gatt connection.
     */
    public disconnect() {
        this.mGattConnection.disconnect();
    }

    public clearTimers() {

    }

    /**
     * This method starts a scan for Bluetooth devices using the provided scan parameters.
     * 1.  checks if the action mode is valid for scanning. If not, it returns without performing any further actions.
     * 2.  removes any pending callbacks and messages from the delay handler.
     * 3.  sets the action mode to scan and clears the list of advertisement devices.
     * 4.  assigns the scan parameters to the action parameters and resets the action.
     * If the GATT connection is not successfully disconnected, it starts the scan. Otherwise, it logs a message indicating that it is waiting for the disconnect.
     *
     * @param scanParameters
     */
    public startScan(scanParameters: ScanParameters) {
        if (!this.validateActionMode(Mode.SCAN)) {
            return;
        }
        this.clearTimers()
        this.actionMode = Mode.SCAN;
        this.advDevices.clear();
        this.mActionParams = scanParameters;
        this.resetAction();
        if (!this.mGattConnection.disconnect()) {
            this.startBleScan();
        } else {
            logd("waiting for disconnect...");
        }
    }

    /**
     * Starts the BLE scan with the specified parameters.
     */
    private startBleScan() {
        logd("start scan: " + this.actionMode);
        let filter = this.mActionParams!.get(ActionParameters.SCAN_FILTERS) as ble.ScanFilter[]
        let timeout = this.mActionParams!.getNumber(ActionParameters.COMMON_SCAN_TIMEOUT, 10 * 1000);
        this.mBleScanner.startScan(filter, timeout);
    }


    /**
     * Used to initiate the provisioning process.
     * rebuild the provisioning device with the params in {@link MeshConfiguration};
     * <p>
     * If the GATT is connected, destroy the connection
     *
     * @param parameters
     * @return returns if the provisioning process is successfully initiated.
     */
    startProvisioning(parameters: ProvisioningParameters): boolean {
        logd("start provision");
        if (!this.validateActionMode(Mode.PROVISION)) {
            return false;
        }
        this.clearTimers()
        this.actionMode = Mode.PROVISION;
        this.mProvisioningController.setProvisioningBridge(this);
        this.mActionParams = parameters;
        this.resetAction();
        let provisioningDevice = parameters.get(ActionParameters.ACTION_PROVISIONING_TARGET) as ProvisioningDevice
        this.rebuildProvisioningDevice(provisioningDevice);
        if (this.mGattConnection.disconnect()) {

            this.isDisconnectWaiting = true;
        } else {
            this.connect(provisioningDevice.bluetoothDeviceId);
        }
        return true;
    }


    continueProvision(address: number): boolean {
        if (this.actionMode != Mode.PROVISION) {
            logd("continue provision fail : not in provision action -> " + this.actionMode);
            return false;
        }
        logd(`continue provision : ${num2Hex(address, 4)}`);
        this.mProvisioningController.continueProvision(address);
        return true;
    }

    /**
     * Used to rebuild the provisioning device by setting various parameters.
     * <p>
     * 1. set the IV Index of the provisioning device to the value stored in the meshConfiguration object.
     * 2. set the Network Key and Network Key Index of the provisioning device to the values stored in the meshConfiguration object.
     * 3. set the IV Update Flag and Key Refresh Flag of the provisioning device to 0.
     *
     * @param provisioningDevice target
     */
    private rebuildProvisioningDevice(provisioningDevice: ProvisioningDevice) {
        provisioningDevice.ivIndex = (this.meshConfiguration.ivIndex);
        provisioningDevice.networkKey = (this.meshConfiguration.networkKey);
        provisioningDevice.networkKeyIndex = (this.meshConfiguration.netKeyIndex);
        provisioningDevice.ivUpdateFlag = 0
        provisioningDevice.keyRefreshFlag = 0
    }

    /**
     * This method starts the process of binding application key to node.
     * <p>
     * If the GATT connection is already established with the proxy node and the binding target is either the direct device address or the binding bearer is set to Any or Flex, it calls the onConnectSuccess() method.
     * <p>
     * Otherwise, it sets the binding start tick to the current system time and checks if disconnecting from the GATT connection is successful. If so, it sets the isDisconnectWaiting flag to true. If not, it starts scanning for devices.
     */
    startKeyBind(bindingParameters: BindingParameters) {
        if (!this.validateActionMode(Mode.MODE_BIND)) {
            logd("key binding currently");
            return;
        }
        this.clearTimers()
        let bindingDevice = bindingParameters.get(ActionParameters.ACTION_BINDING_TARGET) as BindingDevice

        if (!validUnicastAddress(bindingDevice.meshAddress)) {
            logw(`start bind fail: node address invalid ${num2Hex(bindingDevice.meshAddress, 4)}`);
            this.onBindingFail("node address invalid");
            return;
        }

        this.mActionParams = bindingParameters;
        this.actionMode = Mode.MODE_BIND;
        this.reconnectTargetDeviceId = undefined;
        this.resetAction();

        // if mac address
        let bindingTarget = bindingDevice.meshAddress
        let bindingBearer = bindingDevice.bearer
        if (this.mGattConnection.isProxyNodeConnected() &&
            (this.directDeviceAddress == bindingTarget || bindingBearer == BindingBearer.Any ||
                bindingBearer == BindingBearer.Flex)) {
            this.onConnectSuccess();
        } else {
            this.bindingStartTick = currentTimeMillis()
            if (this.mGattConnection.disconnect()) {
                // waiting for callback
                this.isDisconnectWaiting = true;
            } else {
                this.startBleScan();
            }
        }
    }


    /**
     * This method is used to automatically connect to a device based on the provided parameters.
     */
    autoConnect(parameters: AutoConnectParameters) {
        if (!this.validateActionMode(Mode.AUTO_CONNECT)) {
            logd("auto connect currently");
            return;
        }
        this.clearTimers()
        this.mActionParams = parameters;
        logd("auto connect");
        this.actionMode = Mode.AUTO_CONNECT;
        if (!this.validateAutoConnectTargets()) {
            return;
        }
        if (this.mGattConnection.isProxyNodeConnected()) {
            if (this.isLogin) {
                this.onAutoConnectSuccess();
            } else {
                this.proxyFilterInit();
            }
        } else {
            if (this.mGattConnection.disconnect()) {
                // waiting for disconnected
                this.isDisconnectWaiting = true;
            } else {
                this.startBleScan();
            }
        }
    }

    /**
     * used to Send a GattRequest to the GattConnection.
     *
     * @param request the GattRequest to be sent
     * @return true if the request was successfully sent, false otherwise
     */
    getGattConnection() {
        return this.mGattConnection
    }

    /**
     * Retrieves the Maximum Transmission Unit (MTU) value of the current GATT connection.
     * The MTU represents the maximum size of data packets that can be transmitted over the connection.
     *
     * @return The MTU value of the GATT connection.
     */
    getMtu(): number {
        return this.mGattConnection.getMtu();
    }


    /**
     * This method is used to initiate a safety scan.
     * It first checks if the GATT connection is successfully disconnected using the  `disconnect()`  method.
     * If the disconnection is successful, it sets a flag  `isDisconnectWaiting`  to true, indicating that a callback is expected.
     * If the disconnection fails, it proceeds to start the scan by calling the  `startScan()`  method.
     */
    private startSafetyScan() {
        if (this.mGattConnection.disconnect()) {
            // waiting for callback
            this.isDisconnectWaiting = true;
        } else {
            this.startBleScan();
        }
    }

    /**
     * Validates the specified action mode against the current action mode.
     *
     * @param targetMode The target action mode to validate.
     * @return True if the action mode is valid and has been updated, false otherwise.
     */
    private validateActionMode(targetMode: Mode): boolean {
        if (this.actionMode == targetMode) {
            logw("mode not changed : " + this.actionMode);
            return false;
        } else {
            if (this.actionMode == Mode.PROVISION) {
                this.mProvisioningController.clear();
            } else if (this.actionMode == Mode.MODE_BIND) {
                this.mBindingController.clear();
            }
            //            clearNetworkCache();
            this.actionMode = targetMode;
            return true;
        }
    }

    /**
     * check the device key map in MeshConfiguration
     */
    private validateAutoConnectTargets(): boolean {

        if (this.meshConfiguration.deviceKeyMap.length == 0) {
            this.idle(false);
            this.onMeshEvent(MeshEvent.EVENT_TYPE_MESH_EMPTY, "mesh empty");
            return false;
        }
        return true;
    }


    /**
     * Generates a Bluetooth event with the given state and description, and triggers the onEventPrepared method.
     *
     * @param state The state of the Bluetooth event.
     * @param desc  The description of the Bluetooth event.
     */
    private onBluetoothEvent(state: access.BluetoothState, desc: string) {
        let event = new BluetoothEvent(BluetoothEvent.EVENT_TYPE_BLUETOOTH_STATE_CHANGE, state, desc);
        this.onEventPrepared(event);
    }

    /**
     * Handle a mesh event.
     * Creates a new MeshEvent object with the given eventType and desc parameters,
     * and then calls the onEventPrepared method passing the meshEvent as a parameter.
     *
     * @param eventType event type
     * @param desc      description
     */
    private onMeshEvent(eventType: string, desc: string) {
        let meshEvent = new MeshEvent(eventType, desc);
        this.onEventPrepared(meshEvent);
    }

    /**
     * This method is used to handle reliable message process events.
     *
     * @param eventType event type in {@link RemoteProvisioningEvent}
     * @param success   is reliable message success
     * @param opcode    message opcode
     * @param rspMax    response max
     * @param rspCount  response count
     * @param desc      description
     */
    private onReliableMessageProcessEvent(eventType: string, success: boolean, opcode: number, dest: number,
        rspMax: number, rspCount: number, rspArr: Uint16Array, desc: string) {
        let event = new ReliableMessageProcessEvent(eventType,);
        event.success = success
        event.opcode = opcode
        event.rspMax = rspMax
        event.rspCount = rspCount
        event.desc = desc
        event.dest = dest
        event.rspArr = rspArr
        this.onEventPrepared(event);
    }

    /**
     * notify the event callback when an event has been prepared.
     *
     * @param event event
     */
    private onEventPrepared(event: Event) {
        logd("event : " + event.type)
        if (this.eventCallback) {
            this.eventCallback(event);
        }
    }

    /**
     * Used to indicate that an action has started.
     */
    private onActionStart() {
        this.isActionStarted = true;
    }

    /**
     * Reset the action status and connection retry counter.
     */
    private resetAction() {
        this.isActionStarted = false;
        this.connectRetry = 0;
    }

    /**
     * connected and filter set success
     */
    private onAutoConnectSuccess() {
        this.mGattConnection.enableOnlineStatus();
        this.onEventPrepared(new AutoConnectEvent(this.directDeviceAddress));
    }

    /**
     * This method retrieves the online status of the mesh network.
     * It checks if the user is logged in and if the GATT connection is enabled for online status.
     * Otherwise, it returns false.
     *
     * @return true if send gatt command success, otherwise false
     */
    public async getOnlineStatus(): Promise<boolean> {
        return this.isLogin && await this.mGattConnection.getOnlineStatus();
    }

    /**
     * Resets the extend bearer mode to the specified value.
     *
     * @param extendBearerMode the extend bearer mode to be set
     */
    public resetExtendBearerMode(extendBearerMode: ExtendBearerMode) {
        if (this.mNetworkingController != null) {
            this.mNetworkingController.setExtendBearerMode(extendBearerMode);
        }
    }


    /**
     * send mesh message
     * include config message and common message
     */
    public async sendMeshMessage(meshMessage: MeshMessage): Promise<boolean> {
        if (!this.isLogin) {
            logd("send message err : not login");
            return false;
        }
        logd(`send mesh message: ${meshMessage.constructor.name} , opcode=0x${num2Hex(meshMessage.getOpcode(),
            4)} , dst=0x${num2Hex(meshMessage.destinationAddress)} , isReliable=${meshMessage.isReliable()} , retryCnt=${meshMessage.retryCnt
        } , rspMax=${meshMessage.responseMax}`);

        let sent = await this.mNetworkingController.sendMeshMessage(meshMessage);
        if (meshMessage.isReliable()) {
            if (sent) {
                // sent
                this.onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESSING,
                    false,
                    meshMessage.getOpcode(),
                    meshMessage.destinationAddress,
                    meshMessage.responseMax,
                    0,
                    new Uint16Array(0),
                    "mesh message processing");
            } else {
                // busy
                this.onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESS_ERROR,
                    false,
                    meshMessage.getOpcode(),
                    meshMessage.destinationAddress,
                    meshMessage.responseMax,
                    0,
                    new Uint16Array(0),
                    "mesh message send fail");
            }
        }
        return sent;
    }

    /**
     * initialize the proxy filter.
     */
    private proxyFilterInit() {
        logd("filter init start");
        this.mNetworkingController.proxyFilterInit();
    }

    /**
     * receive online status notification
     * post online_status event
     *
     * @param data decrypted notification data
     */
    private onOnlineStatusNotify(data: Uint8Array) {
        let onlineStatusEvent = new OnlineStatusEvent(data);
        this.onEventPrepared(onlineStatusEvent);
    }

    /**
     * gatt notification
     *
     * @param completePacket online_status raw data or mesh complete data
     */
    private onGattNotification(completePacket: Uint8Array) {
        if (completePacket.length > 1) {
            let proxyPduType = (completePacket[0] & ProxyPDU.MASK_TYPE);

            let payloadData = completePacket.slice(1, completePacket.length)
            switch (proxyPduType) {
                case ProxyPDU.TYPE_PROVISIONING_PDU:
                    // provision packet
                    if (this.isActionStarted) {
                        this.mProvisioningController.pushNotification(payloadData);
                    }
                    break;

                case ProxyPDU.TYPE_NETWORK_PDU:

                    // proxy packet
                    this.mNetworkingController.parseNetworkPdu(payloadData);
                    break;

                case ProxyPDU.TYPE_PROXY_CONFIGURATION:
                    this.mNetworkingController.parseProxyConfigurationPdu(payloadData);
                    break;


                case ProxyPDU.TYPE_MESH_BEACON:
                    let beaconType = payloadData[0];
                    if (beaconType == SecureNetworkBeacon.BEACON_TYPE_SECURE_NETWORK) {
                        this.mNetworkingController.parseSecureBeacon(payloadData, this.networkBeaconKey);
                    } else if (beaconType == SecureNetworkBeacon.BEACON_TYPE_MESH_PRIVATE) {
                        this.mNetworkingController.parsePrivateBeacon(payloadData, this.privateBeaconKey);
                    }
                    break;
            }
        }
    }

    /**
     * This method is called when an unexpected notification is received from a specific service and characteristic identified by their UUIDs, along with the data received.
     * It creates a GattNotificationEvent object with the necessary information and passes it to the onEventPrepared() method.
     *
     * @param serviceUUID        service
     * @param characteristicUUID characteristic
     * @param data               notification data
     */
    private onUnexpectedNotify(serviceUUID: string, characteristicUUID: string, data: Uint8Array) {
        let event = new GattNotificationEvent(serviceUUID, characteristicUUID, data);
        this.onEventPrepared(event);
    }

    /**
     * start provision action
     */
    private beginProvision() {
        let provisioningDevice: ProvisioningDevice =
            this.mActionParams!.get(ActionParameters.ACTION_PROVISIONING_TARGET) as ProvisioningDevice
        this.onProvisionBegin(provisioningDevice, "provision begin");
        this.mProvisioningController.begin(provisioningDevice);
    }


    /**
     * gatt connect success
     */
    private onConnectSuccess() {

        if (this.actionMode == Mode.PROVISION) {
            this.onActionStart();
            this.beginProvision();
        } else {
            let isFilterInitNeeded
                = this.mActionParams!.getBool(ActionParameters.COMMON_PROXY_FILTER_INIT_NEEDED, false);

            if ((!this.isLogin && isFilterInitNeeded) || (this.directDeviceAddress == 0)) {
                this.proxyFilterInit();
            } else {
                // no need to init proxy filter
                this.onProxyLoginSuccess();
            }
        }
    }

    /**
     * This method is used to set the identity of a node in a mesh network.
     * <p>
     * call sendMeshMessage send the NodeIdentitySetMessage to the mesh network.
     *
     * @param targetAddress target node address
     */
    private setNodeIdentity(targetAddress: number) {
        logd(`set node identity on ${num2Hex(targetAddress)}`);
        // this.isProxyReconnect = false;
        let message = new NodeIdentitySetMessage(targetAddress);
        message.netKeyIndex = this.meshConfiguration.netKeyIndex
        message.identity = NodeIdentity.RUNNING
        this.sendMeshMessage(message);
    }

    private bindStartTimerId = 0

    /**
     * This method is called when the proxy login is successful. It sets the login status to true and performs different actions based on the action mode.
     * <p>
     * - If the action mode is AUTO_CONNECT, it calls the onAutoConnectSuccess() method.
     * - If the action mode is MODE_BIND, it delays the execution of the binding process by 500 milliseconds and then starts the binding process by calling the onActionStart() method. It retrieves the binding target device from the action parameters and begins the binding process using the specified network key index and application key index.
     * - If the action mode is GATT_OTA, it checks if there is a connection target device. If there is, it sets the node identity for that device. If not, it starts the GATT OTA process.
     * - If the action mode is GATT_CONNECTION, it checks if there is a connection target device. If there is, it sets the node identity for that device. If not, it completes the GATT connection process.
     * - If the action mode is MESH_OTA, it checks if there is a Mesh OTA target device. If there is, it sets the node identity for that device. If not, it starts the Mesh OTA process.
     * - If the action mode is FAST_PROVISION, it starts the fast provisioning process by calling the onActionStart() method and then begins the fast provisioning controller.
     */
    private onProxyLoginSuccess() {
        this.isLogin = true;
        switch (this.actionMode) {
            case Mode.AUTO_CONNECT:
                this.onAutoConnectSuccess();
                break;

            case Mode.MODE_BIND:
                clearTimeout(this.bindStartTimerId)
                this.bindStartTimerId = setTimeout(() => {
                    this.onActionStart();
                    let bindingDevice = this.mActionParams!.get(ActionParameters.ACTION_BINDING_TARGET) as BindingDevice
                    let netKeyIndex = bindingDevice.netKeyIndex
                    if (netKeyIndex == -1) {
                        netKeyIndex = this.meshConfiguration.netKeyIndex;
                    }
                    let appKey = this.meshConfiguration.getAppKey(bindingDevice.appKeyIndex)
                    if (appKey) {
                        this.mBindingController.begin(netKeyIndex, appKey, bindingDevice);
                    } else {
                        this.onBindingFail("appkey not found")
                    }
                }, 500)
                break;
        }
    }

    /**
     * called if action started when gatt disconnected
     * This method handles the event of a connection interruption. It performs different actions based on the current action mode.
     * <p>
     * In the case of the "PROVISION" mode, it retrieves the provisioning device and calls the "onProvisionFailed" method with the device and a description of the interruption.
     * <p>
     * In the case of the "MODE_BIND" mode, it calls the "onBindingFail" method with the description of the interruption.
     * <p>
     * In the case of the "GATT_OTA" mode, it calls the "onOtaComplete" method with a flag indicating the OTA completion status (false in this case) and the description of the interruption.
     * <p>
     * In the case of the "MESH_OTA" mode, it checks if the firmware update controller is distributing by device. If so, it starts scanning for devices again. Otherwise, it dispatches the firmware update state with a flag indicating the completion status (false in this case) and the description of the interruption.
     * <p>
     * In the case of the "FAST_PROVISION" mode, it calls the "onFastProvisioningComplete" method with a flag indicating the completion status (false in this case) and a description of the interruption.
     */
    private onConnectionInterrupt() {
        let desc = "connection interrupt";
        switch (this.actionMode) {
            case Mode.PROVISION:
                let device = this.mProvisioningController.getProvisioningDevice();
                this.onProvisionFailed(device!, desc);
                break;
            case Mode.MODE_BIND:
                this.onBindingFail(desc);
                break;

        }
    }

    /**
     * This method is called when a connection fails. It determines the action mode and performs specific actions based on the mode.
     * <p>
     * If the action mode is "PROVISION", it retrieves the provisioning device and calls the "onProvisionFailed" method, passing the device and a description of the failure.
     * <p>
     * If the action mode is "MODE_BIND", it calls the "onBindingFail" method, passing the description of the failure.
     * <p>
     * If the action mode is "GATT_OTA", it calls the "onOtaComplete" method with a false flag and the description of the failure.
     * <p>
     * If the action mode is "MESH_OTA", it dispatches the false flag and the description of the failure to the "dispatchFUState" method.
     * <p>
     * If the action mode is "FAST_PROVISION", it calls the "onFastProvisioningComplete" method with a false flag and a description of the failure.
     * <p>
     * If the action mode is "GATT_CONNECTION", it calls the "onGattConnectionComplete" method with a false flag and a description of the failure.
     */
    private onConnectionFail() {
        let desc = "connect fail";
        switch (this.actionMode) {
            case Mode.PROVISION:
                let provisioningDevice =
                    this.mActionParams!.get(ActionParameters.ACTION_PROVISIONING_TARGET) as ProvisioningDevice
                this.onProvisionFailed(provisioningDevice, "connect fail");
                break;
            case Mode.MODE_BIND:
                this.onBindingFail(desc);
                break;
        }
    }

    /**
     * This method is called when the GATT connection is disconnected.
     * The purpose of this method is to handle the disconnection event and perform necessary cleanup and actions based on the current action mode.
     */
    private onGattDisconnected() {
        this.clearTimers()
        this.onMeshEvent(MeshEvent.EVENT_TYPE_DISCONNECTED, "disconnected when: " + this.actionMode);
        this.mNetworkingController.clear();
        this.mNetworkingController.resetDirectAddress();
        if (this.isDisconnectWaiting) {
            this.isDisconnectWaiting = false;
            this.connectRetry = -1;
        }
        this.isLogin = false;
        this.directDeviceAddress = 0;
        if (this.actionMode != Mode.IDLE) {
            this.processDisconnection();
        }
    }

    /**
     * It is used to handle the disconnection of a Bluetooth device in a specific action mode.
     */
    public processDisconnection() {

        let needScan = this.actionMode == Mode.SCAN
            || this.actionMode == Mode.AUTO_CONNECT;
        if (needScan) {
            this.startBleScan();
        } else {
            if (this.actionMode == Mode.PROVISION
                || this.actionMode == Mode.MODE_BIND) {
                if (this.isActionStarted) {
                    this.onConnectionInterrupt();
                } else {
                    this.connectRetry++;
                    if (this.connectRetry >= MeshController.MAX_CONNECT_RETRY) {
                        // connect retry max
                        this.onConnectionFail();
                    } else {
                        // reconnect when provision and re-scan when other mode
                        if (this.actionMode == Mode.PROVISION) {
                            let provisioningDevice =
                                this.mActionParams!.get(ActionParameters.ACTION_PROVISIONING_TARGET) as ProvisioningDevice
                            logd("provisioning connect retry: " + this.connectRetry);
                            this.connect(provisioningDevice.bluetoothDeviceId);
                        } else if (this.actionMode == Mode.MODE_BIND) {
                            let device = this.reconnectTargetDeviceId;
                            if (device) {
                                this.connect(device);
                            } else {
                                this.startBleScan();
                            }
                        } else {
                            this.startBleScan();
                        }
                    }
                }
            }
        }

    }


    private connectInitTimerId = 0;
    connectionStateCallback = (state: ble.ProfileConnectionState) => {
        switch (state) {
            case constant.ProfileConnectionState.STATE_DISCONNECTED:
                this.onGattDisconnected()
                break
            case constant.ProfileConnectionState.STATE_CONNECTED:
                clearTimeout(this.connectInitTimerId)
                this.connectInitTimerId = setTimeout(async () => {
                    if (this.actionMode == Mode.PROVISION) {
                        await this.mGattConnection.provisionInit();
                    } else {
                        await this.mGattConnection.proxyInit();
                        this.mNetworkingController.checkSequenceNumber(this.networkId!, this.networkBeaconKey!);
                    }
                    this.onConnectSuccess();
                }, 500)
                break
        }

    }
    gattNotify = (serviceUuid: string, characteristicUuid: string, data: Uint8Array) => {
        if (characteristicUuid == CHARACTERISTIC_ONLINE_STATUS) {
            let decrypted = decryptOnlineStatus(data, this.networkBeaconKey!);
            //                MeshLogger.d("online dec: " + Arrays.bytesToHexString(decrypted));
            if (decrypted != null) {
                logd("online status decrypted data: " + bytesToHexString(decrypted, ":"));
                this.onOnlineStatusNotify(decrypted);
            } else {
                logw("online status decrypt err");
            }
        } else if (characteristicUuid == CHARACTERISTIC_PROXY_OUT || characteristicUuid == CHARACTERISTIC_PB_OUT) {
            this.onGattNotification(data);
        } else {
            this.onUnexpectedNotify(serviceUuid, characteristicUuid, data);
        }
    }

    /**
     * This method is called when a new advertising device is found during scanning.
     * If the device is successfully added, it prepares a scan event with the device information and calls the onEventPrepared method.
     */
    private onDeviceFound(device: ble.ScanResult) {
        logd("on device found: " + device.deviceId);
        if (this.advDevices.hasKey(device.deviceId)) {
            logw("Device already exist");
        } else {
            this.advDevices.set(device.deviceId, device)
            let scanEvent = new ScanEvent(ScanEvent.EVENT_TYPE_DEVICE_FOUND, device);
            this.onEventPrepared(scanEvent);
        }
    }

    /**
     * It creates a ScanEvent object with the EVENT_TYPE_SCAN_FAIL event type and no additional data.
     * The onEventPrepared method is then called to handle the prepared event.
     */
    private onScanFail() {
        //        idle(false);
        let scanEvent = new ScanEvent(ScanEvent.EVENT_TYPE_SCAN_FAIL, undefined);
        this.onEventPrepared(scanEvent);
    }

    /**
     * The purpose of this task is to restart a scan if the current action mode is either "AUTO_CONNECT" or "MESH_OTA".
     * In other words, if the program is in the process of automatically connecting or performing a mesh over-the-air update, the "startScan()" method will be invoked again.
     * <p>
     * This task can be used to schedule the restart of a scan in a background thread or within a specific time interval.
     */
    private restartScanTimerId = 0

    /**
     * This method is called when the ble scanning for devices times out.
     * <p>
     * If the action mode is "SCAN", it calls the onScanTimeoutEvent method. If the action mode is "MODE_BIND", it calls the onBindingFail method with the message "device not found when scanning".
     * <p>
     * If the action mode is "AUTO_CONNECT" or "MESH_OTA", it schedules a delayed task to restart the scanning after 3 seconds.
     * <p>
     * If the action mode is "GATT_OTA", it calls the onOtaComplete method with the parameters false and "ota fail: scan timeout".
     * <p>
     * If the action mode is "GATT_CONNECTION", it calls the onGattConnectionComplete method with the parameters false and "connection fail: scan timeout".
     * <p>
     * If the action mode is "FAST_PROVISION", it calls the onFastProvisioningComplete method with the parameters false and "no unprovisioned device found".
     * <p>
     * Finally, if no device was found during scanning and the location is disabled, it calls the onLocationDisableWarning method.
     *
     * @param anyDeviceFound
     */


    /**
     * This method is triggered when a scan timeout event occurs.
     * Creates a new ScanEvent object with the event type set to "EVENT_TYPE_SCAN_TIMEOUT" and passes null as the additional data.
     */
    private onScanTimeoutEvent() {
        this.idle(false);
        let scanEvent = new ScanEvent(ScanEvent.EVENT_TYPE_SCAN_TIMEOUT, undefined);
        this.onEventPrepared(scanEvent);
    }

    /**
     * validate advertising device when auto connect {@link Mode#AUTO_CONNECT}
     *
     * @param scanRecord scan record
     * @return is validate ok
     */
    private validateProxyAdv(scanRecord: ArrayBuffer): boolean {
        let sr = MeshScanRecord.parseFromBytes(scanRecord);
        if (!sr) {
            return false;
        }
        let serviceData = sr.getProxyServiceData();
        if (serviceData && serviceData.length >= 9) {
            let type = serviceData[0];
            if (type == MeshController.PROXY_ADV_TYPE_NETWORK_ID || type ==
            MeshController.PROXY_ADV_TYPE_PRIVATE_NETWORK_ID) {
                // validate network id matches
                return this.validateNetworkId(scanRecord);
            } else if (type == MeshController.PROXY_ADV_TYPE_NODE_IDENTITY ||
                type == MeshController.PROXY_ADV_TYPE_PRIVATE_NODE_IDENTITY) {
                let nodeIdentityCheck = this.validateNodeIdentity(serviceData);
                logd("check node identity pass? " + nodeIdentityCheck);
                return nodeIdentityCheck;
            }
        }
        return false;
    }

    /**
     * This method is used to validate the network ID in a given scan record.
     * <p>
     * The method takes in a byte array called "scanRecord" as a parameter. It first attempts to parse the scan record using the MeshScanRecord class. If the scan record cannot be parsed, the method returns false.
     * <p>
     * Next, the method retrieves the service data from the scan record using the UUID "SERVICE_PROXY". If the service data is not null and its length is greater than or equal to 9, the method proceeds to validate the network ID.
     * <p>
     * If the type of the service data is "PROXY_ADV_TYPE_NETWORK_ID", the method extracts the advertising network ID from the service data and compares it with the given network ID. If they match, the method returns true.
     * <p>
     * If the type of the service data is "PROXY_ADV_TYPE_PRIVATE_NETWORK_ID", the method extracts the hash and random values from the service data. It then calculates the hash using the network ID and random values along with the network identity key. The calculated hash is compared with the extracted hash, and if they match, the method returns true.
     * <p>
     * If the type of the service data is neither "PROXY_ADV_TYPE_NETWORK_ID" nor "PROXY_ADV_TYPE_PRIVATE_NETWORK_ID", an error message is logged.
     * <p>
     * If the service data is null or its length is less than 9, the method returns false.
     * <p>
     * Overall, this method checks if the network ID in the scan record matches the given network ID and returns true if it does. Otherwise, it returns false.
     *
     * @param scanRecord given scan record
     * @return is validate ok
     */
    private validateNetworkId(scanRecord: ArrayBuffer): boolean {
        let sr = MeshScanRecord.parseFromBytes(scanRecord);
        if (!sr) {
            return false;
        }
        let serviceData = sr.getProxyServiceData();
        if (serviceData != null && serviceData.length >= 9) {
            let type = serviceData[0];
            if (type == MeshController.PROXY_ADV_TYPE_NETWORK_ID) {
                // validate network id matches
                let networkIdLen = 8;
                let advertisingNetworkId = serviceData.slice(1, 1 + networkIdLen)
                let networkIdCheck = bytesEquals(this.networkId!, advertisingNetworkId)
                logd("check network id pass (normal) ? " + networkIdCheck);
                return networkIdCheck;
            } else if (type == MeshController.PROXY_ADV_TYPE_PRIVATE_NETWORK_ID) {
                // validate network id matches
                let hashLen = 8;
                let randomLen = 8;

                let hash = serviceData.slice(1, 1 + hashLen)
                let random = serviceData.slice(9, 9 + randomLen)
                let txt = new Uint8Array(16)
                txt.set(this.networkId!, 0)
                txt.set(random, 8)
                let calcHash = aesEcb(txt, this.networkIdentityKey!);
                let hashRe = calcHash.slice(8, 16)
                let networkIdCheck = bytesEquals(hash, hashRe);
                logd("check network id pass (private) ? " + networkIdCheck);
                return networkIdCheck;
            } else {
                logd("check network id error: not broadcasting network id type");
            }
        }
        return false;
    }

    /**
     * This method is used to validate the identity of a node based on the provided service data.
     * <p>
     *
     * @param serviceData service data
     * @return is validate ok
     */
    private validateNodeIdentity(serviceData: Uint8Array): boolean {
        if (this.meshConfiguration.deviceKeyMap.length == 0 || serviceData.length < 17) {
            return false;
        }

        let deviceKeyMap = this.meshConfiguration.deviceKeyMap;
        let nodeAddress: number;
        for (let devKey of deviceKeyMap) {
            if (this.validateTargetNodeIdentity(serviceData, devKey.address)) {
                this.directDeviceAddress = devKey.address;
                logd("reset direct device address");
                return true;
            }
        }
        return false;
    }

    /**
     * This method is used to validate the identity of a target node based on the service data and node address.
     * It takes the service data and node address as input parameters.
     * <p>
     * The method first checks if the service data is not null and has a length of at least 9 bytes.
     * If the conditions are met, it proceeds with the validation process.
     * <p>
     * It extracts the type of advertisement from the service data, which is stored in the first byte.
     * If the type is either PROXY_ADV_TYPE_NODE_IDENTITY or PROXY_ADV_TYPE_PRIVATE_NODE_IDENTITY,
     * it continues with the validation process.
     * <p>
     * The method then extracts the advertisement hash and random values from the service data.
     * These values are used to calculate the hash of the node identity.
     * <p>
     * If the type is PROXY_ADV_TYPE_NODE_IDENTITY, it generates the node identity hash using the networkIdentityKey,
     * random values, and node address. Otherwise, if the type is PROXY_ADV_TYPE_PRIVATE_NODE_IDENTITY,
     * it generates the private node identity hash using the same parameters.
     * <p>
     * The method compares the calculated hash with the advertisement hash.
     * If they are equal, it sets the pass variable to true.
     * <p>
     * Finally, it logs the result of the identity validation and returns the pass variable.
     */
    private validateTargetNodeIdentity(serviceData: Uint8Array, nodeAddress: number): boolean {
        let pass = false;
        if (serviceData && serviceData.length >= 9) {
            let type = serviceData[0];
            if (type == MeshController.PROXY_ADV_TYPE_NODE_IDENTITY ||
                type == MeshController.PROXY_ADV_TYPE_PRIVATE_NODE_IDENTITY) {
                let dataLen = 8;
                let index = 1;
                let advHash = serviceData.slice(1, dataLen + 1)
                index += dataLen;

                let random = serviceData.slice(index, index + dataLen)

                let hash: Uint8Array;
                if (type == MeshController.PROXY_ADV_TYPE_NODE_IDENTITY) {
                    logd("get node identity hash");
                    hash = generateNodeIdentityHash(this.networkIdentityKey!, random, nodeAddress);
                } else {
                    logd("get private node identity hash");
                    hash = generatePrivateNodeIdentityHash(this.networkIdentityKey!, random, nodeAddress);
                }
                pass = bytesEquals(advHash, hash);
            }
        }
        logd("check target node identity pass? " + pass);
        return pass;
    }


    /**
     * This method is called when a Bluetooth device is found during scanning.
     * It checks if the device should be connected based on the current action mode.
     * <p>
     * If the action mode is AUTO_CONNECT, it checks if the device's advertisement data is valid for proxy connection.
     * <p>
     * If the action mode is GATT_OTA or GATT_CONNECTION, it checks the connection filter type and validates the device based on the filter target.
     * <p>
     * If the action mode is MODE_BIND, it checks if the device's advertisement data is valid for binding.
     * <p>
     * If the action mode is FAST_PROVISION, it always connects to the device.
     * <p>
     * If the action mode is SCAN, it notifies the listener about the found device.
     * <p>
     * If the action mode is MESH_OTA, it checks if the device's advertisement data is valid for mesh OTA.
     * <p>
     * If the device is eligible for connection, the scanning is stopped and the device is connected.
     *
     * @param device     device
     * @param rssi       rssi
     * @param scanRecord scan record
     */
    private onScanFilter(scanResult: ble.ScanResult) {
        //  final BluetoothDevice device, final int rssi, final byte[] scanRecord
        let scanRecord = scanResult.data
        if (!this.isScanning) {
            return;
        }
        let connectIntent = false;
        let sr = MeshScanRecord.parseFromBytes(scanRecord);
        if (!sr) {
            return
        }
        if (this.actionMode == Mode.AUTO_CONNECT) {
            connectIntent = this.validateProxyAdv(scanRecord);
        } else if (this.actionMode == Mode.MODE_BIND) {
            let bindingDevice = this.mActionParams!.get(ActionParameters.ACTION_BINDING_TARGET) as BindingDevice

            if (bindingDevice.bearer == BindingBearer.GattOnly) {
                connectIntent = this.validateTargetNodeIdentity(sr.getProxyServiceData(), bindingDevice.meshAddress)
                // connectIntent = scanResult.rssi >= - 45;
                logd("bind check node identity pass? " + connectIntent);
            } else if (bindingDevice.bearer == BindingBearer.Flex) {
                if (currentTimeMillis() - this.bindingStartTick > MeshController.BINDING_NODE_IDENTITY_SCAN_PERIOD) {
                    connectIntent = this.validateProxyAdv(scanRecord);
                } else {
                    connectIntent =
                        this.validateTargetNodeIdentity(sr.getProxyServiceData(), bindingDevice.meshAddress);
                }
            } else {
                connectIntent = this.validateProxyAdv(scanRecord);
            }
            if (connectIntent && this.directDeviceAddress == bindingDevice.meshAddress) {
                this.reconnectTargetDeviceId = scanResult.deviceId;
            }
        } else if (this.actionMode == Mode.SCAN) {
            let single = this.mActionParams!.getBool(ActionParameters.SCAN_SINGLE_MODE, false);
            if (single) {
                this.stopScan();
            }
            this.onDeviceFound(scanResult);
        }

        if (connectIntent) {
            this.isScanning = false;
            this.connect(scanResult.deviceId);
        }

    }


    /**
     * Implementation of the BleScanner.ScannerCallback interface.
     * It provides callback methods for handling Bluetooth Low Energy (BLE) scanning events.
     * <p>
     * - onLeScan(): This method is called when a BLE device is detected during scanning. It receives the BluetoothDevice object representing the detected device, the received signal strength indicator (RSSI), and the scan record data. It logs the device's name, MAC address, and scan record in a specific format. It then invokes the onScanFilter() method to process the detected device.
     * <p>
     * - onScanFail(): This method is called when the BLE scanning fails. It sets the scanning flag to false and invokes the onScanFail() method in the MeshController class.
     * <p>
     * - onStartedScan(): This method is called when the BLE scanning starts. It sets the scanning flag to true.
     * <p>
     * - onStoppedScan(): This method is called when the BLE scanning stops.
     * <p>
     * - onScanTimeout(): This method is called when the BLE scanning times out. It receives a boolean parameter indicating whether any device was found during the scan. It then invokes the onScanTimeout() method in the MeshController class.
     */


    onScanDeviceFound = (scanResult: ble.ScanResult) => {
        logd("scan:" + scanResult.deviceName + " --id: " + scanResult.deviceId + " --record: " +
        bytesToHexString(new Uint8Array(scanResult.data), ":"));
        this.onScanFilter(scanResult);
    }
    onScanStartFail = () => {
        this.isScanning = false;
        this.onScanFail();
    }
    onScanStarted = () => {
        this.isScanning = true;
    }
    onScanTimeout = () => {
        logd("scanning timeout: " + this.actionMode);
        switch (this.actionMode) {
            case Mode.SCAN:
                this.onScanTimeoutEvent();
                break;

            case Mode.MODE_BIND:
                this.onBindingFail("device not found when scanning");
                break;

            case Mode.AUTO_CONNECT:
                this.restartScanTimerId = setTimeout(() => {
                    if (this.actionMode == Mode.AUTO_CONNECT) {
                        this.startBleScan();
                    }
                })
                break;
        }
    }

    /**
     * This method is used to post a provisioning event.
     *
     * @param eventType          event type
     * @param provisioningDevice provisioning device
     * @param desc               description
     */
    private postProvisioningEvent(eventType: string, provisioningDevice: ProvisioningDevice, desc: string) {

        let provisioningEvent = new ProvisioningEvent(eventType, provisioningDevice, desc);
        this.onEventPrepared(provisioningEvent);
    }

    /**
     * This method is called when the provisioning of a device begins.
     *
     * @param device ProvisioningDevice
     * @param desc   description
     */
    private onProvisionBegin(device: ProvisioningDevice, desc: string) {
        this.postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_BEGIN, device, desc);
    }

    /**
     * This method is called when the provisioning of a device fails.
     * It calls the onProvisionComplete method with a false parameter and posts a ProvisioningEvent with the EVENT_TYPE_PROVISION_FAIL type, the provisioning device, and the failure description.
     * <p>
     *
     * @param provisioningDevice ProvisioningDevice
     * @param desc               description
     */
    private onProvisionFailed(provisioningDevice: ProvisioningDevice, desc: string) {
        logd("provisioning failed: " + desc + " -- " + provisioningDevice.unicastAddress);
        this.onProvisionComplete(false);
        this.postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL, provisioningDevice, desc);
    }

    /**
     * This method is called when the provisioning process is successful.
     * It updates the directDeviceAddress variable with the unicast address of the provisioned device.
     * It also triggers a postProvisioningEvent with the EVENT_TYPE_PROVISION_SUCCESS type, passing the provisioningDevice and desc as parameters.
     *
     * @param provisioningDevice ProvisioningDevice
     * @param desc               description
     */
    private onProvisionSuccess(provisioningDevice: ProvisioningDevice, desc: string) {
        this.onProvisionComplete(true);
        this.directDeviceAddress = provisioningDevice.unicastAddress;
        this.postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS, provisioningDevice, desc);
    }


    private onProvisionCapabilityReceived(provisioningDevice: ProvisioningDevice, desc: string) {
        this.postProvisioningEvent(ProvisioningEvent.EVENT_TYPE_CAPABILITY_RECEIVED, provisioningDevice, desc);
    }

    /**
     * This method is called when the provisioning process is complete.
     * It takes a boolean parameter "success" which indicates whether the provisioning was successful or not.
     *
     * @param success is provisioning successful
     */
    private onProvisionComplete(success: boolean) {
        this.isActionStarted = false;
        // disconnect when provision fail
        this.idle(!success);
    }

    /**
     * This method is an override of the onProvisionStateChanged method from a superclass.
     * It is called when the provisioning state of a device changes.
     * <p>
     * The method takes two parameters: state, which represents the new state of the provisioning process, and desc, which provides a description or additional information about the state change.
     * <p>
     * Inside the method, there is a switch statement that handles different states of the provisioning process.
     * <p>
     * - In the case of ProvisioningController.STATE_COMPLETE, the method retrieves the provisioning device and updates the device key map with the device's unicast address and device key. It then calls the onProvisionSuccess method and logs a message indicating the success of the provisioning process.
     * <p>
     * - In the case of ProvisioningController.STATE_FAILED, the method logs a message indicating the failure of the provisioning process and retrieves the provisioning device. It then calls the onProvisionFailed method.
     * <p>
     * - In the case of ProvisioningController.STATE_CAPABILITY, the method logs a message indicating that the device's capability has been received.
     * <p>
     * Overall, this method handles different states of the provisioning process and performs appropriate actions based on the state.
     *
     * @param state provisioning state
     * @param desc  desc
     */
    public onProvisionStateChanged(state: number, desc: string) {
        let device = this.mProvisioningController.getProvisioningDevice()!
        switch (state) {
            case ProvisioningController.STATE_COMPLETE:
                this.updateDeviceKeyMap(device.unicastAddress, device.deviceKey!)
                logd("provision success");
                this.onProvisionSuccess(device!, desc);
                break;

            case ProvisioningController.STATE_FAILED:
                logd("provision failed, " + desc);
                this.onProvisionFailed(device!, desc);
                break;

            case ProvisioningController.STATE_CAPABILITY:
                logd("on device capability received");
                this.onProvisionCapabilityReceived(device,
                    "device capability received");
                break;
        }
    }

    /**
     * This method is called when a command is prepared to be sent.
     * <p>
     * Handles communication with a Bluetooth Low Energy (BLE) device using the Generic Attribute Profile (GATT) protocol. The sendMeshData() method is responsible for sending the prepared command to the BLE device.
     *
     * @param type proxy pdu typeValue {@link ProxyPDU#type}
     * @param data gatt data
     */
    public async onCommandPrepared(type: number, data: Uint8Array) {
        if (this.mGattConnection != null) {
            await this.mGattConnection.sendMeshData(type, data);
        }
    }

    /**
     * Method to handle the update of network information: the sequence number and IV index.
     *
     * @param sequenceNumber The new sequence number.
     * @param ivIndex        The new IV index.
     */
    public onNetworkInfoUpdate(sequenceNumber: number, ivIndex: number) {
        this.meshConfiguration.sequenceNumber = sequenceNumber;
        this.handleNetworkInfoUpdate(sequenceNumber, this.meshConfiguration.ivIndex);
    }

    /**
     * This method handles the update of network information with the given sequence number and IV index.
     * Creates a NetworkInfoUpdateEvent object with the provided sequence number and IV index.
     * Calls the onEventPrepared method to handle the prepared network info update event.
     *
     * @param sequenceNumber The sequence number of the network information update.
     * @param ivIndex        The IV index of the network information update.
     */
    public handleNetworkInfoUpdate(sequenceNumber: number, ivIndex: number) {
        logd(`handleNetworkInfoUpdate : sequenceNumber -- ${num2Hex(sequenceNumber, 6)} | ivIndex -- ${num2Hex(ivIndex,
            8)}`);

        let networkInfoUpdateEvent = new NetworkInfoUpdateEvent(sequenceNumber, ivIndex);
        this.onEventPrepared(networkInfoUpdateEvent);
    }

    /**
     * Handle mesh notification message
     * Creates a NotificationMessage object using the received parameters and calls the onMeshMessageNotification() method, passing the notificationMessage object as a parameter.
     *
     * @param src    source address
     * @param dst    destination address
     * @param opcode operation code
     * @param params parameters
     */
    public onMeshMessageReceived(src: number, dst: number, opcode: number, params: Uint8Array) {
        logd(`mesh model message received: src -- 0x${num2Hex(src, 4)} | dst -- 0x${num2Hex(dst,
            4)} | opcode -- 0x${num2Hex(opcode,
            4)} | params -- ${bytesToHexString(params, "")} | action mode -- ${this.actionMode}`)
        let notificationMessage = new NotificationMessage(src, dst, opcode, params);
        this.onMeshMessageNotification(notificationMessage);
    }


    /**
     * Callback method called when the proxy initialization is complete.
     *
     * @param success true if the proxy initialization was successful, false otherwise
     * @param address the address of the direct device
     */
    public onProxyInitComplete(success: boolean, address: number) {
        logd("filter init complete, success? " + success);
        if (success) {
            this.directDeviceAddress = address;
            this.onProxyLoginSuccess();
        } else {
            logw("proxy init fail!");
            this.mGattConnection.disconnect();
        }
    }

    /**
     * callback function, indicating that it is called when a heartbeat message is received.
     *
     * @param src  source address
     * @param dst  destination address
     * @param data heartbeat data
     */
    public onHeartbeatMessageReceived(src: number, dst: number, data: Uint8Array) {

    }

    /**
     * This method is called when a reliable message is complete.
     * <p>
     * Depending on the action mode, different controllers are called to handle the completion of the message. If the action mode is MODE_BIND, the binding controller is called. If the action mode is MESH_OTA, the firmware updating controller is called. If the action mode is REMOTE_PROVISION, the remote provisioning controller is called. If the action mode is FAST_PROVISION, the fast provisioning controller is called.
     * <p>
     * If the message was not successful, the onInnerMessageFailed() method is called. Finally, a reliable message process event is triggered with the relevant information.
     * <p>
     *
     * @param success  if response received
     * @param opcode   command opcode
     * @param rspMax   expect response max
     * @param rspCount received response count
     */
    public onReliableMessageComplete(success: boolean, opcode: number, dest: number,
        rspMax: number, rspCount: number, rspArr: Uint16Array) {
        if (this.actionMode == Mode.MODE_BIND) {
            this.mBindingController.onBindingCommandComplete(success, opcode, rspMax, rspCount);
        }

        if (!success) {
            this.onInnerMessageFailed(opcode);
        }
        this.onReliableMessageProcessEvent(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESS_COMPLETE,
            success, opcode, dest, rspMax, rspCount, rspArr, "mesh message send complete");
    }

    /**
     * It is called when a segment message is complete.
     * <p>
     * In this method, there is a check if the current action mode is MESH_OTA. If it is, then the onSegmentComplete method of the fuController object is called with the success parameter.
     * <p>
     *
     * @param success is the segment message send success
     */
    public onSegmentMessageComplete(success: boolean) {

    }

    /**
     * This method is called when an inner message fails to be processed.
     * It checks if the opcode of the failed message is equal to the value of the NODE_ID_SET opcode.
     * If it is, it further checks the action mode to determine the appropriate action to take.
     * If the action mode is GATT_OTA, it calls the onOtaComplete method with a failure status and a corresponding error message.
     * If the action mode is GATT_CONNECTION, it calls the onGattConnectionComplete method with a failure status and a corresponding error message.
     *
     * @param opcode operation code
     */
    public onInnerMessageFailed(opcode: number) {
        if (opcode == Opcode.NODE_ID_SET) {

        }
    }

    // , int src, int dst, int opcode, byte[] params

    /**
     * deal mesh config related message
     */
    private onInnerMessageHandle(notificationMessage: NotificationMessage) {
        let src = notificationMessage.src;
        let opcode = notificationMessage.opcode;
        if (opcode == Opcode.NODE_RESET_STATUS) {
            /*
             * handle node reset message, update mesh configuration info
             */
            this.meshConfiguration.removeDeviceKey(src);
            if (this.actionMode == Mode.AUTO_CONNECT) {
                this.validateAutoConnectTargets();
            }
        } else if (opcode == Opcode.NODE_ID_STATUS) {

        }
    }

    /**
     * This method handles incoming mesh message notifications.
     * It first calls the "onInnerMessageHandle" method to process the notification message.
     * Then, based on the current action mode, it delegates the handling of the notification to the appropriate controller.
     * <p>
     * If the action mode is set to "MODE_BIND", it calls the "onMessageNotification" method of the "mBindingController" to handle the notification.
     * If the action mode is set to "MESH_OTA", it calls the "onMessageNotification" method of the "fuController" to handle the notification.
     * If the action mode is set to "REMOTE_PROVISION", it calls the "onMessageNotification" method of the "mRemoteProvisioningController" to handle the notification.
     * If the action mode is set to "FAST_PROVISION", it calls the "onMessageNotification" method of the "mFastProvisioningController" to handle the notification.
     * <p>
     * After handling the notification, the method determines the event type based on the status message contained in the notification.
     * If the status message is null, the event type is set to "EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN".
     * Otherwise, the event type is set to the name of the status message class.
     * <p>
     *
     * @param notificationMessage mesh notification message
     */
    private onMeshMessageNotification(notificationMessage: NotificationMessage) {
        this.onInnerMessageHandle(notificationMessage);
        if (this.actionMode == Mode.MODE_BIND) {
            this.mBindingController.onMessageNotification(notificationMessage);
        }
        let eventType: string;
        let statusMessage = notificationMessage.statusMessage

        // if message can be parsed
        if (!statusMessage) {
            eventType = StatusNotificationEvent.EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN;
        } else {
            eventType = statusMessage.statusName()
        }

        logd("mesh message notification: " + eventType);
        let statusNotificationEvent = new StatusNotificationEvent(
            eventType, notificationMessage);
        this.onEventPrepared(statusNotificationEvent);
    }


    /**
     * This method is used to handle prepared mesh messages before they are sent.
     * <p>
     * The method first checks if the destination address of the mesh message is the local message address.
     * If it is, it further checks if the message is reliable.
     * If the message is reliable, it calls the  `responseMessage`  method from the  `MessageResponder`  class to generate a notification message.
     * It then calls the  `onMeshMessageNotification`  method to handle the notification message.
     * <p>
     * If the destination address is not the local message address or the message is not reliable, it returns true to indicate that the message should be skipped.
     * <p>
     * If none of the above conditions are met, it calls the  `sendMeshMessage`  method to send the mesh message.
     *
     * @param meshMessage MeshMessage
     * @param mode        mode
     * @return is message send success
     */
    public async onAccessMessagePrepared(meshMessage: MeshMessage, mode: number): Promise<boolean> {
        return await this.sendMeshMessage(meshMessage);
    }

    /********************************************************
     * binding event
     ********************************************************/

    /**
     * Method called when the binding process is successful.
     *
     * @param desc description
     */
    private onBindingSuccess(desc: string) {
        this.onBindingComplete();
        let bindingDevice = this.mBindingController.getBindingDevice();
        let bindingEvent = new BindingEvent(BindingEvent.EVENT_TYPE_BIND_SUCCESS, bindingDevice, desc);
        this.onEventPrepared(bindingEvent);
    }

    /**
     * Method called when the binding process is fail.
     *
     * @param desc description
     */
    private onBindingFail(desc: string) {
        loge("key bind fail : " + desc)
        this.onBindingComplete();
        let bindingDevice = this.mActionParams!.get(ActionParameters.ACTION_BINDING_TARGET) as BindingDevice
        let bindingEvent = new BindingEvent(BindingEvent.EVENT_TYPE_BIND_FAIL, bindingDevice, desc);
        this.onEventPrepared(bindingEvent);
    }

    /**
     * This method is called when the binding process is complete.
     * It clears the networking controller, sets the isActionStarted flag to false,
     * and calls the idle method with a parameter of false to indicate that the app is no longer idle.
     */
    private onBindingComplete() {
        this.mNetworkingController.clear();
        this.isActionStarted = false;
        this.idle(false);
    }

    /**
     * This method updates the device key map with the given address and device key.
     * It adds the device key to the networking controller and also to the mesh configuration's device key map.
     *
     * @param address   node address
     * @param deviceKey device key
     */
    private updateDeviceKeyMap(address: number, deviceKey: Uint8Array) {
        this.mNetworkingController.addDeviceKey(address, deviceKey);
        this.meshConfiguration.addDeviceKey(address, deviceKey);
    }

    /**
     * This method is used to handle the state changes
     *
     * @param state new state
     * @param desc  desc
     * @param mode  access mode
     * @param obj   object
     */
    public onAccessStateChanged(state: number, desc: string, mode: number, obj: Object) {
        logd("access state changed: " + state + " -- " + desc);
        if (this.actionMode == Mode.MODE_BIND && mode == ACCESS_MODE_BINDING) {
            if (state == BindingController.STATE_FAIL) {
                this.onBindingFail(desc);
            } else if (state == BindingController.STATE_SUCCESS) {
                this.onBindingSuccess(desc);
            }
        }
    }


    /**
     * Sets the event callback for this object.
     *
     * @param callback The event callback to be set.
     */
    public setEventCallback(callback: (event: Event) => void) {
        this.eventCallback = callback;
    }


    /**
     * This is an enumeration that represents different modes of operation for a device. Each mode is defined as a constant value and has a corresponding name.
     * <p>
     * - IDLE: Represents the idle state where no scan and connect actions are performed.
     * - SCAN: Represents the scanning mode where the device scans for nearby devices.
     * - PROVISION: Represents the mode where the device automatically scans, connects, and provisions a device.
     * - AUTO_CONNECT: Represents the mode where the device automatically scans, connects, and retrieves the state of a device.
     * - GATT_OTA: Represents the mode where the device automatically scans, connects, and starts over-the-air (OTA) firmware updates.
     * - MODE_BIND: Represents the mode where the device binds an application key to a target device without scanning.
     * - REMOTE_PROVISION: Represents the mode for remote provisioning of a device.
     * - REMOTE_BIND: Represents the mode for remote binding of a device.
     * - FAST_PROVISION: Represents the mode for fast provisioning, a private feature specific to the Telink platform.
     * - MESH_OTA: Represents the mode for mesh firmware updating, specifically for mesh OTA updates.
     * - GATT_CONNECTION: Represents the mode for establishing a GATT connection with a target device.
     * <p>
     */

}

export enum Mode {

    /*
     * no scan and connect actions
     */
    IDLE,


    /**
     * scan
     */
    SCAN,

    /**
     * MODE_PROVISION: auto scan, connect, provision
     */
    PROVISION,


    /**
     * MODE_AUTO_CONNECT: auto scan, connect, get device state
     */
    AUTO_CONNECT,

    /**
     * MODE_OTA: auto scan, connect, start ota
     */
    // GATT_OTA,

    /**
     * bind app key
     * connect target device without scan
     */
    MODE_BIND,

    /**
     * remote provision
     */
    // REMOTE_PROVISION,

    /**
     * remote bind
     */
    // REMOTE_BIND,

    /**
     * fast provision (telink private)
     */
    // FAST_PROVISION,

    /**
     * mesh firmware updating
     * (mesh ota)
     */
    // MESH_OTA,

    /**
     * gatt connection for target device
     */
    // GATT_CONNECTION;
}