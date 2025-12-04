/********************************************************************************************************
 * @file CompositionDataGetMessage.java
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
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';


/**
 * The Config Composition Data Get is an acknowledged message used to read one page of the Composition Data
 * <p>
 * The response to a Config Composition Data Get message is a Config Composition Data Status message {@link CompositionDataStatusMessage}.
 */
export  class CompositionDataGetMessage extends ConfigMessage {
    private static readonly  PAGE_ALL =  0xFF;

    /**
     * Constructs a CompositionDataGetMessage object with the specified destination address.
     *
     * @param destinationAddress The address of the node to which the message is being sent.
     */
    public constructor( destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Returns the opcode of the Cps Get message.
     *
     * @return The opcode value.
     */
    public  getOpcode(): number {
        return Opcode.COMPOSITION_DATA_GET
    }

    /**
     * Returns the opcode of the expected response message to the Cps Get message.
     *
     * @return The response opcode value.
     */
    public  getResponseOpcode(): number {
        return Opcode.COMPOSITION_DATA_STATUS
    }

    /**
     * Returns the parameters of the Cps Get message.
     *
     * @return The parameters as a byte array.
     */
    public  getParams(): Uint8Array {
        return new Uint8Array([CompositionDataGetMessage.PAGE_ALL])
    }


}
