/********************************************************************************************************
 * @file FirmwareUpdateGetMessage.ets
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
 * This class represents a message for requesting firmware update information from a device.
 * It extends the UpdatingMessage class.
 */
export class FirmwareUpdateInfoGetMessage extends UpdatingMessage {
    /**
     * Index of the first requested entry from the Firmware Information List state.
     * This is a 1-byte value.
     */
    private firstIndex: number;

    /**
     * Maximum number of entries that the server includes in a Firmware Update Information Status message.
     * This is a 1-byte value.
     */
    private entriesLimit: number;

    /**
     * Creates a new instance of FirmwareUpdateInfoGetMessage with the specified destination address and app key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex        The app key index for the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.firstIndex = 0;
        this.entriesLimit = 0;
    }

    /**
     * Returns the opcode value for the Firmware Update Information Get message.
     *
     * @returns The opcode value for the message.
     */
    public getOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_INFORMATION_GET;
    }

    /**
     * Returns the opcode value for the Firmware Update Information Status message, which is the response to the Get message.
     *
     * @returns The opcode value for the response message.
     */
    public getResponseOpcode(): number {
        return Opcode.FIRMWARE_UPDATE_INFORMATION_STATUS;
    }

    /**
     * Returns the parameters of the message as a byte array.
     *
     * @returns The parameters of the message.
     */
    public getParams(): Uint8Array {
        let buf = new Uint8Array(2);
        buf[0] = this.firstIndex;
        buf[1] = this.entriesLimit;
        return buf;
    }

    /**
     * Sets the value of the firstIndex parameter.
     *
     * @param firstIndex The value to set.
     */
    public setFirstIndex(firstIndex: number): void {
        this.firstIndex = firstIndex;
    }

    /**
     * Sets the value of the entriesLimit parameter.
     *
     * @param entriesLimit The value to set.
     */
    public setEntriesLimit(entriesLimit: number): void {
        this.entriesLimit = entriesLimit;
    }

    /**
     * Creates a simple FirmwareUpdateInfoGetMessage with the specified destination address and app key index.
     * The response max is set to 1, the firstIndex is set to 0, and the entriesLimit is set to 1.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex        The app key index for the message.
     * @returns The created FirmwareUpdateInfoGetMessage.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number): FirmwareUpdateInfoGetMessage {
        let message = new FirmwareUpdateInfoGetMessage(destinationAddress, appKeyIndex);
        message.responseMax = 1;
        message.setFirstIndex(0);
        message.setEntriesLimit(1);
        return message;
    }
}