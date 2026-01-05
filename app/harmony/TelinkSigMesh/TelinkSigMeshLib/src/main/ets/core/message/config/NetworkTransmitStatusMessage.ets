/********************************************************************************************************
 * @file NetworkTransmitStatusMessage.java
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
 * The Config Network Transmit Status is an unacknowledged message used to report the current Network Transmit state of a node
 * The NetworkTransmitStatusMessage class represents an unacknowledged message used to report the current Network Transmit state of a node.
 * It extends the StatusMessage class and implements the Parcelable interface.
 * <p>
 * The count variable represents the number of transmissions attempted for each Network PDU.
 * The intervalSteps variable represents the interval between each transmission in steps of 10 milliseconds.
 * <p>
 * This message is used to provide information about the current Network Transmit state of a node.
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_NW_TRANSMIT_STATUS
 */
export class NetworkTransmitStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "NetworkTransmitStatusMessage"

    public statusName(): string {
        return NetworkTransmitStatusMessage.STATUS_NAME
    }

    public count = 0;
    public intervalSteps = 0;

    /**
     * Parses the byte array data and sets the count and intervalSteps variables.
     *
     * @param data The byte array data to be parsed.
     */
    public parse(data: Uint8Array) {
        this.count = data[0] & 0b111;
        this.intervalSteps = (data[0] & 0xFF) >> 3;
    }
}

