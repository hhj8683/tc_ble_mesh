/********************************************************************************************************
 * @file DeltaSetMessage.ets
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
import { ByteOrder, num2bytes } from "../../../../../../Index";
import { Opcode } from "../Opcode";
import { GenericMessage } from "./GenericMessage";


/**
 * DeltaSetMessage is a class that represents a message for setting the delta level of a device.
 * It extends the GenericMessage class.
 * The delta level is the difference in the current state of the device from the desired state.
 * The message contains the delta level, transaction ID (tid), transition time, and delay.
 * It also has a flag to indicate whether an acknowledgement is required.
 * The isComplete flag indicates whether the message is complete or not.
 * This class provides methods to create a simple DeltaSetMessage object, set the delta level and other parameters,
 * and get the response opcode and opcode for the message.
 * The getParams method returns the parameters of the message as a byte array.
 */
export class DeltaSetMessage extends GenericMessage {
    private deltaLevel = 0;
    private tid = 0;
    private transitionTime = 0;
    private delay = 0;
    private ack = true;
    private isComplete = false;

    /**
     * Creates a simple DeltaSetMessage object with the given destination address, application key index,
     * delta level, acknowledgement flag, and maximum response time.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The application key index of the message.
     * @param deltaLevel         The delta level to be set.
     * @param ack                The acknowledgement flag.
     * @param rspMax             The maximum response time.
     * @return The created DeltaSetMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, deltaLevel: number, ack: boolean,
        rspMax: number): DeltaSetMessage {
        let deltaSetMessage = new DeltaSetMessage(destinationAddress, appKeyIndex);
        deltaSetMessage.deltaLevel = deltaLevel;
        deltaSetMessage.transitionTime = 0;
        deltaSetMessage.delay = 0;
        deltaSetMessage.ack = ack;
        deltaSetMessage.responseMax = rspMax;
        return deltaSetMessage;
    }

    /**
     * Constructs a DeltaSetMessage object with the given destination address and application key index.
     * Sets the transaction ID position to 4.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The application key index of the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.tidPosition = 4
    }

    /**
     * Returns the response opcode for the message.
     * If an acknowledgement is required, it returns the opcode for G_LEVEL_STATUS.
     * Otherwise, it returns an invalid opcode.
     *
     * @return The response opcode for the message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.G_LEVEL_STATUS : DeltaSetMessage.OPCODE_INVALID;
    }

    /**
     * Returns the opcode for the message.
     * If an acknowledgement is required, it returns the opcode for G_DELTA_SET.
     * Otherwise, it returns the opcode for G_DELTA_SET_NOACK.
     *
     * @return The opcode for the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.G_DELTA_SET : Opcode.G_DELTA_SET_NOACK
    }

    /**
     * Returns the parameters of the message as a byte array.
     * If the message is complete, it returns a byte array with the delta level, tid, transition time, and delay.
     * Otherwise, it returns a byte array with the delta level and tid.
     *
     * @return The parameters of the message as a byte array.
     */
    public getParams() {
        let re = new Uint8Array(this.isComplete ? 7 : 5)
        let offset = 0
        re.set(num2bytes(this.deltaLevel, 4, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 4
        re[offset++] = this.tid
        if (this.isComplete) {
            re[offset++] = this.transitionTime
            re[offset++] = this.delay
        }
        return re
    }
}