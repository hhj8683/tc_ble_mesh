/********************************************************************************************************
 * @file FDFirmwareGetMessage.ets
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
 * The Firmware Distribution Upload Start message is an acknowledged message sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Start message is a Firmware Distribution Upload Status message.
 */
export class FDFirmwareGetMessage extends UpdatingMessage {
    /**
     * Firmware ID
     * The Firmware ID identifying the firmware image to check
     * Variable length
     */
    public firmwareID: number = 0;

    /**
     * Constructs a new FDFirmwareGetMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDFirmwareGetMessage object with the specified destination address and application key index.
     * This method sets the maximum number of response messages to 1.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @return A simple FDFirmwareGetMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDFirmwareGetMessage {
        const message = new FDFirmwareGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Returns the opcode value of the FDFirmwareGetMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_FIRMWARE_GET;
    }

    /**
     * Returns the response opcode value of the FDFirmwareGetMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_UPLOAD_STATUS;
    }
}