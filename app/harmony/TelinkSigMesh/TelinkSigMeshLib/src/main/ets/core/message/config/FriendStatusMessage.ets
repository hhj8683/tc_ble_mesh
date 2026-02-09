/********************************************************************************************************
 * @file     FriendStatusMessage.ets 
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
 * @file FriendStatusMessage.ets
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
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Friend Status is an unacknowledged message used to report the current Friend state of a node
 * The FriendStatusMessage class represents an unacknowledged message used to report the current Friend state of a node.
 * This message is a response to FriendGetMessage and FriendSetMessage.
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_FRIEND_STATUS
 */
export class FriendStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FriendStatusMessage"

    public statusName(): string {
        return FriendStatusMessage.STATUS_NAME
    }

    /**
     * The Friend state of the node.
     */
    public friend = 0;

    /**
     * Default constructor for the FriendStatusMessage class.
     */

    /**
     * Parses the message parameters.
     *
     * @param params The byte array containing the message parameters.
     */
    public parse(params: Uint8Array) {
        this.friend = params[0];
    }
}