/********************************************************************************************************
 * @file FDCapabilitiesGetMessage.ets
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

import { UpdatingMessage } from '../firmwareupdate/UpdatingMessage';
import { Opcode } from "../Opcode";

/**
 * This class represents a message used to retrieve the capabilities of a device in a network.
 * It extends the UpdatingMessage class.
 */
export class FDCapabilitiesGetMessage extends UpdatingMessage {
    /**
     * Constructs a new FDCapabilitiesGetMessage with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDCapabilitiesGetMessage with the specified destination address and application key index.
     * This method sets the maximum number of responses to 1.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     * @return A simple FDCapabilitiesGetMessage.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDCapabilitiesGetMessage {
        const message = new FDCapabilitiesGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode of the FDCapabilitiesGetMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_CAPABILITIES_GET;
    }

    /**
     * Gets the response opcode of the FDCapabilitiesGetMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_CAPABILITIES_STATUS;
    }
}