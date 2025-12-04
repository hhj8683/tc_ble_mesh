/********************************************************************************************************
 * @file BluetoothEvent.java
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
import { Event } from "../Event";
import { access } from "@kit.ConnectivityKit";

/**
 * Represents a Bluetooth event.
 * Extends the Event class and implements the Parcelable interface.
 */
export class BluetoothEvent implements Event {
    type: string;
    /**
     * The event type for a Bluetooth state change.
     */
    public static readonly EVENT_TYPE_BLUETOOTH_STATE_CHANGE = "com.telink.ble.mesh.EVENT_TYPE_BLUETOOTH_STATE_CHANGE";
    private state: access.BluetoothState;
    private desc: string;

    constructor(type: string, state: access.BluetoothState, desc: string) {
        this.type = type;
        this.state = state;
        this.desc = desc;
    }
}