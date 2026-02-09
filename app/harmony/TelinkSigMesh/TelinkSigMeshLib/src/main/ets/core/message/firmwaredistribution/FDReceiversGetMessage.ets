/********************************************************************************************************
 * @file     FDReceiversGetMessage.ets 
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
 * @file FDReceiversGetMessage.ets
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

import { UpdatingMessage } from '../firmwareupdate/UpdatingMessage';
import { Opcode } from "../Opcode";

/**
 * This class represents a message used to request the Firmware Distribution Receivers List from a server.
 * It extends the UpdatingMessage class and includes the necessary parameters for the request.
 */
export class FDReceiversGetMessage extends UpdatingMessage {
    /**
     * first index
     * Index of the first requested entry from the Distribution Receivers List state
     * 2 bytes
     */
    public firstIndex: number = 0;

    /**
     * Entries Limit
     * Maximum number of entries that the server includes in a Firmware Distribution Receivers List message
     * 2 bytes
     */
    public entriesLimit: number = 0;

    /**
     * Constructs a new FDReceiversGetMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDReceiversGetMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     * @param firstIndex The index of the first requested entry.
     * @param entriesLimit The maximum number of entries to include.
     * @return The created FDReceiversGetMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, firstIndex: number, entriesLimit: number): FDReceiversGetMessage {
        const message = new FDReceiversGetMessage(destinationAddress, appKeyIndex);
        message.firstIndex = firstIndex;
        message.entriesLimit = entriesLimit;
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value for the FDReceiversGetMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_RECEIVERS_GET;
    }

    /**
     * Gets the response opcode value for the FDReceiversGetMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_RECEIVERS_LIST;
    }

    /**
     * Gets the byte array representation of the parameters in the FDReceiversGetMessage.
     *
     * @return The byte array representation of the parameters.
     */
    public override getParams(): Uint8Array {
        const buffer = new ArrayBuffer(4);
        const view = new DataView(buffer);
        view.setUint16(0, this.firstIndex, true); // little-endian
        view.setUint16(2, this.entriesLimit, true); // little-endian
        return new Uint8Array(buffer);
    }
}