/********************************************************************************************************
 * @file DefaultTTLStatusMessage.ets
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
import { StatusMessage } from '../StatusMessage';


/**
 * The Config Default TTL Status is an unacknowledged message used to report the current Default TTL state of a node
 * The DefaultTTLStatusMessage class represents an unacknowledged message used to report the current Default TTL state of a node.
 * It is the response to DefaultTTLSetMessage and DefaultTTLGetMessage.
 * response of {@link DefaultTTLSetMessage} {@link DefaultTTLGetMessage}
 * <p>
 * This message has an opcode of CFG_DEFAULT_TTL_STATUS.
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_DEFAULT_TTL_STATUS
 */
export class DefaultTTLStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "DefaultTTLStatusMessage"

    public statusName(): string {
        return DefaultTTLStatusMessage.STATUS_NAME
    }

    /**
     * Default TTL value
     */
    public ttl = 0;

    /**
     * Parses the parameters of the DefaultTTLStatusMessage from a byte array.
     *
     * @param params the byte array containing the parameters of the DefaultTTLStatusMessage
     */
    public parse(params: Uint8Array) {
        this.ttl = params[0];
    }
}