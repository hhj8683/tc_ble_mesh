/********************************************************************************************************
 * @file     SceneRegisterStatusMessage.ets 
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
 * @file SceneRegisterStatusMessage.ets
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
 * This class represents a scene register status message.
 * It extends the StatusMessage class and implements the Parcelable interface.
 * It contains information about the status code, current scene, and scenes.
 */
export class SceneRegisterStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "SceneRegisterStatusMessage"

    public statusName(): string {
        return SceneRegisterStatusMessage.STATUS_NAME
    }

    public statusCode = 0 // The status code of the message
    public currentScene = 0; // The current scene
    public scenes: number[] = []; // An array of scenes

    /**
     * Parses the byte array and sets the values of the status code, current scene, and scenes.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.statusCode = params[index++];
        this.currentScene = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        let rst = params.length - index;
        if (rst > 0 && rst % 2 == 0) {
            let size = rst / 2
            this.scenes = []
            for (let i = 0; i < size; i++) {
                this.scenes.push(bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN))
                index += 2;
            }
        }
    }
}
