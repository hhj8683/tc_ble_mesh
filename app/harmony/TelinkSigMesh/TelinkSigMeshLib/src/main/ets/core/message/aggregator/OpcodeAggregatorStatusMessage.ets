/********************************************************************************************************
 * @file OpcodeAggregatorStatusMessage.ets
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
import { ArrayList } from '@kit.ArkTS';
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';
import { logd, logw } from '../../../utils/MeshLogger';
import { StatusMessage } from '../StatusMessage';
import { AggregatorItem } from './AggregatorItem';

/**
 * An OPCODES_AGGREGATOR_STATUS message is an unacknowledged message used to report status for the most recent operation
 * and response messages as a result of processing the Items field in an OPCODES_AGGREGATOR_SEQUENCE message.
 *
 * @see OpcodeAggregatorSequenceMessage
 */
export class OpcodeAggregatorStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "OpcodeAggregatorStatusMessage"

    public statusName(): string {
        return OpcodeAggregatorStatusMessage.STATUS_NAME
    }
    /**
     * 1 byte
     * Status Code for the requesting message
     */
    public status = 0;
    /**
     * 2 bytes
     */
    public elementAddress = 0;
    /**
     * List of status items with each status item containing an unacknowledged access layer message or empty item
     * Optional
     */
    public statusItems: ArrayList<AggregatorItem> = new ArrayList();

    /**
     * Parses the byte array to extract the params.
     *
     * @param params The byte array containing the params.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index++];
        this.elementAddress = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.statusItems = new ArrayList();
        while (params.length > index) {
            let isLong = (params[index] & 0b01) == 1;
            let len: number;
            let opAndParams: Uint8Array;
            if (isLong) {
                len = ((params[index + 1] & 0xFF) << 8) | ((params[index] & 0xFF) >> 1);
                index += 2;
            } else {
                len = (params[index] & 0xFF) >> 1;
                index += 1;
            }
            if (len == 0) {
                logw("parse err: aggregatorItem len 0");
                continue;
            }
            opAndParams = params.slice(index, len)
            let item = AggregatorItem.fromBytes(opAndParams);
            logd("parsed Aggregator Item : " + item.toString());
            this.statusItems.add(item);
            index += len;
        }

    }
}

