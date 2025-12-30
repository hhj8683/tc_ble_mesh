/********************************************************************************************************
 * @file FirmwareMetadataCheckMessage.ets
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

import { UpdatingMessage } from './UpdatingMessage';
import { Opcode } from "../Opcode";

/**
 * This class represents a message for checking the firmware metadata during a firmware update.
 * It extends the UpdatingMessage class.
 */
export class FirmwareMetadataCheckMessage extends UpdatingMessage {
    public updateFirmwareImageIndex: number = 0x00;
    public incomingFirmwareMetadata: Uint8Array = new Uint8Array(0);

    /**
     * Creates a simple FirmwareMetadataCheckMessage object with the specified destination address, app key index, index, and incoming firmware metadata.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     * @param index The index of the firmware image to check.
     * @param incomingFirmwareMetadata The incoming firmware metadata.
     * @returns A FirmwareMetadataCheckMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, index: number, incomingFirmwareMetadata: Uint8Array): FirmwareMetadataCheckMessage {
        let message = new FirmwareMetadataCheckMessage(destinationAddress, appKeyIndex);
        message.updateFirmwareImageIndex = index;
        message.incomingFirmwareMetadata = incomingFirmwareMetadata;
        return message;
    }

    /**
     * Constructs a FirmwareMetadataCheckMessage object with the specified destination address and app key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The app key index of the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_CHECK;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @returns The parameters of the message.
     */
    public getParams(): Uint8Array {
        let metadataLen: number = this.incomingFirmwareMetadata.byteLength;
        let len: number = 1 + metadataLen;
        let buf = new Uint8Array(len);
        buf[0] = this.updateFirmwareImageIndex;
        if (metadataLen != 0) {
            buf.set(this.incomingFirmwareMetadata, 1);
        }
        return buf
    }

    /**
     * Sets the update firmware image index.
     *
     * @param updateFirmwareImageIndex The update firmware image index to set.
     */
    public setUpdateFirmwareImageIndex(updateFirmwareImageIndex: number): void {
        this.updateFirmwareImageIndex = updateFirmwareImageIndex;
    }

    /**
     * Sets the incoming firmware metadata.
     *
     * @param incomingFirmwareMetadata The incoming firmware metadata to set.
     */
    public setIncomingFirmwareMetadata(incomingFirmwareMetadata: Uint8Array): void {
        this.incomingFirmwareMetadata = incomingFirmwareMetadata;
    }
}