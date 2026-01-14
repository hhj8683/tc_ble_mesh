/********************************************************************************************************
 * @file FirmwareUpdateConfiguration.ets
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

import { BlobTransferType } from '../core/access/fu/BlobTransferType';
import { DistributorType } from '../core/access/fu/DistributorType';
import { FUState } from '../core/access/fu/FUState';
import { UpdatePolicy } from '../core/access/fu/UpdatePolicy';
import { ExtendBearerMode } from '../core/networking/ExtendBearerMode';
import { MeshUpdatingDevice } from './MeshUpdatingDevice';

/**
 * Callback interface for firmware update events
 */
export interface FUCallback {
    onTransferProgress(progress: number, transferType: BlobTransferType): void;
    onLog(tag: string, log: string, logLevel: number): void;
    onStateUpdated(fuState: FUState, info: string): void;
    onDeviceStateUpdate(device: MeshUpdatingDevice, desc: string): void;
}

/**
 * Represents the configuration for a firmware update.
 * Contains various parameters and settings related to the update process.
 */
export class FirmwareUpdateConfiguration {
    // Target devices for updating
    private updatingDevices: Array<MeshUpdatingDevice> = [];

    // Firmware data (null if isContinue is true)
    private firmwareData: Uint8Array = new Uint8Array(0);

    // Metadata
    private metadata: Uint8Array = new Uint8Array(0);

    // Application key index
    private appKeyIndex: number = 0;

    // Group address for subscription message
    private groupAddress: number = 0;

    // BLOB ID
    private blobId: number = 0x8877665544332211;

    // Firmware ID
    private firmwareId: Uint8Array = new Uint8Array([0x01, 0x02, 0x03, 0x04]);

    // Firmware index
    private firmwareIndex: number = 0;

    // Extended bearer mode
    private extendBearerMode: ExtendBearerMode | null = null;

    // Distributor type (0 means using APP as distributor)
    private distributorType: DistributorType = DistributorType.PHONE;

    // Callback for update events
    private callback: FUCallback | null = null;

    // Update policy
    private updatePolicy: UpdatePolicy = UpdatePolicy.VerifyAndApply;

    // Is continue flag
    private isContinue: boolean = false;

    // Distributor address (used when isContinue is true)
    private distributorAddress: number = 0;

    // Proxy address
    private proxyAddress: number = 0;

    // Network interval
    private networkInterval: number = 240;

    /**
     * Constructs a new FirmwareUpdateConfiguration object with the given parameters.
     */
    constructor(
        updatingDevices: Array<MeshUpdatingDevice>,
        firmwareData: Uint8Array,
        metadata: Uint8Array,
        appKeyIndex: number,
        groupAddress: number
    ) {
        this.updatingDevices = updatingDevices;
        this.firmwareData = firmwareData;
        this.metadata = metadata;
        this.appKeyIndex = appKeyIndex;
        this.groupAddress = groupAddress;
    }

    /**
     * Get target devices for updating
     */
    public getUpdatingDevices(): Array<MeshUpdatingDevice> {
        return this.updatingDevices;
    }

    /**
     * Get firmware data
     */
    public getFirmwareData(): Uint8Array {
        return this.firmwareData;
    }

    /**
     * Get application key index
     */
    public getAppKeyIndex(): number {
        return this.appKeyIndex;
    }

    /**
     * Get group address
     */
    public getGroupAddress(): number {
        return this.groupAddress;
    }

    /**
     * Get BLOB ID
     */
    public getBlobId(): number {
        return this.blobId;
    }

    /**
     * Get extended bearer mode
     */
    public getExtendBearerMode(): ExtendBearerMode | null {
        return this.extendBearerMode;
    }

    /**
     * Set extended bearer mode
     */
    public setExtendBearerMode(extendBearerMode: ExtendBearerMode): void {
        this.extendBearerMode = extendBearerMode;
    }

    /**
     * Get metadata
     */
    public getMetadata(): Uint8Array {
        return this.metadata;
    }

    /**
     * Get firmware ID
     */
    public getFirmwareId(): Uint8Array {
        return this.firmwareId;
    }

    /**
     * Set firmware ID
     */
    public setFirmwareId(firmwareId: Uint8Array): void {
        this.firmwareId = firmwareId;
    }

    /**
     * Get firmware index
     */
    public getFirmwareIndex(): number {
        return this.firmwareIndex;
    }

    /**
     * Set firmware index
     */
    public setFirmwareIndex(firmwareIndex: number): void {
        this.firmwareIndex = firmwareIndex;
    }

    /**
     * Get callback
     */
    public getCallback(): FUCallback | null {
        return this.callback;
    }

    /**
     * Set callback
     */
    public setCallback(callback: FUCallback | null): void {
        this.callback = callback;
    }

    /**
     * Get update policy
     */
    public getUpdatePolicy(): UpdatePolicy {
        return this.updatePolicy;
    }

    /**
     * Get distributor type
     */
    public getDistributorType(): DistributorType {
        return this.distributorType;
    }

    /**
     * Set distributor type
     */
    public setDistributorType(distributorType: DistributorType): void {
        this.distributorType = distributorType;
    }

    /**
     * Set update policy
     */
    public setUpdatePolicy(updatePolicy: UpdatePolicy): void {
        this.updatePolicy = updatePolicy;
    }

    /**
     * Check if is continue
     */
    public getIsContinue(): boolean {
        return this.isContinue;
    }

    /**
     * Set is continue
     */
    public setContinue(aContinue: boolean): void {
        this.isContinue = aContinue;
    }

    /**
     * Get distributor address
     */
    public getDistributorAddress(): number {
        return this.distributorAddress;
    }

    /**
     * Set distributor address
     */
    public setDistributorAddress(distributorAddress: number): void {
        this.distributorAddress = distributorAddress;
    }

    /**
     * Dispatch transfer progress event
     */
    public dispatchTransferProgress(progress: number, transferType: BlobTransferType): void {
        if (this.callback) {
            this.callback.onTransferProgress(progress, transferType);
        }
    }

    /**
     * Get network interval
     */
    public getNetworkInterval(): number {
        return this.networkInterval;
    }

    /**
     * Set network interval
     */
    public setNetworkInterval(networkInterval: number): void {
        this.networkInterval = networkInterval;
    }

    /**
     * Dispatch log information
     */
    public dispatchLogInfo(tag: string, log: string, logLevel: number): void {
        if (this.callback) {
            this.callback.onLog(tag, log, logLevel);
        }
    }

    /**
     * Dispatch firmware update state
     */
    public dispatchFUState(fuState: FUState, info: string): void {
        if (this.callback) {
            this.callback.onStateUpdated(fuState, info);
        }
    }

    /**
     * Dispatch device state update
     */
    public dispatchDeviceState(updatingDevice: MeshUpdatingDevice, desc: string): void {
        if (this.callback) {
            this.callback.onDeviceStateUpdate(updatingDevice, desc);
        }
    }

    /**
     * Get proxy address
     */
    public getProxyAddress(): number {
        return this.proxyAddress;
    }

    /**
     * Set proxy address
     */
    public setProxyAddress(proxyAddress: number): void {
        this.proxyAddress = proxyAddress;
    }

    /**
     * Get string representation of the object
     */
    public toString(): string {
        return `FirmwareUpdateConfiguration{
            updatingDevices=${this.updatingDevices.length},
            firmwareData=${this.firmwareData?.length || 0},
            metadata=${this.metadata?.toString() || 'null'},
            appKeyIndex=${this.appKeyIndex},
            groupAddress=${this.groupAddress},
            blobId=${this.blobId.toString(16)},
            firmwareId=${this.firmwareId?.toString() || 'null'},
            firmwareIndex=${this.firmwareIndex},
            distributorType=${this.distributorType},
            callback=${this.callback},
            updatePolicy=${this.updatePolicy},
            isContinue=${this.isContinue},
            distributorAddress=${this.distributorAddress},
            proxyAddress=${this.proxyAddress}
        }`;
    }

    /**
     * Get brief description for UI display
     */
    public getBriefDesc(extendBearerMode: ExtendBearerMode): string {
        return `FU Params{
            updatingDevices=${this.updatingDevices.length},
            firmwareData=${this.firmwareData?.length || 0},
            metadata=${this.metadata?.toString() || 'null'},
            appKeyIndex=${this.appKeyIndex},
            groupAddress=${this.groupAddress.toString(16).padStart(4, '0')},
            blobId=${this.blobId.toString(16).padStart(16, '0')},
            firmwareId=${this.firmwareId?.toString() || 'null'},
            firmwareIndex=${this.firmwareIndex},
            distributorType=${this.distributorType},
            updatePolicy=${this.updatePolicy},
            isContinue=${this.isContinue},
            distributorAddress=${this.distributorAddress.toString(16).padStart(4, '0')},
            proxyAddress=${this.proxyAddress.toString(16).padStart(4, '0')},
            extendBearerMode=${extendBearerMode},
            networkInterval=${this.networkInterval}
        }`;
    }
}