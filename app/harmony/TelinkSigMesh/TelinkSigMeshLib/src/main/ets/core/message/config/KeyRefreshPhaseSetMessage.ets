/********************************************************************************************************
 * @file KeyRefreshPhaseSetMessage.ets
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
import { num2bytes } from "../../../utils/ArrayUtils";
import { Opcode } from "../Opcode";
import { ConfigMessage } from "./ConfigMessage";

/**
 * The Config Key Refresh Phase Set is an acknowledged message used to set the Key Refresh Phase state of the identified network key
 * The KeyRefreshPhaseSetMessage class represents an acknowledged message used to set the Key Refresh Phase state of the identified network key.
 */
export class KeyRefreshPhaseSetMessage extends ConfigMessage {
    public netKeyIndex = 0;
    /**
     * The new Key Refresh Phase transition value.
     */
    public transition = 0;

    /**
     * Creates a simple KeyRefreshPhaseSetMessage with the specified destination address and Key Refresh Phase transition value.
     *
     * @param destinationAddress The destination address for the message.
     * @param transition         The new Key Refresh Phase transition value.
     * @return An instance of KeyRefreshPhaseSetMessage.
     */
    public static getSimple(destinationAddress: number, transition: number) {
        let instance = new KeyRefreshPhaseSetMessage(destinationAddress);
        instance.transition = transition;
        return instance;
    }

    /**
     * Gets the opcode for the KeyRefreshPhaseSetMessage.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.CFG_KEY_REFRESH_PHASE_SET
    }

    /**
     * Gets the response opcode for the KeyRefreshPhaseSetMessage.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.CFG_KEY_REFRESH_PHASE_STATUS
    }

    /**
     * Gets the parameters for the KeyRefreshPhaseSetMessage.
     *
     * @return The parameters as a byte array.
     */
    public getParams() {
        let re = new Uint8Array(3)
        re.set(num2bytes(this.netKeyIndex, 2), 0)
        re[2] = this.transition
        return re
    }
}