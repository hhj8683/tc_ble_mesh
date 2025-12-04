/********************************************************************************************************
 * @file DefaultTTLSetMessage.java
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
 * The Config Default TTL Set is an acknowledged message used to set the Default TTL state of a node
 * <p>
 * The response to a Config Default TTL Get message is a Config Default TTL Status message {@link DefaultTTLStatusMessage}.
 */

export class DefaultTTLSetMessage extends ConfigMessage {
    /**
     * New Default TTL value, difference with {@link com.telink.ble.mesh.core.message.MeshMessage#ttl}
     */
    public newTTL = 0;

    /**
     * Creates a new DefaultTTLSetMessage with the specified destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor(destinationAddress: number) {
        super(destinationAddress);
    }

    /**
     * Creates a simple instance of DefaultTTLSetMessage with the specified destination address and ttl.
     *
     * @param destinationAddress The destination address of the message.
     * @param newTTL             new ttl.
     * @return A simple instance of FriendSetMessage.
     */
    public static getSimple(destinationAddress: number, newTTL: number): DefaultTTLSetMessage {
        let instance = new DefaultTTLSetMessage(destinationAddress);
        instance.newTTL = newTTL;
        return instance;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return Opcode.CFG_DEFAULT_TTL_SET
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_DEFAULT_TTL_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        return new Uint8Array([this.newTTL]);
    }
}
