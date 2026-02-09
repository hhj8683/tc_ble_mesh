/********************************************************************************************************
 * @file     OpcodeAggregatorSequenceMessage.ets 
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
 * @file OpcodeAggregatorSequenceMessage.ets
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
import { AccessType } from "../../networking/AccessType";
import { MeshMessage } from "../MeshMessage";
import { Opcode } from "../Opcode";

/**
 * An OPCODES_AGGREGATOR_SEQUENCE message is an acknowledged message
 * that the Opcodes Aggregator Client uses to encapsulate a sequence of access messages to be processed by the Opcodes Aggregator Server.
 * <p>
 * The response to an OPCODES_AGGREGATOR_SEQUENCE message is an OPCODES_AGGREGATOR_STATUS message.
 *
 * @see OpcodeAggregatorStatusMessage
 */
export class OpcodeAggregatorSequenceMessage extends MeshMessage {
    /**
     * @param accessType  message type, defines the encryption key
     * @param appKeyIndex used when access type is AccessType.APPLICATION
     */
    public constructor(destinationAddress: number,
        accessType: AccessType,
        appKeyIndex: number,
        params: Uint8Array
    ) {
        super();
        this.destinationAddress = destinationAddress;
        this.accessType = accessType;
        this.appKeyIndex = appKeyIndex;
        this.params = params;
    }

    /**
     * Returns the opcode value for the message.
     *
     * @return The opcode value for the message.
     */
    public getOpcode(): number {
        return Opcode.CFG_OP_AGG_SEQ
    }

    /**
     * Returns the response opcode value for the message.
     *
     * @return The response opcode value for the message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_OP_AGG_STATUS
    }
}
