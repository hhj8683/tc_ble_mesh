/********************************************************************************************************
 * @file AppKeyAddMessage.ets
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
 * The Config AppKey Add is an acknowledged message used to add an AppKey to the AppKey List on a node
 * and bind it to the NetKey identified by NetKeyIndex.
 * <p>
 * The added AppKey can be used by the node only as a pair with the specified NetKey.
 * <p>
 * The AppKey is used to authenticate and decrypt messages it receives, as well as authenticate and encrypt messages it sends.
 * <p>
 * The response to a Config AppKey Add message is a Config AppKey Status message {@link AppKeyStatusMessage}.
 */

export class AppKeyAddMessage extends ConfigMessage {
    public netKeyIndex: number = 0
    public appKeyIndex: number = 0
    public appKey: Uint8Array = new Uint8Array(0);

    /**
     * Creates a new AppKeyAddMessage with the specified destination address.
     *
     * @param destinationAddress The destination address of the message.
     */
    public constructor(destinationAddress: number) {
        super(destinationAddress);
    }


    /**
     * Gets the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode(): number {
        return Opcode.APPKEY_ADD;
    }

    /**
     * Gets the opcode of the response message.
     *
     * @return The opcode of the response message.
     */
    public getResponseOpcode(): number {
        return Opcode.APPKEY_STATUS;
    }

    /**
     * Gets the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams(): Uint8Array {

        // netKey index lower 12 bits
        // appKey index higher 12 bits

        let netAppKeyIndex = (this.netKeyIndex & 0x0FFF) | ((this.appKeyIndex & 0x0FFF) << 12);
        let indexBuf = num2bytes(netAppKeyIndex, 3, ByteOrder.LITTLE_ENDIAN);
        let re = new Uint8Array(3 + 16)
        re.set(indexBuf, 0)
        re.set(this.appKey, 3)
        return re
    }
}
