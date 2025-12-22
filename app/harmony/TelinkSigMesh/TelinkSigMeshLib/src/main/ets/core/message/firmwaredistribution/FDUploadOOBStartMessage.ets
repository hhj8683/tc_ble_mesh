/********************************************************************************************************
 * @file FDUploadOOBStartMessage.ets
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
 * The Firmware Distribution Upload OOB Start message is an acknowledged message
 * sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server using an out-of-band mechanism.
 */
export class FDUploadOOBStartMessage extends UpdatingMessage {
    /**
     * Upload URI Length
     * Length of the Upload URI field
     * 1 byte
     */
    public uploadURILength: number = 0;

    /**
     * Upload URI
     * URI for the firmware image source
     * 1 to 255 bytes
     */
    public uploadURI: number = 0;

    /**
     * Upload Firmware ID
     * The Firmware ID value used to generate the URI query string
     * Variable length
     */
    public uploadFirmwareID: Uint8Array = new Uint8Array(0);

    /**
     * Constructs a new FDUploadOOBStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDUploadOOBStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     * @return The created FDUploadOOBStartMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDUploadOOBStartMessage {
        const message = new FDUploadOOBStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value for the FDUploadOOBStartMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_UPLOAD_START;
    }

    /**
     * Gets the response opcode value for the FDUploadOOBStartMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_UPLOAD_STATUS;
    }
}