/********************************************************************************************************
 * @file     FDReceiversDeleteAllMessage.ets 
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
 * @file FDReceiversDeleteAllMessage.ets
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
 * This class represents a message used to delete all FD receivers.
 * It extends the UpdatingMessage class.
 */
export class FDReceiversDeleteAllMessage extends UpdatingMessage {
    /**
     * Constructs a new FDReceiversDeleteAllMessage object with the specified destination address and app key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDReceiversDeleteAllMessage object with the specified destination address and app key index.
     * Sets the response max to 1.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     * @return A simple FDReceiversDeleteAllMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDReceiversDeleteAllMessage {
        const message = new FDReceiversDeleteAllMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_RECEIVERS_DELETE_ALL;
    }

    /**
     * Gets the response opcode of the message.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_RECEIVERS_STATUS;
    }
}