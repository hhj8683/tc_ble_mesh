/********************************************************************************************************
 * @file     BlobTransferStatusMessage.ets 
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
 * @file BlobTransferStatusMessage.ets
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

import { StatusMessage } from "../../../message/StatusMessage";
import { ByteOrder, bytes2Long, bytes2Integer } from '../../../../utils/ArrayUtils';
import { parseMissingBitField } from '../../../../utils/MeshUtils';

/**
 * This class represents a Blob Transfer Status Message, which is a type of Status Message.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 * The Blob Transfer Status Message contains information about the status, transfer mode, transfer phase,
 * blob identifier, blob size, block size log, MTU size, and a bit field indicating blocks that were not received.
 */
export class BlobTransferStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "BlobTransferStatusMessage"

    public statusName(): string {
        return BlobTransferStatusMessage.STATUS_NAME
    }

    /**
     * Status Code for the requesting message
     * lower 4 bits in first byte
     */
    private status: number = 0;

    /**
     * BLOB transfer mode
     * higher 2 bits in first byte
     */
    private transferMode: number = 0;

    /**
     * Transfer phase
     * 8 bits
     */
    private transferPhase: number = 0;

    /**
     * BLOB identifier (Optional)
     * 64 bits
     */
    private blobId = 0; // Using BigInt for 64-bit value

    /**
     * BLOB size in octets
     * If the BLOB ID field is present, then the BLOB Size field may be present;
     * otherwise, the BLOB Size field shall not be present.
     * 32 bits
     */
    private blobSize: number = 0;

    /**
     * Indicates the block size
     * 8 bits
     * present if blobSize is present
     */
    private blockSizeLog: number = 0;

    /**
     * MTU size in octets
     * 16 bits
     * present if blobSize is present
     */
    private transferMTUSize: number = 0;

    /**
     * Bit field indicating blocks that were not received
     * length: Variable, currently 64 bits max
     * present if blobSize is present
     */
    private blocksNotReceived: Array<number> = [];

    /**
     * Default constructor for the BlobTransferStatusMessage class.
     */
    constructor() {
        super();
    }

    /**
     * Parses the byte array and sets the values of the status.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.status = params[index] & 0x0F;
        this.transferMode = (params[index++] >> 6) & 0x03;
        this.transferPhase = params[index++];

        if (params.length < 10) return;

        this.blobId = bytes2Long(params, index, 8, ByteOrder.LITTLE_ENDIAN);
        index += 8;

        if (params.length === 10) return;

        this.blobSize = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;
        this.blockSizeLog = params[index++] & 0xFF;
        this.transferMTUSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.blocksNotReceived = parseMissingBitField(params, index);
    }

    /**
     * Returns the status of the firmware metadata.
     *
     * @return The status of the firmware metadata.
     */
    public getStatus(): number {
        return this.status;
    }

    /**
     * Returns the mode of the transfer.
     *
     * @return The mode of the transfer.
     */
    public getTransferMode(): number {
        return this.transferMode;
    }

    /**
     * Returns the phase of the transfer.
     *
     * @return The phase of the transfer.
     */
    public getTransferPhase(): number {
        return this.transferPhase;
    }

    /**
     * Returns the blob id.
     *
     * @return The blob id.
     */
    public getBlobId(): number {
        return this.blobId;
    }

    /**
     * Returns the blob size.
     *
     * @return The blob size.
     */
    public getBlobSize(): number {
        return this.blobSize;
    }

    /**
     * Returns the block size log.
     *
     * @return The block size log.
     */
    public getBlockSizeLog(): number {
        return this.blockSizeLog;
    }

    /**
     * Returns the mtu size.
     *
     * @return The mtu size.
     */
    public getTransferMTUSize(): number {
        return this.transferMTUSize;
    }

    /**
     * Returns the missing blocks.
     *
     * @return The missing blocks.
     */
    public getBlocksNotReceived(): Array<number> {
        return this.blocksNotReceived;
    }

    /**
     * Returns a string representation of the object.
     *
     * @return A string representation of the object.
     */
    public toString(): string {
        return `BlobTransferStatusMessage{status=${this.status}, transferMode=${this.transferMode}, transferPhase=${this.transferPhase}, blobId=0x${this.blobId.toString(16)}, blobSize=${this.blobSize}, blockSizeLog=${this.blockSizeLog}, transferMTUSize=${this.transferMTUSize}, blocksNotReceived=${this.blocksNotReceived}}`;
    }
}