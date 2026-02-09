/********************************************************************************************************
 * @file NetKeyAddMessage.ets
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
import { ByteOrder, num2bytes } from "../../../utils/ArrayUtils";
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * The Config NetKey Add is an acknowledged message used to add a NetKey to a NetKey List on a node.
 * The added NetKey is then used by the node to authenticate and decrypt messages it receives, as well as authenticate and encrypt messages it sends.
 * <p>
 * The response to a Config NetKey Add message is a Config NetKey Status message.
 */

/**
 * This class represents a network key add message that is used to add a new network key to a device.
 * It extends the ConfigMessage class.
 */
export class NetKeyAddMessage extends ConfigMessage {
    public netKeyIndex = 0; // The index of the network key
    public netKey = new Uint8Array(0); // The network key


    /**
     * Constructs a NetKeyAddMessage object with the specified destination address, network key index, and network key.
     *
     * @param destinationAddress The destination address of the message.
     * @param netKeyIndex        The index of the network key.
     * @param netKey             The network key.
     */
    public static getSimple(destinationAddress: number, netKeyIndex: number, netKey: Uint8Array): NetKeyAddMessage {
        let instance = new NetKeyAddMessage(destinationAddress)
        instance.netKeyIndex = netKeyIndex;
        instance.netKey = netKey;
        return instance
    }

    /**
     * Returns the opcode of the message, which is NETKEY_ADD.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return Opcode.NETKEY_ADD
    }

    /**
     * Returns the response opcode of the message, which is NETKEY_STATUS.
     *
     * @return The response opcode of the message.
     */
    public getResponseOpcode() {
        return Opcode.NETKEY_STATUS
    }

    /**
     * Returns the parameters of the message as a byte array.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        let buf = new Uint8Array(2 + 16)
        buf.set(num2bytes(this.netKeyIndex, 2, ByteOrder.LITTLE_ENDIAN), 0)
        buf.set(this.netKey, 2)
        return buf
    }
}