/********************************************************************************************************
 * @file     FriendSetMessage.ets 
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
 * @file FriendSetMessage.ets
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
import { EventBus } from '@nutpi/eventbus';
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';


/**
 * The Config Friend Set message is used to set the Friend state of a node.
 * It is an acknowledged message, meaning that a response is expected.
 * The response to a Config Friend Set message is a Config Friend Status message.
 * <p>
 * This message contains the new Friend state that is to be set.
 * <p>
 * Example usage:
 * FriendSetMessage message = FriendSetMessage.getSimple(destinationAddress, friend);
 * <p>
 * The message can then be sent to the destination address.
 * <p>
 * Note: The destination address should be specified when creating an instance of this message.
 *
 * @see FriendStatusMessage
 */
export class FriendSetMessage extends ConfigMessage {
    /**
     * The new Friend state to be set.
     */
    public friend = 0;

    /**
     * Creates a new FriendSetMessage with the specified destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor(destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Creates a simple instance of FriendSetMessage with the specified destination address and Friend state.
     *
     * @param destinationAddress The destination address of the message.
     * @param friend             The new Friend state to be set.
     * @return A simple instance of FriendSetMessage.
     */
    public static getSimple(destinationAddress: number, friend: number): FriendSetMessage {
        let instance = new FriendSetMessage(destinationAddress);
        instance.friend = friend;

        return instance;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return Opcode.CFG_FRIEND_SET;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_FRIEND_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        return new Uint8Array([this.friend])
    }
}