/********************************************************************************************************
 * @file     KeyRefreshPhaseGetMessage.ets 
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
 * @file KeyRefreshPhaseGetMessage.ets
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
import { num2bytes } from "../../../utils/ArrayUtils";
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * The Config Key Refresh Phase Get is an acknowledged message used to get the current Key Refresh Phase state of the identified network key.
 * This class represents a message used to get the key refresh phase in a configuration.
 * It extends the ConfigMessage class.
 */
export class KeyRefreshPhaseGetMessage extends ConfigMessage {
    /**
     * The index of the network key.
     */
    public netKeyIndex = 0;

    /**
     * Creates a new instance of KeyRefreshPhaseGetMessage with the specified destination address and network key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param netKeyIndex        The index of the network key.
     * @return A new instance of KeyRefreshPhaseGetMessage.
     */
    public static getSimple(destinationAddress: number, netKeyIndex: number): KeyRefreshPhaseGetMessage {
        let instance = new KeyRefreshPhaseGetMessage(destinationAddress);
        instance.netKeyIndex = netKeyIndex;
        return instance;
    }

    /**
     * Gets the opcode for the message.
     *
     * @return The opcode for the message.
     */
    public getOpcode() {
        return Opcode.CFG_KEY_REFRESH_PHASE_GET
    }

    /**
     * Gets the opcode for the response to the message.
     *
     * @return The opcode for the response to the message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_KEY_REFRESH_PHASE_STATUS
    }

    /**
     * Gets the parameters for the message.
     *
     * @return The parameters for the message.
     */
    public getParams(): Uint8Array | undefined {
        return num2bytes(this.netKeyIndex, 2)
    }
}