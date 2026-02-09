/********************************************************************************************************
 * @file     BridgingTableAddMessage.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
/********************************************************************************************************
 * @file BridgingTableAddMessage.ets
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
 * mesh message used to add BridgingTable to a node
 * Created by kee on 2021/1/14.
 */
export class BridgingTableAddMessage extends ConfigMessage {
    /**
     * Allowed directions for the bridged traffic
     * 8 bits
     */
    public directions = 0;
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
     * Creates a new BridgingTableAddMessage with the specified destination address.
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
    public getOpcode(): number {
        return Opcode.BRIDGING_TABLE_ADD;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode(): number {
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
        let buf = new Uint8Array(8)
        let offset = 0
        buf[offset++] = this.directions
        buf.set(indexBuf, offset)
        offset += 3
        buf.set(num2bytes(this.address1, 2, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 2
        buf.set(num2bytes(this.address2, 2, ByteOrder.LITTLE_ENDIAN), offset)
        return buf
    }
}
