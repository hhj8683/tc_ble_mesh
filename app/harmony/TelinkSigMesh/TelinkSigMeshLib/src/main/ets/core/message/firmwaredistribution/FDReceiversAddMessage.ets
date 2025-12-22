/********************************************************************************************************
 * @file FDReceiversAddMessage.ets
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
 * This class represents a message for adding receivers in a Firmware Distribution (FD) operation.
 * It extends the UpdatingMessage class.
 * The message contains a list of ReceiverEntry objects, where each entry represents a receiver.
 * Each receiver entry consists of a 2-byte unicast address and a 1-byte firmware image index.
 * The message is used to add receivers for updating firmware in a specific destination address and application key index.
 * The opcode for this message is FD_RECEIVERS_ADD.
 * The response opcode for this message is FD_RECEIVERS_STATUS.
 * The getParams() method converts the list of receiver entries into a byte array by allocating 3 bytes for each entry.
 * The byte array is then returned as the parameters for the message.
 */
export class FDReceiversAddMessage extends UpdatingMessage {
    /**
     * Receiver Entry: every entry is 3 bytes
     */
    public entries: Array<ReceiverEntry> = [];

    /**
     * Constructs a new FDReceiversAddMessage with the specified destination address and application key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Creates a simple FDReceiversAddMessage with the specified destination address, application key index, and receiver entries.
     * The response maximum is set to 1.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     * @param entries The list of receiver entries for the message.
     * @return The created FDReceiversAddMessage.
     */
    public static getSimple(destinationAddress: number, appKeyIndex: number, entries: Array<ReceiverEntry>): FDReceiversAddMessage {
        const message = new FDReceiversAddMessage(destinationAddress, appKeyIndex);
        message.entries = entries;
        message.responseMax = 1;
        return message;
    }

    /**
     * Gets the opcode for the message.
     *
     * @return The opcode for the message (FD_RECEIVERS_ADD).
     */
    public override getOpcode(): number {
        return Opcode.FD_RECEIVERS_ADD;
    }

    /**
     * Gets the response opcode for the message.
     *
     * @return The response opcode for the message (FD_RECEIVERS_STATUS).
     */
    public override getResponseOpcode(): number {
        return Opcode.FD_RECEIVERS_STATUS;
    }

    /**
     * Converts the list of receiver entries into a byte array.
     *
     * @return The byte array representing the receiver entries.
     */
    public override getParams(): Uint8Array {
        if (!this.entries || this.entries.length === 0) {
            return new Uint8Array(0);
        }
        
        const buffer = new ArrayBuffer(3 * this.entries.length);
        const dataView = new DataView(buffer);
        let offset = 0;
        
        for (const entry of this.entries) {
            dataView.setUint16(offset, entry.address, true); // little-endian
            offset += 2;
            dataView.setUint8(offset, entry.imageIndex);
            offset += 1;
        }
        
        return new Uint8Array(buffer);
    }
}

/**
 * This class represents a receiver entry in the FDReceiversAddMessage.
 * Each entry contains a 2-byte unicast address and a 1-byte firmware image index.
 */
export class ReceiverEntry {
    /**
     * The unicast address of the Updating node
     * 2 bytes
     */
    public address: number = 0;

    /**
     * Update Firmware Image Index
     * The index of the firmware image in the Firmware Information List state to be updated
     * 1 byte
     */
    public imageIndex: number = 0;

    /**
     * Constructs a new ReceiverEntry with the specified unicast address and firmware image index.
     *
     * @param address The unicast address of the updating node.
     * @param imageIndex The index of the firmware image in the Firmware Information List state to be updated.
     */
    constructor(address: number, imageIndex: number) {
        this.address = address;
        this.imageIndex = imageIndex;
    }
}