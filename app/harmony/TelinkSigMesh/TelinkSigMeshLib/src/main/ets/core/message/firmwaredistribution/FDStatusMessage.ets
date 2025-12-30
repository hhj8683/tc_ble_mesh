/********************************************************************************************************
 * @file FDStatusMessage.ets
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

import { StatusMessage } from '../../message/StatusMessage';
import { DistributionStatus } from '../firmwareupdate/DistributionStatus';
import { DistributionPhase } from './DistributionPhase';
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';

/**
 * The Firmware Distribution Status message is an unacknowledged message sent by a Firmware Distribution Server
 * to report the status of a firmware image distribution.
 * A Firmware Distribution Status message is sent as a response to:
 * Firmware Distribution Get message,
 * Firmware Distribution Start message, Firmware Distribution Cancel message,
 * Firmware Distribution Apply message.
 */
export class FDStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FDStatusMessage"

    public statusName(): string {
        return FDStatusMessage.STATUS_NAME
    }

    /**
     * Status Code for the requesting message
     * 8 bits
     *
     * @see DistributionStatus
     */
    public status: DistributionStatus = DistributionStatus.SUCCESS;

    /**
     * Phase of the firmware image distribution
     * 8 bits
     *
     * @see DistributionPhase
     */
    public distPhase: DistributionPhase = DistributionPhase.IDLE;

    /**
     * Distribution Multicast Address
     * Multicast address used in firmware image distribution
     * (Optional)
     * 16 bits
     */
    public distMulticastAddress: number = 0;

    /**
     * Distribution AppKey Index
     * Index of an application key used in a firmware image distribution
     * 16 bits
     */
    public distAppKeyIndex: number = 0;

    /**
     * Distribution TTL
     * Time To Live value used in a firmware image distribution
     * 8 bits
     */
    public distTTL: number = 0;

    /**
     * Distribution Timeout Base
     * Used to compute the timeout of the firmware image distribution
     * 16 bits
     */
    public distTimeoutBase: number = 0;

    /**
     * Distribution Transfer Mode
     * Mode of the transfer
     * 2 bits
     */
    public distTransferMode: number = 0;

    /**
     * Firmware update policy
     * 1 bit
     */
    public updatePolicy: number = 0;

    /**
     * Reserved for Future Use
     * 5 bits
     */
    public RFU: number = 0;

    /**
     * The index of the firmware image in the Firmware Images List state
     * used during firmware image distribution
     * 16 bits
     */
    public distImageIndex: number = 0;

    constructor() {
        super();
    }

    /**
     * Parses the byte array to extract the parameters.
     *
     * @param params The byte array containing the parameters.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.status = params[index++] & 0xFF;
        this.distPhase = params[index++] & 0xFF;
        
        if (params.length === 2) {
            // Only status and phase are present
            return;
        }

        // Read multicast address if present (16 bits)
        this.distMulticastAddress = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        // Read AppKey index (16 bits)
        this.distAppKeyIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        // Read TTL (8 bits)
        this.distTTL = params[index++] & 0xFF;

        // Read timeout base (16 bits)
        this.distTimeoutBase = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        // Read transfer mode (2 bits), update policy (1 bit) and RFU (5 bits)
        const modePolicyRfu = params[index++];
        this.distTransferMode = modePolicyRfu & 0b11;
        this.updatePolicy = (modePolicyRfu >> 2) & 0b1;
        this.RFU = (modePolicyRfu >> 3) & 0b11111;

        // Read image index (16 bits)
        this.distImageIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

    /**
     * Returns a string representation of the FDStatusMessage object.
     *
     * @return A string representation of the FDStatusMessage object.
     */
    public toString(): string {
        return `FDStatusMessage{
            status=${DistributionStatus[this.status]},
            distPhase=${DistributionPhase[this.distPhase]},
            distMulticastAddress=${this.distMulticastAddress},
            distAppKeyIndex=${this.distAppKeyIndex},
            distTTL=${this.distTTL},
            distTimeoutBase=${this.distTimeoutBase},
            distTransferMode=${this.distTransferMode},
            updatePolicy=${this.updatePolicy},
            RFU=${this.RFU},
            distImageIndex=${this.distImageIndex}
        }`;
    }
}