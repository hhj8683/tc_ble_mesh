/********************************************************************************************************
 * @file     FDUploadStartMessage.ets 
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
 * @file FDUploadStartMessage.ets
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
 * The Firmware Distribution Upload Start message is an acknowledged message
 * sent by a Firmware Distribution Client to start a firmware image upload to a Firmware Distribution Server.
 * The response to a Firmware Distribution Upload Start message is a Firmware Distribution Upload Status message.
 */
export class FDUploadStartMessage extends UpdatingMessage {
    /**
     * Upload TTL
     * Time To Live value used in a firmware image upload
     * 1 byte
     */
    public uploadTTL: number = 0;

    /**
     * Upload Timeout Base
     * Used to compute the timeout of the firmware image upload
     * 2 bytes
     */
    public uploadTimeoutBase: number = 0;

    /**
     * Upload BLOB ID
     * BLOB identifier for the firmware image
     * 8 bytes
     */
    public uploadBLOBID: bigint = 0n;

    /**
     * Upload Firmware Size
     * Firmware image size (in octets)
     * 4 bytes
     */
    public uploadFirmwareSize: number = 0;

    /**
     * Upload Firmware Metadata Length
     * Size of the Upload Firmware Metadata field
     * 1 byte
     */
    public uploadFirmwareMetadataLength: number = 0;

    /**
     * Upload Firmware Metadata
     * Vendor-specific firmware metadata
     * 1 to 255 bytes
     */
    public uploadFirmwareMetadata: Uint8Array = new Uint8Array(0);

    /**
     * Upload Firmware ID
     * The Firmware ID identifying the firmware image being uploaded
     * Variable
     */
    public uploadFirmwareID: Uint8Array = new Uint8Array(0);

    /**
     * Constructs a new FDUploadStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDUploadStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     * @return The created FDUploadStartMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDUploadStartMessage {
        const message = new FDUploadStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value for the FDUploadStartMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_UPLOAD_START;
    }

    /**
     * Gets the response opcode value for the FDUploadStartMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_UPLOAD_STATUS;
    }

    /**
     * Gets the byte array representation of the parameters in the FDUploadStartMessage.
     *
     * @return The byte array representation of the parameters.
     */
    public override getParams(): Uint8Array {
        const totalLength = 1 + 2 + 8 + 4 + 1 + this.uploadFirmwareMetadata.length + this.uploadFirmwareID.length;
        const buffer = new ArrayBuffer(totalLength);
        const view = new DataView(buffer);
        let offset = 0;

        // Write uploadTTL (1 byte)
        view.setUint8(offset, this.uploadTTL);
        offset += 1;

        // Write uploadTimeoutBase (2 bytes)
        view.setUint16(offset, this.uploadTimeoutBase, true); // little-endian
        offset += 2;

        // Write uploadBLOBID (8 bytes)
        // Since we're dealing with BigInt, we'll split it into two 32-bit parts
        const blobIdLow = Number(this.uploadBLOBID & 0xFFFFFFFFn);
        const blobIdHigh = Number(this.uploadBLOBID >> 32n);
        view.setUint32(offset, blobIdLow, true); // little-endian
        offset += 4;
        view.setUint32(offset, blobIdHigh, true); // little-endian
        offset += 4;

        // Write uploadFirmwareSize (4 bytes)
        view.setUint32(offset, this.uploadFirmwareSize, true); // little-endian
        offset += 4;

        // Write uploadFirmwareMetadataLength (1 byte)
        view.setUint8(offset, this.uploadFirmwareMetadataLength);
        offset += 1;

        // Copy uploadFirmwareMetadata
        for (let i = 0; i < this.uploadFirmwareMetadata.length; i++) {
            view.setUint8(offset + i, this.uploadFirmwareMetadata[i]);
        }
        offset += this.uploadFirmwareMetadata.length;

        // Copy uploadFirmwareID
        for (let i = 0; i < this.uploadFirmwareID.length; i++) {
            view.setUint8(offset + i, this.uploadFirmwareID[i]);
        }

        return new Uint8Array(buffer);
    }
}