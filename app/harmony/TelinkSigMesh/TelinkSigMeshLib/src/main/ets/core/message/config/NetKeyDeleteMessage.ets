/********************************************************************************************************
 * @file NetKeyDeleteMessage.java
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
import { num2bytes } from '../../../utils/ArrayUtils';
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';

/**
 * The NetKeyDeleteMessage class represents a Config NetKey Delete message.
 * This message is used to delete a NetKey from a NetKey List on a node.
 * <p>
 * The message is sent to the destination address specified in the constructor.
 * <p>
 * The Config NetKey Delete is an acknowledged message used to delete a NetKey on a NetKey List from a node.
 * The response to this message is a Config NetKey Status message.
 */
export class NetKeyDeleteMessage extends ConfigMessage {
    // The index of the NetKey to be deleted
    public netKeyIndex = 0;

    /**
     * Constructs a NetKeyDeleteMessage object with the specified destination address and NetKey index.
     *
     * @param destinationAddress The destination address for the message.
     * @param netKeyIndex        The index of the NetKey to be deleted.
     */
    public static getSimple(destinationAddress: number, netKeyIndex: number): NetKeyDeleteMessage {
        let instance = new NetKeyDeleteMessage(destinationAddress);
        instance.netKeyIndex = netKeyIndex;
        return instance
    }

    /**
     * Returns the opcode for the NetKey Delete message.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.NETKEY_DEL
    }

    /**
     * Returns the opcode for the response to the NetKey Delete message.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.NETKEY_STATUS
    }

    /**
     * Returns the parameters of the NetKey Delete message as a byte array.
     *
     * @return The parameters byte array.
     */
    public getParams() {
        let buf = num2bytes(this.netKeyIndex, 2)
        return buf
    }
}
