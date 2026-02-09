/********************************************************************************************************
 * @file     CtlTemperatureSetMessage.ets 
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
 * @file CtlTemperatureSetMessage.ets
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
import { ByteOrder, num2bytes } from "../../../utils/ArrayUtils";
import { GenericMessage } from "../generic/GenericMessage";
import { Opcode } from "../Opcode";

/**
 * This class represents a message for setting the temperature in a CLT (Color Light Temperature) device.
 * It can be used for both CLT Temperature Set and CLT Temperature Set No Ack commands.
 * The message can be sent with or without acknowledgement.
 * The message includes the temperature value and the delta UV value.
 * It also includes a transaction ID, transition time, and delay.
 * The message can be marked as complete to include all parameters, or incomplete to exclude the transition time and delay.
 * The message extends the GenericMessage class.
 *
 * @author kee
 * @see GenericMessage
 * @since 2019/8/14
 */
export class CtlTemperatureSetMessage extends GenericMessage {
    public temperature = 0;
    public deltaUV = 0;
    public tid = 0;
    public transitionTime = 0;
    public delay = 0;
    public ack = false;
    public isComplete = false;

    /**
     * Creates a new CtlTemperatureSetMessage with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The application key index.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.tidPosition = 4
    }

    /**
     * Creates a simple CtlTemperatureSetMessage with the given parameters.
     *
     * @param address     The destination address of the message.
     * @param appKeyIndex The application key index.
     * @param temperature The temperature value to set.
     * @param deltaUV     The delta UV value to set.
     * @param ack         Whether to include acknowledgement or not.
     * @param rspMax      The maximum number of responses expected.
     * @return The created CtlTemperatureSetMessage.
     */
    public static getSimple(address: number, appKeyIndex: number, temperature: number, deltaUV: number, ack: boolean,
        rspMax: number): CtlTemperatureSetMessage {
        let message = new CtlTemperatureSetMessage(address, appKeyIndex);
        message.temperature = temperature;
        message.deltaUV = deltaUV;
        message.ack = ack;
        message.responseMax = rspMax
        return message;
    }

    /**
     * Gets the opcode for the response message.
     * If acknowledgement is enabled, returns the opcode for LIGHT_CTL_TEMP_STATUS.
     * Otherwise, returns the opcode from the super class.
     *
     * @return The opcode for the response message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.LIGHT_CTL_TEMP_STATUS : super.getResponseOpcode();
    }

    /**
     * Gets the opcode for the message.
     * If acknowledgement is enabled, returns the opcode for LIGHT_CTL_TEMP_SET.
     * Otherwise, returns the opcode for LIGHT_CTL_TEMP_SET_NOACK.
     *
     * @return The opcode for the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.LIGHT_CTL_TEMP_SET : Opcode.LIGHT_CTL_TEMP_SET_NOACK
    }

    /**
     * Gets the parameters of the message as a byte array.
     * If the message is marked as complete, returns a byte array with all parameters.
     * Otherwise, returns a byte array without the transition time and delay.
     *
     * @return The parameters of the message as a byte array.
     */
    public getParams() {
        let re = new Uint8Array(this.isComplete ? 7 : 5)
        let offset = 0
        re.set(num2bytes(this.temperature, 2, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 2
        re.set(num2bytes(this.deltaUV, 2, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 2
        re[offset++] = this.tid
        if (this.isComplete) {
            re[offset++] = this.transitionTime
            re[offset++] = this.delay
        }

        return re
    }
}