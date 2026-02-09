/********************************************************************************************************
 * @file GattOtaEvent.ets
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
 * This class represents a GattOtaEvent, which is an event related to GATT OTA (Over-the-Air) updates.
 * It extends the Event class and contains additional properties for progress and description.
 */
export class GattOtaEvent implements Event {
    public type: string;
    public static readonly EVENT_TYPE_OTA_SUCCESS = "com.telink.sig.mesh.OTA_SUCCESS";
    public static readonly EVENT_TYPE_OTA_FAIL = "com.telink.sig.mesh.OTA_FAIL";
    public static readonly EVENT_TYPE_OTA_PROGRESS = "com.telink.sig.mesh.OTA_PROGRESS";
    public progress: number = 0
    public desc: string = ''

    constructor(type: string, desc: string) {
        this.type = type;
        this.desc = desc;
    }


}