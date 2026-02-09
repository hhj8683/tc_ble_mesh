/********************************************************************************************************
 * @file     BindingController.ets 
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
 * @file BindingController.ets
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

import { BindingDevice } from "../../entity/BindingDevice";
import { CompositionData } from "../../entity/CompositionData";
import { MeshSigModel, useDeviceKeyForEnc } from "../../foundation/MeshSigModel";
import { num2Hex } from "../../utils/ArrayUtils";
import { logd, logw } from "../../utils/MeshLogger";
import { aggregateMessages, parseOpcodeAggregatorStatus } from "../../utils/MeshUtils";
import { OpcodeAggregatorSequenceMessage } from "../message/aggregator/OpcodeAggregatorSequenceMessage";
import { OpcodeAggregatorStatusMessage } from "../message/aggregator/OpcodeAggregatorStatusMessage";
import { AppKeyAddMessage } from "../message/config/AppKeyAddMessage";
import { AppKeyStatusMessage } from "../message/config/AppKeyStatusMessage";
import { CompositionDataGetMessage } from "../message/config/CompositionDataGetMessage";
import { CompositionDataStatusMessage } from "../message/config/CompositionDataStatusMessage";
import { ModelAppBindMessage } from "../message/config/ModelAppBindMessage";
import { ModelAppStatusMessage } from "../message/config/ModelAppStatusMessage";
import { MeshMessage } from "../message/MeshMessage";
import { NotificationMessage } from "../message/NotificationMessage";
import { Opcode } from "../message/Opcode";
import { StatusMessage } from "../message/StatusMessage";
import { AccessType } from "../networking/AccessType";
import AccessBridge, { ACCESS_MODE_BINDING } from "./AccessBridge";
import { BindingBearer } from "./BindingBearer";
import { ArrayList } from "@kit.ArkTS";

/**
 * binding flow,
 * 1. get composition data
 * 2. add app key
 * 3. bind app key for selected models or all models
 * Created by kee on 2019/9/10.
 */

const LOG_TAG = "Binding";

interface BindingModel {
    modelId: number
    elementOffset: number
    sig: boolean
}

export class BindingController {
    public static readonly STATE_FAIL = 0;
    public static readonly STATE_SUCCESS = 1;
    /**
     * init
     */
    private static readonly STEP_INIT = 0;
    /**
     * getting composition data
     */
    private static readonly STEP_GET_CPS = 1;
    /**
     * app key adding
     */
    private static readonly STEP_APP_KEY_ADD = 2;
    /**
     * key binding one by one
     */
    private static readonly STEP_APP_KEY_BIND = 3;
    /**
     * send app key add and model bind by opcode-aggregator
     */
    private static readonly STEP_SEND_OP_AGG = 4;
    private step = BindingController.STEP_INIT;
    private netKeyIndex = 0;
    private appKey: Uint8Array = new Uint8Array(0);
    /**
     * binding target node
     */
    private bindingDevice: BindingDevice = new BindingDevice()
    /**
     * binding models index
     */
    private modelIndex = 0;
    //    private int appKeyIndex;
    /**
     * target models in binding device
     */
    private bindingModels: ArrayList<BindingModel> = new ArrayList();
    // for command sent
    private accessBridge: AccessBridge;
    /**
     * check is the cps contains Opcode Aggregator server model
     *
     * @see MeshSigModel#SIG_MD_CFG_OP_AGG_S
     */
    private isAggSupported = false;
    private static readonly BINDING_TIMEOUT_GATT = 30 * 1000;
    private static readonly BINDING_TIMEOUT_ADV = 60 * 1000;
    private bindingTimeoutTask = 0

    public constructor(accessBridge: AccessBridge) {
        this.accessBridge = accessBridge;
    }

    public getBindingDevice(): BindingDevice {
        return this.bindingDevice;
    }

    public begin(netKeyIndex: number, appKey: Uint8Array, device: BindingDevice) {
        this.netKeyIndex = netKeyIndex;
        this.bindingDevice = device;
        this.appKey = appKey;
        this.bindingModels.clear();
        this.modelIndex = 0;
        clearTimeout(this.bindingTimeoutTask)
        this.bindingTimeoutTask = setTimeout(() => {
            this.onBindingTimeout()
        },
            this.isGattBearer() ? BindingController.BINDING_TIMEOUT_GATT : BindingController.BINDING_TIMEOUT_ADV);

        logd("binding begin: defaultBound? " + device.defaultBound);
        if (!device.compositionData) {
            this.getCompositionData();
        } else {
            if (device.defaultBound) {
                this.addAppKey();
            } else {
                this.onCompositionDataReceived(device.compositionData);
            }
        }
    }

    public clear() {
        clearTimeout(this.bindingTimeoutTask)
        this.modelIndex = 0;
        this.step = BindingController.STEP_INIT;
        this.bindingModels.clear();
    }

    private isGattBearer() {
        return this.bindingDevice && this.bindingDevice.bearer == BindingBearer.GattOnly;
    }

    private getCompositionData() {
        this.updateStep(BindingController.STEP_GET_CPS);
        this.onMeshMessagePrepared(new CompositionDataGetMessage(this.bindingDevice.meshAddress));
    }

    private addAppKey() {
        logd("add app key");
        this.updateStep(BindingController.STEP_APP_KEY_ADD);
        let command = new AppKeyAddMessage(this.bindingDevice.meshAddress)
        command.netKeyIndex = (this.netKeyIndex);
        command.appKeyIndex = (this.bindingDevice.appKeyIndex);
        command.appKey = (this.appKey);
        this.onMeshMessagePrepared(command);
    }

    private async onMeshMessagePrepared(meshMessage: MeshMessage) {
        if (!this.isGattBearer()) {
            meshMessage.retryCnt = 8
        }
        let isMessageSent = await this.accessBridge.onAccessMessagePrepared(meshMessage, ACCESS_MODE_BINDING);
        if (!isMessageSent) {
            this.onBindFail("binding message sent error");
        }
    }

    private bindNextModel() {

        if (this.bindingModels.length > this.modelIndex) {
            let bindingModel = this.bindingModels[this.modelIndex]
            let modelId = bindingModel.modelId;
            let command = new ModelAppBindMessage(this.bindingDevice.meshAddress);

            let eleAdr = this.bindingDevice.meshAddress + bindingModel.elementOffset;
            command.elementAddress = eleAdr
            command.appKeyIndex = this.bindingDevice.appKeyIndex;
            command.isSigModel = bindingModel.sig
            command.modelIdentifier = modelId
            logd(`bind next model:  modelId=${num2Hex(modelId)} eleAdr=${num2Hex(eleAdr, 4)}`);
            this.onMeshMessagePrepared(command);
        } else {
            this.onBindSuccess();
        }
    }

    private updateStep(step: number) {
        logd("update bind step: " + step);
        this.step = step;
    }

    private onCompositionDataReceived(compositionData?: CompositionData) {
        let modelsInCps = this.getAllModels(compositionData);
        if (!modelsInCps || modelsInCps.length == 0) {
            this.onBindFail("no models in composition data");
            return;
        }
        this.bindingModels.clear();
        this.modelIndex = 0;
        if (!this.bindingDevice.models) {
            for (let mdl of modelsInCps) {
                this.bindingModels.add(mdl)
            }
        } else {
            // models filter
            outer:
                for (let bindingModel of modelsInCps) {
                    for (let modelId of this.bindingDevice.models) {
                        if (bindingModel.modelId == modelId) {
                            this.bindingModels.add(bindingModel);
                            continue outer;
                        }
                    }
                }
        }

        if (this.bindingModels.length == 0) {
            this.onBindFail("no target models found");
        } else {
            logd("models prepared: " + this.bindingModels.length);
            this.bindingDevice.compositionData = compositionData
            //  draft feature
            //            isAggSupported = false;
            if (this.isAggSupported) {
                logd("bind app key by opcode-aggregator");
                this.sendOpAggMessage();
            } else {
                this.addAppKey();
            }
        }
    }

    /**
     * add app key,
     */
    private sendOpAggMessage() {
        this.updateStep(BindingController.STEP_SEND_OP_AGG);

        let aggMsgs: ArrayList<MeshMessage> = new ArrayList();
        // B8090600000000009F2F5D99D2B563E4CA8390D116DC7C73803D060000000200803D060000000300803D060000000010803D060000000210803D060000000410803D060000000610803D060000000710803D060000000013803D060000000113803D060000000313803D060000000413803D0600000011020000803D070000000210803D070000000613
        let appKeyAddMsg = new AppKeyAddMessage(this.bindingDevice.meshAddress)
        appKeyAddMsg.netKeyIndex = (this.netKeyIndex);
        appKeyAddMsg.appKeyIndex = this.bindingDevice.appKeyIndex
        appKeyAddMsg.appKey = this.appKey
        // insert app key add message
        aggMsgs.add(appKeyAddMsg);

        let bindMsg: ModelAppBindMessage;
        for (let bindingModel of this.bindingModels) {
            let modelId = bindingModel.modelId;
            bindMsg = new ModelAppBindMessage(this.bindingDevice.meshAddress)

            let eleAdr = this.bindingDevice.meshAddress + bindingModel.elementOffset;
            bindMsg.elementAddress = (eleAdr);
            bindMsg.appKeyIndex = this.bindingDevice.appKeyIndex
            bindMsg.isSigModel = (bindingModel.sig);
            bindMsg.modelIdentifier = modelId
            aggMsgs.add(bindMsg);
        }
        let elementAddress = this.bindingDevice.meshAddress
        let params = aggregateMessages(elementAddress, aggMsgs);
        let aggSeqMsg = new OpcodeAggregatorSequenceMessage(this.bindingDevice.meshAddress, AccessType.DEVICE,
            this.bindingDevice.appKeyIndex, params);
        this.onMeshMessagePrepared(aggSeqMsg);
    }


    private getAllModels(compositionData?: CompositionData): ArrayList<BindingModel> | undefined {
        if (!compositionData || !compositionData.elements) {
            return undefined;
        }

        let models: ArrayList<BindingModel> = new ArrayList();
        this.isAggSupported = false;
        let offset = 0;
        for (let ele of compositionData.elements) {
            if (ele.sigModels) {
                for (let modelId of ele.sigModels) {
                    if (!useDeviceKeyForEnc(modelId)) {
                        models.add({ modelId: modelId, elementOffset: offset, sig: true })
                        if (modelId == MeshSigModel.SIG_MD_CFG_OP_AGG_S) {
                            this.isAggSupported = true;
                        }
                    }
                }
                if (ele.vendorModels != null) {
                    for (let modelId of ele.vendorModels) {
                        models.add({ modelId: modelId, elementOffset: offset, sig: false })
                    }
                }
                offset++;
            }
        }
        return models;
    }

    public onMessageNotification(message: NotificationMessage) {
        logw(`binding message ${JSON.stringify(message)}`)
        let opcode = message.opcode
        let statusMessage = message.statusMessage
        switch (opcode) {
            case Opcode.COMPOSITION_DATA_STATUS:
                if (this.step != BindingController.STEP_GET_CPS) {
                    logw("step not getting cps");
                    return;
                }
                let cpsDataStMsg = statusMessage as CompositionDataStatusMessage

                let compositionData = cpsDataStMsg.compositionData
                this.onCompositionDataReceived(compositionData);
                break;

            case Opcode.APPKEY_STATUS: {
                if (this.step != BindingController.STEP_APP_KEY_ADD) {
                    logw("step not app key adding");
                    return;
                }
                let appKeyStatusMessage = statusMessage as AppKeyStatusMessage
                this.onAppKeyStatus(appKeyStatusMessage);
                break;
            }
            case Opcode.MODE_APP_STATUS: {
                if (this.step != BindingController.STEP_APP_KEY_BIND) {
                    logw("step not app key binding");
                    return;
                }
                let appStatus = statusMessage as ModelAppStatusMessage
                this.onModelAppStatus(appStatus);
                break;
            }
            case Opcode.CFG_OP_AGG_STATUS: {
                if (this.step != BindingController.STEP_SEND_OP_AGG) {
                    logw("step not at sending op agg");
                    return;
                }
                let opAggStatusMsg = statusMessage as OpcodeAggregatorStatusMessage
                if (opAggStatusMsg.status != 0) {
                    this.onBindFail("opcode aggregator status error: " + opAggStatusMsg.status);
                    return;
                }

                let statusMessageList = parseOpcodeAggregatorStatus(opAggStatusMsg);
                if (!statusMessageList || statusMessageList.length == 0) {
                    this.onBindFail("opcode agg status parse error");
                    return;
                }

                let subStatusMessage: StatusMessage;
                for (let i = 0; i < statusMessageList.length; i++) {
                    subStatusMessage = statusMessageList[i];

                    if (subStatusMessage instanceof AppKeyStatusMessage) {
                        let appKeyStatusMessage = subStatusMessage as AppKeyStatusMessage;
                        if (appKeyStatusMessage.status == 0) {
                            logd("app key add success (op agg)");
                        } else {
                            this.onBindFail("app key status error (op agg)");
                            return;
                        }
                    } else if (subStatusMessage instanceof ModelAppStatusMessage) {
                        let appStatus = subStatusMessage as ModelAppStatusMessage
                        let modelId = appStatus.modelIdentifier
                        let isSig = this.isSigModel(modelId);
                        if (!isSig || appStatus.status == 0) {
                            logd(`model bind success (op agg) modelId-${num2Hex(modelId, 6)} isSig-${isSig}}`);
                        } else {
                            this.onBindFail("mode app status error (op agg)");
                            return;
                        }
                    }
                }
                logd("bind complete by op agg");
                this.onBindSuccess();
            }
                break;
        }
    }

    private isSigModel(modelId: number): boolean {
        for (let model of this.bindingModels) {
            if (model.modelId == modelId) {
                return model.sig;
            }
        }
        return false;
    }


    private onAppKeyStatus(appKeyStatusMessage: AppKeyStatusMessage) {
        if (appKeyStatusMessage.status == 0) {
            logd("app key add success");
            if (this.bindingDevice.defaultBound) {
                logd("default bound complete");
                this.onBindSuccess();
            } else {
                this.updateStep(BindingController.STEP_APP_KEY_BIND);
                this.bindNextModel();
            }
        } else {
            this.onBindFail("app key status error");
        }

    }

    private onModelAppStatus(appStatus: ModelAppStatusMessage) {
        if (this.bindingModels.length > this.modelIndex) {
            let modelId = this.bindingModels[this.modelIndex].modelId;
            let sig = this.bindingModels[this.modelIndex].sig;
            if (modelId == appStatus.modelIdentifier) {
                if (!sig || appStatus.status == 0) {
                    this.modelIndex++;
                    this.bindNextModel();
                } else {
                    this.onBindFail("mode app status error");
                }
            } else {
                logw(`model id error : settingModel=${num2Hex(modelId, 4)} , stModel=${num2Hex(appStatus.modelIdentifier)}`);
                this.modelIndex++;
                this.bindNextModel();
            }
        }
    }

    public onBindingCommandComplete(success: boolean, opcode: number, rspMax: number, rspCount: number) {
        if (!success) {
            this.onBindFail("binding command send fail");
        }
    }

    private onBindFail(desc: string) {
        logd("binding fail: " + desc);
        this.onBindingComplete();
        this.onBindState(BindingController.STATE_FAIL, desc);
    }

    private onBindSuccess() {
        this.onBindingComplete();
        this.onBindState(BindingController.STATE_SUCCESS, "binding success");
    }

    private onBindingComplete() {
        this.clear();
    }

    private onBindState(state: number, desc: string) {
        this.accessBridge.onAccessStateChanged(state, desc, ACCESS_MODE_BINDING, undefined);
    }


    public onBindingTimeout() {
        this.onBindFail("binding timeout");
    }
}
