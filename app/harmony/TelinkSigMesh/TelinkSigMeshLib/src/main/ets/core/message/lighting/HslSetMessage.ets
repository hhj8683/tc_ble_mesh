/********************************************************************************************************
 * @file HslSetMessage.ets
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
import { num2bytes } from '../../../utils/ArrayUtils';
import { GenericMessage } from '../generic/GenericMessage';
import { Opcode } from '../Opcode';


/**
 * include HSL set and HSL set no ack
 * This class represents a HSL Set message, which is used to set the lightness, hue, and saturation values of a device.
 * It extends the GenericMessage class.
 * The message can be configured to include a transaction id, transition time, and delay.
 * It can also be configured to request an acknowledgment from the receiving device.
 */
export class HslSetMessage extends GenericMessage {
    private lightness: number = 0; // The lightness value to set
    private hue: number = 0; // The hue value to set
    private saturation = 0; // The saturation value to set
    private tid = 0; // The transaction id
    private transitionTime = 0; // The transition time
    private delay = 0; // The delay
    private ack = false; // Flag to request acknowledgment
    private isComplete = false; // Flag to indicate if the message is complete

    /**
     * Constructs a simple HSL Set message with the given parameters.
     *
     * @param address     The destination address of the message
     * @param appKeyIndex The application key index
     * @param lightness   The lightness value to set
     * @param hue         The hue value to set
     * @param saturation  The saturation value to set
     * @param ack         Flag to request acknowledgment
     * @param rspMax      The maximum number of responses expected
     * @return The constructed HslSetMessage
     */
    public static getSimple(address: number, appKeyIndex: number, lightness: number, hue: number, saturation: number,
        ack: boolean, rspMax: number): HslSetMessage {
        let message = new HslSetMessage(address, appKeyIndex);
        message.lightness = lightness;
        message.hue = hue;
        message.saturation = saturation;
        message.ack = ack;
        message.responseMax = rspMax
        return message;
    }

    /**
     * Constructs a HSL Set message with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message
     * @param appKeyIndex        The application key index
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.tidPosition = 6
    }

    /**
     * Returns the response opcode based on the acknowledgment flag.
     *
     * @return The response opcode
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.LIGHT_HSL_STATUS : super.getResponseOpcode();
    }

    /**
     * Returns the opcode based on the acknowledgment flag.
     *
     * @return The opcode
     */
    public getOpcode() {
        return this.ack ? Opcode.LIGHT_HSL_SET : Opcode.LIGHT_HSL_SET_NOACK;
    }

    /**
     * Returns the parameters of the message as a byte array.
     * The byte array includes the lightness, hue, saturation, tid, transition time, and delay if the message is complete.
     * Otherwise, it includes only the lightness, hue, saturation, and tid.
     *
     * @return The parameters as a byte array
     */
    public getParams() {
        let buf = new Uint8Array(this.isComplete ? 9 : 7)
        let offset = 0
        buf.set(num2bytes(this.lightness, 2), offset)
        offset += 2
        buf.set(num2bytes(this.hue, 2), offset)
        offset += 2
        buf.set(num2bytes(this.saturation, 2), offset)
        offset += 2
        buf[offset++] = this.tid
        if (this.isComplete) {
            buf[offset++] = this.transitionTime
            buf[offset++] = this.delay
        }
        return buf;
    }
}