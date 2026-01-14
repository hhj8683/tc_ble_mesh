/********************************************************************************************************
 * @file FUController.ets
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
import { LOCAL_MESSAGE_ADDRESS, log, logd, LOG_DEFAULT_LEVEL, MeshMessage } from "../../../../../../Index";
import { FirmwareUpdateConfiguration } from "../../../entity/FirmwareUpdateConfiguration";
import { MeshUpdatingDevice } from "../../../entity/MeshUpdatingDevice";
import { FDCancelMessage } from "../../message/firmwaredistribution/FDCancelMessage";
import { FDReceiversGetMessage } from "../../message/firmwaredistribution/FDReceiversGetMessage";
import { FDReceiversListMessage } from "../../message/firmwaredistribution/FDReceiversListMessage";
import {
  getDescriptionByCodeOfTransferMode,
  TransferMode } from "../../message/firmwareupdate/blobtransfer/TransferMode";
import { UpdatePhase } from "../../message/firmwareupdate/UpdatePhase";
import { NotificationMessage } from "../../message/Index";
import { Opcode } from "../../message/Opcode";
import AccessBridge, { ACCESS_MODE_FIRMWARE_UPDATING } from "../AccessBridge";
import { BlobTransferType } from "./BlobTransferType";
import { FUAction } from "./FUAction";
import { FUActionHandler } from "./FUActionHandler";
import FUDistributor from "./FUDistributor";
import { FUInitiator } from "./FUInitiator";
import { FUState, getDescriptionByCodeOfFUState } from "./FUState";
import RemoteDistributorAssist from "./RemoteDistributorAssist";
import { UpdatePolicy } from "./UpdatePolicy";

/**
 * implementation of firmware update flow
 * use FirmwareUpdateInitiator for initiation
 * use FirmwareUpdateDistributor for distribution
 */
class FUController implements FUActionHandler {
  private readonly LOG_TAG = "FU-Controller";

  private currentState: FUState = FUState.IDLE;

  /**
   * firmware update initiator, used to send mesh message from initiator to distributor
   */
  private initiator: FUInitiator | null = null;

  /**
   * firmware update distributor, used to send mesh message from distributor to updating nodes
   */
  private distributor: FUDistributor | null = null;

  private distributorAssist: RemoteDistributorAssist | null = null;

  // private handler: any; // 假设HarmonyOS的Handler类似实现

  private configuration: FirmwareUpdateConfiguration | null = null;

  /**
   * 0 means use APP as distributor
   */
  private distributorAddress: number = 0;

  private appKeyIndex: number = 0;

  private updatePolicy: UpdatePolicy | null = null;

  private deviceList: Array<MeshUpdatingDevice> | null = null;

  /**
   * {@link FDReceiversGetMessage}
   */
  private firstIndexInList: number = 0;

  /**
   * is update running
   * valued by true when update started
   * if distribute by Device, running stopped when distribute start success;
   * otherwise if distribute by Phone, running stopped when update apply success
   */
  private accessBridge: AccessBridge | null = null;

  private isDirectUpdating: boolean = false;

  private connectedAddress: number = 0;

  private progressCheckTaskTimeoutId: number = 0;

  // constructor(handlerThread: any) {
  //   this.handler = new Handler(handlerThread.getLooper());
  //   this.initiator = new FUInitiator(handlerThread, this);
  //   this.distributor = new FUDistributor(handlerThread, this);
  //   this.distributorAssist = new RemoteDistributorAssist(handlerThread, this);
  // }
  constructor() {
    this.initiator = new FUInitiator(this);
    this.distributor = new FUDistributor(this);
    this.distributorAssist = new RemoteDistributorAssist(this);
  }

  /**
   * register
   */
  register(accessBridge: AccessBridge): void {
    this.accessBridge = accessBridge;
  }

  /**
   * start or continue firmware update flow
   */
  begin(configuration: FirmwareUpdateConfiguration, connectedAddress: number): void {
    this.configuration = configuration;
    this.updatePolicy = configuration.getUpdatePolicy();
    this.deviceList = configuration.getUpdatingDevices();
    this.distributorAddress = configuration.getDistributorAddress();
    this.appKeyIndex = configuration.getAppKeyIndex();
    this.connectedAddress = connectedAddress;
    this.isDirectUpdating = this.isConnectedNodeUpdating(connectedAddress);
    this.distributorAssist?.resetConfig(configuration);
    if (!this.deviceList || this.deviceList.length === 0) {
      this.onComplete(false, "device list empty");
      return;
    }
    this.controllerLog(`FU begin - ${this.updatePolicy}  isContinue ? ${configuration.getIsContinue()} -- ${this.currentState} -- ${configuration.toString()}`);
    if (this.currentState === FUState.IDLE && !configuration.getIsContinue()) {
      this.startInitiate();
    } else {
      /*
       * may
       * 1. app reopened, check progress
       * 2. device disconnected and reconnect
       * 3. device apply complete
       */
      // currentState = FUState.DISTRIBUTING_BY_DEVICE;

      if (this.currentState === FUState.DISTRIBUTING_BY_PHONE) {
        this.controllerLog("begin -> distributing by phone");
        this.onFUStateUpdate(FUState.DISTRIBUTING_BY_PHONE, "");
        this.distributor?.begin(configuration, connectedAddress, true);
      } else if (this.currentState === FUState.UPDATE_RECHECKING) {
        this.controllerLog("begin -> rechecking firmware");
        this.distributorAssist?.recheckFirmware(true);
      } else {
        this.onFUStateUpdate(FUState.DISTRIBUTING_BY_DEVICE, "");
        this.fetchProgressState();
      }
    }
  }

  stop(): void {
    if (this.isInitiating()) {
      this.onComplete(false, "initiate stopped");
    } else if (this.isDistributingByPhone()) {
      this.distributor?.stop();
    } else if (this.isDistributingByDevice()) {
      this.cancelDistribution();
      this.onComplete(false, "device distribute stopped");
    }
  }

  isInitiating(): boolean {
    return this.currentState === FUState.INITIATING;
  }

  isDistributingByPhone(): boolean {
    return this.currentState === FUState.DISTRIBUTING_BY_PHONE;
  }

  hold(): void {
    this.controllerLog(`hold dist ${this.distributor?.isRunning()}`);
    if (this.distributor?.isRunning()) {
      this.distributor.holdTransfer();
    }
  }

  private fetchProgressState(): void {
    const getMessage = FDReceiversGetMessage.getSimple(this.distributorAddress, this.appKeyIndex, this.firstIndexInList, 1);
    this.onMessagePrepared(getMessage);
  }

  /**
   * check remote distribution state and progress
   */
  private startProgressCheckTask(): void {
    this.controllerLog("start progress check task");
    clearTimeout(this.progressCheckTaskTimeoutId);
    this.progressCheckTaskTimeoutId = setTimeout(() => {
      this.progressCheckTask()
    }, 10 * 1000);
  }

  private readonly progressCheckTask = (): void => {
    this.fetchProgressState();
  };

  private onProgressState(message: NotificationMessage): void {
    const listMessage = message.statusMessage as FDReceiversListMessage;
    const receiverList = listMessage.getReceiversList();

    if (receiverList && receiverList.length !== 0) {
      const frsReceiver = receiverList[0];
      logd(`first receiver : ${frsReceiver.toString()}`)
      const transferProgress = frsReceiver.transferProgress * 2;
      this.onTransferProgress(transferProgress, BlobTransferType.MESH_DIST);
      // actionHandler.onTransferProgress(transferProgress, BlobTransferType.MESH);

      if (transferProgress >= 100) {
        const phase = frsReceiver.retrievedUpdatePhase;
        if (phase === UpdatePhase.IDLE) {
          // rebooted, check firmware
          this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "device may reboot complete");
          this.distributorAssist?.recheckFirmware(true);
        } else if (
          phase === UpdatePhase.TRANSFER_ERROR ||
          phase === UpdatePhase.APPLY_FAILED ||
          phase === UpdatePhase.TRANSFER_CANCELED
        ) {
          this.onDeviceUpdate(this.deviceList![this.firstIndexInList], "device ReceiversList phase error : phase-" + phase);
          this.firstIndexInList++;
          if (this.firstIndexInList >= (this.deviceList?.length || 0)) {
            this.onComplete(false, "all devices phase error");
          } else {
            this.startProgressCheckTask();
          }
        } else {
          logd(`onProgressState : ${this.currentState}`);

          if (this.updatePolicy === UpdatePolicy.VerifyOnly) {
            if (
              phase === UpdatePhase.VERIFICATION_FAILED ||
              phase === UpdatePhase.VERIFICATION_SUCCEEDED
            ) {
              // apply all devices update
              this.onFUStateUpdate(FUState.UPDATE_APPLYING, "");
              this.distributorAssist?.applyDistribute();
            } else {
              this.startProgressCheckTask();
            }
          } else {
            if (this.isDirectUpdating) {
              // gatt will be terminated
              // waiting for reconnect
              this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "");
              this.controllerLog("waiting for disconnect -- 1");
            } else {
              // changed from 0x06 to 0x08
              if (
                phase === UpdatePhase.APPLY_SUCCESS ||
                phase === UpdatePhase.APPLYING_UPDATE
              ) {
                this.onFUStateUpdate(FUState.DISTRIBUTE_CONFIRMING, "");
                this.distributorAssist?.confirmDistribute();
              } else {
                // distribute not complete
                this.startProgressCheckTask();
              }
            }
          }
        }
      } else {
        // check progress
        const phase = frsReceiver.retrievedUpdatePhase;
        if (phase === UpdatePhase.TRANSFER_ACTIVE) {
          this.startProgressCheckTask();
        } else {
          this.onComplete(false, "phase error - progress not 100 ");
        }
      }
    } else {
      // no receivers, recheck all firmware id
      this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "no receivers found");
      this.distributorAssist?.recheckFirmware(true);
    }
  }

  private isConnectedNodeUpdating(directAddress: number): boolean {
    if (!this.configuration || !this.configuration.getUpdatingDevices()) return false;
    return this.configuration.getUpdatingDevices().some((device) => device.meshAddress === directAddress);
  }

  /**
   * if distributing by device or later, auto connect mesh
   */
  needAutoConnect(): boolean {
    return this.currentState >= FUState.DISTRIBUTING_BY_PHONE;
  }

  isRunning(): boolean {
    return this.currentState !== FUState.IDLE;
  }

  /**
   * stop update actions and clear cache
   */
  clear(): void {
    this.currentState = FUState.IDLE;
    this.firstIndexInList = 0;
    this.controllerLog("clear FU --------");
    if (this.initiator?.isRunning()) {
      this.initiator.clear();
    }
    if (this.distributor?.isRunning()) {
      this.distributor.clear();
    }
    if (this.configuration) {
      this.configuration.setCallback(null);
      this.configuration = null;
    }
  }

  dispatchError(errorMsg: string): void {
    this.onComplete(false, errorMsg);
  }

  /**
   * reliable command complete
   */
  onUpdatingCommandComplete(success: boolean, opcode: number, rspMax: number, rspCount: number): void {
    this.controllerLog(`updating command complete: opcode-${opcode.toString(16).padStart(4, '0')} success?-${success}`);
    if (success) return; // skip success state
    if (opcode === Opcode.FD_RECEIVERS_LIST) {
      this.onComplete(false, "receiver list command send fail");
      return;
    }
    if (this.initiator?.isRunning()) {
      this.initiator.onInitiateCommandFailed(opcode);
    } else if (this.distributor?.isRunning()) {
      this.distributor.onDistributeCommandFailed(opcode);
    } else if (this.distributorAssist?.isRunning()) {
      this.distributorAssist.onAssistCommandFailed(opcode);
    }
  }

  /**
   * segmented message complete
   */
  onSegmentComplete(success: boolean): void {
    if (this.initiator?.isRunning()) {
      this.initiator.getTransfer()?.onTransferSegmentComplete(success);
    } else if (this.distributor?.isRunning()) {
      this.distributor.getTransfer()?.onTransferSegmentComplete(success);
    }
  }

  /**
   * receive mesh message notification
   */
  onMessageNotification(message: NotificationMessage): void {
    this.controllerLog(`rcv notification : ${message.opcode.toString(16).padStart(4, '0')}`);
    if (message.opcode === Opcode.FD_RECEIVERS_LIST) {
      this.onProgressState(message);
      return;
    }
    if (this.initiator?.isRunning()) {
      this.controllerLog("retransmit to initiator");
      this.initiator.onMessageNotification(message);
    } else if (this.distributor?.isRunning()) {
      this.controllerLog("retransmit to distributor");
      this.distributor.onMessageNotification(message);
    } else if (this.distributorAssist?.isRunning()) {
      this.controllerLog("retransmit to assist");
      this.distributorAssist.onMessageNotification(message);
    }
  }

  onMulticastMessageComplete(opcode: number, remainingNodes: Array<number>): void {
    if (this.initiator?.isRunning()) {
      this.controllerLog("multicast msg complete -> initiator");
      this.initiator.onMulticastMessageComplete(opcode, remainingNodes);
    } else if (this.distributor?.isRunning()) {
      this.controllerLog("multicast msg complete -> distributor");
      this.distributor.onMulticastMessageComplete(opcode, remainingNodes);
    }
  }

  /**
   * current action: distributing by device
   */
  isDistributingByDevice(): boolean {
    return this.currentState === FUState.DISTRIBUTING_BY_DEVICE;
  }

  /**
   * start initiate by initiator
   */
  private startInitiate(): void {
    this.initiator?.clear();
    this.distributor?.clear();
    this.onFUStateUpdate(FUState.INITIATING, "");
    if (this.configuration) {
      this.initiator?.begin(this.configuration, this.distributorAddress);
    }
  }

  /**
   * firmware update state updated
   */
  private onFUStateUpdate(state: FUState, extraInfo: string): void {
    this.controllerLog(`state update : ${getDescriptionByCodeOfFUState(state)}`);
    this.currentState = state;
    if (this.configuration) {
      this.configuration.dispatchFUState(state, extraInfo);
    }
    if (this.accessBridge) {
      this.accessBridge.onAccessStateChanged(
        state,
        getDescriptionByCodeOfFUState(state),
        ACCESS_MODE_FIRMWARE_UPDATING,
        undefined
      );
    }
  }

  private onComplete(success: boolean, desc: string): void {
    this.controllerLog(`firmware update complete - ${desc} -- ${success}`);
    this.cancelDistribution();
    // this.handler.removeCallbacksAndMessages(null);
    const fuState = success ? FUState.UPDATE_COMPLETE : FUState.UPDATE_FAIL;
    this.onFUStateUpdate(fuState, desc);
    this.clear();
  }

  /****************************************************************
   * {@link FUActionHandler} start
   ****************************************************************/

  onDeviceUpdate(device: MeshUpdatingDevice, desc: string): void {
    this.controllerLog(`device state update : ${desc}`);
    if (this.configuration) {
      this.configuration.dispatchDeviceState(device, desc);
    }
  }

  /**
   * firmware update action complete
   */
  onActionComplete(success: boolean, action: FUAction, desc: string): void {
    this.controllerLog(`action complete - ${desc} success ? ${success} -- ${action}`);
    switch (action) {
      case FUAction.INITIATE:
        if (!success) {
          this.onFUStateUpdate(FUState.INITIATE_FAIL, "");
          this.onComplete(false, desc);
          return;
        }
        this.onFUStateUpdate(FUState.INITIATE_SUCCESS, "");
        if (this.distributorAddress === LOCAL_MESSAGE_ADDRESS) {
          // distribute by phone
          this.controllerLog("start distribution by phone");
          this.onFUStateUpdate(FUState.DISTRIBUTING_BY_PHONE, "");
          if (this.configuration) {
            this.distributor?.begin(this.configuration, this.connectedAddress, false);
          }
        } else {
          // distribute by direct connected device, gatt connection can be terminated
          this.controllerLog("start distribution by remote device -- > end");
          this.onFUStateUpdate(FUState.DISTRIBUTING_BY_DEVICE, "");
          this.startProgressCheckTask();
          // fetchProgressState();
        }
        break;

      case FUAction.DISTRIBUTE:
        if (success) {
          // phone distribute complete, after send firmware update apply
          this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "");
          if (!this.isDirectUpdating) {
            this.distributorAssist?.recheckFirmware(false);
          } else {
            // otherwise , gatt connection will be terminated
            this.controllerLog("direct device will lose disconnection - 0");
          }
        } else {
          this.onComplete(false, desc);
        }
        break;

      case FUAction.DISTRIBUTE_ASSIST:
        if (!success) {
          this.onComplete(false, desc);
          return;
        }
        if (this.currentState === FUState.UPDATE_APPLYING) {
          // apply 完成, 设备重启或者不重启
          if (!this.isDirectUpdating) {
            this.onFUStateUpdate(FUState.DISTRIBUTE_CONFIRMING, "");
            this.distributorAssist?.confirmDistribute();
          } else {
            // otherwise , gatt connection will be terminated
            this.controllerLog("direct device will lose disconnection - 1");
            this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "");
          }
        } else if (this.currentState === FUState.DISTRIBUTE_CONFIRMING) {
          // getting distribute complete and distribute phase is completed
          this.onFUStateUpdate(FUState.UPDATE_RECHECKING, "");
          this.distributorAssist?.recheckFirmware(false);
        } else if (this.currentState === FUState.UPDATE_RECHECKING) {
          // recheck firmware complete
          this.onComplete(true, desc);
        }
        break;
    }
  }

  private cancelDistribution(): void {
    const cancelMessage = FDCancelMessage.getSimple(this.distributorAddress, this.appKeyIndex);
    cancelMessage.setAck(false);
    this.onMessagePrepared(cancelMessage);
  }

  onMessagePrepared(meshMessage: MeshMessage): Promise<boolean> {
    meshMessage.retryInterval = 5 * 1000;
    if (this.accessBridge) {
      return this.accessBridge.onAccessMessagePrepared(meshMessage, ACCESS_MODE_FIRMWARE_UPDATING);
    } else {
      return Promise.resolve(false);
    }
  }

  onTransferStart(transferMode: TransferMode): void {
    if (this.configuration) {
      this.configuration.dispatchFUState(FUState.TRANSFER_START, getDescriptionByCodeOfTransferMode(transferMode));
    }
  }

  onTransferProgress(progress: number, transferType: BlobTransferType): void {
    if (this.configuration) {
      this.configuration.dispatchTransferProgress(progress, transferType);
    }
  }

  onActionLog(tag: string, logStr: string, logLevel: number): void {
    log(logStr, this.LOG_TAG, logLevel);
    if (this.configuration) {
      this.configuration.dispatchLogInfo(tag, logStr, logLevel);
    }
  }

  /****************************************************************
   * {@link FUActionHandler} end
   ****************************************************************/

  private controllerLog(logInfo: string): void {
    this.onActionLog(this.LOG_TAG, logInfo, LOG_DEFAULT_LEVEL);
  }
}

export default FUController;