/********************************************************************************************************
 * @file BlobBlockGetMessage.ets
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

/**
 * This class represents a BlobBlockGetMessage, which is used to request a specific block of data from a blob.
 * It extends the UpdatingMessage class.
 */
export class BlobBlockGetMessage extends UpdatingMessage {

    /**
     * Creates and returns a simple BlobBlockGetMessage with the given destination address and application key index.
     * This message has a response maximum of 1.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @return A BlobBlockGetMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): BlobBlockGetMessage {
        const message = new BlobBlockGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Constructs a BlobBlockGetMessage with the given destination address and application key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode for the BlobBlockGetMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.BLOB_BLOCK_GET;
    }

    /**
     * Returns the response opcode for the BlobBlockGetMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.BLOB_BLOCK_STATUS;
    }
}