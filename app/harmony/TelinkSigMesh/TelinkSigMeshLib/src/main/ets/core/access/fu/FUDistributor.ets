/********************************************************************************************************
 * @file FUDistributor.ets
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
import { LOG_DEFAULT_LEVEL } from "../../../utils/MeshLogger";
import { TransferMode } from "../../message/firmwareupdate/blobtransfer/TransferMode";
import { FirmwareUpdateApplyMessage } from "../../message/firmwareupdate/FirmwareUpdateApplyMessage";
import { FirmwareUpdateCancelMessage } from "../../message/firmwareupdate/FirmwareUpdateCancelMessage";
import { FirmwareUpdateGetMessage } from "../../message/firmwareupdate/FirmwareUpdateGetMessage";
import { FirmwareUpdateStartMessage } from "../../message/firmwareupdate/FirmwareUpdateStartMessage";
import { FirmwareUpdateStatusMessage } from "../../message/firmwareupdate/FirmwareUpdateStatusMessage";
import { UpdatePhase } from "../../message/firmwareupdate/UpdatePhase";
import { UpdateStatus } from "../../message/firmwareupdate/UpdateStatus";
import { NotificationMessage } from "../../message/Index";
import { MeshMessage } from "../../message/MeshMessage";
import { Opcode } from "../../message/Opcode";
import { BlobTransfer } from "./BlobTransfer";
import { BlobTransferCallback } from "./BlobTransferCallback";
import { BlobTransferType } from "./BlobTransferType";
import { FUAction } from "./FUAction";
import { FUActionHandler } from "./FUActionHandler";

/**
 * distribute by phone
 */
class FUDistributor implements BlobTransferCallback {
  private readonly LOG_TAG = "FU-Distributor";

  /**
   * not in initiator processing
   */
  public static readonly STEP_IDLE = 0;

  /**
   * update start
   */
  public static readonly STEP_UPDATE_START = 2;

  /**
   * blob transfer start
   */
  public static readonly STEP_BLOB_TRANSFER = 3;

  /**
   * update get
   */
  public static readonly STEP_UPDATE_GET = 4;

  /**
   * update apply
   */
  public static readonly STEP_UPDATE_APPLY = 5;

  public step: number = FUDistributor.STEP_IDLE;

  /**
   * update get
   */
  public static readonly STEP_UPDATE_CONTINUE = 0x10;

  /**
   * update stop
   */
  public static readonly STEP_UPDATE_STOP = 0x11;

  /**
   * params: update ttl
   */
  public static readonly UPDATE_TTL = 0xFF;

  /**
   * node address
   */
  private nodes: MeshUpdatingDevice[] = [];

  /**
   * app key index that updating model bound with
   */
  private appKeyIndex: number = 0;

  /**
   * operation index
   */
  private nodeIndex: number = 0;

  private blobId: number = 0;

  /**
   * metadata
   */
  private metadata: Uint8Array = new Uint8Array(8);

  /**
   * callback
   */
  private actionHandler: FUActionHandler | null = null;

  private transfer: BlobTransfer | null = null;

  private isContinue: boolean = false;

  private connectedAddress: number = 0;

  // constructor(handlerThread: any, actionHandler: FUActionHandler) {
  //   this.transfer = new BlobTransfer(handlerThread, this);
  //   this.actionHandler = actionHandler;
  // }
  constructor(actionHandler: FUActionHandler) {
    this.transfer = new BlobTransfer(this);
    this.actionHandler = actionHandler;
  }

  begin(configuration: FirmwareUpdateConfiguration, connectedAddress: number, isContinue: boolean): void {
    this.appKeyIndex = configuration.getAppKeyIndex();
    this.connectedAddress = connectedAddress;
    this.isContinue = isContinue;
    this.log(`distribute begin - ${configuration.getUpdatingDevices().length} -- isContinue? ${isContinue}`);
    this.nodes = configuration.getUpdatingDevices();
    let transferType: BlobTransferType;
    let directAddress: number;
    if (this.nodes.length === 1 && this.nodes[0].meshAddress === connectedAddress) {
      // only direct connected node need update
      transferType = BlobTransferType.GATT_DIST;
      directAddress = connectedAddress;
    } else {
      // transfer by mesh
      transferType = BlobTransferType.MESH_DIST;
      directAddress = -1;
    }
    this.transfer!.resetParams(configuration, transferType, directAddress);

    this.metadata = configuration.getMetadata();
    this.blobId = configuration.getBlobId();

    if (isContinue) {
      this.step = FUDistributor.STEP_UPDATE_CONTINUE;
    } else {
      this.step = FUDistributor.STEP_UPDATE_START;
      this.actionHandler?.onTransferProgress(0, transferType);
    }
    this.nodeIndex = 0;
    this.nextAction();
  }

  getTransfer(): BlobTransfer | null {
    return this.transfer;
  }

  stop(): void {
    if (this.step !== FUDistributor.STEP_IDLE) {
      if (this.transfer) {
        this.transfer.clear();
      }
      this.step = FUDistributor.STEP_UPDATE_STOP;
      this.nodeIndex = 0;
      this.nextAction();
    }
  }

  clear(): void {
    if (this.transfer) {
      this.transfer.clear();
    }
    /*if (this.step === this.STEP_BLOB_TRANSFER) {
      transfer.clear();
    }*/
    this.step = FUDistributor.STEP_IDLE;
  }

  isRunning(): boolean {
    return this.step !== FUDistributor.STEP_IDLE;
  }

  holdTransfer(): void {
    this.log(`hold transfer :${this.step}`);
    if (this.step === FUDistributor.STEP_BLOB_TRANSFER) {
      if (this.transfer) {
        this.transfer.hold();
      }
    }
  }

  onDistributeCommandFailed(opcode: number): void {
    if (
      (this.step === FUDistributor.STEP_UPDATE_START && opcode === Opcode.FIRMWARE_UPDATE_START) ||
      (this.step === FUDistributor.STEP_UPDATE_APPLY && opcode === Opcode.FIRMWARE_UPDATE_APPLY) ||
      (this.step === FUDistributor.STEP_UPDATE_GET && opcode === Opcode.FIRMWARE_UPDATE_GET)
    ) {
      // to updating nodes
      this.onDeviceFail(this.nodes![this.nodeIndex], "command send to updating node fail");
      this.nodeIndex++;
      this.nextAction();
    } else if (this.step === FUDistributor.STEP_BLOB_TRANSFER) {
      if (this.transfer) {
        this.transfer.onTransferCommandFail(opcode);
      }
    }
  }

  /****************************************************************
   * {@link BlobTransferCallback} start
   ****************************************************************/

  onTransferProgressUpdate(progress: number, transferType: BlobTransferType): void {
    this.actionHandler?.onTransferProgress(progress, transferType);
  }

  onTransferStart(transferMode: TransferMode): void {
    this.actionHandler?.onTransferStart(transferMode);
  }

  onTransferComplete(success: boolean, desc: string): void {
    this.log(`distribute blob transfer complete : success?${success}`);
    if (success) {
      this.nextStep();
    } else {
      this.onDistributeComplete(false, "blob transfer fail when distribute - " + desc);
    }
  }

  onTransferringDeviceFail(address: number, desc: string): void {
    if (!this.nodes) return;
    for (const device of this.nodes) {
      if (device.meshAddress === address) {
        this.onDeviceFail(device, desc);
        return;
      }
    }
  }

  onMeshMessagePrepared(meshMessage: MeshMessage): Promise<boolean> {
    if (this.actionHandler) {
      return this.actionHandler.onMessagePrepared(meshMessage);
    } else {
      return Promise.resolve(false);
    }
  }

  onTransferLog(tag: string, log: string, logLevel: number): void {
    this.actionHandler?.onActionLog(tag, log, logLevel);
  }

  /****************************************************************
   * {@link BlobTransferCallback} end
   ****************************************************************/

  private onDistributeComplete(success: boolean, desc: string): void {
    if (success) {
      this.actionHandler?.onTransferProgress(100, BlobTransferType.MESH_DIST);
    }
    this.log(`distribute complete : success ? ${success} -- ${desc}`);
    this.step = FUDistributor.STEP_IDLE;
    this.actionHandler?.onActionComplete(success, FUAction.DISTRIBUTE, desc);
  }

  /**
   * process distribute actions step by step
   */
  private nextStep(): void {
    this.step++;
    this.log(`next step: ${this.step}`);
    this.nodeIndex = 0;
    this.nextAction();
  }

  /**
   * execute distribute actions(one by one && step by step)
   * one device by one device
   * if all devices executed, then next step
   */
  private nextAction(): void {
    if (this.nodeIndex >= (this.nodes?.length || 0)) {
      // all nodes executed
      this.log(`current step complete: ${this.step}`);
      if (this.step === FUDistributor.STEP_UPDATE_APPLY) {
        this.onDistributeComplete(true, "update apply complete");
        return;
      }

      if (this.step === FUDistributor.STEP_UPDATE_STOP) {
        this.onDistributeComplete(false, "update stopped");
        return;
      }

      this.removeFailedDevices();

      // check if has available nodes
      if (this.nodes.length !== 0) {
        this.nextStep();
      } else {
        this.onDistributeComplete(false, "all nodes failed when executing action");
      }
    } else {
      const meshAddress = this.nodes[this.nodeIndex].meshAddress;
      this.log(`action executing: ${this.step} -- ${meshAddress.toString(16).padStart(4, '0')}`);
      if (this.step === FUDistributor.STEP_UPDATE_START) {
        const updateStartMessage = new FirmwareUpdateStartMessage(meshAddress, this.appKeyIndex);
        updateStartMessage.metadata = this.metadata;
        updateStartMessage.updateBLOBID = this.blobId;
        updateStartMessage.updateTtl = FUDistributor.UPDATE_TTL;
        updateStartMessage.updateTimeoutBase = 0;
        updateStartMessage.updateFirmwareImageIndex = 0;
        this.onMeshMessagePrepared(updateStartMessage);
      } else if (this.step === FUDistributor.STEP_UPDATE_GET) {
        const getMessage = FirmwareUpdateGetMessage.getSimple(meshAddress, this.appKeyIndex);
        this.onMeshMessagePrepared(getMessage);
      } else if (this.step === FUDistributor.STEP_UPDATE_APPLY) {
        const applyMessage = FirmwareUpdateApplyMessage.getSimple(meshAddress, this.appKeyIndex);
        this.onMeshMessagePrepared(applyMessage);
      } else if (this.step === FUDistributor.STEP_BLOB_TRANSFER) {
        this.log("blob transfer start");
        if (this.transfer) {
          this.transfer.begin(this.isContinue);
        }
      } else if (this.step === FUDistributor.STEP_UPDATE_CONTINUE) {
        const getMessage = FirmwareUpdateGetMessage.getSimple(this.connectedAddress, this.appKeyIndex);
        this.onMeshMessagePrepared(getMessage);
      } else if (this.step === FUDistributor.STEP_UPDATE_STOP) {
        const cancelMessage = FirmwareUpdateCancelMessage.getSimple(meshAddress, this.appKeyIndex);
        this.onMeshMessagePrepared(cancelMessage);
      }
    }
  }

  /**
   * filter out initiator messages
   *
   * @param message notification message
   */
  onMessageNotification(message: NotificationMessage): void {
    const opcode = message.opcode;
    this.log(`message notification: ${opcode}`);
    if (this.step === FUDistributor.STEP_IDLE) {
      this.log("notification when idle");
      return;
    }
    if (!opcode) return;
    const src = message.src;

    // message received from updating devices
    if (this.step === FUDistributor.STEP_UPDATE_START) {
      if (!this.nodes || this.nodes.length <= this.nodeIndex) {
        this.log("node index overflow");
        return;
      }

      if (this.nodes[this.nodeIndex].meshAddress !== src) {
        this.log("distributor unexpected notification src");
        return;
      }
    }
    if (opcode === Opcode.FIRMWARE_UPDATE_STATUS) {
      this.onFirmwareUpdateStatus(message.statusMessage as FirmwareUpdateStatusMessage);
    } else if (this.step === FUDistributor.STEP_BLOB_TRANSFER) {
      if (this.transfer) {
        this.transfer.onTransferNotification(message);
      }
    }
  }

  onMulticastMessageComplete(opcode: number, remainingNodes: Array<number>): void {
    if (this.step !== FUDistributor.STEP_BLOB_TRANSFER) {
      this.log("multi complete -> distributor -> not at blob transfer");
      return;
    }
    if (this.transfer) {
      this.transfer.onMulticastMessageComplete(opcode);
    }
  }

  private onDeviceApplySuccess(device: MeshUpdatingDevice): void {
    this.log("device apply success");
    // should wait for recheck firmware
    // device.state = (MeshUpdatingDevice.STATE_SUCCESS);
    // actionHandler.onDeviceUpdate(device, "device update success");
  }

  /**
   * response of {@link FirmwareUpdateStartMessage} or {@link FirmwareUpdateApplyMessage}
   *
   * @param firmwareUpdateStatusMessage status
   */
  private onFirmwareUpdateStatus(firmwareUpdateStatusMessage: FirmwareUpdateStatusMessage): void {
    this.log(`firmware update status: ${firmwareUpdateStatusMessage.toString()}`);
    const status = firmwareUpdateStatusMessage.getStatus() & 0xFF;

    if (status !== UpdateStatus.SUCCESS) {
      this.onDeviceFail(this.nodes[this.nodeIndex], "firmware update status err");
      this.nodeIndex++;
      this.nextAction();
    } else {
      const phase = firmwareUpdateStatusMessage.getPhase() & 0xFF;
      if (this.step === FUDistributor.STEP_UPDATE_CONTINUE) {
        const pass = phase === UpdatePhase.TRANSFER_ACTIVE || phase === UpdatePhase.APPLY_SUCCESS;
        if (pass) {
          this.step = FUDistributor.STEP_BLOB_TRANSFER;
          this.nextAction();
        } else {
          this.onDistributeComplete(false, "continue distribute error : device may have been rebooted");
        }
      } else if (
        this.step === FUDistributor.STEP_UPDATE_START ||
        this.step === FUDistributor.STEP_UPDATE_GET ||
        this.step === FUDistributor.STEP_UPDATE_APPLY ||
        this.step === FUDistributor.STEP_UPDATE_STOP
      ) {
        let pass = true;
        if (!pass) {
          this.onDeviceFail(this.nodes[this.nodeIndex], "firmware update phase err");
        } else {
          if (this.step === FUDistributor.STEP_UPDATE_APPLY) {
            if (
              phase === UpdatePhase.VERIFICATION_SUCCEEDED ||
              phase === UpdatePhase.APPLYING_UPDATE
            ) {
              this.onDeviceApplySuccess(this.nodes[this.nodeIndex]);
            } else {
              this.onDeviceFail(this.nodes[this.nodeIndex], "phase error when update apply");
            }
          } else {
            // start, get or stop complete
          }
        }
        this.nodeIndex++;
        this.nextAction();
      }
    }
  }

  /**
   * device fail
   *
   * @param device updating device
   */
  private onDeviceFail(device: MeshUpdatingDevice, desc: string): void {
    this.log(`node updating fail: ${device.meshAddress.toString(16).padStart(4, '0')} -- ${desc}`);
    device.state = MeshUpdatingDevice.STATE_FAIL;
    this.actionHandler?.onDeviceUpdate(device, `node updating fail: ${device.meshAddress.toString(16).padStart(4, '0')} -- `);
  }

  private removeFailedDevices(): void {
    if (!this.nodes) return;
    const filteredNodes = this.nodes.filter(device => device.state !== MeshUpdatingDevice.STATE_FAIL);
    this.nodes = filteredNodes;
  }

  private log(logInfo: string, logLevel: number = LOG_DEFAULT_LEVEL): void {
    this.actionHandler?.onActionLog(this.LOG_TAG, logInfo, logLevel);
  }
}

export default FUDistributor;