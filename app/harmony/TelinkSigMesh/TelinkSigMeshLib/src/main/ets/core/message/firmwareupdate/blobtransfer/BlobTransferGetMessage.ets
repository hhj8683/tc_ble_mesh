/********************************************************************************************************
 * @file     BlobTransferGetMessage.ets 
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
 * @file BlobTransferGetMessage.ets
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
 * This class represents a BlobTransferGetMessage, which is used to request a blob transfer from a destination address
 * to a specified appKeyIndex. It extends the UpdatingMessage class.
 */
export class BlobTransferGetMessage extends UpdatingMessage {
    /**
     * Creates a new instance of BlobTransferGetMessage with the specified destination address and appKeyIndex.
     *
     * @param destinationAddress The destination address to send the blob transfer request to.
     * @param appKeyIndex The index of the app key to be used for the blob transfer.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode value for the BlobTransferGetMessage.
     *
     * @return The opcode value for the BlobTransferGetMessage.
     */
    public getOpcode(): number {
        return Opcode.BLOB_TRANSFER_GET;
    }

    /**
     * Returns the response opcode value for the BlobTransferGetMessage.
     *
     * @return The response opcode value for the BlobTransferGetMessage.
     */
    public getResponseOpcode(): number {
        return Opcode.BLOB_TRANSFER_STATUS;
    }

    /**
     * Creates and returns a simple BlobTransferGetMessage with the specified destination address and appKeyIndex.
     * The response max is set to 1 by default.
     *
     * @param destinationAddress The destination address to send the blob transfer request to.
     * @param appKeyIndex The index of the app key to be used for the blob transfer.
     * @return A simple BlobTransferGetMessage with the specified destination address and appKeyIndex.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): BlobTransferGetMessage {
        const message = new BlobTransferGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }
}