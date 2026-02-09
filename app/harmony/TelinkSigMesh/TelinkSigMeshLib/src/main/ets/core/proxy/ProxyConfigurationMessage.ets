/********************************************************************************************************
 * @file     ProxyConfigurationMessage.ets 
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
 * @file ProxyConfigurationMessage.ets
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

/**
 * This abstract class represents a proxy configuration message.
 * It provides constants for different types of proxy configuration messages.
 * Subclasses of this class should implement the getOpcode() and toByteArray() methods.
 */
export abstract class ProxyConfigurationMessage {
    /**
     * Set Filter Type
     * Sent by a Proxy Client to set the proxy filter typeValue.
     */
    public static readonly OPCODE_SET_FILTER_TYPE = 0x00;
    /**
     * Add Addresses To Filter
     * Sent by a Proxy Client to add addresses to the proxy filter list.
     */
    public static readonly OPCODE_ADD_ADDRESS = 0x01;
    /**
     * Remove Addresses From Filter
     * Sent by a Proxy Client to remove addresses from the proxy filter list.
     */
    public static readonly OPCODE_REMOVE_ADDRESS = 0x02;
    /**
     * Filter Status
     * Acknowledgment by a Proxy Server to a Proxy Client to report the status of the proxy filter list.
     */
    public static readonly OPCODE_FILTER_STATUS = 0x03;

    /**
     * @return message opcode
     */
    public abstract getOpcode(): number;

    /**
     * @return message data
     */
    public abstract toByteArray(): Uint8Array;
}
