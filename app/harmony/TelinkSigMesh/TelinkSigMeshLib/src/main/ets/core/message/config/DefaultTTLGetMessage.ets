/********************************************************************************************************
 * @file DefaultTTLGetMessage.ets
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
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * The Config Default TTL Get is an acknowledged message used to get the current Default TTL state of a node.
 * <p>
 * The response to a Config Default TTL Get message is a Config Default TTL Status message {@link DefaultTTLStatusMessage}.
 */
export class DefaultTTLGetMessage extends ConfigMessage {

    /**
     * Constructs a DefaultTTLGetMessage object with the specified destination address.
     *
     * @param destinationAddress The address of the node to which the message is being sent.
     */
    public constructor( destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public  getOpcode() : number{
        return Opcode.CFG_DEFAULT_TTL_GET;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public  getResponseOpcode() {
        return Opcode.CFG_DEFAULT_TTL_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return null.
     */
    public  getParams() {
        return undefined;
    }

}
