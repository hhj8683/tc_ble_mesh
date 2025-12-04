/********************************************************************************************************
 * @file BridgingTableStatusMessage.java
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
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';
import { StatusMessage } from '../StatusMessage';

/**
 * Created by kee on 2021/1/14.
 */
export  class BridgingTableStatusMessage extends StatusMessage  {
    public static readonly STATUS_NAME = "BridgingTableStatusMessage"

    public statusName(): string {
        return BridgingTableStatusMessage.STATUS_NAME
    }
    /**
     * Status Code for the requesting message
     * 8 bits
     */
    public  status = 0;

    /**
     * Allowed directions for bridged traffic or bridged traffic not allowed
     * 8 bits
     */
    public  currentDirections = 0;

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
    public  address2 = 0;



    /**
     * Parses the parameters of the BridgingTableStatusMessage from a byte array.
     *
     * @param params the byte array containing the parameters of the BridgingTableStatusMessage
     */
    public  parse( params: Uint8Array) {
        let index = 0;
        this.status = params[index++] & 0xFF;
        this.currentDirections = params[index++];

        let netKeyIndexes = bytes2Integer(new Uint8Array([
                params[index++], params[index++], params[index++],
        ]), ByteOrder.LITTLE_ENDIAN);

        this.netKeyIndex1 = netKeyIndexes & 0x0FFF;
        this.netKeyIndex2 = (netKeyIndexes >> 12) & 0x0FFF;


        this.address1 = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.address2 = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }

}
