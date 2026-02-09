/********************************************************************************************************
 * @file     GattProxyGetMessage.ets 
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
 * @file GattProxyGetMessage.ets
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
 * The Config GATT Proxy Get is an acknowledged message used to get the current GATT Proxy state of a node
 * The GattProxyGetMessage class represents an acknowledged message used to retrieve the current GATT Proxy state of a node.
 * This message is sent to a destination address and expects a response in the form of a GattProxyStatusMessage.
 * The response to a Config GATT Proxy Get message is a Config GATT Proxy Status message.
 * {@link GattProxyStatusMessage}
 */
export class GattProxyGetMessage extends ConfigMessage {
    /**
     * Gets the opcode value for the GattProxyGetMessage.
     *
     * @return The opcode value.
     */
    public getOpcode() {
        return Opcode.CFG_GATT_PROXY_GET
    }

    /**
     * Gets the response opcode value for the GattProxyGetMessage.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode() {
        return Opcode.CFG_GATT_PROXY_STATUS
    }

    /**
     * Gets the parameters for the GattProxyGetMessage.
     *
     * @return The parameters.
     */
    public getParams() {
        return undefined;
    }
}