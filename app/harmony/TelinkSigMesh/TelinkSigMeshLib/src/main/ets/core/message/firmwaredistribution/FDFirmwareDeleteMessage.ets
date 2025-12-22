/********************************************************************************************************
 * @file FDFirmwareDeleteMessage.ets
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
 * The Firmware Distribution Firmware Delete message is an acknowledged message sent by a Firmware Distribution Client to delete a stored firmware image on a Firmware Distribution Server.
 * The response to a Firmware Distribution Firmware Delete message is a Firmware Distribution Firmware Status message.
 */
export class FDFirmwareDeleteMessage extends UpdatingMessage {
    /**
     * Firmware ID
     * The Firmware ID identifying the firmware image to check
     * Variable length
     */
    public firmwareID: number = 0;

    /**
     * Constructs a new FDFirmwareDeleteMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDFirmwareDeleteMessage object with the specified destination address and application key index.
     * This method sets the response maximum to 1.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @return A new FDFirmwareDeleteMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDFirmwareDeleteMessage {
        const message = new FDFirmwareDeleteMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value for the FDFirmwareDeleteMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_FIRMWARE_DELETE;
    }

    /**
     * Gets the response opcode value for the FDFirmwareDeleteMessage.
     * The response opcode is for the Firmware Distribution Firmware Status message.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_UPLOAD_STATUS;
    }
}