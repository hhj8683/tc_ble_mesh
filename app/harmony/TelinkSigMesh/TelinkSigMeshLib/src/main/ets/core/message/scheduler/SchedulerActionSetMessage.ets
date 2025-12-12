/********************************************************************************************************
 * @file SchedulerActionSetMessage.java
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
import { GenericMessage } from "../generic/GenericMessage";
import { Opcode } from "../Opcode";

/**
 * This class represents a Scheduler Action Set Message, which is used to send scheduler action set commands to a device.
 * It extends the GenericMessage class.
 * The Scheduler Action Set Message can be sent with or without acknowledgement.
 * The message includes the scheduler parameters.
 * <p>
 * Example usage:
 * SchedulerActionSetMessage message = SchedulerActionSetMessage.getSimple(address, appKeyIndex, schedulerParams, ack, rspMax);
 *
 * @author kee
 * @since 2019/8/14
 */
export class SchedulerActionSetMessage extends GenericMessage {
    public schedulerParams: Uint8Array = new Uint8Array();
    public ack = false;

    /**
     * Creates a simple SchedulerActionSetMessage object with the given parameters.
     *
     * @param address         The destination address of the message.
     * @param appKeyIndex     The index of the application key.
     * @param schedulerParams The scheduler parameters to be set.
     * @param ack             Specifies whether the message requires acknowledgement.
     * @param rspMax          The maximum number of response messages expected.
     * @return The created SchedulerActionSetMessage object.
     */
    public static getSimple(address: number, appKeyIndex: number, schedulerParams: Uint8Array, ack: boolean,
        rspMax: number): SchedulerActionSetMessage {
        let message = new SchedulerActionSetMessage(address, appKeyIndex)
        message.schedulerParams = schedulerParams
        message.ack = ack
        message.responseMax = rspMax
        return message
    }

    /**
     * Constructs a SchedulerActionSetMessage object with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The index of the application key.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the opcode of the response message.
     * If the message requires acknowledgement, the opcode is Opcode.SCHD_ACTION_STATUS.value.
     * Otherwise, it calls the super class method to get the opcode.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.SCHD_ACTION_STATUS : super.getResponseOpcode();
    }

    /**
     * Returns the opcode of the message.
     * If the message requires acknowledgement, the opcode is Opcode.SCHD_ACTION_SET.value.
     * Otherwise, the opcode is Opcode.SCHD_ACTION_SET_NOACK.value.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.SCHD_ACTION_SET : Opcode.SCHD_ACTION_SET_NOACK
    }

    /**
     * Returns the scheduler parameters of the message.
     *
     * @return The scheduler parameters of the message.
     */
    public getParams() {
        return this.schedulerParams;
    }
}