/********************************************************************************************************
 * @file     AppKeyStatusMessage.ets 
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
 * @file AppKeyStatusMessage.ets
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
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';
import { StatusMessage } from '../StatusMessage';

/**
 * The Config AppKey Status is an unacknowledged message used to report a status for the requesting message,
 * based on the NetKey Index identifying the NetKey on the NetKey List and on the AppKey Index identifying the AppKey on the AppKey List.
 */
export class AppKeyStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "AppKeyStatusMessage"

    public statusName(): string {
        return AppKeyStatusMessage.STATUS_NAME
    }
    /**
     * 1 byte
     * Status Code for the requesting message
     */
    public status: number = 0
    /**
     * 12 bits
     */
    public netKeyIndex: number = 0
    /**
     * 12 bits
     */
    public appKeyIndex = 0;

    public parse(params: Uint8Array) {
        this.status = params[0];

        let netAppKeyIndex = bytes2Integer(params, 1, 3, ByteOrder.LITTLE_ENDIAN);

        this.netKeyIndex = netAppKeyIndex & 0x0FFF;
        this.appKeyIndex = (netAppKeyIndex >> 12) & 0x0FFF;
    }
}

