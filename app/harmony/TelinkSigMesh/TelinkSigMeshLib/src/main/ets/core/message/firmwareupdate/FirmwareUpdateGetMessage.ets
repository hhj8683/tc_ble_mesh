/********************************************************************************************************
 * @file     FirmwareUpdateGetMessage.ets 
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
 * @file FirmwareUpdateGetMessage.ets
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

import { UpdatingMessage } from './UpdatingMessage';
import { Opcode } from "../Opcode";

/**
 * This class represents a firmware update get message, which is used to request information about a firmware update.
 * It extends the UpdatingMessage class.
 */
export class FirmwareUpdateGetMessage extends UpdatingMessage {
    /**
     * Creates a simple firmware update get message with the specified destination address and application key index.
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @returns The created FirmwareUpdateGetMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FirmwareUpdateGetMessage {
        let message = new FirmwareUpdateGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Constructs a new FirmwareUpdateGetMessage with the specified destination address and application key index.
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Gets the opcode for the firmware update get message.
     * @returns The opcode for the firmware update get message.
     */
    public getOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_GET;
    }

    /**
     * Gets the response opcode for the firmware update get message.
     * @returns The response opcode for the firmware update get message.
     */
    public getResponseOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_STATUS;
    }
}