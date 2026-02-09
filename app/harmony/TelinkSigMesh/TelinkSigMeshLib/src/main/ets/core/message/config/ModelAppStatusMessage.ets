/********************************************************************************************************
 * @file     ModelAppStatusMessage.ets 
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
 * @file ModelAppStatusMessage.ets
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
import { ByteOrder, bytes2Integer } from "../../../utils/ArrayUtils";
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Model App Status is an unacknowledged message used to report a status for the requesting message,
 * based on the element address, the AppKeyIndex identifying the AppKey on the AppKey List, and the ModelIdentifier.
 * The ModelAppStatusMessage class is a Parcelable class that extends the StatusMessage class.
 * It represents a message containing the status of a model application.
 * The class provides methods to parse the message parameters from a byte array,
 * as well as getters to retrieve the status, element address, app key index, and model identifier.
 */
const MODEL_STATUS_SIG_LEN = 7;

const MODEL_STATUS_VENDOR_LEN = 9;

export class ModelAppStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "ModelAppStatusMessage"

    public statusName(): string {
        return ModelAppStatusMessage.STATUS_NAME
    }
    public status = 0;
    public elementAddress = 0
    public appKeyIndex = 0;
    /**
     * 2 or 4 bytes
     */
    public  modelIdentifier = 0;

    /**
     * Parses the message parameters from a byte array.
     * It sets the status, element address, app key index, and model identifier based on the byte array values.
     *
     * @param params The byte array containing the message parameters.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index++];
        this.elementAddress = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.appKeyIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        let modelIdLen: number;
        if (params.length == MODEL_STATUS_SIG_LEN) {
            modelIdLen = 2;
        } else {
            modelIdLen = 4;
        }
        this.modelIdentifier = bytes2Integer(params, index, modelIdLen, ByteOrder.LITTLE_ENDIAN);
    }
}