/********************************************************************************************************
 * @file FirmwareMetadataStatusMessage.ets
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

import { AdditionalInformation } from './AdditionalInformation';
import { StatusMessage } from "../../message/StatusMessage";
import { UpdateStatus } from './UpdateStatus';

/**
 * This class represents a firmware metadata status message.
 * It extends the StatusMessage class and implements the Parcelable interface.
 */
export class FirmwareMetadataStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FirmwareMetadataStatusMessage"

    public statusName(): string {
        return FirmwareMetadataStatusMessage.STATUS_NAME
    }

    /**
     * The status of the firmware metadata.
     * It is represented by 3 bits.
     *
     * @see UpdateStatus
     */
    private status: UpdateStatus = UpdateStatus.UNKNOWN_ERROR;

    /**
     * Additional information about the firmware metadata.
     * It is represented by 5 bits.
     *
     * @see AdditionalInformation
     */
    private additionalInformation: AdditionalInformation = AdditionalInformation.UNKNOWN_ERROR;

    /**
     * The index of the firmware image in the Firmware Information List state that was checked.
     * It is represented by 8 bits.
     */
    private updateFirmwareImageIndex: number = 0;

    /**
     * Default constructor for the FirmwareMetadataStatusMessage class.
     */
    // constructor() {
    //     super();
    //     this.status = 0;
    //     this.additionalInformation = 0;
    //     this.updateFirmwareImageIndex = 0;
    // }

    /**
     * Parses the byte array and sets the values of the status, additionalInformation, and updateFirmwareImageIndex fields accordingly.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index] & 0x07;
        this.additionalInformation = (params[index++] >> 3) & 0x1F;
        this.updateFirmwareImageIndex = params[index] & 0xFF;
    }

    /**
     * Returns the status of the firmware metadata.
     *
     * @return The status of the firmware metadata.
     */
    public getStatus(): number {
        return this.status;
    }

    /**
     * Returns the additional information about the firmware metadata.
     *
     * @return The additional information about the firmware metadata.
     */
    public getAdditionalInformation(): number {
        return this.additionalInformation;
    }

    /**
     * Returns the index of the firmware image in the Firmware Information List state that was checked.
     *
     * @return The index of the firmware image.
     */
    public getUpdateFirmwareImageIndex(): number {
        return this.updateFirmwareImageIndex;
    }

    /**
     * Converts the object to a string representation.
     *
     * @returns A string representation of the object.
     */
    public toString(): string {
        return `FirmwareMetadataStatusMessage - Status: ${this.status}, Additional Information: ${this.additionalInformation}, Update Firmware Image Index: ${this.updateFirmwareImageIndex}`;
    }
}