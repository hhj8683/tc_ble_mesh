/********************************************************************************************************
 * @file AutoConnectEvent.java
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
import { Event } from '../Event';

/**
 * Represents an event for auto connection.
 * This event is triggered when a device is automatically connected.
 * The connected device's address is stored in the event.
 */
export class AutoConnectEvent implements Event {
    // Event type for auto connect login
    public static readonly EVENT_TYPE_AUTO_CONNECT_LOGIN = "com.telink.ble.mesh.EVENT_TYPE_AUTO_CONNECT_LOGIN";
    public type: string = AutoConnectEvent.EVENT_TYPE_AUTO_CONNECT_LOGIN
    // Address of the connected device
    public connectedAddress: number

    /**
     * Constructs a new AutoConnectEvent with the specified sender, type, and connected address.
     *
     * @param sender           the object that triggered the event
     * @param type             the type of the event
     * @param connectedAddress the address of the connected device
     */
    public constructor(connectedAddress: number) {
        this.connectedAddress = connectedAddress;
    }
}