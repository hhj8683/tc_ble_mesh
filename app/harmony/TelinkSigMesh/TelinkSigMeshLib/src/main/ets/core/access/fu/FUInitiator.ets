/********************************************************************************************************
 * @file     FUInitiator.ets 
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
 * @file FUInitiator.ets
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

import { FDReceiversAddMessage, ReceiverEntry } from '../../../core/message/firmwaredistribution/FDReceiversAddMessage';
import { FirmwareUpdateConfiguration } from '../../../entity/FirmwareUpdateConfiguration';
import { MeshUpdatingDevice } from '../../../entity/MeshUpdatingDevice';
import { MeshSigModel } from '../../../foundation/MeshSigModel';
import { log, logd, LOG_DEFAULT_LEVEL, LOG_LEVEL_DEBUG, LOG_LEVEL_WARN } from '../../../utils/MeshLogger';
import { LOCAL_MESSAGE_ADDRESS } from '../../../utils/MeshUtils';
import { FDCapabilitiesGetMessage } from '../../message/firmwaredistribution/FDCapabilitiesGetMessage';
import { FDCapabilitiesStatusMessage } from '../../message/firmwaredistribution/FDCapabilitiesStatusMessage';
import { FDReceiversStatusMessage } from '../../message/firmwaredistribution/FDReceiversStatusMessage';
import { FDStartMessage } from '../../message/firmwaredistribution/FDStartMessage';
import { FDStatusMessage } from '../../message/firmwaredistribution/FDStatusMessage';
import { FDUploadStartMessage } from '../../message/firmwaredistribution/FDUploadStartMessage';
import { FDUploadStatusMessage } from '../../message/firmwaredistribution/FDUploadStatusMessage';
import { AdditionalInformation } from '../../message/firmwareupdate/AdditionalInformation';
import { TransferMode } from '../../message/firmwareupdate/blobtransfer/TransferMode';
import { DistributionStatus, getDescriptionByCodeOfDistributionStatus } from '../../message/firmwareupdate/DistributionStatus';
import { FirmwareMetadataCheckMessage } from '../../message/firmwareupdate/FirmwareMetadataCheckMessage';
import { FirmwareMetadataStatusMessage } from '../../message/firmwareupdate/FirmwareMetadataStatusMessage';
import { FirmwareUpdateInfoGetMessage } from '../../message/firmwareupdate/FirmwareUpdateInfoGetMessage';
import { FirmwareUpdateInfoStatusMessage } from '../../message/firmwareupdate/FirmwareUpdateInfoStatusMessage';
import { UpdateStatus, getDescriptionByCodeOfUpdateStatus } from '../../message/firmwareupdate/UpdateStatus';
import {
  ConfigStatus,
  MeshMessage,
  ModelSubscriptionSetMessage, ModelSubscriptionStatusMessage, NotificationMessage } from '../../message/Index';
import { Opcode } from '../../message/Opcode';
import { BlobTransfer } from './BlobTransfer';
import { BlobTransferCallback } from './BlobTransferCallback';
import { BlobTransferType } from './BlobTransferType';
import { FUAction } from './FUAction';
import { FUActionHandler } from './FUActionHandler';
import { UpdatePolicy } from './UpdatePolicy';

/**
 * send mesh message to distributor
 * actions:
 * 1. firmware distribution capabilities get (to distributor)
 * 2. firmware update info get (to nodes)
 * 3. firmware update metadata check (to nodes)
 * 4. subscription set (to nodes)
 * 5. firmware distribution receivers add (to distributor)
 * 6. firmware distribution upload start (to distributor)
 * 7. blob transfer (to distributor)
 */
export class FUInitiator implements BlobTransferCallback {
  private static readonly LOG_TAG = 'FU-Initiator';
  /**
   * not in initiator processing
   */
  private static readonly STEP_IDLE = 0;
  /**
   * get firmware distribution capabilities
   */
  private static readonly STEP_DST_CAP_GET = 1;
  /**
   * get update metadata check
   */
  private static readonly STEP_UPDATE_METADATA_CHECK = 2;
  /**
   * sub set (grouping)
   */
  private static readonly STEP_SUB_SET = 3;
  /**
   * get firmware update info
   */
  private static readonly STEP_UPDATE_INFO_GET = 4;
  /**
   * distribution receivers add
   */
  private static readonly STEP_DST_RECEIVERS_ADD = 5;
  /**
   * distribution upload start
   */
  private static readonly STEP_DST_UPLOAD_START = 6;
  /**
   * distribution upload start
   */
  private static readonly STEP_BLOB_TRANSFER = 7;
  /**
   * send distribution start
   */
  public static readonly STEP_DST_START = 8;
  private step: number = FUInitiator.STEP_IDLE;
  /**
   * node address | ignore
   */
  private updatingDevices?: MeshUpdatingDevice[];
  private distributorAddress: number = 0;
  /**
   * blob transfer type, may be gatt or local
   */
  private type?: BlobTransferType;
  /**
   * group address for subscription
   */
  private groupAddress: number = 0;
  /**
   * app key index that updating model bound with
   */
  private appKeyIndex: number = 0;
  /**
   * operation index
   */
  private deviceIndex: number = 0;
  private metadataIndex: number = 0;
  private metadata: Uint8Array = new Uint8Array(8);
  private firmwareId?: Uint8Array;
  private blobId: number = 0;
  private firmwareSize: number = 0;
  private updatePolicy: UpdatePolicy = UpdatePolicy.VerifyOnly;
  private isUpdatingLpn: boolean = false;
  private actionHandler?: FUActionHandler;
  private transfer?: BlobTransfer;

  // constructor(handlerThread: any, actionHandler: FUActionHandler) {
  //   this.transfer = new BlobTransfer(handlerThread, this);
  //   this.actionHandler = actionHandler;
  // }
  constructor(actionHandler: FUActionHandler) {
    this.transfer = new BlobTransfer(this);
    this.actionHandler = actionHandler;
  }

  /**
   * begin distributor initiation
   */
  begin(configuration: FirmwareUpdateConfiguration, distributorAddress: number): void {
    this.updatingDevices = configuration.getUpdatingDevices();
    this.metadata = configuration.getMetadata();
    this.groupAddress = configuration.getGroupAddress();
    this.appKeyIndex = configuration.getAppKeyIndex();

    if (this.updatingDevices?.length) {
      this.isUpdatingLpn = this.updatingDevices[0].isLpn;
    }

    this.blobId = configuration.getBlobId();

    if (!configuration.getIsContinue()) {
      this.firmwareSize = configuration.getFirmwareData().length;
    }

    this.firmwareId = configuration.getFirmwareId();
    this.updatePolicy = configuration.getUpdatePolicy();
    this.distributorAddress = distributorAddress;
    this.type = distributorAddress === LOCAL_MESSAGE_ADDRESS
      ? BlobTransferType.LOCAL_INIT
      : BlobTransferType.GATT_INIT;

    this.transfer?.resetParams(configuration, this.type, distributorAddress);
    this.log(`initiator begin : node size - ${this.updatingDevices?.length} -- distAdr - ${distributorAddress}`);

    this.step = FUInitiator.STEP_DST_CAP_GET;
    this.nextAction();
  }

  clear(): void {
    this.transfer?.clear();
    this.step = FUInitiator.STEP_IDLE;
  }

  isRunning(): boolean {
    return this.step !== FUInitiator.STEP_IDLE;
  }

  private onInitComplete(success: boolean, desc: string): void {
    if (success) {
      this.onTransferProgressUpdate(100, this.type!);
    }
    this.step = FUInitiator.STEP_IDLE;
    this.actionHandler?.onActionComplete(success, FUAction.INITIATE, desc);
  }

  getTransfer(): BlobTransfer | undefined {
    return this.transfer;
  }

  /**
   * execute updating actions(one by one && step by step)
   * one device by one device
   * if all devices executed, then next step
   */
  private nextAction(): void {
    if (this.step === FUInitiator.STEP_UPDATE_METADATA_CHECK ||
      this.step === FUInitiator.STEP_SUB_SET ||
      (this.step === FUInitiator.STEP_UPDATE_INFO_GET && this.isUpdatingLpn)) {

      if (this.deviceIndex >= (this.updatingDevices?.length || 0)) {
        this.log(`current step complete: ${this.step}`);
        this.removeFailedDevices();

        if (this.updatingDevices?.length) {
          this.deviceIndex = 0;
          this.log(`next step: ${this.step + 1}`);
          this.step++;
          this.nextAction();
        } else {
          this.onInitComplete(false, 'all device failed when initiate');
        }
      } else {
        const meshAddress = this.updatingDevices![this.deviceIndex].meshAddress;
        this.log(`action executing: ${this.step} -- ${meshAddress.toString(16).padStart(4, '0').toUpperCase()}`,
          LOG_LEVEL_WARN);

        if (this.step === FUInitiator.STEP_UPDATE_METADATA_CHECK) {
          this.log(`node -> metadata check ${meshAddress.toString(16).padStart(4, '0').toUpperCase()}`, LOG_LEVEL_WARN);
          this.onMeshMessagePrepared(FirmwareMetadataCheckMessage.getSimple(
            meshAddress,
            this.appKeyIndex,
            this.metadataIndex,
            this.metadata
          ));
        } else if (this.step === FUInitiator.STEP_SUB_SET) {
          this.log(`node -> sub set ${meshAddress.toString(16).padStart(4, '0').toUpperCase()}`, LOG_LEVEL_WARN);
          const eleAdr = this.updatingDevices![this.deviceIndex].updatingEleAddress;
          const modelId = MeshSigModel.SIG_MD_OBJ_TRANSFER_S;
          this.onMeshMessagePrepared(ModelSubscriptionSetMessage.getSimple(
            meshAddress,
            ModelSubscriptionSetMessage.MODE_ADD,
            eleAdr,
            this.groupAddress,
            modelId,
            true
          ));
        } else if (this.step === FUInitiator.STEP_UPDATE_INFO_GET) {
          this.log(`node -> update info get ${meshAddress.toString(16).padStart(4, '0').toUpperCase()}`,
            LOG_LEVEL_WARN);
          const infoGetMessage = FirmwareUpdateInfoGetMessage.getSimple(meshAddress, this.appKeyIndex);
          const nodeAdrList: number[] = [];

          this.updatingDevices?.forEach(dev => {
            nodeAdrList.push(dev.meshAddress);
          });

          infoGetMessage.responseMax = nodeAdrList.length;
          // infoGetMessage.setBrokerConfig(new MulticastMessageBroker.Config(nodeAdrList));
          this.onMeshMessagePrepared(infoGetMessage);
        }
      }
      return;
    }

    switch (this.step) {
      case FUInitiator.STEP_DST_CAP_GET: {
        this.log('distributor -> get capability', LOG_LEVEL_WARN);
        this.onMeshMessagePrepared(FDCapabilitiesGetMessage.getSimple(this.distributorAddress, this.appKeyIndex));
        break;
      }

      case FUInitiator.STEP_DST_RECEIVERS_ADD: {
        this.log('distributor -> add receivers', LOG_LEVEL_WARN);
        const entryList: ReceiverEntry[] = [];

        this.updatingDevices?.forEach(updatingDevice => {
          entryList.push(new ReceiverEntry(updatingDevice.meshAddress, 0));
        });

        const receiversAddMessage = FDReceiversAddMessage.getSimple(
          this.distributorAddress,
          this.appKeyIndex,
          entryList
        );
        this.onMeshMessagePrepared(receiversAddMessage);
        break;
      }

      case FUInitiator.STEP_DST_UPLOAD_START: {
        this.log('distributor -> upload start', LOG_LEVEL_WARN);
        const uploadStartMessage = FDUploadStartMessage.getSimple(this.distributorAddress, this.appKeyIndex);
        uploadStartMessage.uploadTTL = 0xFF;
        uploadStartMessage.uploadTimeoutBase = 0;
        uploadStartMessage.uploadBLOBID = this.blobId;
        uploadStartMessage.uploadFirmwareSize = this.firmwareSize;
        uploadStartMessage.uploadFirmwareMetadataLength = this.metadata.length;
        uploadStartMessage.uploadFirmwareMetadata = this.metadata;
        uploadStartMessage.uploadFirmwareID = this.firmwareId!;
        this.onMeshMessagePrepared(uploadStartMessage);
        break;
      }

      case FUInitiator.STEP_UPDATE_INFO_GET: {
        this.log(`group -> update info get ${this.groupAddress.toString(16).padStart(4, '0').toUpperCase()}`,
          LOG_LEVEL_WARN);
        const infoGetMessage = FirmwareUpdateInfoGetMessage.getSimple(this.groupAddress, this.appKeyIndex);
        const nodeAdrList: number[] = [];

        this.updatingDevices?.forEach(dev => {
          nodeAdrList.push(dev.meshAddress);
        });

        infoGetMessage.responseMax = nodeAdrList.length;
        // infoGetMessage.setBrokerConfig(new MulticastMessageBroker.Config(nodeAdrList));
        this.onMeshMessagePrepared(infoGetMessage);
        break;
      }

      case FUInitiator.STEP_BLOB_TRANSFER: {
        this.log('start blob transfer from initiator to distributor', LOG_LEVEL_WARN);
        this.transfer?.begin(false);
        break;
      }

      case FUInitiator.STEP_DST_START: {
        this.log('distributor -> distribute start', LOG_LEVEL_WARN);
        const startMessage = FDStartMessage.getSimple(this.distributorAddress, this.appKeyIndex);
        startMessage.distributionAppKeyIndex = this.appKeyIndex;
        startMessage.distributionTTL = 0xFF;
        startMessage.distributionTimeoutBase = 0;
        startMessage.distributionTransferMode = TransferMode.PUSH;
        startMessage.updatePolicy = this.updatePolicy;
        startMessage.distributionImageIndex = 0;

        if (this.updatingDevices?.length === 1 && this.updatingDevices[0].isLpn) {
          startMessage.distributionMulticastAddress = 0;
        } else {
          startMessage.distributionMulticastAddress = this.groupAddress;
        }

        this.log(`distribute start address: ${startMessage.distributionMulticastAddress.toString(16)
          .padStart(4, '0')
          .toUpperCase()}`);
        this.onMeshMessagePrepared(startMessage);
        break;
      }
    }
  }

  /**
   * filter out initiator messages
   * @param message notification message
   */
  onMessageNotification(message: NotificationMessage): void {
    const opcode = message.opcode;
    this.log(`message notification: ${opcode}`);

    if (this.step === FUInitiator.STEP_IDLE) {
      this.log('notification when idle');
      return;
    }

    if (this.step === FUInitiator.STEP_BLOB_TRANSFER) {
      this.log('notification trans to blob-transfer');
      this.transfer?.onTransferNotification(message);
      return;
    }

    if (!opcode) return;
    const src = message.src;

    if (this.step === FUInitiator.STEP_UPDATE_INFO_GET ||
      this.step === FUInitiator.STEP_UPDATE_METADATA_CHECK ||
      this.step === FUInitiator.STEP_SUB_SET) {

      if (this.deviceIndex >= (this.updatingDevices?.length || 0)) {
        this.log('node index overflow');
        return;
      }

      if (this.updatingDevices![this.deviceIndex].meshAddress !== src) {
        this.log('initiator unexpected notification src');
        return;
      }
    }

    switch (opcode) {
      case Opcode.FD_CAPABILITIES_STATUS:
        this.onCapStatus(message.statusMessage as FDCapabilitiesStatusMessage);
        break;
      case Opcode.FIRMWARE_UPDATE_INFORMATION_STATUS:
        this.onFirmwareInfoStatus(message.statusMessage as FirmwareUpdateInfoStatusMessage);
        break;
      case Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_STATUS:
        this.onMetadataStatus(message.statusMessage as FirmwareMetadataStatusMessage);
        break;
      case Opcode.CFG_MODEL_SUB_STATUS:
        this.onSubscriptionStatus(message.statusMessage as ModelSubscriptionStatusMessage);
        break;
      case Opcode.FD_RECEIVERS_STATUS:
        this.onRevStatus(message.statusMessage as FDReceiversStatusMessage);
        break;
      case Opcode.FD_UPLOAD_STATUS:
        this.onUploadStatus(message.statusMessage as FDUploadStatusMessage);
        break;
      case Opcode.FD_STATUS:
        this.onFDStatus(message.statusMessage as FDStatusMessage);
        break;
    }
  }

  onInitiateCommandFailed(opcode: number): void {
    if ((this.step === FUInitiator.STEP_DST_CAP_GET && opcode === Opcode.FD_CAPABILITIES_GET) ||
      (this.step === FUInitiator.STEP_DST_RECEIVERS_ADD && opcode === Opcode.FD_RECEIVERS_ADD) ||
      (this.step === FUInitiator.STEP_DST_UPLOAD_START && opcode === Opcode.FD_UPLOAD_STATUS) ||
      (this.step === FUInitiator.STEP_DST_START && opcode === Opcode.FD_START)) {

      this.onInitComplete(false, 'distribution command fail');
    } else if ((this.step === FUInitiator.STEP_UPDATE_INFO_GET && opcode === Opcode.FIRMWARE_UPDATE_INFORMATION_GET) ||
      (this.step === FUInitiator.STEP_UPDATE_METADATA_CHECK &&
        opcode === Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_STATUS) ||
      (this.step === FUInitiator.STEP_SUB_SET && opcode === Opcode.CFG_MODEL_SUB_STATUS)) {

      this.onDeviceFail(this.updatingDevices![this.deviceIndex], 'updating node init command fail');
      this.deviceIndex++;
      this.nextAction();
    } else if (this.step === FUInitiator.STEP_BLOB_TRANSFER) {
      this.transfer?.onTransferCommandFail(opcode);
    }
  }

  private onFDStatus(statusMessage: FDStatusMessage): void {
    if (this.step !== FUInitiator.STEP_DST_START) {
      this.log('not at STEP_UPDATE_START');
      return;
    }

    if (statusMessage.status === DistributionStatus.SUCCESS) {
      this.onInitComplete(true, 'initiate distributor success');
    } else {
      this.onInitComplete(false,
        `initiate distributor fail: distribution status - ${getDescriptionByCodeOfDistributionStatus(statusMessage.status)}`);
    }
  }

  /**
   * firmware distribute capability status
   */
  private onCapStatus(statusMessage: FDCapabilitiesStatusMessage): void {
    if (this.step !== FUInitiator.STEP_DST_CAP_GET) {
      this.log('not at STEP_DST_CAP_GET');
      return;
    }

    this.step++;
    this.nextAction();
  }

  private onFirmwareInfoStatus(firmwareInfoStatusMessage: FirmwareUpdateInfoStatusMessage): void {
    this.log(`firmware info status: ${firmwareInfoStatusMessage.toString()}`);

    if (this.step !== FUInitiator.STEP_UPDATE_INFO_GET) {
      this.log('not at STEP_GET_FIRMWARE_INFO');
      return;
    }

    const firstIndex = firmwareInfoStatusMessage.getFirstIndex();
    const companyId = firmwareInfoStatusMessage.getListCount();
    const firmwareInformationList = firmwareInfoStatusMessage.getFirmwareInformationList();

    if (this.isUpdatingLpn) {
      this.deviceIndex++;
      this.nextAction();
    }
  }

  onMulticastMessageComplete(opcode: number, remainingNodes: number[]): void {
    if (this.step !== FUInitiator.STEP_UPDATE_INFO_GET || this.isUpdatingLpn) {
      this.log(`multi complete -> not at STEP_GET_FIRMWARE_INFO or not updating lpn , state : ${this.step} isUpdatingLpn : ${this.isUpdatingLpn}`);
      return;
    }

    if (remainingNodes.length === 0) {
      this.log('all nodes have responded the update info status');
    } else {
      this.updatingDevices = this.updatingDevices?.filter(device => {
        if (remainingNodes.includes(device.meshAddress)) {
          device.state = MeshUpdatingDevice.STATE_FAIL;
          this.actionHandler?.onDeviceUpdate(device, 'update info status no reply from the device');
          return false;
        }
        return true;
      });
    }

    this.step++;
    this.nextAction();
  }

  private onMetadataStatus(metadataStatusMessage: FirmwareMetadataStatusMessage): void {
    const status = metadataStatusMessage.getStatus();
    if (this.step !== FUInitiator.STEP_UPDATE_METADATA_CHECK) {
      this.log('not at STEP_UPDATE_METADATA_CHECK');
      return;
    }

    if (status !== UpdateStatus.SUCCESS) {
      this.onDeviceFail(this.updatingDevices![this.deviceIndex],
        `metadata check error: ${getDescriptionByCodeOfUpdateStatus(status)}`);
    } else {
      const device = this.updatingDevices![this.deviceIndex];
      device.additionalInformation = metadataStatusMessage.getAdditionalInformation();
      device.state = MeshUpdatingDevice.STATE_METADATA_RSP;
      this.actionHandler?.onDeviceUpdate(device, 'device metadata check complete');
    }

    this.deviceIndex++;
    this.nextAction();
  }

  private onSubscriptionStatus(subscriptionStatusMessage: ModelSubscriptionStatusMessage): void {
    this.log(`subscription status: ${subscriptionStatusMessage.toString()}`);

    if (this.step !== FUInitiator.STEP_SUB_SET) {
      this.log('not at STEP_SUB_SET');
      return;
    }

    if (subscriptionStatusMessage.status !== ConfigStatus.SUCCESS) {
      this.onDeviceFail(this.updatingDevices![this.deviceIndex],
        `grouping status err ${subscriptionStatusMessage.statusName()}`);
    }

    this.deviceIndex++;
    this.nextAction();
  }

  private onRevStatus(statusMessage: FDReceiversStatusMessage): void {
    if (this.step !== FUInitiator.STEP_DST_RECEIVERS_ADD) {
      this.log('not at STEP_DST_RECEIVERS_ADD');
      return;
    }

    this.step++;
    this.nextAction();
  }

  private onUploadStatus(uploadStatusMessage: FDUploadStatusMessage): void {
    this.log(`upload status: ${uploadStatusMessage.toString()}`);

    if (this.step !== FUInitiator.STEP_DST_UPLOAD_START) {
      this.log('not at STEP_DST_UPLOAD_START');
      return;
    }

    this.step++;
    this.nextAction();
  }

  /****************************************************************
   * BlobTransferCallback implementation
   ****************************************************************/

  onTransferProgressUpdate(progress: number, transferType: BlobTransferType): void {
    this.actionHandler?.onTransferProgress(progress, transferType);
  }

  onTransferStart(transferMode: TransferMode): void {
    this.actionHandler?.onTransferStart(transferMode);
  }

  onTransferComplete(success: boolean, desc: string): void {
    this.log(`initiator transfer complete: success?${success}`);
    this.step++;
    this.nextAction();
  }

  onTransferringDeviceFail(address: number, desc: string): void {
    this.log(`node updating fail: ${address.toString(16).padStart(4, '0').toUpperCase()} -- ${desc}`);
    const device = this.getDeviceByAddress(address);
    if (device) {
      this.onDeviceFail(device,
        `node updating fail: ${device.meshAddress.toString(16).padStart(4, '0').toUpperCase()} -- `);
    }
  }

  onMeshMessagePrepared(meshMessage: MeshMessage): Promise<boolean> {
    logd(`initiator send message to : ${meshMessage.destinationAddress}`);
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
   * Helper methods
   ****************************************************************/

  private onDeviceFail(device: MeshUpdatingDevice, desc: string): void {
    device.state = MeshUpdatingDevice.STATE_FAIL;
    this.actionHandler?.onDeviceUpdate(device, desc);
  }

  private removeFailedDevices(): void {
    this.updatingDevices = this.updatingDevices?.filter(device => device.state !== MeshUpdatingDevice.STATE_FAIL);
  }

  private getDeviceByAddress(address: number): MeshUpdatingDevice | undefined {
    return this.updatingDevices?.find(device => device.meshAddress === address);
  }

  private log(logInfo: string, logLevel: number = LOG_DEFAULT_LEVEL): void {
    this.actionHandler?.onActionLog(FUInitiator.LOG_TAG, logInfo, logLevel);
  }
}