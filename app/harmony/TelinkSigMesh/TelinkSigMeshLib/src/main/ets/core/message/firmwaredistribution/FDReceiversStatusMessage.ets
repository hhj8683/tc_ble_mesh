/********************************************************************************************************
 * @file     FDReceiversStatusMessage.ets 
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
 * @file FDReceiversStatusMessage.ets
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

import { StatusMessage } from '../../message/StatusMessage';
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';

/**
 * This class represents a status message for firmware distribution receivers.
 * It extends the StatusMessage class and contains the status code and the number of entries in the distribution receivers list.
 */
export class FDReceiversStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FDReceiversStatusMessage"

    public statusName(): string {
        return FDReceiversStatusMessage.STATUS_NAME
    }

    /**
     * Status Code for the requesting message
     * 1 byte
     */
    private status: number = 0;

    /**
     * Receivers List Count
     * The number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    private receiversListCount: number = 0;

    /**
     * Default constructor for the FDReceiversStatusMessage class.
     */
    constructor() {
        super();
    }

    /**
     * Parses the byte array to extract the status code and receivers list count.
     *
     * @param params The byte array containing the status code and receivers list count.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.status = params[index++] & 0xFF;
        this.receiversListCount = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

    /**
     * Returns the status code.
     *
     * @return The status code.
     */
    public getStatus(): number {
        return this.status;
    }

    /**
     * Returns the number of entries in the distribution receivers list.
     *
     * @return The number of entries in the distribution receivers list.
     */
    public getReceiversListCount(): number {
        return this.receiversListCount;
    }

    /**
     * Returns a string representation of the FDReceiversStatusMessage object.
     *
     * @return A string representation of the FDReceiversStatusMessage object.
     */
    public toString(): string {
        return `FirmwareDistributionReceiversStatus{status=${this.status}, receiversListCount=${this.receiversListCount}}`;
    }
}