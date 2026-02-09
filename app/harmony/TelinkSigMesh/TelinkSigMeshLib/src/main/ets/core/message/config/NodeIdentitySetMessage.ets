/********************************************************************************************************
 * @file     NodeIdentitySetMessage.ets 
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
 * @file NodeIdentitySetMessage.ets
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
 * The Config Node Identity Set is a message used to set the current Node Identity state for a subnet.
 * It is an acknowledged message, meaning that the sender expects a response.
 * The response to a Config Node Identity Set message is a Config Node Identity Status message.
 * {@link NodeIdentityStatusMessage}
 */
export class NodeIdentitySetMessage extends ConfigMessage {
    // Variables
    public netKeyIndex = 0;
    public identity = 0;

    /**
     * Creates a new NodeIdentitySetMessage with the given destination address.
     *
     * @param destinationAddress The destination address for the message.
     */
    public constructor(destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Creates a simple NodeIdentitySetMessage with the given destination address, netKeyIndex, and identity.
     *
     * @param destinationAddress The destination address for the message.
     * @param netKeyIndex        The netKey index to set.
     * @param identity           The identity to set.
     * @return The created NodeIdentitySetMessage.
     */
    public static getSimple(destinationAddress: number, netKeyIndex: number, identity: number): NodeIdentitySetMessage {
        let message = new NodeIdentitySetMessage(destinationAddress);
        message.netKeyIndex = netKeyIndex;
        message.identity = identity;
        return message;
    }

    /**
     * Gets the opcode for the NodeIdentitySetMessage.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.NODE_ID_SET;
    }

    /**
     * Gets the response opcode for the NodeIdentitySetMessage.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.NODE_ID_STATUS;
    }

    /**
     * Gets the parameters for the NodeIdentitySetMessage.
     *
     * @return The parameters as a byte array.
     */
    public getParams(): Uint8Array {
        // netKey index lower 12 bits
        let netAppKeyIndex = (this.netKeyIndex & 0x0FFF);
        let paramsBuffer = new Uint8Array(3)
        paramsBuffer.set(num2bytes(netAppKeyIndex, 2), 0)
        paramsBuffer[2] = this.identity
        return paramsBuffer
    }
}