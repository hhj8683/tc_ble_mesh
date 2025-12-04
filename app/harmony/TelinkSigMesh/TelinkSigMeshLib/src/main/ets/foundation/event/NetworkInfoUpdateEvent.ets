/********************************************************************************************************
 * @file NetworkInfoUpdateEvent.java
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

/**
 * This class represents a network information update event.
 * It extends the Event class and implements the Parcelable interface.
 * The event is triggered when there is an update in the network information.
 * The event type is defined as "com.telink.ble.mesh.EVENT_TYPE_NETWORKD_INFO_UPDATE".
 * The sequence number and ivIndex are used to provide additional information about the update.
 */
export class NetworkInfoUpdateEvent implements Event {
    public static readonly EVENT_TYPE_NETWORK_INFO_UPDATE = "com.telink.ble.mesh.EVENT_TYPE_NETWORKD_INFO_UPDATE";
    public type: string = NetworkInfoUpdateEvent.EVENT_TYPE_NETWORK_INFO_UPDATE
    public sequenceNumber: number;
    // The sequence number of the update
    public ivIndex: number;

    // The ivIndex of the update

    /**
     * Constructs a new NetworkInfoUpdateEvent with the specified sender, type, sequence number, and ivIndex.
     *
     * @param sender         the object that triggered the event
     * @param type           the type of the event
     * @param sequenceNumber the sequence number of the update
     * @param ivIndex        the ivIndex of the update
     */
    public constructor(sequenceNumber: number, ivIndex: number) {
        this.sequenceNumber = sequenceNumber;
        this.ivIndex = ivIndex;
    }
}