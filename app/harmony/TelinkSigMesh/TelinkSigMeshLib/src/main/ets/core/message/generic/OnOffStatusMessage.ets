/********************************************************************************************************
 * @file     OnOffStatusMessage.ets 
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
 * @file OnOffStatusMessage.ets
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
import { StatusMessage } from "../StatusMessage";

/**
 * This class represents a message for the on/off status of a device.
 * It extends the StatusMessage class and implements the Parcelable interface.
 */

const DATA_LEN_COMPLETE = 3;

export class OnOffStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "OnOffStatusMessage"

    public statusName(): string {
        return OnOffStatusMessage.STATUS_NAME
    }

    // public statusName: string = this.constructor.name
    // public statusName: string = "OnOffStatusMessage"
    public presentOnOff = 0;
    public targetOnOff = 0;
    public remainingTime = 0;
    public isComplete = false;

    /**
     * Parses the given byte array to initialize the attributes of the OnOffStatusMessage object.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        this.presentOnOff = params[0];
        if (params.length >= DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetOnOff = params[1];
            this.remainingTime = params[2];
        }
    }
}