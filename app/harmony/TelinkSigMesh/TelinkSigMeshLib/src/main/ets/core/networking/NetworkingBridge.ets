/********************************************************************************************************
 * @file     NetworkingBridge.ets 
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
 * @file NetworkingBridge.ets
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
 * This interface represents a bridge for networking operations.
 */
export interface NetworkingBridge {

    /**
     * This method is called when a command is prepared to be sent over the network.
     *
     * @param type proxy pdu typeValue {@link ProxyPDU#type}
     * @param data gatt data
     */
    onCommandPrepared(type: number, data: Uint8Array): void

    /**
     * application layer should save updated network info
     * This method is called when the network information is updated.
     *
     * @param sequenceNumber The sequence number.
     * @param ivIndex        The IV index.
     */
    onNetworkInfoUpdate(sequenceNumber: Number, ivIndex: Number): void

    /**
     * mesh model message
     * This method is called when a mesh model message is received.
     *
     * @param src    The source address.
     * @param dst    The destination address.
     * @param opcode The opcode of the message.
     * @param params The parameters of the message.
     */
    onMeshMessageReceived(src: number, dst: number, opcode: number, params?: Uint8Array): void

    /**
     * received proxy status message when set filter type, or add/remove address
     *
     * @param success True if the initialization was successful, false otherwise.
     * @param address The unicast address of the connected node.
     */
    onProxyInitComplete(success: boolean, address: number): void

    /**
     * heartbeat message received
     *
     * @param data heartbeat data
     */
    onHeartbeatMessageReceived(src: number, dst: number, data: Uint8Array): void

    /**
     * This method is called when a reliable message is complete.
     *
     * @param success  True if the response was received, false otherwise.
     * @param opcode   The command opcode.
     * @param destAdr  The command destination address.
     * @param rspMax   The maximum expected response count.
     * @param rspCount The received response count.
     * @param rspArr   The replied address array
     */
    onReliableMessageComplete(success: boolean, opcode: number,
        destAdr: number, rspMax: number, rspCount: number, rspArr: Uint16Array): void

    /**
     * This method is called when a segment message is complete.
     *
     * @param success True if the segment message was successfully received, false otherwise.
     */
    onSegmentMessageComplete(success: boolean): void
}
