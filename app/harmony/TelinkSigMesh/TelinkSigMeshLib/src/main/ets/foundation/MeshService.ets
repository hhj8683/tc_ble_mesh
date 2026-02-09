/********************************************************************************************************
 * @file     MeshService.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
/********************************************************************************************************
 * @file MeshService.ets
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
import { MeshMessage } from "../core/message/MeshMessage";
import { ExtendBearerMode } from "../core/networking/ExtendBearerMode";
import { logd } from "../utils/MeshLogger";
import { Event } from "./Event";
import { AutoConnectParameters, BindingParameters, ProvisioningParameters, ScanParameters } from "./Index";
import { MeshConfiguration } from "./MeshConfiguration";
import { MeshController, Mode } from "./MeshController";
import { GattOtaParameters } from "./parameter/GattOtaParameters";

/**
 * Created by kee on 2019/8/26.
 */

export class MeshService {
    /**
     * singleton for mesh-service
     */
    private static instance: MeshService;
    /**
     * mesh protocol implementation
     */
    private mController: MeshController

    private constructor() {
        this.mController = new MeshController()
    }

    static getInstance(): MeshService {
        if (!MeshService.instance) {
            MeshService.instance = new MeshService();
        }
        return MeshService.instance;
    }

    /**
     * init mesh engine
     */
    public init(callback: (event: Event) => void) {
        logd("MeshService#init");
        this.mController.setEventCallback(callback)
    }

    /**
     * clear mesh engine
     */
    public clear() {
        logd("MeshService#clear");
        if (this.mController != null) {
            this.mController.stop();
        }
    }

    public clearNetworkCache() {
        logd("MeshService#clearNetworkCache");
        if (this.mController != null) {
            this.mController.clearNetworkCache();
        }
    }

    /**
     * setup mesh info
     *
     * @param configuration mesh configuration, inner params should not be null
     */
    public setupMeshNetwork(configuration: MeshConfiguration) {
        this.mController.setupMeshNetwork(configuration);
    }

    /**
     * check bluetooth state
     * state will be received by BluetoothEvent
     * {@link com.telink.ble.mesh.foundation.event.BluetoothEvent}
     */
    public checkBluetoothState() {
        this.mController.checkBluetoothState();
    }

    /********************************************************************************
     * mesh api
     ********************************************************************************/

    /**
     * @return is proxy connected && proxy set success (if proxy filter set needed)
     */
    public isProxyLogin() {
        return this.mController.isProxyLogin();
    }

    /**
     * @return direct connected node address,
     * or 0 : invalid address
     */
    public getDirectConnectedNodeAddress() {
        return this.mController.getDirectNodeAddress();
    }

    /**
     * remove device in mesh configuration
     * this action only delete device info in map ,
     * if kick-out device from mesh network is needed, call sendMeshMessage(NodeResetMessage)
     *
     * @param meshAddress target device address
     */
    public removeDevice(meshAddress: number) {
        this.mController.removeDevice(meshAddress);
    }

    /**
     * get current action mode
     *
     * @return current mode
     * @see com.telink.ble.mesh.foundation.MeshController.Mode
     */
    public getCurrentMode(): Mode {
        return this.mController.getMode();
    }

    /**
     * start scanning
     */
    public startScan(scanParameters: ScanParameters) {
        this.mController.startScan(scanParameters);
    }

    /**
     * stop bluetooth scanning
     */
    public stopScan() {
        this.mController.stopScan();
    }

    /**
     * start provisioning if device found by {@link #startScan(ScanParameters)}
     */
    public startProvisioning(provisioningParameters: ProvisioningParameters) {
        return this.mController.startProvisioning(provisioningParameters);
    }

    /**
     * used when {@link com.telink.ble.mesh.entity.ProvisioningDevice#autoStart} is false
     *
     * @param address unicast address
     * @return is continue success
     */
    public continueProvision(address: number) {
        return this.mController.continueProvision(address);
    }

    /**
     * start binding application key for models in node if device provisioned
     */
    public startKeyBind(bindingParameters: BindingParameters) {
        this.mController.startKeyBind(bindingParameters);
    }

    /**
     * scanning an connecting proxy node for mesh control
     */
    public autoConnect(parameters: AutoConnectParameters) {
        this.mController.autoConnect(parameters);
    }

    /**
     * scanning an connecting proxy node for mesh control
     */
    public startGattOta(parameters: GattOtaParameters) {
        this.mController.startGattOta(parameters);
    }


    /**
     * idle
     *
     * @param disconnect if disconnect current gatt connection
     */
    public idle(disconnect: boolean) {
        this.mController.idle(disconnect);
    }

    public disconnect() {
        this.mController.disconnect();
    }


    public getGattConnection(): GattConnection {
        return this.mController.getGattConnection()
    }

    /**
     * @return get current gatt connection mtu
     */
    public getMtu(): number {
        return this.mController.getMtu();
    }

    /**
     * send mesh message
     * 1. if message is reliable (with ack), message.responseOpcode should be valued by message ack opcode
     * {@link MeshMessage#getResponseOpcode()}
     * Besides, message.responseMax is suggested to be valued by expected response count,
     * for example, 3 nodes in group(0xC001), 3 is the best value for responseMax when get group status
     * 2. if message is with tid (for example: OnOffSetMessage {@link com.telink.ble.mesh.core.message.generic.OnOffSetMessage})
     * and App do not want to manage tid, valid message.tidPosition should be valued
     * otherwise tid in message will be sent,
     *
     * @param meshMessage message
     */
    public async sendMeshMessage(meshMessage: MeshMessage): Promise<boolean> {
        if (meshMessage == null) {
            return false;
        }
        return this.mController.sendMeshMessage(meshMessage);
    }

    /**
     * Telink-private protocol.
     * get all devices status by send command to OnlineStatus handle
     *
     * @return if online_status supported
     * @see com.telink.ble.mesh.core.ble.UUIDInfo#CHARACTERISTIC_ONLINE_STATUS
     */
    public getOnlineStatus() {
        return this.mController.getOnlineStatus();
    }


    /**
     * @param extendBearerMode new mode
     */
    public resetExtendBearerMode(extendBearerMode: ExtendBearerMode) {
        this.mController.resetExtendBearerMode(extendBearerMode);
    }

    /********************************************************************************
     * bluetooth api
     ********************************************************************************/

    /**
     * @return bluetooth enabled
     */
    public isBluetoothEnabled() {
        return this.mController.isBluetoothEnabled();
    }

    /**
     * enable bluetooth
     */
    public enableBluetooth() {
        this.mController.enableBluetooth();
    }

    /**
     * get current connected device macAddress
     */
    public getCurDeviceMac() {
        return this.mController.getCurDeviceMac();
    }
}
