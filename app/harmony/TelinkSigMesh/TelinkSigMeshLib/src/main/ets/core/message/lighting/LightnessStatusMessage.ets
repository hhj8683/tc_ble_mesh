/********************************************************************************************************
 * @file LightnessStatusMessage.java
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date     Sep. 30, 2017
 *
 * @par     Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
 * This class represents a status message for the lightness of a device.
 * It extends the StatusMessage class and implements the Parcelable interface.
 */
const DATA_LEN_COMPLETE = 5;
export class LightnessStatusMessage extends StatusMessage  {
    public static readonly STATUS_NAME = "LightnessStatusMessage"

    public statusName(): string {
        return LightnessStatusMessage.STATUS_NAME
    }

    public   presentLightness = 0;

    /**
     * The target value of the Lightness state (optional).
     */
    public   targetLightness = 0;

    public  remainingTime = 0;

    /**
     * tag of is complete message
     */
    public   isComplete = false;

    /**
     * Parses the byte array parameters and sets the values accordingly.
     *
     * @param params The byte array containing the parameters.
     */
    public  parse( params: Uint8Array) {
        this.presentLightness = bytes2Integer(params, 0, 2, ByteOrder.LITTLE_ENDIAN);
        if (params.length >= DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.targetLightness = bytes2Integer(params, 2, 2, ByteOrder.LITTLE_ENDIAN);
            this.remainingTime = params[4];
        }
    }
}