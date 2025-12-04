/********************************************************************************************************
 * @file ModelAppBindMessage.java
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
import { num2bytes } from '../../../utils/ArrayUtils';
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';

/**
 * The Config Model App Bind Message is used to bind an AppKey to a model in a mesh network.
 * This message is sent to configure the model's application key.
 * <p>
 * The response to this message is a Config Model App Status message.
 *
 * @see ModelAppStatusMessage
 */
export class ModelAppBindMessage extends ConfigMessage {
    /**
     * The address of the element to bind the AppKey to.
     * This is a 2-byte value.
     */
    public   elementAddress = 0;

    /**
     * The index of the AppKey to bind.
     * This is a 2-byte value, but only 12 bits are used.
     */
    public   appKeyIndex = 0

    /**
     * The SIG Model ID or Vendor Model ID.
     * If it is a SIG Model, it is a 2-byte value.
     * If it is a Vendor Model, it is a 4-byte value.
     */
    public   modelIdentifier = 0;

    /**
     * Flag indicating whether the model is a SIG Model or a Vendor Model.
     * True if it is a SIG Model, false if it is a Vendor Model.
     */
    public  isSigModel = true;

    /**
     * Constructs a new ModelAppBindMessage with the specified destination address.
     *
     * @param destinationAddress The address of the destination node.
     */
    public constructor( destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode value.
     */
    public  getOpcode() : number{
        return Opcode.MODE_APP_BIND
    }

    /**
     * Gets the response opcode of the message.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() : number{
        return Opcode.MODE_APP_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters as a byte array.
     */
    public  getParams(): Uint8Array {
        // check if sig model or vendor model
//        boolean isSigModel = isSigModel(this.modelIdentifier);
        let bufferSize = this.isSigModel ? 6 : 8;
        let buf = new Uint8Array(bufferSize)
        let offset = 0
        buf.set(num2bytes(this.elementAddress, 2), offset)
        offset += 2

        buf.set(num2bytes(this.appKeyIndex, 2), offset)
        offset += 2

        buf.set(num2bytes(this.modelIdentifier, this.isSigModel ? 2 : 4), offset)

        return buf
    }
}
