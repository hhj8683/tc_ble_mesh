/********************************************************************************************************
 * @file     EventBus.ets 
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
 * @file Event.ets
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
import { HashMap, HashSet } from "@kit.ArkTS";
import { Event } from "./Event";

/**
 * This is an abstract class representing an event.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 * The event class is generic, allowing for different types of events to be created.
 * The sender and type properties represent the sender object and the type of the event, respectively.
 * The threadMode property represents the thread mode in which the event should be handled.
 * The default thread mode is set to Default.
 */
export class EventBus {
    private static instance: EventBus;
    private events: HashMap<string, HashSet<(event: Event) => void>> = new HashMap();

    private constructor() {
    }

    static getInstance(): EventBus {
        if (!EventBus.instance) {
            EventBus.instance = new EventBus();
        }
        return EventBus.instance;
    }

    on(eventType: string, callback: (event: Event) => void): void {
        if (!this.events.get(eventType)) {
            this.events.set(eventType, new HashSet())
        }
        this.events.get(eventType).add(callback);
    }

    emit(data: Event): void {
        let eventType: string = data.type
        let callbacks = this.events.get(eventType)
        if (callbacks) {
            callbacks.forEach((cb) => {
                if (cb) {
                    cb(data)
                }
            })
        }
    }

    off(eventType: string, callback: (event: Event) => void): void {
        const callbacks = this.events.get(eventType)
        if (callbacks) {
            if (callback) {
                callbacks.remove(callback)
            }
        }
    }


    offEvents(callback: (event: Event) => void): void {
        for (let cbs of this.events.values()) {
            for (let cb of cbs) {
                if (cb == callback) {
                    cbs.remove(cb)
                }
            }
        }
    }
}