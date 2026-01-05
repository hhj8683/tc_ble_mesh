/********************************************************************************************************
 * @file NodeIdentityGetMessage.java
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
 * The Config Node Identity Get is an acknowledged message used to get the current Node Identity state for a subnet
 * The NodeIdentityGetMessage class represents an acknowledged message used to retrieve the current Node Identity state for a specific subnet.
 */
export class NodeIdentityGetMessage extends ConfigMessage {
    public netKeyIndex = 0;

    /**
     * Constructs a new NodeIdentityGetMessage with the specified destination address and network key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param netKeyIndex        The network key index.
     */
    public static getSimple(destinationAddress: number, netKeyIndex: number): NodeIdentityGetMessage {
        let ist = new NodeIdentityGetMessage(destinationAddress)
        ist.netKeyIndex = netKeyIndex;
        return ist
    }

    /**
     * Returns the opcode value for the NodeIdentityGetMessage.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.NODE_ID_GET
    }

    /**
     * Returns the response opcode value for the NodeIdentityGetMessage.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.NODE_ID_STATUS
    }

    /**
     * Returns the parameters of the NodeIdentityGetMessage as a byte array.
     *
     * @return The parameters as a byte array.
     */
    public getParams(): Uint8Array | undefined {
        return num2bytes(this.netKeyIndex, 2)
    }
}