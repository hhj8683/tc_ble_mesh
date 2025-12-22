/********************************************************************************************************
 * @file BlobTransferCancelMessage.ets
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

/**
 * This class represents a message used to cancel a blob transfer.
 * It extends the UpdatingMessage class.
 */
export class BlobTransferCancelMessage extends UpdatingMessage {
    /**
     * The identifier of the blob to be cancelled.
     * It is a 64-bit value.
     */
    private blobId: number = 0;

    /**
     * Creates a new BlobTransferCancelMessage with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a new BlobTransferCancelMessage with the specified destination address, application key index, and blob ID.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @param blobId The ID of the blob to be cancelled.
     * @return The created BlobTransferCancelMessage.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, blobId: number): BlobTransferCancelMessage {
        const message = new BlobTransferCancelMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.setBlobId(blobId);
        return message;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode value.
     */
    public getOpcode(): number {
        return Opcode.BLOB_TRANSFER_CANCEL;
    }

    /**
     * Gets the response opcode of the message.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode(): number {
        return Opcode.BLOB_TRANSFER_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters as a byte array.
     */
    public getParams(): Uint8Array {
        const buffer = new ArrayBuffer(16);
        const view = new DataView(buffer);
        view.setBigUint64(0, BigInt(this.blobId), true); // Little-endian
        return new Uint8Array(buffer);
    }

    /**
     * Sets the blob ID of the message.
     *
     * @param blobId The blob ID to be set.
     */
    public setBlobId(blobId: number): void {
        this.blobId = blobId;
    }
}