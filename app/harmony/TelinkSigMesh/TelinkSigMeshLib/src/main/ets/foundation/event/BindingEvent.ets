/********************************************************************************************************
 * @file BindingEvent.ets
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
import { BindingDevice } from '../../entity/BindingDevice';
import { Event } from '../Event';

/**
 * This class represents a binding event that can occur during the process of binding a device.
 * It extends the Event class and contains information about the binding device and a description of the event.
 */
export class BindingEvent implements Event {
    public type: string;
    public static readonly EVENT_TYPE_BIND_SUCCESS = "com.telink.ble.mesh.EVENT_TYPE_BIND_SUCCESS";
    public static readonly EVENT_TYPE_BIND_FAIL = "com.telink.ble.mesh.EVENT_TYPE_BIND_FAIL";
    public bindingDevice: BindingDevice;
    // The device being bound
    public desc: string;

    // Description of the event

    /**
     * Constructor for the BindingEvent class.
     *
     * @param sender        The object that sent the event
     * @param type          The type of the event
     * @param bindingDevice The device being bound
     * @param desc          The description of the event
     */
    public constructor(type: string, bindingDevice: BindingDevice, desc: string) {
        this.type = type
        this.bindingDevice = bindingDevice;
        this.desc = desc;
    }
}