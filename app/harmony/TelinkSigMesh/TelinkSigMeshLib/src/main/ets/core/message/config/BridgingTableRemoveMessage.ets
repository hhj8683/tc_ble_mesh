/********************************************************************************************************
 * @file BridgingTableRemoveMessage.java
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
import { ByteOrder, num2bytes } from '../../../utils/ArrayUtils';
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';

/**
 * mesh message used to remove BridgingTable in a node
 * Created by kee on 2021/1/14.
 */
export class BridgingTableRemoveMessage extends ConfigMessage {
    /**
     * NetKey Index of the first subnet
     * 12 bits
     */
    public netKeyIndex1 = 0;
    /**
     * NetKey Index of the second subnet
     * 12 bits
     */
    public netKeyIndex2 = 0;
    /**
     * Address of the node in the first subnet
     * 16 bits
     */
    public address1 = 0;
    /**
     * Address of the node in the second subnet
     * 16 bits
     */
    public address2 = 0;

    /**
     * Creates a new BridgingTableRemoveMessage with the specified destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor(destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return Opcode.BRIDGING_TABLE_REMOVE;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode() {
        return Opcode.BRIDGING_TABLE_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        let netKeyIndexes = (this.netKeyIndex1 & 0x0FFF) | ((this.netKeyIndex2 & 0x0FFF) << 12);
        let indexBuf = num2bytes(netKeyIndexes, 3, ByteOrder.LITTLE_ENDIAN);

        let buf = new Uint8Array(7)
        let offset = 0
        buf.set(indexBuf, offset)
        offset += 3
        buf.set(num2bytes(this.address1, 2, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 2
        buf.set(num2bytes(this.address2, 2, ByteOrder.LITTLE_ENDIAN), offset)
        return buf
    }
}
