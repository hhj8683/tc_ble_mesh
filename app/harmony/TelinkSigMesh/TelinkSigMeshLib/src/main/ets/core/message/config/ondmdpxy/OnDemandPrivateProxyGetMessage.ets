/********************************************************************************************************
 * @file OnDemandPrivateProxyGetMessage.ets
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
import { Opcode } from "../../Opcode";
import { ConfigMessage } from "../ConfigMessage";


/**
 * represents a message that can be sent to request information about an on-demand private proxy.
 */
export class OnDemandPrivateProxyGetMessage extends ConfigMessage {
    /**
     * Returns the opcode value for the OnDemandPrivateProxyGetMessage, which is Opcode.CFG_ON_DEMAND_PROXY_GET.
     *
     * @return The opcode value for the OnDemandPrivateProxyGetMessage.
     */
    public getOpcode() {
        return Opcode.CFG_ON_DEMAND_PROXY_GET
    }

    /**
     * Returns the response opcode value for the OnDemandPrivateProxyGetMessage, which is Opcode.CFG_ON_DEMAND_PROXY_GET.
     *
     * @return The response opcode value for the OnDemandPrivateProxyGetMessage.
     */

    public getResponseOpcode() {
        return Opcode.CFG_ON_DEMAND_PROXY_STATUS;
    }

    /**
     * Returns the parameters of the OnDemandPrivateProxyGetMessage.
     *
     * @return The parameters as a byte array.
     */
    public getParams() {
        return undefined;
    }
}
