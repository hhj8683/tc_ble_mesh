/********************************************************************************************************
 * @file RelaySetMessage.java
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
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * The Config Relay Set is an acknowledged message used to set the Relay and Relay Retransmit states of a node.
 */
export class RelaySetMessage extends ConfigMessage {
    /**
     * 0x00 The node support Relay feature that is disabled
     * 0x01 The node supports Relay feature that is enabled
     * 0x02 Relay feature is not supported
     * 8 bits (1 byte)
     */
    public relay = 0;
    /**
     * 3 bits
     */
    public retransmitCount = 0;
    /**
     * Number of 10-millisecond steps between retransmissions
     * retransmission interval = (Relay Retransmit Interval Steps + 1) * 10
     * 5 bits
     */
    public retransmitIntervalSteps = 0;

    /**
     * Creates a new RelaySetMessage with the specified parameters.
     *
     * @param destinationAddress      The destination address of the message.
     * @param relay                   The relay state of the node.
     * @param retransmitCount         The number of retransmissions.
     * @param retransmitIntervalSteps The interval between retransmissions.
     * @return The created RelaySetMessage instance.
     */
    public static getSimple(destinationAddress: number, relay: number, retransmitCount: number,
        retransmitIntervalSteps: number): RelaySetMessage {
        let instance = new RelaySetMessage(destinationAddress);
        instance.relay = relay;
        instance.retransmitCount = retransmitCount;
        instance.retransmitIntervalSteps = retransmitIntervalSteps;
        return instance;
    }

    /**
     * Returns the opcode value for the RelaySetMessage, which is Opcode.CFG_RELAY_SET.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.CFG_RELAY_SET;
    }

    /**
     * Returns the response opcode value for the RelaySetMessage, which is Opcode.CFG_RELAY_STATUS.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.CFG_RELAY_STATUS;
    }

    /**
     * Returns the parameters of the RelaySetMessage.
     *
     * @return The parameters.
     */
    public getParams() {
        return new Uint8Array([this.relay, ((this.retransmitCount & 0b111) | (this.retransmitIntervalSteps << 3))]);
    }
}
