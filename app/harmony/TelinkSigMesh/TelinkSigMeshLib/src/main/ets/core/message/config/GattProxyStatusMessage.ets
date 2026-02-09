/********************************************************************************************************
 * @file     GattProxyStatusMessage.ets 
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
 * @file GattProxyStatusMessage.ets
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
import { StatusMessage } from "../StatusMessage";

/**
 * The Config GATT Proxy Status is an unacknowledged message used to report the current GATT Proxy state of a node
 * <p>
 * The GattProxyStatusMessage class represents an unacknowledged message used to report the current GATT Proxy state of a node.
 * It is a response to the GattProxyGetMessage and GattProxySetMessage.
 * <p>
 * This message is identified by the Opcode CFG_GATT_PROXY_STATUS.
 * <p>
 * The GattProxyStatusMessage class implements the Parcelable interface to allow for easy serialization and deserialization of the message.
 * <p>
 * The gattProxy field represents the current GATT Proxy state of the node.
 *
 * @see com.telink.ble.mesh.core.message.Opcode#CFG_GATT_PROXY_STATUS
 */
export class GattProxyStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "GattProxyStatusMessage"

    public statusName(): string {
        return GattProxyStatusMessage.STATUS_NAME
    }

    public gattProxy = 0;

    /**
     * Method to parse the received byte array and populate the fields of the GattProxyStatusMessage object.
     *
     * @param params The byte array containing the parameters of the message.
     */
    public parse(params: Uint8Array) {
        this.gattProxy = params[0];
    }
}