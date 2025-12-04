/********************************************************************************************************
 * @file MeshEvent.java
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
 * Represents a mesh event.
 * Extends the Event class with a String type.
 * Contains constants for different types of mesh events.
 * Stores a description of the event.
 */
export class MeshEvent implements Event {
    public type: string;
    // Constants for different types of mesh events
    public static readonly EVENT_TYPE_MESH_EMPTY = "com.telink.ble.mesh.MESH_EMPTY";
    public static readonly EVENT_TYPE_DISCONNECTED = "com.telink.ble.mesh.EVENT_TYPE_DISCONNECTED";
    public static readonly EVENT_TYPE_MESH_RESET = "com.telink.sig.mesh.EVENT_TYPE_MESH_RESET";
    // Description of the event
    public desc : string;

    constructor(type: string, desc: string) {
        this.type = type
        this.desc = desc
    }
}
