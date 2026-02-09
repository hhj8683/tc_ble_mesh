/********************************************************************************************************
 * @file     BlobBlockStartMessage.ets 
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
 * @file BlobBlockStartMessage.ets
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
 * This class represents a message used to start the transfer of a blob block.
 * It extends the UpdatingMessage class.
 * The message contains the block number and chunk size of the incoming block.
 */
export class BlobBlockStartMessage extends UpdatingMessage {
    /**
     * The block number of the incoming block.
     * It is represented by 2 bytes.
     */
    private blockNumber: number = 0;
    
    /**
     * The chunk size (in octets) for the incoming block.
     * It is represented by 2 bytes.
     */
    private chunkSize: number = 0;

    /**
     * Creates a new BlobBlockStartMessage with the specified destination address and application key index.
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode of the message.
     * @returns The opcode of the message.
     */
    public getOpcode(): number {
        return Opcode.BLOB_BLOCK_START;
    }

    /**
     * Returns the opcode of the response message.
     * @returns The opcode of the response message.
     */
    public getResponseOpcode(): number {
        return Opcode.BLOB_BLOCK_STATUS;
    }

    /**
     * Returns the parameters of the message as a byte array.
     * @returns The parameters of the message as a byte array.
     */
    public getParams(): Uint8Array {
        const buffer = new ArrayBuffer(4);
        const view = new DataView(buffer);
        view.setUint16(0, this.blockNumber, true); // Little-endian
        view.setUint16(2, this.chunkSize, true);   // Little-endian
        return new Uint8Array(buffer);
    }

    /**
     * Sets the block number of the incoming block.
     * @param blockNumber The block number of the incoming block.
     */
    public setBlockNumber(blockNumber: number): void {
        this.blockNumber = blockNumber;
    }

    /**
     * Sets the chunk size of the incoming block.
     * @param chunkSize The chunk size of the incoming block.
     */
    public setChunkSize(chunkSize: number): void {
        this.chunkSize = chunkSize;
    }

    /**
     * Creates and returns a simple BlobBlockStartMessage with the specified destination address,
     * application key index, block number, and chunk size.
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @param blockNumber The block number of the incoming block.
     * @param chunkSize The chunk size of the incoming block.
     * @returns A simple BlobBlockStartMessage with the specified parameters.
     */
    public static getSimple(
        destinationAddress: number,
        appKeyIndex: number,
        blockNumber: number,
        chunkSize: number
    ): BlobBlockStartMessage {
        const message = new BlobBlockStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.setBlockNumber(blockNumber);
        message.setChunkSize(chunkSize);
        return message;
    }
}