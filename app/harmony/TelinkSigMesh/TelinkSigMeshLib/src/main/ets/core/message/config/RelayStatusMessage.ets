/********************************************************************************************************
 * @file     RelayStatusMessage.ets 
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
 * @file RelayStatusMessage.ets
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
 * The Config Relay Status is an unacknowledged message used to report the current Relay and Relay Retransmit states of a node.
 * <p>
 * response of {@link RelayGetMessage} {@link RelaySetMessage}
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_RELAY_STATUS
 */
export class RelayStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "RelayStatusMessage"

    public statusName(): string {
        return RelayStatusMessage.STATUS_NAME
    }

    /**
     * 0x00 The node support Relay feature that is disabled
     * 0x01 The node supports Relay feature that is enabled
     * 0x02 Relay feature is not supported
     * 8 bits (1 byte)
     */
    public relay = 0;
    /**
     * 3 bits
     */
    public retransmitCount = 0;
    /**
     * Number of 10-millisecond steps between retransmissions
     * retransmission interval = (Relay Retransmit Interval Steps + 1) * 10
     * 5 bits
     */
    public retransmitIntervalSteps = 0;

    /**
     * Parses the byte array and sets the fields of the RelayStatusMessage object accordingly.
     *
     * @param params the byte array to parse
     */
    public parse(params: Uint8Array) {
        this.relay = params[0]
        this.retransmitCount = (params[1] & 0b111)
        this.retransmitIntervalSteps = (params[1] & 0xFF) >> 3
    }
}
