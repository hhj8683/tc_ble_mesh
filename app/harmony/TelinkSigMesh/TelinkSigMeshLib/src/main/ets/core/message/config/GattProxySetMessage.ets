/********************************************************************************************************
 * @file     GattProxySetMessage.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
/********************************************************************************************************
 * @file GattProxySetMessage.ets
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
 * The GattProxySetMessage class represents an acknowledged message used to set the GATT Proxy state of a node.
 * This message is used to enable or disable the GATT Proxy feature.
 * <p>
 * The response to a GattProxySetMessage is a GattProxyStatusMessage.
 * <p>
 * Example usage:
 * GattProxySetMessage message = GattProxySetMessage.getSimple(destinationAddress, gattProxy);
 *
 * @see ConfigMessage
 * @see GattProxyStatusMessage
 */
export class GattProxySetMessage extends ConfigMessage {
    /**
     * The new GATT Proxy state.
     * Possible values:
     * - 00: enabled
     * - 01: disabled
     */
    public gattProxy = 0;

    /**
     * Creates a simple GattProxySetMessage with the specified destination address and GATT Proxy state.
     *
     * @param destinationAddress The address of the node to which the message is being sent.
     * @param gattProxy          The new GATT Proxy state.
     * @return GattProxySetMessage instance.
     */
    public static getSimple(destinationAddress: number, gattProxy: number): GattProxySetMessage {
        let instance = new GattProxySetMessage(destinationAddress);
        instance.gattProxy = gattProxy;
        return instance;
    }

    /**
     * Gets the opcode of the GattProxySetMessage.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.CFG_GATT_PROXY_SET
    }

    /**
     * Gets the response opcode of the GattProxySetMessage.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.CFG_GATT_PROXY_STATUS
    }

    /**
     * Gets the parameters of the GattProxySetMessage.
     *
     * @return The parameters as a byte array.
     */
    public getParams() {
        return new Uint8Array([this.gattProxy])
    }
}