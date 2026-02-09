/********************************************************************************************************
 * @file     FDFirmwareGetByIndexMessage.ets 
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
 * @file FDFirmwareGetByIndexMessage.ets
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
 * The Firmware Distribution Upload Start message is an acknowledged message sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Start message is a Firmware Distribution Upload Status message.
 */
export class FDFirmwareGetByIndexMessage extends UpdatingMessage {
    /**
     * Distribution Firmware Image Index
     * Index of the entry in the Firmware Images List state
     * 2 bytes
     */
    public distImageIndex: number = 0;

    /**
     * Constructs a new FDFirmwareGetByIndexMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address to send the message to.
     * @param appKeyIndex The index of the application key to use for encryption and decryption.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDFirmwareGetByIndexMessage object with the specified destination address and application key index.
     * This method sets the response maximum to 1.
     *
     * @param destinationAddress The destination address to send the message to.
     * @param appKeyIndex The index of the application key to use for encryption and decryption.
     * @return A simple FDFirmwareGetByIndexMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDFirmwareGetByIndexMessage {
        const message = new FDFirmwareGetByIndexMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value of the FDFirmwareGetByIndexMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_FIRMWARE_GET;
    }

    /**
     * Gets the response opcode value of the FDFirmwareGetByIndexMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_UPLOAD_STATUS;
    }
}