/********************************************************************************************************
 * @file BlobInfoGetMessage.ets
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
 * This class represents a Blob Information Get Message, which is used to request information about a blob.
 * It extends the UpdatingMessage class.
 */
export class BlobInfoGetMessage extends UpdatingMessage {
    /**
     * Creates a new BlobInfoGetMessage with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode value for the Blob Information Get Message.
     *
     * @return The opcode value for the message.
     */
    override getOpcode(): number {
        return Opcode.BLOB_INFORMATION_GET;
    }

    /**
     * Returns the response opcode value for the Blob Information Get Message.
     *
     * @return The response opcode value for the message.
     */
    override getResponseOpcode(): number {
        return Opcode.BLOB_INFORMATION_STATUS;
    }

    /**
     * Creates and returns a simple BlobInfoGetMessage with the given destination address and application key index.
     * The response max is set to 1.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @return A simple BlobInfoGetMessage object.
     */
    static getSimple(destinationAddress: number, appKeyIndex: number): BlobInfoGetMessage {
        const message = new BlobInfoGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }
}