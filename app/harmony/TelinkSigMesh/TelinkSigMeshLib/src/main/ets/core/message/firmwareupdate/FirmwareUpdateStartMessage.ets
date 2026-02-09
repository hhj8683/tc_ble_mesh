/********************************************************************************************************
 * @file     FirmwareUpdateStartMessage.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
/********************************************************************************************************
 * @file FirmwareUpdateStartMessage.ets
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
 * This class represents a Firmware Update Start Message, which is a type of UpdatingMessage.
 * It contains various fields and methods to handle the firmware update process.
 */
export class FirmwareUpdateStartMessage extends UpdatingMessage {
    /**
     * Default TTL value
     */
    public static readonly DEFAULT_UPDATE_TTL: number = 10;

    /**
     * Time To Live value to use during firmware image transfer
     * 1 byte
     */
    public updateTtl: number = FirmwareUpdateStartMessage.DEFAULT_UPDATE_TTL;

    /**
     * Used to compute the timeout of the firmware image transfer
     * Client Timeout = [12,000 * (Client Timeout Base + 1) + 100 * Transfer TTL] milliseconds
     * using blockSize
     * 2 bytes
     */
    public updateTimeoutBase: number;

    /**
     * BLOB identifier for the firmware image
     * 8 bytes
     */
    public updateBLOBID: bigint;

    /**
     * Index of the firmware image in the Firmware Information List state to be updated
     * 1 byte
     */
    public updateFirmwareImageIndex: number;

    /**
     * Vendor-specific firmware metadata
     * If the value of the Incoming Firmware Metadata Length field is greater than 0,
     * the Incoming Firmware Metadata field shall be present.
     * 1-255 bytes
     */
    public metadata: Uint8Array;

    /**
     * Creates a new instance of FirmwareUpdateStartMessage with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.updateTimeoutBase = 0;
        this.updateBLOBID = 0n;
        this.updateFirmwareImageIndex = 0;
        this.metadata = new Uint8Array(0);
    }

    /**
     * Returns the opcode value for the Firmware Update Start Message.
     *
     * @returns The opcode value.
     */
    public getOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_START;
    }

    /**
     * Returns the opcode value for the response message to the Firmware Update Start Message.
     *
     * @returns The response opcode value.
     */
    public getResponseOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_STATUS;
    }

    /**
     * Returns the parameters of the Firmware Update Start Message as a byte array.
     *
     * @returns The parameters byte array.
     */
    public getParams(): Uint8Array {
        const metadataLen = this.metadata.length;
        const len = 12 + metadataLen;
        const buffer = new ArrayBuffer(len);
        const dataView = new DataView(buffer);
        const params = new Uint8Array(buffer);

        dataView.setUint8(0, this.updateTtl);
        dataView.setUint16(1, this.updateTimeoutBase, true);
        dataView.setBigUint64(3, this.updateBLOBID, true);
        dataView.setUint8(11, this.updateFirmwareImageIndex);

        params.set(this.metadata, 12);

        return params;
    }

    /**
     * Returns the update TTL value.
     *
     * @returns The update TTL value.
     */
    public getUpdateTtl(): number {
        return this.updateTtl;
    }

    /**
     * Sets the update TTL value.
     *
     * @param updateTtl The update TTL value to set.
     */
    public setUpdateTtl(updateTtl: number): void {
        this.updateTtl = updateTtl;
    }

    /**
     * Returns the update timeout base value.
     *
     * @returns The update timeout base value.
     */
    public getUpdateTimeoutBase(): number {
        return this.updateTimeoutBase;
    }

    /**
     * Sets the update timeout base value.
     *
     * @param updateTimeoutBase The update timeout base value to set.
     */
    public setUpdateTimeoutBase(updateTimeoutBase: number): void {
        this.updateTimeoutBase = updateTimeoutBase;
    }

    /**
     * Returns the update BLOB ID.
     *
     * @returns The update BLOB ID.
     */
    public getUpdateBLOBID(): bigint {
        return this.updateBLOBID;
    }

    /**
     * Sets the update BLOB ID.
     *
     * @param updateBLOBID The update BLOB ID to set.
     */
    public setUpdateBLOBID(updateBLOBID: bigint): void {
        this.updateBLOBID = updateBLOBID;
    }

    /**
     * Returns the update firmware image index.
     *
     * @returns The update firmware image index.
     */
    public getUpdateFirmwareImageIndex(): number {
        return this.updateFirmwareImageIndex;
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
     * Returns the firmware metadata.
     *
     * @returns The firmware metadata.
     */
    public getMetadata(): Uint8Array {
        return this.metadata;
    }

    /**
     * Sets the firmware metadata.
     *
     * @param metadata The firmware metadata to set.
     */
    public setMetadata(metadata: Uint8Array): void {
        this.metadata = metadata;
    }

    /**
     * Creates and returns a simplified instance of FirmwareUpdateStartMessage with the given parameters.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The application key index.
     * @param updateTimeoutBase The update timeout base value.
     * @param blobId The BLOB identifier for the firmware image.
     * @param metadata The firmware metadata.
     * @returns The simplified FirmwareUpdateStartMessage instance.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, updateTimeoutBase: number, blobId: bigint, metadata: Uint8Array): FirmwareUpdateStartMessage {
        let message = new FirmwareUpdateStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.updateTimeoutBase = updateTimeoutBase;
        message.updateBLOBID = blobId;
        message.updateFirmwareImageIndex = 0;
        message.metadata = metadata;
        return message;
    }
}