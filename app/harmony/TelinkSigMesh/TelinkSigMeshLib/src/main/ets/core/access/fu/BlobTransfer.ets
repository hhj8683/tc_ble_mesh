/********************************************************************************************************
 * @file     BlobTransfer.ets 
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
 * @file BlobTransfer.ets
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
import { LOG_LEVEL_DEBUG, logd, loge } from '../../../../ets/utils/MeshLogger';
import { MeshFirmwareParser } from '../MeshFirmwareParser';
import { BlobBlockStartMessage } from '../../message/firmwareupdate/blobtransfer/BlobBlockStartMessage';
import { BlobBlockStatusMessage } from '../../message/firmwareupdate/blobtransfer/BlobBlockStatusMessage';
import { BlobChunkTransferMessage } from '../../message/firmwareupdate/blobtransfer/BlobChunkTransferMessage';
import { BlobInfoGetMessage } from '../../message/firmwareupdate/blobtransfer/BlobInfoGetMessage';
import { BlobInfoStatusMessage } from '../../message/firmwareupdate/blobtransfer/BlobInfoStatusMessage';
import { BlobPartialBlockReportMessage } from '../../message/firmwareupdate/blobtransfer/BlobPartialBlockReportMessage';
import { BlobTransferGetMessage } from '../../message/firmwareupdate/blobtransfer/BlobTransferGetMessage';
import { BlobTransferStartMessage } from '../../message/firmwareupdate/blobtransfer/BlobTransferStartMessage';
import { BlobTransferStatusMessage } from '../../message/firmwareupdate/blobtransfer/BlobTransferStatusMessage';
import { TransferMode } from '../../message/firmwareupdate/blobtransfer/TransferMode';
import { TransferStatus } from '../../message/firmwareupdate/blobtransfer/TransferStatus';
import { ExtendBearerMode } from '../../networking/ExtendBearerMode';
import { NetworkingController } from '../../networking/NetworkingController';
import { FirmwareUpdateConfiguration } from '../../../entity/FirmwareUpdateConfiguration';
import { MeshUpdatingDevice } from '../../../entity/MeshUpdatingDevice';
// import { MulticastMessageBroker } from '../../../foundation/MulticastMessageBroker';
import { GattConnection } from '../../../ble/GattConnection';
import { MeshMessage } from '../../message/MeshMessage';
import { NotificationMessage } from '../../message/Index';
import { Opcode } from '../../message/Opcode';
import { UpdateStatus } from '../../message/firmwareupdate/UpdateStatus';
import { BlobBlockGetMessage } from '../../message/firmwareupdate/blobtransfer/BlobBlockGetMessage';
import { BlobTransferType } from './BlobTransferType';
import { BlobTransferCallback } from './BlobTransferCallback';

/**
 * used in Firmware Update Flow (MeshOTA)
 * initiator send blob to distributor
 * distributor send blob to initiator
 */
export class BlobTransfer {

    private readonly LOG_TAG = "BlobTransfer";

    // lpn receive packet from friend
    // from 5 * 1000 to 30 * 1000
    // PTS BV6 need to be more than 67.
    private static readonly PARTIAL_WAITING_TIMEOUT = 68 * 1000;

    /**
     * blob transfer get
     */
    private static readonly STEP_IDLE = 0;

    /**
     * blob transfer get
     */
    private static readonly STEP_BLOB_TRANSFER_GET = 5;

    /**
     * get blob info
     */
    private static readonly STEP_BLOB_INFO_GET = 6;

    /**
     * blob transfer start
     */
    private static readonly STEP_BLOB_TRANSFER_START = 7;

    /**
     * blob block transfer start
     */
    private static readonly STEP_BLOB_BLOCK_START = 8;

    /**
     * sending chunk data
     */
    private static readonly STEP_BLOB_CHUNK_SENDING = 9;

    /**
     * get block
     *
     * @see Opcode#BLOB_BLOCK_STATUS
     */
    private static readonly STEP_BLOB_BLOCK_GET = 10;

    private step: number = BlobTransfer.STEP_IDLE;

    /**
     * operation index for sending unicast message
     */
    private nodeIndex: number = 0;

    /**
     * 1. add all nodes to the list
     * 2. remove the failed node
     * 3. remove the no chunk missing node
     * if the list is empty, it means all nodes have received data complete
     */
    private missingNodes: number[] = [];

    /**
     * received missing chunk number
     */
    private missingChunks: number[] = [];

    /**
     * direction of blob sending
     */
    private transferType: BlobTransferType = BlobTransferType.LOCAL_INIT;

    // private delayHandler: any; // Handler type would be defined based on the actual implementation
    private firmwareParser: MeshFirmwareParser = new MeshFirmwareParser();

    /**
     * transfer target devices
     */
    private targetDevices: TargetDevice[] = [];
    //    List<MeshUpdatingDevice> deviceList;
    private firmwareData: Uint8Array = new Uint8Array();

    /**
     * sending missing chunk
     */
    private missingChunkIndex: number = 0;

    /**
     * mix format : mix all format received after checkMissingChunks {@link #checkMissingChunks()}
     */
    private mixedFormat: number = -1;

    private extendBearerMode: ExtendBearerMode = ExtendBearerMode.NONE;

    private transferCallback: BlobTransferCallback;

    private blobId: number = 0;

    private appKeyIndex: number = 0;

    private groupAddress: number = 0;

    /**
     * max missing chunk number in each block for progress calculate
     */
    private pullMaxChunkNumber: number = 0;

    private pullProgress: number = -1;

    /**
     * transfer mode confirmed by the last BlobInfoStatus
     */
    private transferMode: TransferMode = TransferMode.PUSH;

    private networkInterval: number = 0;

    private parRptWaitingTimeoutId: number = 0;
    private actionTaskTimeoutId: number = 0;
    private chunkSendingTaskTimeoutId: number = 0;
    private missingChunkSendingTaskTimeoutId: number = 0;

    // public constructor(handlerThread: any, callback: BlobTransferCallback) {
    //     this.delayHandler = new Handler(handlerThread.getLooper());
    //     this.transferCallback = callback;
    // }
    public constructor(callback: BlobTransferCallback) {
        this.transferCallback = callback;
    }

    /**
     * @param type          BlobTransferType
     * @param directAddress transfer blob to local or direct connected address used when type is BlobTransferType.LOCAL or BlobTransferType.GATT,
     *                      otherwise not used
     */
    public resetParams(configuration: FirmwareUpdateConfiguration, type: BlobTransferType, directAddress: number): void {
        this.firmwareData = configuration.getFirmwareData();
        this.extendBearerMode = configuration.getExtendBearerMode();
        this.blobId = configuration.getBlobId();
        this.appKeyIndex = configuration.getAppKeyIndex();
        this.groupAddress = configuration.getGroupAddress();
        this.networkInterval = configuration.getNetworkInterval();
        this.targetDevices = [];
        this.transferType = type;
        this.log("transfer begin: " + type);
        this.missingNodes = [];
        this.mixedFormat = -1;
        if (type === BlobTransferType.LOCAL_INIT || type === BlobTransferType.GATT_INIT) {
            this.targetDevices.push(new TargetDevice(directAddress));
            this.missingNodes.push(directAddress);
        } else {
            // BlobTransferType.MESH
            for (const device of configuration.getUpdatingDevices()) {
                this.targetDevices.push(new TargetDevice(device.meshAddress));
                this.missingNodes.push(device.meshAddress);
            }
        }
    }

    public begin(isContinue: boolean): void {
        this.log(`blob transfer begin : continue-${isContinue} step-${this.step.toString().padStart(2, '0')}`);
        NetworkingController.netPktSendInterval = this.networkInterval;
        this.log(`network transmit changed : ${this.networkInterval}`);
        if (isContinue) {
            this.log("blob transfer continue");
            // continue last action
            this.nextAction();
        } else {
            /*if (this.step !== STEP_IDLE) {
                onTransferComplete(false, "transfer not idle");
                return;
            }*/
            this.log(`blob transfer continue: block--chunk ${this.firmwareParser.currentBlockIndex()} -- ${this.firmwareParser.currentChunkIndex()}`);
            // new transfer flow
            this.step = BlobTransfer.STEP_BLOB_TRANSFER_GET;
            this.pullProgress = -1;
            this.nextAction();
        }
    }

    public clear(): void {
        NetworkingController.netPktSendInterval = NetworkingController.NETWORK_INTERVAL_DEFAULT;
        this.log(`network transmit revert : ${NetworkingController.NETWORK_INTERVAL_DEFAULT}`);
        this.step = BlobTransfer.STEP_IDLE;
        clearTimeout(this.parRptWaitingTimeoutId);
    }

    public hold(): void {
        clearTimeout(this.parRptWaitingTimeoutId);
    }

    private readonly ACTION_TASK = (): void => {
        // STEP_BLOB_BLOCK_START is group message
        // STEP_BLOB_BLOCK_GET is unicast message, but only send to first missing node
        if (this.step === BlobTransfer.STEP_BLOB_BLOCK_START && this.transferMode === TransferMode.PUSH) {
            // send to group
            if (this.firmwareParser.hasNextBlock()) {
                this.firmwareParser.nextBlock();
                this.log(`(push)next block: ${this.firmwareParser.currentBlockIndex()}`);
            } else {
                this.log(`(push)all blocks sent complete at: block -- ${this.firmwareParser.currentBlockIndex()}`);
                this.onTransferComplete(true, "success");
                return;
            }
            const blockNumber = this.firmwareParser.currentBlockIndex();
            const chunkSize = this.firmwareParser.getChunkSize();

            const startMessage = BlobBlockStartMessage.getSimple(this.groupAddress, this.appKeyIndex,
                blockNumber, chunkSize);
            if (this.transferType === BlobTransferType.LOCAL_INIT) {
                startMessage.destinationAddress = 0;
            } else if (this.transferType === BlobTransferType.GATT_INIT) {
                if (this.targetDevices.length === 0) {
                    this.onTransferComplete(false, "target device size error");
                    return;
                }
                startMessage.destinationAddress = this.targetDevices[0].address;
            } else {
                const nodeAdrList: number[] = [];
                for (const dev of this.targetDevices) {
                    nodeAdrList.push(dev.address);
                }
                // startMessage.setBrokerConfig(new MulticastMessageBroker.Config(nodeAdrList));
                // startMessage.setResponseMax(nodeAdrList.length);
            }
            this.onTransferMessagePrepared(startMessage);
            return;
        } else if (this.step === BlobTransfer.STEP_BLOB_BLOCK_GET) {
            const adr = this.getMissingNodeAdr();
            if (adr === -1) {
                // no chunks missing node
                // send the next block
                this.step = BlobTransfer.STEP_BLOB_BLOCK_START;
                this.pullMaxChunkNumber = 0;
                this.nextAction();
            } else {
                this.onTransferMessagePrepared(BlobBlockGetMessage.getSimple(adr, this.appKeyIndex));
            }
            return;
        }
        if (this.nodeIndex >= this.targetDevices.length) {
            // all nodes executed
            this.log(`current step complete: ${this.getStepDesc(this.step)}`);
            this.removeFailedDevices();
            this.log(`remaining device count : ${this.targetDevices.length}`);
            // check if has available nodes
            if (this.targetDevices.length !== 0) {
                this.nodeIndex = 0;
                // check if we're not at BLOB_BLOCK_GET step
                if (this.step !== BlobTransfer.STEP_BLOB_BLOCK_GET) {
                    this.log(`next step: ${this.getStepDesc(this.step + 1)}`);
                    this.step++;
                    this.nextAction();
                } else {
                    this.log("onGetBlobBlockComplete");
                    this.onGetBlobBlockComplete();
                }
            } else {
                this.onTransferComplete(false, "all nodes failed when executing action");
            }
        } else {
            const meshAddress = this.targetDevices[this.nodeIndex].address;
            this.log(`action executing: ${this.getStepDesc(this.step)} -- ${meshAddress.toString(16).toUpperCase().padStart(4, '0')}`);
            switch (this.step) {
                case BlobTransfer.STEP_BLOB_INFO_GET:
                    this.onTransferMessagePrepared(BlobInfoGetMessage.getSimple(meshAddress, this.appKeyIndex));
                    break;

                case BlobTransfer.STEP_BLOB_TRANSFER_START:
                    if (this.nodeIndex === 0) {
                        this.transferCallback.onTransferStart(this.transferMode);
                    }
                    const objectSize = this.firmwareParser.getObjectSize();
                    const blockSizeLog = Math.floor(Math.log2(this.firmwareParser.getBlockSize()));
                    const mtu = 380;

                    const blobTransferStartMessage = BlobTransferStartMessage.getSimple(meshAddress, this.appKeyIndex,
                        this.blobId, objectSize, blockSizeLog, mtu);
                    blobTransferStartMessage.setTransferMode(this.transferMode);
                    this.onTransferMessagePrepared(blobTransferStartMessage);
                    break;

                case BlobTransfer.STEP_BLOB_TRANSFER_GET:
                    this.onTransferMessagePrepared(BlobTransferGetMessage.getSimple(meshAddress, this.appKeyIndex));
                    break;

                case BlobTransfer.STEP_BLOB_BLOCK_START:
                    if (this.nodeIndex === 0) {
                        if (this.firmwareParser.hasNextBlock()) {
                            this.firmwareParser.nextBlock();
                            this.log(`(pull)next block: ${this.firmwareParser.currentBlockIndex()}`);
                        } else {
                            this.log(`(pull)all blocks sent complete at: block -- ${this.firmwareParser.currentBlockIndex()}`);
                            // step = STEP_UPDATE_GET;
                            this.onTransferComplete(true, "success");
                            return;
                        }
                    }
                    const blockNumber = this.firmwareParser.currentBlockIndex();
                    const chunkSize = this.firmwareParser.getChunkSize();
                    this.onTransferMessagePrepared(BlobBlockStartMessage.getSimple(meshAddress, this.appKeyIndex,
                        blockNumber, chunkSize));
                    break;

                case BlobTransfer.STEP_BLOB_CHUNK_SENDING:
                    if (this.transferMode === TransferMode.PUSH) {
                        this.sendChunks();
                    } else {
                        this.sendMissingChunks();
                        this.log("waiting for pull request");
                        this.restartParRptWaiting();
                    }
                    break;

                case BlobTransfer.STEP_BLOB_BLOCK_GET:
                    this.onTransferMessagePrepared(BlobBlockGetMessage.getSimple(meshAddress, this.appKeyIndex));
                    break;

                default:
                    break;
            }
        }
    };

    /**
     * only used in pull mode
     * start partial report waiting task when start block send by pull  or received last partial report
     * if timeout , set state failed
     */
    private restartParRptWaiting(): void {
        clearTimeout(this.parRptWaitingTimeoutId)
        this.parRptWaitingTimeoutId = setTimeout(() => {
            this.onParRptTimeout()
        }, BlobTransfer.PARTIAL_WAITING_TIMEOUT)

        // this.delayHandler.removeCallbacks(this.PARTIAL_REPORT_WAITING_TASK);
        // this.delayHandler.postDelayed(this.PARTIAL_REPORT_WAITING_TASK, BlobTransfer.PARTIAL_WAITING_TIMEOUT);
    }

    onParRptTimeout() {
        // this.onProvisionFail("provisioning timeout");
    }

    /**
     * only used in pull mode
     * stop partial report waiting task when block send complete
     */
    private stopParRptWaiting(): void {
        clearTimeout(this.parRptWaitingTimeoutId);
        // this.delayHandler.removeCallbacks(this.PARTIAL_REPORT_WAITING_TASK);
    }

    private readonly PARTIAL_REPORT_WAITING_TASK = (): void => {
        this.onTransferComplete(false, "partial report waiting timeout");
    };

    private nextAction(): void {
        let delay: number;
        if (this.transferType === BlobTransferType.LOCAL_INIT || this.transferType === BlobTransferType.GATT_DIST) {
            delay = 0;
        } else {
            delay = 300;
        }
        // delay = 0;
        this.log(`action: ${this.getStepDesc(this.step)} -- node index -- ${this.nodeIndex}`);
        clearTimeout(this.actionTaskTimeoutId);
        this.parRptWaitingTimeoutId = setTimeout(() => {
            this.onActionTaskTimeout()
        }, delay)
        // this.delayHandler.removeCallbacks(this.ACTION_TASK);
        // this.delayHandler.postDelayed(this.ACTION_TASK, delay);
    }

    onActionTaskTimeout() {
        // this.onTransferComplete(false, "action task timeout");
    }

    private onGetBlobBlockComplete(): void {
        // check if has missing chunk
        this.log(`onGetBlobBlockComplete : ${this.mixedFormat} -- ${this.missingChunks.length}`);
        let blockSendComplete: boolean = false;
        switch (this.mixedFormat) {
            case BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING:
                this.logWithLevel("get blob block complete -> no chunks missing", LOG_LEVEL_DEBUG);
                blockSendComplete = true;
                break;
            case BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING:
                // resend all chunks
                this.logWithLevel("get blob block complete -> all chunks missing", LOG_LEVEL_DEBUG);
                this.step = BlobTransfer.STEP_BLOB_CHUNK_SENDING;
                this.firmwareParser.resetBlock();
                this.nextAction();
                break;
            case BlobBlockStatusMessage.FORMAT_SOME_CHUNKS_MISSING:
            case BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS:
                if (this.missingChunks.length === 0) {
                    this.logWithLevel("get blob block complete -> missing chunks size 0", LOG_LEVEL_DEBUG);
                    blockSendComplete = true;
                } else {
                    // resend missing chunks
                    this.logWithLevel(`get blob block complete -> resend missing chunks , size=${this.missingChunks.length}`, LOG_LEVEL_DEBUG);
                    this.printMissingChunkNumber("mixed missing chunks : ", this.missingChunks);
                    this.missingChunkIndex = 0;
                    this.sendMissingChunks();
                }
                break;
        }

        if (blockSendComplete) {
            // remove the first node in missingNodes, and check the next missing node
            if (this.missingNodes.length > 0) {
                this.missingNodes.shift();
            }
            this.step = BlobTransfer.STEP_BLOB_BLOCK_GET;
            this.nextAction();
        } else {
            this.log("block not complete : ");
        }
    }

    private printMissingChunkNumber(preDesc: string, chunks: number[]): void {
        let str = new String(preDesc);
        for (const chunkNumber of chunks) {
            str += `${chunkNumber.toString(16).toUpperCase().padStart(4, '0')}  `;
        }
        this.logWithLevel(str.toString(), LOG_LEVEL_DEBUG);
    }

    private removeFailedDevices(): void {
        const iterator = this.targetDevices.values();
        let updatingNode: TargetDevice;
        while ((updatingNode = iterator.next().value) !== undefined) {
            if (updatingNode.state === MeshUpdatingDevice.STATE_FAIL) {
                if (this.missingNodes.includes(updatingNode.address)) {
                    const index = this.missingNodes.indexOf(updatingNode.address);
                    if (index !== -1) {
                        this.missingNodes.splice(index, 1);
                    }
                }
                this.targetDevices.splice(this.targetDevices.indexOf(updatingNode), 1);
            }
        }
    }

    private onTransferMessagePrepared(meshMessage: MeshMessage): void {
        /*if (meshMessage.getDestinationAddress() !== MeshUtils.LOCAL_MESSAGE_ADDRESS) {
            // for test
            nodeIndex++;
            nextAction();
            return;
        }*/
        if (meshMessage.getOpcode() === Opcode.BLOB_BLOCK_GET) {
            meshMessage.retryCnt = 30;
        } else {
            meshMessage.retryCnt = 10; // ble stack may cache the packets and the mesh message may not receive response , so set retry count larger to wait for longer time
        }
        this.log(`mesh message prepared: ${meshMessage.constructor.name}
                opcode: 0x${meshMessage.getOpcode().toString(16).toUpperCase().padStart(4, '0')} -- dst: 0x${meshMessage.destinationAddress.toString(16).toUpperCase().padStart(4, '0')}`);
        if (this.transferCallback !== null) {
            const isMessageSent = this.transferCallback.onMeshMessagePrepared(meshMessage);
            if (!isMessageSent) {
                if (meshMessage instanceof BlobChunkTransferMessage) {
                    this.onTransferComplete(false, "chunk transfer message sent error");
                } else {
                    if (this.targetDevices.length > this.nodeIndex) {
                        this.onDeviceFail(this.targetDevices[this.nodeIndex], `mesh message sent error -- opcode: 0x${meshMessage.getOpcode().toString(16).toUpperCase().padStart(4, '0')}`);
                    }
                }
            }
        }
    }

    /**
     * device fail
     *
     * @param device updating device
     */
    private onDeviceFail(device: TargetDevice, desc: string): void {
        this.logWithLevel(`node updating fail(A): ${device.address.toString(16).toUpperCase().padStart(4, '0')} -- ${desc}`, LOG_LEVEL_DEBUG);
        device.state = MeshUpdatingDevice.STATE_FAIL;
        if (this.transferCallback !== null) {
            this.transferCallback.onTransferringDeviceFail(device.address, `node updating fail: ${device.address.toString(16).toUpperCase().padStart(4, '0')} -- ${desc}`);
        }
    }

    /**
     * device fail
     *
     * @param address updating device address
     */
    private onDeviceFailWithAddress(address: number, desc: string): void {
        this.logWithLevel(`node updating fail: ${address.toString(16).toUpperCase().padStart(4, '0')} -- ${desc}`, LOG_LEVEL_DEBUG);
        const target = this.targetDevices.find(dev => dev.address === address);
        if (target === undefined) {
            this.log("device not found in target list ");
            return;
        }
        target.state = MeshUpdatingDevice.STATE_FAIL;
        if (this.transferCallback !== null) {
            this.transferCallback.onTransferringDeviceFail(address, `node updating fail: ${address.toString(16).toUpperCase().padStart(4, '0')} -- ${desc}`);
        }
    }

    /**
     * no device success
     */
    private onTransferComplete(success: boolean, desc: string): void {
        this.logWithLevel(`blob transfer complete:  -- ${desc}`, LOG_LEVEL_DEBUG);
        this.clear();
        if (this.transferCallback !== null) {
            this.transferCallback.onTransferComplete(success, desc);
        }
    }

    public onTransferCommandFail(opcode: number): void {
        this.log("transfer command fail");
        const fail = (this.step === BlobTransfer.STEP_BLOB_TRANSFER_GET && opcode === Opcode.BLOB_TRANSFER_GET)
            || (this.step === BlobTransfer.STEP_BLOB_INFO_GET && opcode === Opcode.BLOB_INFORMATION_GET)
            || (this.step === BlobTransfer.STEP_BLOB_TRANSFER_START && opcode === Opcode.BLOB_TRANSFER_START)
            || (this.step === BlobTransfer.STEP_BLOB_BLOCK_START && opcode === Opcode.BLOB_BLOCK_START)
            || (this.step === BlobTransfer.STEP_BLOB_BLOCK_GET && opcode === Opcode.BLOB_BLOCK_GET);
        if (fail) {
            this.onDeviceFail(this.targetDevices[this.nodeIndex], "device transfer command send fail");
            this.nodeIndex++;
            this.nextAction();
        } else if ((this.step === BlobTransfer.STEP_BLOB_CHUNK_SENDING && opcode === Opcode.BLOB_CHUNK_TRANSFER)) {
            this.onTransferComplete(false, "chunk transfer command send fail");
        }
    }

    public onTransferSegmentComplete(success: boolean): void {
        if ((this.transferType === BlobTransferType.GATT_INIT || this.transferType === BlobTransferType.GATT_DIST) && this.step === BlobTransfer.STEP_BLOB_CHUNK_SENDING) {
            if (success) {
                if (this.transferMode === TransferMode.PUSH) {
                    this.sendChunks();
                }
            } else {
                this.onTransferComplete(false, "chunk send fail -- segment message send fail");
            }
        }
    }

    public onMulticastMessageComplete(opcode: number): void {
        if (this.step !== BlobTransfer.STEP_BLOB_BLOCK_START || this.transferMode !== TransferMode.PUSH) {
            this.log("multi complete -> distributor -> blob transfer -> not at blob transfer start");
            return;
        }
        this.step++;
        this.nextAction();
    }

    public onTransferNotification(message: NotificationMessage): void {
        // const opcode = Opcode.valueOf(message.opcode);
        const opcode = message.opcode;
        this.log(`message notification: ${opcode}`);
        if (this.step === BlobTransfer.STEP_IDLE) {
            this.log("notification when idle");
            return;
        }
        if (opcode === null) return;
        // const src = message.getSrc();
        const src = message.src;

        // Opcode.BLOB_BLOCK_STATUS use the address in missingNodes
        if (opcode === Opcode.BLOB_INFORMATION_STATUS || opcode === Opcode.BLOB_TRANSFER_STATUS || opcode === Opcode.BLOB_PARTIAL_BLOCK_REPORT) {
            if (this.targetDevices.length <= this.nodeIndex) {
                this.logWithLevel("node index overflow", LOG_LEVEL_DEBUG);
                return;
            }

            if (this.targetDevices[this.nodeIndex].address !== src) {
                // only report error for blob transfer message
                this.log("blob transfer unexpected notification src");
                return;
            }
        }

        switch (opcode) {
            case Opcode.BLOB_INFORMATION_STATUS:
                this.onBlobInfoStatus(message.statusMessage as BlobInfoStatusMessage);
                break;

            case Opcode.BLOB_TRANSFER_STATUS:
                this.onBlobTransferStatus(message.statusMessage as BlobTransferStatusMessage);
                break;

            case Opcode.BLOB_BLOCK_STATUS:
                this.onBlobBlockStatus(message);
                break;

            case Opcode.BLOB_PARTIAL_BLOCK_REPORT:
                this.onBlobPartialBlockReport(message.statusMessage as BlobPartialBlockReportMessage);
                break;
        }
    }

    private sendChunks(): void {
        const chunkData = this.firmwareParser.nextChunk();
        //        if (firmwareParser.currentChunkIndex() == 10){
        //            // for test, skip chunk index 10, then test resend missing chunk
        //            chunkData = firmwareParser.nextChunk();
        //        }
        const chunkIndex = this.firmwareParser.currentChunkIndex();
        if (chunkData !== null) {
            this.validateUpdatingProgress();
            const blobChunkTransferMessage = this.generateChunkTransferMessage(chunkIndex, chunkData);
            this.log(`next chunk transfer msg: ${blobChunkTransferMessage.toString()} - extendBearerMode - ${this.extendBearerMode}`);
            this.onTransferMessagePrepared(blobChunkTransferMessage);
            if (this.transferType === BlobTransferType.GATT_INIT || this.transferType === BlobTransferType.GATT_DIST) {
                const len = chunkData.length + 3;
                const isSegment = len > this.getSegmentLen();
                if (!isSegment) {
                    // if not segmented message, send next
                    this.sendChunks();
                    //                    delayHandler.postDelayed(chunkSendingTask, 100); // for test
                }
                // else , waiting for segment block ack complete
            } else {
                // for LOCAL or MESH type, send chunk by timer
                this.chunkSendingTaskTimeoutId = setTimeout(() => {
                    this.chunkSendingTask()
                }, this.getChunkSendingInterval())
            }
        } else {
            this.log(`chunks sent complete at: block -- ${this.firmwareParser.currentBlockIndex()}
                    chunk -- ${this.firmwareParser.currentChunkIndex()}`);
            this.checkMissingChunks();
        }
    }

    private getSegmentLen(): number {
        let segLen: number;
        if (GattConnection.mtu < NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG) {
            segLen = NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
        } else if (this.transferType === BlobTransferType.GATT_INIT || this.transferType === BlobTransferType.GATT_DIST) {
            segLen = NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG;
        } else {
            segLen = this.extendBearerMode === ExtendBearerMode.NONE ? NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT : NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG;
        }
        this.log(`segment len: ${segLen}`);
        return segLen;
    }

    /**
     * validate blob transfer progress
     */
    private validateUpdatingProgress(): void {
        if (this.transferMode === TransferMode.PUSH) {
            if (this.firmwareParser.validateProgress()) {
                const progress = this.firmwareParser.getProgress();
                this.log(`chunk sending progress: ${progress}`);
                this.transferCallback.onTransferProgressUpdate(progress, this.transferType);
                //            onStateUpdate(STATE_PROGRESS, "progress update", progress);
            }
        } else if (this.transferMode === TransferMode.PULL) {
            const progress = this.firmwareParser.getProgressAt(this.firmwareParser.currentBlockIndex(), this.pullMaxChunkNumber);
            if (this.pullProgress !== progress) {
                this.pullProgress = progress;
                this.transferCallback.onTransferProgressUpdate(progress, this.transferType);
            }
        }
    }

    private checkMissingChunks(): void {
        this.logWithLevel("check missing chunks (get blob block)", LOG_LEVEL_DEBUG);
        this.missingChunks = [];
        this.mixedFormat = -1;
        this.step = BlobTransfer.STEP_BLOB_BLOCK_GET;
        this.nodeIndex = 0;
        this.nextAction();
    }

    /**
     * @return -1 for no missing node, other value for the node address
     */
    private getMissingNodeAdr(): number {
        if (this.missingNodes.length === 0) {
            return -1;
        }
        return this.missingNodes[0];
    }

    private sendMissingChunks(): void {
        if (this.missingChunkIndex >= this.missingChunks.length) {
            // all missing chunk sent
            this.log(`all missing chunks sent complete: ${this.missingChunkIndex}`);
            if (this.transferMode === TransferMode.PUSH) {
                this.checkMissingChunks();
            }

            // if pull mode, check
        } else {
            const chunkNumber = this.missingChunks[this.missingChunkIndex];
            this.log(`send missing chunk at : ${this.firmwareParser.currentBlockIndex()} - ${chunkNumber}`);
            const chunkData = this.firmwareParser.chunkAt(chunkNumber);
            if (chunkData === null) {
                this.log(`chunk index overflow when resending chunk: ${chunkNumber}`);
                return;
            }
            if (this.transferMode === TransferMode.PULL) {
                if (this.pullMaxChunkNumber < chunkNumber) {
                    this.pullMaxChunkNumber = chunkNumber;
                }
                this.validateUpdatingProgress();
            }
            const blobChunkTransferMessage = this.generateChunkTransferMessage(chunkNumber, chunkData);
            this.onTransferMessagePrepared(blobChunkTransferMessage);
            this.missingChunkSendingTaskTimeoutId = setTimeout(() => {
                this.missingChunkSendingTask();
            }, this.getChunkSendingInterval());
            // this.delayHandler.removeCallbacks(this.missingChunkSendingTask);
            // this.delayHandler.postDelayed(this.missingChunkSendingTask, this.getChunkSendingInterval());
        }
    }

    /**
     * mix missing chunks
     *
     * @param chunks chunks from remote device
     */
    private mixMissingChunks(chunks: number[]): void {
        if (this.mixedFormat === BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING) return;
        if (chunks !== null) {
            for (const chunkNumber of chunks) {
                if (!this.missingChunks.includes(chunkNumber)) {
                    this.missingChunks.push(chunkNumber);
                }
            }
        }
    }

    /**
     * mix format info
     *
     * @param format format from remote device
     */
    private mixFormat(format: number): void {
        if (this.mixedFormat === BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING) {
            return;
        }
        if (this.mixedFormat === -1) {
            this.mixedFormat = format;
        } else if (this.mixedFormat !== format && format !== BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING) {
            this.mixedFormat = format;
        }
    }

    private getChunkSendingInterval(): number {
        // relay 320 ms
        let result: number;
        if (this.transferType === BlobTransferType.LOCAL_INIT) {
            result = 1;
        } else if (this.transferType === BlobTransferType.GATT_INIT || this.transferType === BlobTransferType.GATT_DIST) {
            if (this.transferMode === TransferMode.PULL) {
                result = 10;
            } else {
                result = 10; // update from 100, for resend chunk faster
            }
        } else if (this.transferMode === TransferMode.PULL) {
            result = 120;
        } else {
            // 12
            // 208
            // chunk size + opcode(1 byte)
            const chunkMsgLen = this.firmwareParser.getChunkSize() + 1;
            const unsegLen = this.getSegmentLen();
            const segLen = unsegLen + 1;
            const segmentCnt = chunkMsgLen === unsegLen ? 1 : (chunkMsgLen % segLen === 0 ? Math.floor(chunkMsgLen / segLen) : Math.floor(chunkMsgLen / segLen) + 1);
            result = segmentCnt * NetworkingController.netPktSendInterval + 240;
            //        final long min = 5 * 1000;
            // use 5000 when DLE disabled, use 300 when DLE enabled => changed to 3000
            const min = unsegLen === NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT ? 3000 : 300;
            result = Math.max(min, result);
        }
        this.log(`chunk sending interval: ${result}`);
        return result;
    }

    private readonly missingChunkSendingTask = (): void => {
        this.missingChunkIndex++;
        this.sendMissingChunks();
    };

    private readonly chunkSendingTask = (): void => {
        this.sendChunks();
    };

    private generateChunkTransferMessage(chunkNumber: number, chunkData: Uint8Array): BlobChunkTransferMessage {
        let address: number;
        if (this.transferType === BlobTransferType.LOCAL_INIT
            || this.transferType === BlobTransferType.GATT_INIT
            || this.transferType === BlobTransferType.GATT_DIST) {
            // only one device
            address = this.targetDevices[0].address; // if long packet , waiting for block ack
        } else {
            if (this.firmwareParser.getChunkSize() <= 8 && this.targetDevices.length === 1) {
                address = this.targetDevices[0].address;
            } else if (this.transferMode === TransferMode.PULL) {
                address = this.targetDevices[0].address; // for LPN
            } else {
                address = this.groupAddress;
            }
        }
        return BlobChunkTransferMessage.getSimple(address, this.appKeyIndex, chunkNumber, chunkData);
    }

    /**
     * response of {@link BlobTransferStartMessage}
     */
    private onBlobTransferStatus(transferStatusMessage: BlobTransferStatusMessage): void {
        this.log(`blob transfer status: ${transferStatusMessage.toString()}`);
        if (this.step === BlobTransfer.STEP_BLOB_TRANSFER_START || this.step === BlobTransfer.STEP_BLOB_TRANSFER_GET) {
            const status = transferStatusMessage.getStatus();
            if (status !== UpdateStatus.SUCCESS) {
                this.onDeviceFail(this.targetDevices[this.nodeIndex], "object transfer status err");
            }
            this.nodeIndex++;
            this.nextAction();
        }
    }

    /**
     * response of BLOCK_GET
     * {@link #checkMissingChunks()}
     * {@link BlobBlockStartMessage}
     */
    private onBlobBlockStatus(message: NotificationMessage): void {
        if (this.step !== BlobTransfer.STEP_BLOB_BLOCK_GET && this.step !== BlobTransfer.STEP_BLOB_BLOCK_START) {
            return;
        }
        const blobBlockStatusMessage = message.statusMessage as BlobBlockStatusMessage;
        this.log(`block status: ${blobBlockStatusMessage.toString()}`);
        const srcAddress = message.src;
        const transferStatus = blobBlockStatusMessage.getStatus() & 0xFF;
        if (transferStatus !== TransferStatus.SUCCESS) {
            this.onDeviceFailWithAddress(srcAddress, "block status err");
        } else {
            // only check chunk missing when STEP_GET_BLOB_BLOCK
            if (this.step === BlobTransfer.STEP_BLOB_BLOCK_GET || (this.step === BlobTransfer.STEP_BLOB_BLOCK_START && this.transferMode === TransferMode.PULL)) {
                const format = blobBlockStatusMessage.getFormat();
                this.log("block status: 1 ");
                this.mixFormat(format);
                this.log(`block status: 2 - mix ${this.mixedFormat}`);
                switch (format) {
                    case BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING:
                        this.logWithLevel(`all chunks missing: ${srcAddress.toString(16).toUpperCase().padStart(4, '0')}`, LOG_LEVEL_DEBUG);
                        break;

                    case BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING:
                        this.logWithLevel(`no chunks missing: ${srcAddress.toString(16).toUpperCase().padStart(4, '0')}`, LOG_LEVEL_DEBUG);
                        break;

                    case BlobBlockStatusMessage.FORMAT_SOME_CHUNKS_MISSING:
                        this.mixMissingChunks(blobBlockStatusMessage.getMissingChunks());
                        this.printMissingChunkNumber(`missing chunks(some) at ${srcAddress.toString(16).toUpperCase().padStart(4, '0')} : `, blobBlockStatusMessage.getMissingChunks());
                        break;

                    case BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS:
                        this.mixMissingChunks(blobBlockStatusMessage.getEncodedMissingChunks());
                        this.printMissingChunkNumber(`missing chunks(encoded) at ${srcAddress.toString(16).toUpperCase().padStart(4, '0')} : `, blobBlockStatusMessage.getEncodedMissingChunks());
                        break;
                }
                if (this.step === BlobTransfer.STEP_BLOB_BLOCK_START) {
                    // pull
                    this.nodeIndex++;
                    this.nextAction();
                    return;
                }
            } else {
                // block status: 3 - step = 8 -- mode PUSH
                this.log(`block status: 3 - step = ${this.step} -- mode ${this.transferMode}`);
                // STEP_BLOB_BLOCK_START complete -> local & push
                if (this.transferType === BlobTransferType.LOCAL_INIT || this.transferType === BlobTransferType.GATT_INIT) {
                    this.step++;
                    this.nextAction();
                    return;
                }
            }
        }
        this.onGetBlobBlockComplete();
        //        nodeIndex++; //  this is unicast message response, no need to increase node index
        //        nextAction();
    }

    /**
     * only used at pull mode
     */
    private onBlobPartialBlockReport(reportMessage: BlobPartialBlockReportMessage): void {
        if (this.step !== BlobTransfer.STEP_BLOB_CHUNK_SENDING) {
            this.log("partial report not at chunk sending");
            return;
        }
        const encodedMissingChunks = reportMessage.getEncodedMissingChunks();
        if (encodedMissingChunks.length === 0) {
            this.log("no missing chunks in PartialBlockReport ");
            this.stopParRptWaiting();
            this.pullMaxChunkNumber = 0;
            this.checkMissingChunks();
        } else {
            this.restartParRptWaiting();
            let missingDesc = "";
            for (const index of encodedMissingChunks) {
                missingDesc += `${index},`;
            }
            this.logWithLevel(`PartialBlockReport:blockIndex=${this.firmwareParser.currentBlockIndex()}, missingChunkSize=${encodedMissingChunks.length}, detail=${missingDesc.toString()}`, LOG_LEVEL_DEBUG);
            clearTimeout(this.missingChunkSendingTaskTimeoutId);
            // this.delayHandler.removeCallbacks(this.missingChunkSendingTask);
            this.missingChunks = encodedMissingChunks;
            this.missingChunkIndex = 0;
            this.mixedFormat = BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS;
            this.sendMissingChunks();
        }
    }

    /**
     * response of {@link BlobInfoStatusMessage}
     */
    private onBlobInfoStatus(blobInfoStatusMessage: BlobInfoStatusMessage): void {
        this.log(`object info status: ${blobInfoStatusMessage.toString()}`);
        if (this.step !== BlobTransfer.STEP_BLOB_INFO_GET) {
            this.log("not at STEP_GET_BLOB_INFO");
            return;
        }
        const blockSize = Math.pow(2, blobInfoStatusMessage.getMaxBlockSizeLog());
        let chunkSize = blobInfoStatusMessage.getMaxChunkSize();

        const pushSupported = blobInfoStatusMessage.isPushModeSupported();
        const pullSupported = blobInfoStatusMessage.isPullModeSupported();

        // use push mode when transfer to direct connected device
        const gattTransfer = this.transferType === BlobTransferType.GATT_DIST || this.transferType === BlobTransferType.GATT_INIT;
        this.log(`blob info: pushSupported - ${pushSupported} -- pullSupported: ${pullSupported} -- gattTransfer: ${gattTransfer}`);
        if (pullSupported) {
            if (pushSupported) {
                this.transferMode = gattTransfer ? TransferMode.PUSH : TransferMode.PULL;
            } else {
                this.transferMode = TransferMode.PULL;
            }
        } else if (pushSupported) {
            this.transferMode = TransferMode.PUSH;
        }
        //        this.transferMode = TransferMode.PULL;

        this.log(`refresh transfer mode: ${this.transferMode}`);

        if (pullSupported && pushSupported && this.transferMode === TransferMode.PUSH) {
            chunkSize = 208;
        }
        this.log(`chunk size : ${chunkSize} block size: ${blockSize}`);
        this.firmwareParser.resetWithParams(this.firmwareData, blockSize, chunkSize);
        this.nodeIndex++;
        this.nextAction();
    }

    /**
     * get step description
     */
    private getStepDesc(step: number): string {
        switch (step) {
            case BlobTransfer.STEP_BLOB_TRANSFER_START:
                return "blob-transfer-start";

            case BlobTransfer.STEP_BLOB_TRANSFER_GET:
                return "blob-transfer-get";

            case BlobTransfer.STEP_BLOB_INFO_GET:
                return "get-blob-info";

            case BlobTransfer.STEP_BLOB_BLOCK_START:
                return "blob-block-transfer-start";

            case BlobTransfer.STEP_BLOB_CHUNK_SENDING:
                return "blob-chunk-sending";

            case BlobTransfer.STEP_BLOB_BLOCK_GET:
                return "get-blob-block";
        }
        return "unknown";
    }

    private log(logInfo: string): void {
        this.logWithLevel(logInfo, LOG_LEVEL_DEBUG);
    }

    private logWithLevel(logInfo: string, level: number): void {
        this.transferCallback.onTransferLog(this.LOG_TAG, logInfo, level);
    }
}

export class TargetDevice {
    public address: number;

    public state: number = MeshUpdatingDevice.STATE_INITIAL;

    public constructor(address: number) {
        this.address = address;
    }
}