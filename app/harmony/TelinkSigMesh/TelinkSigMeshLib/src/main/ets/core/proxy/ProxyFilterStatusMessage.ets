/********************************************************************************************************
 * @file ProxyFilterStatusMessage.java
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

import { ByteOrder, bytes2Integer } from "../../utils/ArrayUtils";
import { ProxyConfigurationMessage } from "./ProxyConfigurationMessage";

/**
 * This class represents a Proxy Filter Status Message, which is a type of Proxy Configuration Message.
 */
const DATA_LEN = 4;

export class ProxyFilterStatusMessage extends ProxyConfigurationMessage {
    /**
     * The filter type (white list or black list).
     */
    public filterType: number = 0;
    /**
     * The number of addresses in the proxy filter list.
     */
    public listSize: number = 0;

    /**
     * Constructs a new ProxyFilterStatusMessage instance.
     */
    public constructor() {
        super();
    }

    /**
     * Converts a byte array to a ProxyFilterStatusMessage object.
     *
     * @param data The byte array containing the message data.
     * @return A ProxyFilterStatusMessage object if the byte array is valid, null otherwise.
     */
    public static fromBytes(data: Uint8Array): ProxyFilterStatusMessage | undefined {
        if (data.length != DATA_LEN) {
            return undefined;
        }
        let instance = new ProxyFilterStatusMessage();
        let index = 0;
        let opcode = data[index++];
        if (opcode != ProxyFilterStatusMessage.OPCODE_FILTER_STATUS) {
            return undefined;
        }
        instance.filterType = data[index++];
        instance.listSize = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        return instance;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode(): number {
        return ProxyFilterStatusMessage.OPCODE_FILTER_STATUS;
    }

    /**
     * Converts the ProxyFilterStatusMessage object to a byte array.
     *
     * @return A byte array representing the ProxyFilterStatusMessage object.
     */
    public toByteArray(): Uint8Array {
        // BIG_ENDIAN
        return new Uint8Array([this.getOpcode(), this.filterType, this.listSize >> 8, this.listSize])
    }
}