/********************************************************************************************************
 * @file NetKeyStatusMessage.ets
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
 * The Config NetKey Status is an unacknowledged message used to report the status of the operation on the NetKey List.
 */
export class NetKeyStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "NetKeyStatusMessage"

    public statusName(): string {
        return NetKeyStatusMessage.STATUS_NAME
    }

    /**
     * 1 byte
     * Status Code for the requesting message
     */
    public status = 0;
    /**
     * 2 bytes
     * Index of the NetKey
     */
    public netKeyIndex = 0;

    /**
     * Parses the given byte array and sets the status and netKeyIndex values accordingly.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index++] & 0xFF;
        this.netKeyIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
    }
}