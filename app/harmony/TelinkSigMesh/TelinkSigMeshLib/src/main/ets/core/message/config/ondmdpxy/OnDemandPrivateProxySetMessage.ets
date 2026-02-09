/********************************************************************************************************
 * @file     OnDemandPrivateProxySetMessage.ets 
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
 * @file OnDemandPrivateProxySetMessage.ets
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
import { Opcode } from '../../Opcode';
import { ConfigMessage } from '../ConfigMessage';

/**
 * This class represents a message for setting the state of an on-demand private GATT proxy.
 * It extends the ConfigMessage class.
 */
export class OnDemandPrivateProxySetMessage extends ConfigMessage {
    /**
     * The new state of the on-demand private GATT proxy.
     */
    public privateProxy = 0;

    public static getSimple(destinationAddress: number, privateProxy: number): OnDemandPrivateProxySetMessage {
        let instance = new OnDemandPrivateProxySetMessage(destinationAddress);
        instance.privateProxy = privateProxy;
        return instance;
    }

    /**
     * Returns the opcode of the message.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return Opcode.CFG_ON_DEMAND_PROXY_SET
    }

    /**
     * Returns the response opcode of the message.
     *
     * @return The response opcode of the message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_ON_DEMAND_PROXY_STATUS
    }

    /**
     * Returns the parameters of the message.
     *
     * @return The parameters of the message.
     */
    public getParams() {
        return new Uint8Array([this.privateProxy])
    }
}