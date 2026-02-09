/********************************************************************************************************
 * @file     MeshUpdatingDevice.ets 
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
 * @file MeshUpdatingDevice.ets
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

import { AdditionalInformation } from '../core/message/firmwareupdate/AdditionalInformation';

/**
 * Represents a device capable of updating a mesh network.
 */
export class MeshUpdatingDevice {
    // Static constants for device state
    public static STATE_INITIAL = 0;
    public static STATE_SUCCESS = 1;
    public static STATE_FAIL = 2;
    public static STATE_METADATA_RSP = 3;

    // Unicast address
    public meshAddress: number = 0;

    // Element address at updating model
    public updatingEleAddress: number = 0;

    // Current state
    public state: number = MeshUpdatingDevice.STATE_INITIAL;

    // PID information
    public pidInfo: string = "";

    // Latest firmware ID
    // public firmwareId: number[] = [];
    public firmwareId: Uint8Array = new Uint8Array();

    // Additional information in metadata
    public additionalInformation: AdditionalInformation | null = null;

    // PID value
    public pid: number = 0;

    // Version ID
    public vid: number = 0;

    // Indicates if the device supports firmware update
    public isSupported: boolean = false;

    // Indicates if the device is online
    public isOnline: boolean = false;

    // Indicates if the device is selected
    public selected: boolean = false;

    // Indicates if the device is a low power node
    public isLpn: boolean = false;

    // Indicates if the device is a sensor
    public isSensor: boolean = false;

    // Flag indicating whether an update is needed
    public needUpdate: boolean = false;

    /**
     * Default constructor
     */
    constructor() {}

    /**
     * Get description of the device's state
     */
    public getStateDesc(): string {
        switch (this.state) {
            case MeshUpdatingDevice.STATE_INITIAL:
                return "INIT";
            case MeshUpdatingDevice.STATE_FAIL:
                return "Update Fail";
            case MeshUpdatingDevice.STATE_SUCCESS:
                return "Update Success";
            case MeshUpdatingDevice.STATE_METADATA_RSP:
                return "Metadata RSP";
            default:
                return "";
        }
    }
    
}