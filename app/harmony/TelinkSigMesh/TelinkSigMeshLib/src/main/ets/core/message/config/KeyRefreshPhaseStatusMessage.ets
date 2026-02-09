/********************************************************************************************************
 * @file     KeyRefreshPhaseStatusMessage.ets 
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
 * @file KeyRefreshPhaseStatusMessage.ets
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
import { ByteOrder, bytes2Integer } from "../../../utils/ArrayUtils";
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Key Refresh Phase Status is an unacknowledged message used to report the current Key Refresh Phase state of the identified network key
 * <p>
 * response of {@link KeyRefreshPhaseGetMessage} {@link KeyRefreshPhaseSetMessage}
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_KEY_REFRESH_PHASE_STATUS
 */
export class KeyRefreshPhaseStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "KeyRefreshPhaseStatusMessage"

    public statusName(): string {
        return KeyRefreshPhaseStatusMessage.STATUS_NAME
    }
    public status = 0;
    public netKeyIndex = 0;
    public phase = 0;

    /**
     * Parses the parameters of the KeyRefreshPhaseStatusMessage from a byte array.
     *
     * @param params the byte array containing the parameters of the KeyRefreshPhaseStatusMessage
     */
    public parse(params: Uint8Array) {
        let offset = 0;
        this.status = params[offset++];
        this.netKeyIndex = bytes2Integer(params, offset, 2, ByteOrder.LITTLE_ENDIAN);
        offset += 2;
        this.phase = params[offset];
    }

}
