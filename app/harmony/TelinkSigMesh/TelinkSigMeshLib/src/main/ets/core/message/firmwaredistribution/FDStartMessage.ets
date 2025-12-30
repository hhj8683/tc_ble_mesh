/********************************************************************************************************
 * @file FDStartMessage.ets
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
 * The Firmware Distribution Start message is an acknowledged message sent by a Firmware Distribution Client
 * to start the firmware image distribution to the Updating nodes in the Distribution Receivers List.
 * The response to a Firmware Distribution Start message is a Firmware Distribution Status message.
 */
export class FDStartMessage extends UpdatingMessage {
    /**
     * Distribution AppKey Index
     * Index of the application key used in a firmware image distribution
     * 16 bits
     */
    public distributionAppKeyIndex: number = 0;

    /**
     * Distribution TTL
     * Time To Live value used in a firmware image distribution
     * 8 bits
     */
    public distributionTTL: number = 0;

    /**
     * Distribution Timeout Base
     * Used to compute the timeout of the firmware image distribution
     * 16 bits
     */
    public distributionTimeoutBase: number = 0;

    /**
     * Distribution Transfer Mode
     * Mode of the transfer
     * 2 bits
     */
    public distributionTransferMode: number = 0;

    /**
     * Update Policy
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
     * Distribution Firmware Image Index
     * Index of the firmware image in the Firmware Images List state to use during firmware image distribution
     * 16 bits
     */
    public distributionImageIndex: number = 0;

    /**
     * Distribution Multicast Address
     * Multicast address used in a firmware image distribution
     * 16 or 128 bits
     * 16 bit group address currently
     */
    public distributionMulticastAddress: number = 0;

    /**
     * Constructs a new FDStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDStartMessage object with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex The index of the application key used for encryption.
     * @return The created FDStartMessage object.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FDStartMessage {
        const message = new FDStartMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode value for the FDStartMessage.
     *
     * @return The opcode value.
     */
    public override getOpcode(): number {
        return Opcode.FD_START;
    }

    /**
     * Gets the response opcode value for the FDStartMessage.
     *
     * @return The response opcode value.
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_STATUS;
    }

    /**
     * Gets the byte array representation of the parameters in the FDStartMessage.
     *
     * @return The byte array representation of the parameters.
     */
    public override getParams(): Uint8Array {
        const modePolicyType = (this.distributionTransferMode & 0b11) | ((this.updatePolicy & 0b1) << 2);

        const buffer = new ArrayBuffer(10); // 2 + 1 + 2 + 1 + 2 + 2 = 10 bytes
        const view = new DataView(buffer);

        view.setUint16(0, this.distributionAppKeyIndex, true); // little-endian
        view.setUint8(2, this.distributionTTL);
        view.setUint16(3, this.distributionTimeoutBase, true);
        view.setUint8(5, modePolicyType);
        view.setUint16(6, this.distributionImageIndex, true);
        view.setUint16(8, this.distributionMulticastAddress, true);

        return new Uint8Array(buffer);
    }
}