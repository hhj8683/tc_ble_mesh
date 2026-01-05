/********************************************************************************************************
 * @file NetworkTransmitSetMessage.java
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
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';

/**
 * set network transmit params
 * Network transmit params are used when node sending network pdu from self -- source address is self --
 * Meanwhile relay params are used when relay network pdu, generally smaller than network transmit
 */
export class NetworkTransmitSetMessage extends ConfigMessage {
    // networkTransmitCount, default is 5
    public count = 0;
    // networkTransmitIntervalSteps, default is 2
    // transmission interval = (Network Transmit Interval Steps + 1) * 10
    public intervalSteps = 0;

    /**
     * Creates a new NetworkTransmitSetMessage with the given destination address, count, and interval steps.
     *
     * @param destinationAddress The destination address for the message.
     * @param count              The number of times the network PDU should be transmitted.
     * @param intervalSteps      The interval steps for transmitting the network PDU.
     * @return The created NetworkTransmitSetMessage.
     */
    public static getSimple(destinationAddress: number, count: number,
        intervalSteps: number): NetworkTransmitSetMessage {
        let message = new NetworkTransmitSetMessage(destinationAddress);
        message.count = count;
        message.intervalSteps = intervalSteps;
        return message;
    }

    /**
     * Returns the opcode value for the NetworkTransmitSetMessage.
     *
     * @return The opcode value for the NetworkTransmitSetMessage.
     */
    public getOpcode() {
        return Opcode.CFG_NW_TRANSMIT_SET
    }

    /**
     * Returns the response opcode value for the NetworkTransmitSetMessage.
     *
     * @return The response opcode value for the NetworkTransmitSetMessage.
     */
    public getResponseOpcode() {
        return Opcode.CFG_NW_TRANSMIT_STATUS
    }

    /**
     * Returns the parameters of the NetworkTransmitSetMessage.
     *
     * @return The parameters of the NetworkTransmitSetMessage.
     */
    public getParams() {
        return new Uint8Array([((this.count & 0b111) | (this.intervalSteps << 3))])
    }
}
