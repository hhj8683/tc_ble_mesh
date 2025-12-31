/********************************************************************************************************
 * @file NodeInfo.java
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
import {
    ByteOrder,
    bytesToHexString,
    CompositionData,
    EventBus,
    logd,
    MeshSigModel,
    num2bytes,
    num2Hex
} from "telinksigmeshlib";
import { NodeStatusChangedEvent } from "./NodeStatusChangedEvent";
import { OnlineState } from "./OnlineState";
import { PublishModel } from "./PublishModel";
import { Scheduler } from "./Scheduler";

/**
 * Created by kee on 2019/8/22.
 */
// @Observed
export class NodeInfo {
    public static readonly LOCAL_DEVICE_KEY = "00112233445566778899AABBCCDDEEFF";
    public name = '';
    /**
     * primary element unicast address
     */
    public meshAddress = 0;
    /**
     * device-uuid from scan-record when normal provision
     * or
     * device scan report when fast-provision or remote-provision
     */
    public deviceUUID = '';
    /**
     * network key indexes, contains at least one primary network key.
     * can be add by {@link com.telink.ble.mesh.core.message.config.NetKeyAddMessage}
     * big endian hex string
     */
    public netKeyIndexes: string[] = []
    /**
     * element count
     */
    public elementCnt = 0;
    public bound = false;
    public deviceKey = ""
    /**
     * Whether periodic broadcast is configured
     */
    public timePublishConfigured = false;
    /**
     * device subscription/group info
     * hex string list, bigEndian
     */
    public subList: string[] = []
    // device lightness
    public lum = 100;
    // device temperature
    public temp = 0;
    /**
     * device on off state
     * 0:off 1:on -1:offline
     */
    public onlineState: OnlineState = OnlineState.OFFLINE;

    /**
     * composition dataNodeInfo
     * {@link com.telink.ble.mesh.core.message.config.CompositionDataStatusMessage}
     */
    public compositionData: CompositionData | undefined = undefined;


    /**
     * scheduler
     */
    public schedulers: Scheduler[] = []
    /**
     * publication
     */
    public publishModel: PublishModel | undefined = undefined
    /**
     * default bind support
     */
    public defaultBind = false;
    /**
     * subnet bridge enable
     */
    public subnetBridgeEnabled = false;
    // public Array<BridgingTable> bridgingTableList;

    /**
     * for UI selection
     */
    public selected = false;
    /**
     * configs
     */

    // default TTL
    public defaultTTL = 0x0A;
    // is relay enabled
    public relayEnable = true;
    // relay retransmit, include count and steps
    public relayRetransmit = 0x15;
    // is secure network beacon opened
    public beaconOpened = true;
    // is gatt proxy enabled
    public gattProxyEnable = true;
    public privateBeaconOpened = false;
    public privateGattProxyEnable = false;
    // is friend enabled
    public friendEnable = true;
    // network retransmit
    public networkRetransmit = 0x15;
    // network retransmit
    public onDemandPrivateGattProxy = 20;
    /**
     * direct forwarding enabled
     */
    public directForwardingEnabled = false;
    public directRelayEnabled = false;
    public directProxyEnabled = false;
    public directFriendEnabled = false;
    /**
     * lighting control enabled
     */
    public lcEnabled = true;
    /**
     * lighting control properties
     */
    // public ToOne<NodeLcProps> nodeLcProps;

    /**
     *
     */
    // public Array<NodeSensorState> sensorStateList;


    /**
     * switch actions
     */
    // public Array<SwitchAction> switchActions;

    /**
     * used to save state when pair with mesh devices
     */
    // public Array<SwitchState> switchStates;

    /**
     * only used for enocean switch device
     */
    // public boolean isFromNfc = false;

    private offlineCheckTimerId = 0

    public getOnlineState() {
        return this.onlineState;
    }

    public setOnlineState(onlineState: OnlineState) {
        this.onlineState = onlineState;
        if (this.isSensor()) {
            return;
        }
        if (this.publishModel) {
            clearTimeout(this.offlineCheckTimerId)
            let timeout = this.publishModel.period * 3 + 2000;
            if (this.onlineState != OnlineState.OFFLINE && timeout > 0) {

                this.offlineCheckTimerId = setTimeout(() => {
                    this.offlineTask()
                }, timeout)
            }
        }
    }

    public offlineTask() {
        this.onlineState = OnlineState.OFFLINE;
        logd("offline check task running");
        let event = new NodeStatusChangedEvent(this)
        EventBus.getInstance().emit(event);

    }

    public isPubSet() {
        return this.publishModel != undefined;
    }

    public getName() {
        return this.name
    }

    public getFmtNameAdr() {
        return `${this.getName()}(0x${num2Hex(this.meshAddress)})`
    }

    public updateName(newName: string) {
        this.name = newName;
        let event = new NodeStatusChangedEvent(this)
        EventBus.getInstance().emit(event);
    }

    public addDefaultName() {
        this.name =
            `${this.isSensor() ? "sensor" : "node"}-${num2Hex(this.meshAddress, this.meshAddress <= 0xFF ? 2 : 4)}`;
    }

    /**
     * used in db
     */
    public getPublishModel() {
        return this.publishModel;
    }

    public setPublishModel(model?: PublishModel) {
        this.publishModel = model
        if (this.isSensor()) {
            return;
        }
        clearTimeout(this.offlineCheckTimerId)
        if (this.publishModel && this.onlineState != OnlineState.OFFLINE) {
            let timeout = this.publishModel.period * 3 + 2000;
            if (timeout > 0) {
                this.offlineCheckTimerId = setTimeout(() => {
                    this.offlineTask()
                }, timeout)
            }
        }
    }

    public getSchedulerByIndex(index: number): Scheduler | undefined {
        if (this.schedulers.length == 0) {
            return undefined;
        }
        for (let scheduler of this.schedulers) {
            if (scheduler.getIndex() == index) {
                return scheduler;
            }
        }
        return undefined;
    }

    public saveScheduler(scheduler: Scheduler) {
        for (let i = 0; i < this.schedulers.length; i++) {
            if (this.schedulers[i].getIndex() == scheduler.getIndex()) {
                this.schedulers[i] = scheduler
                return;
            }
        }
        this.schedulers.push(scheduler)
    }

    // 0 - 15/0x0f, -1 err
    public allocSchedulerIndex(): number {
        if (this.schedulers == null || this.schedulers.length == 0) {
            return 0;
        }

        // find the value that not used
        outer:
            for (let i = 0; i <= 0x0f; i++) {
                for (let scheduler of this.schedulers) {
                    if (scheduler.getIndex() == i) {
                        continue outer;
                    }
                }
                return i;
            }
        return -1;
    }

    /**
     * find the first element that contains target model id
     * @param tarModelId target model id
     * @return element address: -1 err
     */
    public getElementByModel(tarModelId: number): number {
        if (!this.compositionData) {
            return -1;
        }
        let eleAdr = this.meshAddress;
        for (let element of this.compositionData.elements) {
            if (element.sigModels != null) {
                for (let modelId of element.sigModels) {
                    if (modelId == tarModelId) {
                        return eleAdr;
                    }
                }
            }

            if (element.vendorModels != null) {
                for (let modelId of element.vendorModels) {
                    if (modelId == tarModelId) {
                        return eleAdr;
                    }
                }
            }

            eleAdr++;
        }
        return -1;
    }

    /**
     * find all elements that contains target model id
     * such as multi on/off model may exist in different element
     *
     * @return element adr list
     */
    public getElementsByModel(targetModelId: number): Array<number> | undefined {
        if (!this.compositionData) {
            return undefined;
        }
        let addressList: Array<number> = []

        // element address is based on primary address and increase in loop
        let eleAdr = this.meshAddress;
        outer:
            for (let element of this.compositionData.elements) {
                if (element.sigModels != null) {
                    for (let modelId of element.sigModels) {
                        if (modelId == targetModelId) {
                            addressList.push(eleAdr++);
                            continue outer;
                        }
                    }
                }
                eleAdr++;
            }

        return addressList;
    }

    /**
     * @param associatedModelId target model id {@link MeshSigModel#getLevelAssociatedList()}
     * @return element address: -1 err
     */
    public getLevelAssociatedEleAdr(associatedModelId: number) {
        if (!this.compositionData) {
            return -1;
        }
        let eleAdr = this.meshAddress;
        for (let element of this.compositionData.elements) {
            if (element.sigModels != null) {
                if (element.containModel(associatedModelId) && element.containModel(MeshSigModel.SIG_MD_G_LEVEL_S)) {
                    return eleAdr;
                }
            }
            eleAdr++;
        }
        return -1;
    }

    /**
     * get lum model element
     *
     * @return lum lightness union info
     */
    public getLumEleInfo(): Map<number, boolean> | undefined {
        if (!this.compositionData) {
            return undefined;
        }
        let eleAdr = this.meshAddress;

        let result: Map<number, boolean> = new Map()

        for (let element of this.compositionData.elements) {
            if (element.sigModels != null) {
                let levelSupport = false;
                let lumSupport = false;
                // if contains lightness model
                for (let modelId of element.sigModels) {
                    if (modelId == MeshSigModel.SIG_MD_LIGHTNESS_S) {
                        lumSupport = true;
                    }
                    if (modelId == MeshSigModel.SIG_MD_G_LEVEL_S) {
                        levelSupport = true;
                    }
                }

                if (lumSupport) {
                    result.set(eleAdr, levelSupport);
                    return result;
                }
            }
            eleAdr++;
        }
        return undefined;
    }

    /**
     * get element with temperature model
     *
     * @return temp & isLevelSupported
     */
    public getTempEleInfo(): Map<number, boolean> | undefined {
        if (!this.compositionData) {
            return undefined;
        }
        let eleAdr = this.meshAddress;

        let result: Map<number, boolean> = new Map()

        for (let element of this.compositionData.elements) {
            if (element.sigModels != null) {
                let levelSupport = false;
                let tempSupport = false;
                // contains temperature model
                for (let modelId of element.sigModels) {
                    if (modelId == MeshSigModel.SIG_MD_LIGHT_CTL_TEMP_S) {
                        tempSupport = true;
                    }
                    if (modelId == MeshSigModel.SIG_MD_G_LEVEL_S) {
                        levelSupport = true;
                    }
                }

                if (tempSupport) {
                    result.set(eleAdr, levelSupport);
                    return result;
                }
            }
            eleAdr++;
        }
        return undefined;
    }

    public getPidDesc() {
        let pidInfo = "";
        if (this.bound && this.compositionData) {
            return `cid-${bytesToHexString(num2bytes(this.compositionData.cid, 2,
                ByteOrder.LITTLE_ENDIAN))} pid-${bytesToHexString(num2bytes(this.compositionData.pid, 2,
                ByteOrder.LITTLE_ENDIAN))}`
        } else {
            return "(unbound)";
        }
    }

    public isDefaultBind() {
        return this.defaultBind;
    }

    public setDefaultBind(defaultBind: boolean) {
        this.defaultBind = defaultBind;
    }

    public isLpn() {
        return this.compositionData && this.compositionData.lowPowerSupport();
    }

    /**
     * is node offline
     */
    public isOffline() {
        return this.onlineState == OnlineState.OFFLINE;
    }


    /**
     * is node on
     */
    public isOn() {
        return this.onlineState == OnlineState.ON;
    }


    /**
     * is node off
     */
    public isOff() {
        return this.onlineState == OnlineState.OFF;
    }


    // public NodeLcProps getLcProps() {
    //     if (nodeLcProps.getTarget() == null) {
    //         MeshLogger.d("create new props : " + meshAddress);
    //         nodeLcProps.setTarget(new NodeLcProps());
    //         save();
    //     }
    //     return nodeLcProps.getTarget();
    // }

    /**
     * Triggered only when response is received that sends an unspecified propertyID message
     *
     * @param sensorData key : propertyID. value : sensor data
     * @see com.telink.ble.mesh.core.message.sensor.SensorGetMessage propertyID
     */
    // public  resetSensorStateList( sensorData: Map<number, Uint8Array>) {
    //     this.sensorStateList.clear();
    //     NodeSensorState st;
    //     for (int i = 0; i < sensorData.size(); i++) {
    //         st = new NodeSensorState();
    //         st.propertyID = sensorData.keyAt(i);
    //         st.state = sensorData.valueAt(i);
    //         this.sensorStateList.add(st);
    //         this.save();
    //     }
    // }


    /**
     * the sensor device contains sensor server model, and do not contains lightness server model
     *
     * @return
     */
    public isSensor() {
        return this.getElementByModel(MeshSigModel.SIG_MD_SENSOR_S) != -1
            && this.getElementByModel(MeshSigModel.SIG_MD_LIGHTNESS_S) == -1;
    }

    /**
     * contains sensor server model and lightness server model,
     * because the sensor dose not contains lightness function
     *
     * @return
     */
    public isGateway() {
        return this.getElementByModel(MeshSigModel.SIG_MD_SENSOR_S) != -1
            && this.getElementByModel(MeshSigModel.SIG_MD_LIGHTNESS_S) != -1;
    }
}
