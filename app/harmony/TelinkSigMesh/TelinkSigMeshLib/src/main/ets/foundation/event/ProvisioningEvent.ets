/********************************************************************************************************
 * @file ProvisioningEvent.ets
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
import { ProvisioningDevice } from '../../entity/ProvisioningDevice';
import { Event } from '../Event';

/**
 * Created by kee on 2019/9/4.
 */

/**
 * ProvisioningEvent class represents an event related to the provisioning process in a BLE mesh network.
 * It extends the Event class and implements the Parcelable interface for easy data transfer.
 */
export class ProvisioningEvent implements Event {
    public static readonly EVENT_TYPE_PROVISION_GET_REVISION = "com.telink.ble.mesh.EVENT_TYPE_PROVISION_GET_REVISION";
    public static readonly EVENT_TYPE_PROVISION_BEGIN = "com.telink.ble.mesh.EVENT_TYPE_PROVISION_BEGIN";
    public static readonly EVENT_TYPE_PROVISION_SUCCESS = "com.telink.ble.mesh.EVENT_TYPE_PROVISION_SUCCESS";
    public static readonly EVENT_TYPE_PROVISION_FAIL = "com.telink.ble.mesh.EVENT_TYPE_PROVISION_FAIL";
    public static readonly EVENT_TYPE_CAPABILITY_RECEIVED = "com.telink.ble.mesh.EVENT_TYPE_CAPABILITY_RECEIVED";
    public type: string;
    public provisioningDevice: ProvisioningDevice;
    // The provisioning device associated with the event
    public desc = "";

    // Additional description for the event

    constructor(type: string, provisioningDevice: ProvisioningDevice, desc: string) {
        this.type = type;
        this.provisioningDevice = provisioningDevice;
        this.desc = desc;
    }
}
