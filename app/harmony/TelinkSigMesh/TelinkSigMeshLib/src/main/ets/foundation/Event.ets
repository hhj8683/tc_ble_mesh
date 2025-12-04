/********************************************************************************************************
 * @file Event.java
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

/**
 * This is an abstract class representing an event.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 * The event class is generic, allowing for different types of events to be created.
 * The sender and type properties represent the sender object and the type of the event, respectively.
 * The threadMode property represents the thread mode in which the event should be handled.
 * The default thread mode is set to Default.
 */
export interface Event {
    type: string;
}