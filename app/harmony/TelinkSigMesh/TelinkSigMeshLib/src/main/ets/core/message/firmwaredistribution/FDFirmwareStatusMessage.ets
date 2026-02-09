/********************************************************************************************************
 * @file     FDFirmwareStatusMessage.ets 
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
 * @file FDFirmwareStatusMessage.ets
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

import { StatusMessage } from "../../message/StatusMessage";
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';

/**
 * This class represents a firmware status message for a Firmware Distribution Server.
 * It extends the StatusMessage class and contains information about the status code, entry count, distribution firmware image index,
 * and firmware ID.
 */
export class FDFirmwareStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FDFirmwareStatusMessage"

    public statusName(): string {
        return FDFirmwareStatusMessage.STATUS_NAME
    }

    /**
     * Status Code for the requesting message.
     * It is represented by 1 byte.
     */
    public status: number = 0;

    /**
     * Entry Count.
     * It represents the number of firmware images stored on the Firmware Distribution Server.
     * It is represented by 2 bytes.
     */
    public entryCount: number = 0;

    /**
     * Distribution Firmware Image Index.
     * It represents the index of the firmware image in the Firmware Images List state.
     * It is represented by 2 bytes.
     */
    public distImageIndex: number = 0;

    /**
     * Firmware ID.
     * It identifies the associated firmware image.
     * It has a variable length.
     */
    public firmwareID: Uint8Array | null = null;

    /**
     * Default constructor for FDFirmwareStatusMessage.
     */
    constructor() {
        super();
    }

    /**
     * Parses the byte array and sets the values of the FDFirmwareStatusMessage object.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.status = params[index++] & 0xFF;
        this.entryCount = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.distImageIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        if (params.length === 5) return;
        this.firmwareID = new Uint8Array(params.buffer, index, params.length - index);
    }
}