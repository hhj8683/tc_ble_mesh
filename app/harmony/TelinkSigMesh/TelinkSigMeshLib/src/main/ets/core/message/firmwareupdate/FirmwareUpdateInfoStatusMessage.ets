/********************************************************************************************************
 * @file FirmwareInformationEntry.ets
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


import { StatusMessage } from "../../message/StatusMessage";

/**
 * This class represents an entry in the firmware information list.
 * It implements the Parcelable interface for easy data transfer.
 * The class contains information about the length of the current firmware ID field,
 * the current firmware ID, the length of the update URI field, and the update URI.
 */
export class FirmwareInformationEntry {
    // Length of the Current Firmware ID field
    public currentFirmwareIDLength: number;
    // Identifies the firmware image on the node or any subsystem on the node
    public currentFirmwareID: Uint8Array;
    // Length of the Update URI field
    public updateURILength: number;
    // URI used to retrieve a new firmware image
    public updateURI: Uint8Array;

    constructor() {
        this.currentFirmwareIDLength = 0;
        this.currentFirmwareID = new Uint8Array(0);
        this.updateURILength = 0;
        this.updateURI = new Uint8Array(0);
    }
}

/**
 * This class represents a status message for firmware update information.
 * It extends the StatusMessage class and implements the Parcelable interface for easy data transfer.
 * The class contains information about the number of entries in the firmware information list state of the server,
 * the index of the first requested entry, and a list of firmware information entries.
 * The class provides methods to parse the byte array parameters, retrieve the list count, first index, and firmware information list,
 * and get the first entry from the firmware information list.
 */
export class FirmwareUpdateInfoStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FirmwareUpdateInfoStatusMessage"

    public statusName(): string {
        return FirmwareUpdateInfoStatusMessage.STATUS_NAME
    }

    /**
     * The number of entries in the Firmware Information List state of the server
     * 1 byte
     */
    private listCount: number;

    /**
     * Index of the first requested entry from the Firmware Information List state
     * 1 byte
     */
    private firstIndex: number;

    /**
     * List of entries
     */
    private firmwareInformationList: FirmwareInformationEntry[];

    constructor() {
        super();
        this.listCount = 0;
        this.firstIndex = 0;
        this.firmwareInformationList = [];
    }

    /**
     * Parses the byte array parameters and sets the values of the class fields accordingly.
     * @param params The byte array parameters to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.listCount = params[index++] & 0xFF;
        this.firstIndex = params[index++] & 0xFF;
        this.firmwareInformationList = [];

        for (let i = 0; i < this.listCount; i++) {
            const firmwareIdLength = params[index++] & 0xFF;
            let currentFirmwareID: Uint8Array;
            if (firmwareIdLength > 0) {
                currentFirmwareID = params.slice(index, index + firmwareIdLength);
                index += firmwareIdLength;
            } else {
                currentFirmwareID = new Uint8Array(0);
            }

            const uriLen = params[index++];
            let updateURI: Uint8Array;
            if (uriLen > 0) {
                updateURI = params.slice(index, index + uriLen);
                index += uriLen;
            } else {
                updateURI = new Uint8Array(0);
            }

            const informationEntry = new FirmwareInformationEntry();
            informationEntry.currentFirmwareIDLength = firmwareIdLength;
            informationEntry.currentFirmwareID = currentFirmwareID;
            informationEntry.updateURILength = uriLen;
            informationEntry.updateURI = updateURI;
            this.firmwareInformationList.push(informationEntry);
        }
    }

    /**
     * Returns the number of entries in the Firmware Information List state of the server.
     * @returns The number of entries.
     */
    public getListCount(): number {
        return this.listCount;
    }

    /**
     * Returns the index of the first requested entry from the Firmware Information List state.
     * @returns The index of the first requested entry.
     */
    public getFirstIndex(): number {
        return this.firstIndex;
    }

    /**
     * Returns the list of firmware information entries.
     * @returns The list of entries.
     */
    public getFirmwareInformationList(): FirmwareInformationEntry[] {
        return this.firmwareInformationList;
    }

    /**
     * Returns the first entry from the firmware information list.
     * @returns The first entry, or null if the list is empty or the first index is out of bounds.
     */
    getFirstEntry(): FirmwareInformationEntry | null {
        if (this.firmwareInformationList.length === 0 || this.firstIndex >= this.firmwareInformationList.length) {
            return null;
        }
        return this.firmwareInformationList[this.firstIndex];
    }

    /**
     * Returns a string representation of the FirmwareUpdateInfoStatusMessage object.
     * @returns A string representation.
     */
    override toString(): string {
        return `FirmwareUpdateInfoStatusMessage{listCount=${this.listCount}, firstIndex=${this.firstIndex}, firmwareInformationList=${this.firmwareInformationList.length}}`;
    }
}
