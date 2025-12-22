/********************************************************************************************************
 * @file FirmwareUpdateStatusMessage.ets
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

import { StatusMessage } from '../StatusMessage';
import { UpdateStatus } from './UpdateStatus';

/**
 * This class represents a firmware update status message.
 * It extends the StatusMessage class.
 */
export class FirmwareUpdateStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FirmwareUpdateStatusMessage"

    public statusName(): string {
        return FirmwareUpdateStatusMessage.STATUS_NAME
    }

    /**
     * The status of the firmware update.
     * It is represented by the 3 lower bits in the first byte of the message.
     */
    private status: UpdateStatus;
    
    /**
     * The phase of the firmware update.
     * It is represented by the 3 higher bits in the first byte of the message.
     */
    private phase: number;
    
    /**
     * The Time To Live (TTL) value to use during firmware image transfer.
     * It is represented by 1 byte in the message.
     */
    private updateTtl: number;
    
    /**
     * Additional information about the firmware update.
     * It is represented by 5 bits in the message (3 bits reserved for future use).
     */
    private additionalInfo: number;
    
    /**
     * The base value used to compute the timeout of the firmware image transfer.
     * The client timeout is calculated as [12,000 * (Client Timeout Base + 1) + 100 * Transfer TTL] milliseconds.
     * It is represented by 2 bytes in the message.
     */
    private updateTimeoutBase: number;
    
    /**
     * The BLOB identifier for the firmware image.
     * It is represented by 8 bytes in the message.
     */
    private updateBLOBID: bigint;
    
    /**
     * The index of the firmware image being updated.
     * It is represented by 1 byte in the message.
     */
    private updateFirmwareImageIndex: number;
    
    /**
     * Indicates if the firmware update message is complete or not.
     * If the Update TTL field is present, the Additional Information field, Update Timeout field, BLOB ID field, and Installed Firmware ID field shall be present;
     * otherwise, the Additional Information field, Update Timeout field, BLOB ID field, and Installed Firmware ID field shall not be present.
     */
    private isComplete: boolean = false;

    /**
     * Default constructor for the FirmwareUpdateStatusMessage class.
     */
    constructor() {
        super();
        this.status = UpdateStatus.UNKNOWN_ERROR;
        this.phase = 0;
        this.updateTtl = 0;
        this.additionalInfo = 0;
        this.updateTimeoutBase = 0;
        this.updateBLOBID = 0n;
        this.updateFirmwareImageIndex = 0;
        this.isComplete = false;
    }

    /**
     * Parses the byte array to populate the fields of the FirmwareUpdateStatusMessage object.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index] & 0x07;
        this.phase = (params[index] & 0xFF) >> 5;
        this.isComplete = params.length > 1;
        
        if (!this.isComplete) return;
        
        index++;
        this.updateTtl = params[index++];
        this.additionalInfo = (params[index++] & 0x1F);
        
        // Parse updateTimeoutBase (2 bytes, little-endian)
        this.updateTimeoutBase = params[index] | (params[index + 1] << 8);
        index += 2;
        
        // Parse updateBLOBID (8 bytes, little-endian)
        this.updateBLOBID = 0n;
        for (let i = 0; i < 8; i++) {
            this.updateBLOBID |= BigInt(params[index + i]) << BigInt(i * 8);
        }
        index += 8;
        
        this.updateFirmwareImageIndex = params[index] & 0xFF;
    }

    /**
     * Returns the status of the firmware update.
     *
     * @return The status of the firmware update.
     */
    public getStatus(): number {
        return this.status;
    }

    /**
     * Returns the phase of the firmware update.
     *
     * @return The phase of the firmware update.
     */
    public getPhase(): number {
        return this.phase;
    }

    /**
     * Returns the Time To Live (TTL) value used during firmware image transfer.
     *
     * @return The Time To Live (TTL) value used during firmware image transfer.
     */
    public getUpdateTtl(): number {
        return this.updateTtl;
    }

    /**
     * Returns the additional information about the firmware update.
     *
     * @return The additional information about the firmware update.
     */
    public getAdditionalInfo(): number {
        return this.additionalInfo;
    }

    /**
     * Returns the base value used to compute the timeout of the firmware image transfer.
     *
     * @return The base value used to compute the timeout of the firmware image transfer.
     */
    public getUpdateTimeoutBase(): number {
        return this.updateTimeoutBase;
    }

    /**
     * Returns the BLOB identifier for the firmware image.
     *
     * @return The BLOB identifier for the firmware image.
     */
    public getUpdateBLOBID(): bigint {
        return this.updateBLOBID;
    }

    /**
     * Returns the index of the firmware image being updated.
     *
     * @return The index of the firmware image being updated.
     */
    public getUpdateFirmwareImageIndex(): number {
        return this.updateFirmwareImageIndex;
    }

    /**
     * Returns whether the firmware update message is complete or not.
     *
     * @return True if the firmware update message is complete, false otherwise.
     */
    public isCompleteStatus(): boolean {
        return this.isComplete;
    }

    /**
     * Returns a string representation of the FirmwareUpdateStatusMessage object.
     *
     * @return A string representation of the FirmwareUpdateStatusMessage object.
     */
    public toString(): string {
        return `FirmwareUpdateStatusMessage{status=${this.status}, phase=${this.phase}, updateTtl=${this.updateTtl}, additionalInfo=${this.additionalInfo}, updateTimeoutBase=${this.updateTimeoutBase}, updateBLOBID=0x${this.updateBLOBID.toString(16)}, updateFirmwareImageIndex=${this.updateFirmwareImageIndex}, isComplete=${this.isComplete}}`;
    }
}