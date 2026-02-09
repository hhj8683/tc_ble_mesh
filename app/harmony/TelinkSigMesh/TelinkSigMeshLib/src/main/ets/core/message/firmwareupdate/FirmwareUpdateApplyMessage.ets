/********************************************************************************************************
 * @file     FirmwareUpdateApplyMessage.ets 
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
 * @file FirmwareUpdateApplyMessage.ets
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
 * Represents a firmware update apply message.
 * Extends the UpdatingMessage class.
 */
export class FirmwareUpdateApplyMessage extends UpdatingMessage {
    /**
     * Creates a simple firmware update apply message with the specified destination address and app key index.
     * Sets the response max to 1.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     * @returns A FirmwareUpdateApplyMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FirmwareUpdateApplyMessage {
        let message = new FirmwareUpdateApplyMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Creates a firmware update apply message with the specified destination address and app key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Gets the opcode of the firmware update apply message.
     *
     * @returns The opcode value of the firmware update apply message.
     */
    public getOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_APPLY;
    }

    /**
     * Gets the response opcode of the firmware update apply message.
     *
     * @returns The response opcode value of the firmware update apply message.
     */
    public getResponseOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_STATUS;
    }
}