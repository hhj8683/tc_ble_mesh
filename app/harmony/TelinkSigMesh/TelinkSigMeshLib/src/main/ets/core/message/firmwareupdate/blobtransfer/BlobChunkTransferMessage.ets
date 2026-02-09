/********************************************************************************************************
 * @file     BlobChunkTransferMessage.ets 
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
 * @file BlobChunkTransferMessage.ets
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date     Sep. 30, 2017
 *
 * @par     Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
import { bytesToHexString } from "../../../../utils/ArrayUtils";


/**
 * This class represents a message for transferring a chunk of binary data in a block.
 * It extends the UpdatingMessage class.
 */
export class BlobChunkTransferMessage extends UpdatingMessage {

    /**
     * The chunk's number in a set of chunks in a block.
     * It is represented by 2 bytes.
     */
    private chunkNumber: number = 0;

    /**
     * Binary data from the current block.
     */
    private chunkData: Uint8Array = new Uint8Array(0);

    /**
     * Constructs a new BlobChunkTransferMessage with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode value for this message.
     *
     * @return The opcode value.
     */
    public getOpcode(): number {
        return Opcode.BLOB_CHUNK_TRANSFER;
    }

    /**
     * Returns the response opcode value for this message.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode(): number {
        return BlobChunkTransferMessage.OPCODE_INVALID;
    }

    /**
     * Returns the parameters of this message as a byte array.
     *
     * @return The parameters as a byte array.
     */
    public getParams(): Uint8Array {
        const buffer = new ArrayBuffer(2 + this.chunkData.length);
        const view = new DataView(buffer);
        view.setUint16(0, this.chunkNumber, true); // Little-endian
        for (let i = 0; i < this.chunkData.length; i++) {
            view.setUint8(2 + i, this.chunkData[i]);
        }
        return new Uint8Array(buffer);
    }

    /**
     * Returns a string representation of this BlobChunkTransferMessage.
     *
     * @return A string representation of the message.
     */
    public toString(): string {
        return `BlobChunkTransferMessage{chunkNumber=${this.chunkNumber}, chunkData=${bytesToHexString(this.chunkData)}}`;
    }

    /**
     * Sets the chunk number for this message.
     *
     * @param chunkNumber The chunk number to set.
     */
    public setChunkNumber(chunkNumber: number): void {
        this.chunkNumber = chunkNumber;
    }

    /**
     * Sets the chunk data for this message.
     *
     * @param chunkData The chunk data to set.
     */
    public setChunkData(chunkData: Uint8Array): void {
        this.chunkData = chunkData;
    }

    /**
     * Returns a BlobChunkTransferMessage object with the specified parameters.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     * @param chunkNumber The chunk number.
     * @param chunkData The chunk data.
     * @return The BlobChunkTransferMessage object.
     */
    public static getSimple(
        destinationAddress: number,
        appKeyIndex: number,
        chunkNumber: number,
        chunkData: Uint8Array
    ): BlobChunkTransferMessage {
        const message = new BlobChunkTransferMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.setChunkNumber(chunkNumber);
        message.setChunkData(chunkData);
        return message;
    }
}