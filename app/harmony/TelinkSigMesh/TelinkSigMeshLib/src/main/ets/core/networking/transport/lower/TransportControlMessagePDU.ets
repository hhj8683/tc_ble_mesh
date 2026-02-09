/********************************************************************************************************
 * @file     TransportControlMessagePDU.ets 
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
 * @file TransportControlMessagePDU.ets
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
import { LowerTransportPDU }from "./LowerTransportPDU";


/**
 * This class represents a transport control message PDU (Protocol Data Unit) used in a lower transport layer.
 * It extends the "LowerTransportPDU" class.
 * <p>
 * The class defines two static final integer variables:
 * - CONTROL_MESSAGE_OPCODE_SEG_ACK: Represents the opcode for a segment acknowledgement control message.
 * Its value is 0x00.
 * - CONTROL_MESSAGE_OPCODE_HEARTBEAT: Represents the opcode for a heartbeat control message.
 * Its value is 0x0A.
 * <p>
 * This class is abstract and cannot be instantiated directly.
 */
export abstract class TransportControlMessagePDU extends LowerTransportPDU {

    public static readonly  CONTROL_MESSAGE_OPCODE_SEG_ACK = 0x00;


    /*
    other values defined in
    spec#3.6.5.11 Summary of opcodes
     */

    public static readonly  CONTROL_MESSAGE_OPCODE_HEARTBEAT = 0x0A;

}
