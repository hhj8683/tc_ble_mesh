/********************************************************************************************************
 * @file NodeResetStatusMessage.ets
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
import { StatusMessage } from '../StatusMessage'

/**
 * The Config Node Reset Status is an unacknowledged message used to acknowledge that an element has received a Config Node Reset message.
 * The NodeResetStatusMessage class represents an unacknowledged message used to acknowledge that an element has received a Config Node Reset message.
 * It extends the StatusMessage class and implements the Parcelable interface.
 * <p>
 */
export class NodeResetStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "NodeResetStatusMessage"

    public statusName(): string {
        return NodeResetStatusMessage.STATUS_NAME
    }

    /**
     * This method is used to parse the byte array params.
     * It overrides the parse method of the StatusMessage class.
     *
     * @param params The byte array to be parsed.
     */
    public parse(params: Uint8Array) {
    }
}