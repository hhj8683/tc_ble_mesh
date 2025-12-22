/********************************************************************************************************
 * @file BlobTransferStartMessage.ets
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

import { UpdatingMessage } from '../UpdatingMessage';
import { Opcode } from '../../Opcode';
import { TransferMode } from './TransferMode';

/**
 * This class represents a message used to start a BLOB transfer.
 * The message contains information such as the transfer mode, BLOB identifier, BLOB size, block size, and client MTU size.
 * It extends the UpdatingMessage class.
 */
export class BlobTransferStartMessage extends UpdatingMessage {
    /**
     * The transfer mode for the BLOB transfer.
     * It is represented by the higher 2 bits in the first byte of the message.
     */
    private transferMode: TransferMode = TransferMode.PUSH;

    /**
     * The identifier for the BLOB.
     * It is a 64-bit value.
     */
    private blobId: number = 0;

    /**
     * The size of the BLOB in octets.
     * It is a 32-bit value.
     */
    private blobSize: number = 0;

    /**
     * The block size for the transfer.
     * It is an 8-bit value.
     */
    private blockSizeLog: number = 0;

    /**
     * The maximum transmission unit (MTU) size supported by the client.
     */
    private clientMTUSize: number = 0;

    /**
     * Constructs a BlobTransferStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a BlobTransferStartMessage object with the specified parameters.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @param blobId The BLOB identifier.
     * @param blobSize The size of the BLOB in octets.
     * @param blockSizeLog The block size for the transfer.
     * @param clientMTUSize The maximum transmission unit (MTU) size supported by the client.
     * @returns The created BlobTransferStartMessage object.
     */
    public static getSimple(
        destinationAddress: number,
        appKeyIndex: number,
        blobId: number,
        blobSize: number,
        blockSizeLog: number,
        clientMTUSize: number
    ): BlobTransferStartMessage {
        const message = new BlobTransferStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.blobId = blobId;
        message.blobSize = blobSize;
        message.blockSizeLog = blockSizeLog;
        message.clientMTUSize = clientMTUSize;
        return message;
    }

    /**
     * Returns the opcode for the message, which is Opcode.BLOB_TRANSFER_START.
     *
     * @returns The opcode for the message.
     */
    public getOpcode(): number {
        return Opcode.BLOB_TRANSFER_START;
    }

    /**
     * Returns the response opcode for the message, which is Opcode.BLOB_TRANSFER_STATUS.
     *
     * @returns The response opcode for the message.
     */
    public getResponseOpcode(): number {
        return Opcode.BLOB_TRANSFER_STATUS;
    }

    /**
     * Returns the parameters of the message as a byte array.
     * The parameters include the transfer mode, blob ID, blob size, block size, and client MTU size.
     *
     * @returns The parameters of the message as a byte array.
     */
    public getParams(): Uint8Array {
        const buffer = new ArrayBuffer(16);
        const view = new DataView(buffer);
        view.setUint8(0, (this.transferMode << 6) & 0xFF);
        view.setBigUint64(1, BigInt(this.blobId), true); // Little-endian
        view.setUint32(9, this.blobSize, true); // Little-endian
        view.setUint8(13, this.blockSizeLog);
        view.setUint16(14, this.clientMTUSize, true); // Little-endian
        return new Uint8Array(buffer);
    }

    /**
     * Sets the transfer mode for the BLOB transfer.
     *
     * @param transferMode The transfer mode to set.
     */
    public setTransferMode(transferMode: TransferMode): void {
        this.transferMode = transferMode;
    }

    /**
     * Sets the BLOB identifier.
     *
     * @param blobId The BLOB identifier to set.
     */
    public setBlobId(blobId: number): void {
        this.blobId = blobId;
    }

    /**
     * Sets the size of the BLOB in octets.
     *
     * @param blobSize The size of the BLOB to set.
     */
    public setBlobSize(blobSize: number): void {
        this.blobSize = blobSize;
    }

    /**
     * Sets the block size for the transfer.
     *
     * @param blockSizeLog The block size to set.
     */
    public setBlockSizeLog(blockSizeLog: number): void {
        this.blockSizeLog = blockSizeLog;
    }

    /**
     * Sets the maximum transmission unit (MTU) size supported by the client.
     *
     * @param clientMTUSize The client MTU size to set.
     */
    public setClientMTUSize(clientMTUSize: number): void {
        this.clientMTUSize = clientMTUSize;
    }
}