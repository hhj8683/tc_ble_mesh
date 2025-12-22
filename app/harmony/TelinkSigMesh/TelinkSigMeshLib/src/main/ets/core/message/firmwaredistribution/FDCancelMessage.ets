/********************************************************************************************************
 * @file FDCancelMessage.ets
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
import { MeshMessage } from "../MeshMessage";

/**
 * The Firmware Distribution Cancel message is an acknowledged message
 * sent by a Firmware Distribution Client to stop the firmware image distribution from a Firmware Distribution Server.
 * The response to a Firmware Distribution Cancel message is a Firmware Distribution Status message.
 */
export class FDCancelMessage extends UpdatingMessage {
    private ack: boolean = true; // Flag indicating if an acknowledgement is expected 

    /**
     * Constructor for the FDCancelMessage class.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDCancelMessage with default values.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @return A simple FDCancelMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDCancelMessage {
        const message = new FDCancelMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Returns the opcode value for the FDCancelMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_CANCEL;
    }

    /**
     * Returns the acknowledgement flag for the FDCancelMessage.
     *
     * @return The acknowledgement flag.
     */
    public isAck(): boolean {
        return this.ack;
    }

    /**
     * Sets the acknowledgement flag for the FDCancelMessage.
     *
     * @param ack The acknowledgement flag.
     */
    public setAck(ack: boolean): void {
        this.ack = ack;
    }

    /**
     * Returns the response opcode value for the FDCancelMessage.
     * If the acknowledgement flag is true, it returns the FD_STATUS opcode value.
     * Otherwise, it returns the OPCODE_INVALID value.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return this.ack ? Opcode.FD_STATUS : MeshMessage.OPCODE_INVALID;
    }
}