/********************************************************************************************************
 * @file ModelSubscriptionStatusMessage.java
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

import { ModelPublication } from "../../../entity/ModelPublication";
import { ByteOrder, bytes2Integer, num2Hex } from "../../../utils/ArrayUtils";
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Model Subscription Status is an unacknowledged message used to report a status of the operation on the Subscription List
 */

/**
 * The ModelSubscriptionStatusMessage class represents an unacknowledged message used to report the status of an operation on the Subscription List in the Config Model.
 */

export class ModelPublicationStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "ModelPublicationStatusMessage"

    public statusName(): string {
        return ModelPublicationStatusMessage.STATUS_NAME
    }

    /**
     * The status code for the requesting message.
     */
    public status = 0;
    /**
     * The model publication information.
     */
    public  publication?: ModelPublication;

    /**
     * Parses the byte array data and populates the fields of the ModelPublicationStatusMessage object.
     *
     * @param data The byte array data to parse.
     */
    public parse(data: Uint8Array) {
        let index = 0;
        this.status = data[index++];

        let modelPublication = new ModelPublication();
        modelPublication.elementAddress = bytes2Integer(data, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        modelPublication.publishAddress = bytes2Integer(data, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        modelPublication.appKeyIndex = (data[index++] & 0xFF) | ((data[index] & 0b1111) << 8);
        modelPublication.credentialFlag = (data[index] >> 4) & 0b1;
        modelPublication.rfu = (data[index] >> 5) & 0b111;
        index++;
        modelPublication.ttl = data[index++];
        modelPublication.period = data[index++];
        modelPublication.retransmitCount = (data[index] >> 5) & 0b111;
        modelPublication.retransmitIntervalSteps = data[index++] & 0x1F;
        modelPublication.modelId = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);

        if ((index + 2) <= data.length) {
            modelPublication.sig = false;
            modelPublication.modelId |= ((data[index++] & 0xFF) << 16) | ((data[index] & 0xFF) << 24);
        }

        this.publication = modelPublication;
    }
}