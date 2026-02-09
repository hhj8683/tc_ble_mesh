/********************************************************************************************************
 * @file ModelSubscriptionSetMessage.ets
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

import { ByteOrder, num2bytes } from "../../../utils/ArrayUtils";
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * device grouping
 * composite of [Config Model Subscription Add] and [Config Model Subscription Delete]
 * <p>
 * This class represents a message for setting model subscriptions in a device grouping.
 * It is a composite of [Config Model Subscription Add] and [Config Model Subscription Delete] messages.
 * The response to a Config Model Subscription Delete message is a Config Model Subscription Status message.
 * See {@link ModelSubscriptionStatusMessage} for more information.
 */
const PARAM_LEN_SIG = 6;
const PARAM_LEN_VENDOR = 8;
export  class ModelSubscriptionSetMessage extends ConfigMessage {

    public static readonly  MODE_ADD = 0;
    public static readonly  MODE_DELETE = 1;
    public  mode =ModelSubscriptionSetMessage. MODE_ADD;
    public   elementAddress = 0;
    /**
     * The group address for the model subscription.
     */
    public   address = 0;
    /**
     * The identifier of the model.
     * The length of the identifier is determined by whether it is a SIG or vendor model.
     */
    public   modelIdentifier = 0;
    /**
     * Indicates whether the model is a SIG model or a vendor model.
     */
    public isSig = true;

    /**
     * Creates a new instance of ModelSubscriptionSetMessage with the given destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor( destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Creates a simple ModelSubscriptionSetMessage with the given parameters.
     *
     * @param destinationAddress The destination address of the message.
     * @param mode               The mode of the message (MODE_ADD or MODE_DELETE).
     * @param elementAddress     The address of the element.
     * @param groupAddress       The group address.
     * @param modelId            The identifier of the model.
     * @param isSig              Indicates whether the model is a SIG model or a vendor model.
     * @return A ModelSubscriptionSetMessage with the specified parameters.
     */
    public static  getSimple(destinationAddress: number, mode: number, elementAddress: number, groupAddress: number, modelId: number, isSig: boolean): ModelSubscriptionSetMessage {
        let message = new ModelSubscriptionSetMessage(destinationAddress);
        message.mode = mode;
        message.elementAddress = elementAddress;
        message.address = groupAddress;
        message.modelIdentifier = modelId;
        message.isSig = isSig;
        return message;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public  getOpcode() {
        return this.mode == ModelSubscriptionSetMessage.MODE_ADD ? Opcode.CFG_MODEL_SUB_ADD : Opcode.CFG_MODEL_SUB_DEL
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public  getResponseOpcode() {
        return Opcode.CFG_MODEL_SUB_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        let offset = 0
            let buf = new Uint8Array(this.isSig ? PARAM_LEN_SIG : PARAM_LEN_VENDOR)
            buf.set(num2bytes(this.elementAddress,2, ByteOrder.LITTLE_ENDIAN), offset)
            offset += 2
            buf.set(num2bytes(this.address,2, ByteOrder.LITTLE_ENDIAN), offset)
            offset += 2
            buf.set(num2bytes(this.modelIdentifier,this.isSig ? 2 : 4, ByteOrder.LITTLE_ENDIAN), offset)
        return buf
    }
}