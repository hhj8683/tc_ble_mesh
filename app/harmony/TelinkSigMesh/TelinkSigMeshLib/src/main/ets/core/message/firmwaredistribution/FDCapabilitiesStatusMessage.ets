/********************************************************************************************************
 * @file FDCapabilitiesStatusMessage.ets
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
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';
import { OOBRetrievalSupported } from "./DistributorCapabilities";


/**
 * Firmware Distribution Capabilities Status
 * response to a Firmware Distributor Capabilities Get message
 *
 * @see FDCapabilitiesGetMessage
 */
export class FDCapabilitiesStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FDCapabilitiesStatusMessage"

    public statusName(): string {
        return FDCapabilitiesStatusMessage.STATUS_NAME
    }

    /**
     * Max Distribution Receivers List Size
     * Maximum number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    private maxReceiversListSize: number = 0;

    /**
     * Max Firmware Images List Size
     * Maximum number of entries in the Firmware Images List state
     * 2 bytes
     */
    public maxImagesListSize: number = 0;

    /**
     * Max Firmware Image Size
     * Maximum size of one firmware image (in octets)
     * 4 bytes
     */
    private maxImageSize: number = 0;

    /**
     * Max Upload Space
     * Total space dedicated to storage of firmware images (in octets)
     * 4 bytes
     */
    private maxUploadSpace: number = 0;

    /**
     * Remaining Upload Space
     * Remaining available space in firmware image storage (in octets)
     * 4 bytes
     */
    private remainingUploadSpace: number = 0;

    /**
     * Out-of-Band Retrieval Supported
     * Value of the Out-of-Band Retrieval Supported state
     * 1 byte
     */
    private oobRetrievalSupported: number = 0;

    /**
     * Supported URI Scheme Names
     * Value of the Supported URI Scheme Names state
     * Variable
     */
    private uriSchemeNames: Uint8Array | null = null;

    /**
     * Default constructor for the FDCapabilitiesStatusMessage class.
     */
    constructor() {
        super();
    }

    /**
     * Parses the byte array representation of the FDCapabilitiesStatusMessage object.
     *
     * @param params The byte array containing the values to parse.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.maxReceiversListSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.maxImagesListSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.maxImageSize = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;
        this.maxUploadSpace = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;
        this.remainingUploadSpace = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
        index += 4;
        this.oobRetrievalSupported = params[index++] & 0xFF;
        if (this.oobRetrievalSupported === OOBRetrievalSupported.SUPPORTED) { // Assuming 1 means SUPPORTED
            const uriLength = params.length - index;
            this.uriSchemeNames = new Uint8Array(params.buffer, index, uriLength);
        } else {
            this.uriSchemeNames = null;
        }
    }

    /**
     * Gets the maximum number of entries in the Distribution Receivers List state.
     *
     * @return The maximum number of entries in the Distribution Receivers List state.
     */
    public getMaxReceiversListSize(): number {
        return this.maxReceiversListSize;
    }

    /**
     * Sets the maximum number of entries in the Distribution Receivers List state.
     *
     * @param maxReceiversListSize The maximum number of entries in the Distribution Receivers List state.
     */
    public setMaxReceiversListSize(maxReceiversListSize: number): void {
        this.maxReceiversListSize = maxReceiversListSize;
    }

    /**
     * Gets the maximum number of entries in the Firmware Images List state.
     *
     * @return The maximum number of entries in the Firmware Images List state.
     */
    public getMaxImagesListSize(): number {
        return this.maxImagesListSize;
    }

    /**
     * Sets the maximum number of entries in the Firmware Images List state.
     *
     * @param maxImagesListSize The maximum number of entries in the Firmware Images List state.
     */
    public setMaxImagesListSize(maxImagesListSize: number): void {
        this.maxImagesListSize = maxImagesListSize;
    }

    /**
     * Gets the maximum size of one firmware image (in octets).
     *
     * @return The maximum size of one firmware image (in octets).
     */
    public getMaxImageSize(): number {
        return this.maxImageSize;
    }

    /**
     * Sets the maximum size of one firmware image (in octets).
     *
     * @param maxImageSize The maximum size of one firmware image (in octets).
     */
    public setMaxImageSize(maxImageSize: number): void {
        this.maxImageSize = maxImageSize;
    }

    /**
     * Gets the total space dedicated to storage of firmware images (in octets).
     *
     * @return The total space dedicated to storage of firmware images (in octets).
     */
    public getMaxUploadSpace(): number {
        return this.maxUploadSpace;
    }

    /**
     * Sets the total space dedicated to storage of firmware images (in octets).
     *
     * @param maxUploadSpace The total space dedicated to storage of firmware images (in octets).
     */
    public setMaxUploadSpace(maxUploadSpace: number): void {
        this.maxUploadSpace = maxUploadSpace;
    }

    /**
     * Gets the remaining available space in firmware image storage (in octets).
     *
     * @return The remaining available space in firmware image storage (in octets).
     */
    public getRemainingUploadSpace(): number {
        return this.remainingUploadSpace;
    }

    /**
     * Sets the remaining available space in firmware image storage (in octets).
     *
     * @param remainingUploadSpace The remaining available space in firmware image storage (in octets).
     */
    public setRemainingUploadSpace(remainingUploadSpace: number): void {
        this.remainingUploadSpace = remainingUploadSpace;
    }

    /**
     * Gets the value indicating whether out-of-band retrieval is supported.
     *
     * @return The value indicating whether out-of-band retrieval is supported.
     */
    public getOobRetrievalSupported(): number {
        return this.oobRetrievalSupported;
    }

    /**
     * Sets the value indicating whether out-of-band retrieval is supported.
     *
     * @param oobRetrievalSupported The value indicating whether out-of-band retrieval is supported.
     */
    public setOobRetrievalSupported(oobRetrievalSupported: number): void {
        this.oobRetrievalSupported = oobRetrievalSupported;
    }

    /**
     * Gets the supported URI scheme names.
     *
     * @return The supported URI scheme names.
     */
    public getUriSchemeNames(): Uint8Array | null {
        return this.uriSchemeNames;
    }

    /**
     * Sets the supported URI scheme names.
     *
     * @param uriSchemeNames The supported URI scheme names.
     */
    public setUriSchemeNames(uriSchemeNames: Uint8Array | null): void {
        this.uriSchemeNames = uriSchemeNames;
    }
}