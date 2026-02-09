/********************************************************************************************************
 * @file ModelSubscriptionStatusMessage.ets
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

import { ByteOrder, bytes2Integer, num2Hex } from "../../../utils/ArrayUtils";
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Model Subscription Status is an unacknowledged message used to report a status of the operation on the Subscription List
 */

/**
 * The ModelSubscriptionStatusMessage class represents an unacknowledged message used to report the status of an operation on the Subscription List in the Config Model.
 */
const DATA_LEN_SIG = 7;
const DATA_LEN_VENDOR = 9;

export class ModelSubscriptionStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "ModelSubscriptionStatusMessage"

    public statusName(): string {
        return ModelSubscriptionStatusMessage.STATUS_NAME
    }

    public status = 0;
    public elementAddress = 0;
    /**
     * The group address.
     */
    public address = 0;
    /**
     * The model identifier, which can be 2 or 4 bytes determined by whether it is a SIG or vendor model.
     */
    public modelIdentifier = 0;
    /**
     * Indicates whether the model is a SIG or vendor model.
     */
    public isSig = true;

    /**
     * Constructs a new ModelSubscriptionStatusMessage object.
     */
    public constructor() {
        super();
    }

    /**
     * Parses the byte array to populate the fields of the ModelSubscriptionStatusMessage object.
     *
     * @param params The byte array containing the data to parse.
     */
    public parse(params: Uint8Array) {
        this.isSig = params.length == DATA_LEN_SIG;
        let index = 0;
        this.status = params[index++];
        this.elementAddress = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.address = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.modelIdentifier = bytes2Integer(params, index, this.isSig ? 2 : 4, ByteOrder.LITTLE_ENDIAN);
    }


    /**
     * Returns a string representation of the ModelSubscriptionStatusMessage object.
     *
     * @return A string representation of the ModelSubscriptionStatusMessage object.
     */
    public toString() {
        return `ModelSubscriptionStatusMessage: status=${this.status}, elementAddress=${num2Hex(this.elementAddress,
            4)}, groupAddress=${
        num2Hex(this.address, 4)} , modelId=${num2Hex(this.modelIdentifier, 4)}`
    }
}