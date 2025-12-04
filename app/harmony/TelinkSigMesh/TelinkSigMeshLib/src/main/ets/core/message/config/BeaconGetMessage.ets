/********************************************************************************************************
 * @file BeaconGetMessage.java
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
 * The Config Beacon Get is an acknowledged message used to get the current Secure Network Beacon state of a node
 */
 class BeaconGetMessage extends ConfigMessage {

    /**
     * Creates a new BeaconGetMessage with the specified destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor( destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public  getOpcode(): number {
        return Opcode.CFG_BEACON_GET;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public  getResponseOpcode() : number{
        return Opcode.CFG_BEACON_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return null.
     */
    public  getParams() : Uint8Array | undefined{
        return undefined;
    }

}
