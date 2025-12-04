/********************************************************************************************************
 * @file ScanEvent.java
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
import { ble } from '@kit.ConnectivityKit';

/**
 * Represents a scanning event that occurs during a BLE scan.
 * Extends the Event class and implements the Parcelable interface for serialization.
 */
export class ScanEvent implements Event {
    public type: string;
    public static readonly EVENT_TYPE_DEVICE_FOUND = "com.telink.ble.mesh.EVENT_TYPE_DEVICE_FOUND";
    public static readonly EVENT_TYPE_SCAN_TIMEOUT = "com.telink.ble.mesh.EVENT_TYPE_SCAN_TIMEOUT";
    public static readonly EVENT_TYPE_SCAN_FAIL = "com.telink.ble.mesh.EVENT_TYPE_SCAN_FAIL";
    public  advertisingDevice?: ble.ScanResult;

    constructor(type: string, advertisingDevice?: ble.ScanResult) {
        this.type = type;
        this.advertisingDevice = advertisingDevice;
    }
}