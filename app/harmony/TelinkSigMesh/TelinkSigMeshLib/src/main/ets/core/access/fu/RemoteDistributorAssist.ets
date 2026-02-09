/********************************************************************************************************
 * @file     RemoteDistributorAssist.ets 
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
 * @file RemoteDistributorAssist.ets
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
import { FirmwareUpdateConfiguration } from "../../../entity/FirmwareUpdateConfiguration";
import { MeshUpdatingDevice } from "../../../entity/MeshUpdatingDevice";
import { logd, LOG_LEVEL_DEBUG } from "../../../utils/MeshLogger";
import { DistributionPhase } from "../../message/firmwaredistribution/DistributionPhase";
import { FDApplyMessage } from "../../message/firmwaredistribution/FDApplyMessage";
import { FDGetMessage } from "../../message/firmwaredistribution/FDGetMessage";
import { FDStatusMessage } from "../../message/firmwaredistribution/FDStatusMessage";
import { DistributionStatus } from "../../message/firmwareupdate/DistributionStatus";
import { FirmwareUpdateInfoGetMessage } from "../../message/firmwareupdate/FirmwareUpdateInfoGetMessage";
import { FirmwareUpdateInfoStatusMessage } from "../../message/firmwareupdate/FirmwareUpdateInfoStatusMessage";
import { MeshMessage, NotificationMessage } from "../../message/Index";
import { Opcode } from "../../message/Opcode";
import { FUAction } from "./FUAction";
import { FUActionHandler } from "./FUActionHandler";

/**
 * remote distributor assistance
 * 1. get remote distribution progress
 * 2. send apply if needed
 */
class RemoteDistributorAssist {
  // private handler: any; // 假设HarmonyOS的Handler类似实现

  private static readonly STEP_IDLE = 0;
  private static readonly STEP_DIST_APPLYING = 1;
  private static readonly STEP_DIST_GET = 2;
  private static readonly STEP_RECHECK = 3;

  private step: number = RemoteDistributorAssist.STEP_IDLE;

  private static readonly CONFIRM_INTERVAL = 10 * 1000;
  private static readonly APPLY_INTERVAL = 10 * 1000;

  private deviceIndex: number = 0;

  private actionHandler: FUActionHandler | null = null;

  private devices: Array<MeshUpdatingDevice> | null = null;

  private appKeyIndex: number = 0;

  private distributorAddress: number = 0;

  private newFirmwareId: Uint8Array | null = null;

  private distGetTaskTimeoutId = 0;
  private recheckFirmwareTimeoutId = 0;
  private applyTaskTimeoutId = 0;

  // constructor(handlerThread: any, actionHandler: FUActionHandler) {
  //   // 假设HarmonyOS有类似HandlerThread的实现
  //   this.handler = new Handler(handlerThread.getLooper());
  //   this.actionHandler = actionHandler;
  // }
  constructor(actionHandler: FUActionHandler) {
    this.actionHandler = actionHandler;
  }

  /**
   * @param configuration updating configs
   */
  resetConfig(configuration: FirmwareUpdateConfiguration): void {
    this.distributorAddress = configuration.getDistributorAddress();
    this.devices = configuration.getUpdatingDevices();
    this.appKeyIndex = configuration.getAppKeyIndex();
    this.newFirmwareId = configuration.getFirmwareId();
    this.deviceIndex = 0;
  }

  clear(): void {
    this.step = RemoteDistributorAssist.STEP_IDLE;
    // this.handler.removeCallbacksAndMessages(null);
  }

  applyDistribute(): void {
    this.log("apply distribution");
    this.step = RemoteDistributorAssist.STEP_DIST_APPLYING;
    this.deviceIndex = 0;
    this.executeAction();
  }

  private readonly APPLY_TASK = (): void => {
    this.applyDistribute();
  };

  confirmDistribute(): void {
    this.log("confirm distribute after(ms) : " + RemoteDistributorAssist.CONFIRM_INTERVAL);
    this.step = RemoteDistributorAssist.STEP_DIST_GET;
    // this.handler.removeCallbacks(this.DIST_GET_TASK);
    // this.handler.postDelayed(this.DIST_GET_TASK, RemoteDistributorAssist.CONFIRM_INTERVAL);
    clearTimeout(this.distGetTaskTimeoutId)
    this.distGetTaskTimeoutId = setTimeout(() => {
      this.DIST_GET_TASK()
    }, RemoteDistributorAssist.CONFIRM_INTERVAL)
  }

  private readonly DIST_GET_TASK = (): void => {
    this.log("confirm distribute");
    const fdGetMessage = FDGetMessage.getSimple(this.distributorAddress, this.appKeyIndex);
    this.onMeshMessagePrepared(fdGetMessage);
  };

  recheckFirmware(immediate: boolean): void {
    this.log("recheck firmware");
    this.step = RemoteDistributorAssist.STEP_RECHECK;
    this.deviceIndex = 0;
    const delay = immediate ? 0 : 10 * 1000;
    clearTimeout(this.recheckFirmwareTimeoutId)
    this.recheckFirmwareTimeoutId = setTimeout(() => {
      this.executeAction()
    }, delay)
  }

  private onRecheckComplete(): void {
    this.log("recheck firmware info complete");
    this.onAssistComplete(true, "recheck complete");
  }

  private executeAction(): void {
    this.log("execute action : " + this.step);
    if (this.step === RemoteDistributorAssist.STEP_DIST_APPLYING) {
      const fdApplyMessage = FDApplyMessage.getSimple(this.distributorAddress, this.appKeyIndex);
      this.onMeshMessagePrepared(fdApplyMessage);
    } else if (this.step === RemoteDistributorAssist.STEP_RECHECK) {
      if (this.deviceIndex >= (this.devices?.length || 0)) {
        this.onRecheckComplete();
      } else {
        const device = this.devices![this.deviceIndex];
        const infoGetMessage = FirmwareUpdateInfoGetMessage.getSimple(device.meshAddress, this.appKeyIndex);
        this.onMeshMessagePrepared(infoGetMessage);
      }
    }
  }

  /**
   * response of
   * distribute apply
   * or
   * distribute get
   *
   * @param message
   */
  private onDistributeStatus(message: NotificationMessage): void {
    if (this.step === RemoteDistributorAssist.STEP_DIST_APPLYING) {
      const fdStatusMessage = message.statusMessage as FDStatusMessage;
      if (fdStatusMessage.status === DistributionStatus.WRONG_PHASE && fdStatusMessage.distPhase === DistributionPhase.TRANSFER_ACTIVE) {
        this.log("waiting for next apply action...");
        clearTimeout(this.applyTaskTimeoutId)
        this.applyTaskTimeoutId = setTimeout(() => {
          this.APPLY_TASK()
        }, RemoteDistributorAssist.APPLY_INTERVAL)
      } else {
        this.onAssistComplete(fdStatusMessage.status === DistributionStatus.SUCCESS, "distribute apply complete");
      }
    } else if (this.step === RemoteDistributorAssist.STEP_DIST_GET) {
      const fdStatusMessage = message.statusMessage as FDStatusMessage;
      if (fdStatusMessage.status === DistributionStatus.SUCCESS) {
        const phase = fdStatusMessage.distPhase;
        if (phase === DistributionPhase.COMPLETED) {
          this.onAssistComplete(true, "distribute confirm complete");
        } else if (phase === DistributionPhase.APPLYING_UPDATE) {
          this.confirmDistribute();
        } else {
          this.onAssistComplete(false, "distribute phase error");
        }
      } else {
        this.onAssistComplete(false, "distribute status error");
      }
    }
  }

  private onFirmwareInfoStatus(message: NotificationMessage): void {
    const infoStatusMessage = message.statusMessage as FirmwareUpdateInfoStatusMessage;
    const infoEntry = infoStatusMessage.getFirstEntry();
    const src = message.src;
    if (!this.devices) return;
    for (const device of this.devices) {
      if (device.meshAddress === src) {
        if (infoEntry && this.arraysEquals(this.newFirmwareId!, infoEntry.currentFirmwareID)) {
          device.firmwareId = infoEntry.currentFirmwareID;
          this.onDeviceStateUpdate(device, MeshUpdatingDevice.STATE_SUCCESS, "device firmware id updated");
        } else {
          this.onDeviceStateUpdate(device, MeshUpdatingDevice.STATE_FAIL, "device firmware id not updated");
        }
        break;
      }
    }
    this.deviceIndex++;
    this.executeAction();
  }

  private onAssistComplete(success: boolean, desc: string): void {
    this.step = RemoteDistributorAssist.STEP_IDLE;
    // this.handler.removeCallbacksAndMessages(null);
    if (this.actionHandler) {
      this.actionHandler.onActionComplete(success, FUAction.DISTRIBUTE_ASSIST, desc);
    }
  }

  private onDeviceFail(device: MeshUpdatingDevice, desc: string): void {
    this.onDeviceStateUpdate(device, MeshUpdatingDevice.STATE_FAIL, desc);
  }

  private onDeviceStateUpdate(device: MeshUpdatingDevice, state: number, desc: string): void {
    this.log(`node updating changed : ${device.meshAddress.toString(16).padStart(4, '0')} -- ${desc}`);
    device.state = state;
    if (this.actionHandler) {
      this.actionHandler.onDeviceUpdate(device, `node(${device.meshAddress.toString(16).padStart(4, '0')})  state update : -- ${state.toString(16).padStart(2, '0')} -- ${desc}`);
    }
  }

  /**
   *
   */
  public onMessageNotification(message: NotificationMessage): void {
    if (this.step === RemoteDistributorAssist.STEP_IDLE) {
      this.log("notification when idle");
      return;
    }
    if (message.opcode === Opcode.FD_STATUS) {
      this.onDistributeStatus(message);
    } else if (this.step === RemoteDistributorAssist.STEP_RECHECK && message.opcode === Opcode.FIRMWARE_UPDATE_INFORMATION_STATUS) {
      this.onFirmwareInfoStatus(message);
    }
  }

  /**
   *
   */
  public onAssistCommandFailed(opcode: number): void {
    if (this.step === RemoteDistributorAssist.STEP_DIST_APPLYING && opcode === Opcode.FIRMWARE_UPDATE_APPLY) {
      // to updating nodes
      this.onDeviceFail(this.devices![this.deviceIndex], "apply command send fail");
      this.deviceIndex++;
      this.executeAction();
    } else if (this.step === RemoteDistributorAssist.STEP_RECHECK && opcode === Opcode.FIRMWARE_UPDATE_INFORMATION_GET) {
      this.onDeviceFail(this.devices![this.deviceIndex], "recheck command fail");
      this.deviceIndex++;
      this.executeAction();
    }
  }

  public onMeshMessagePrepared(meshMessage: MeshMessage): Promise<boolean> {
    logd(`initiator send message to : ${meshMessage.destinationAddress}`);
    if (this.actionHandler) {
      return this.actionHandler.onMessagePrepared(meshMessage);
    } else {
      return Promise.resolve(false);
    }
  }

  public isRunning(): boolean {
    return this.step !== RemoteDistributorAssist.STEP_IDLE;
  }

  private log(logInfo: string): void {
    this.actionHandler?.onActionLog("Assist", logInfo, LOG_LEVEL_DEBUG);
  }

  private arraysEquals(a: Uint8Array, b: Uint8Array): boolean {
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) {
      if (a[i] !== b[i]) return false;
    }
    return true;
  }
}

export default RemoteDistributorAssist;