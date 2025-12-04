/********************************************************************************************************
 * @file ScanParameters.java
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
import { SERVICE_PROVISION, SERVICE_PROXY } from '../../ble/UuidInfo';
import { ActionParameters } from './ActionParameters';
import { ble } from '@kit.ConnectivityKit';

/**
 * Scan params
 * This class represents the scan parameters for Bluetooth scanning.
 * It extends the Parameters class.
 */
export class ScanParameters extends ActionParameters {
    private filter: ble.ScanFilter;

    // The scan filter used for filtering scan results.

    /**
     * Default constructor for ScanParameters.
     * Initializes the scan filter.
     */
    public constructor() {
        super();
        this.filter = {}
    }

    /**
     * Returns the default scan parameters.
     *
     * @param provisioned - a boolean indicating if the device is provisioned
     * @param single      - a boolean indicating if the scan is in single mode
     * @return the default ScanParameters object
     */
    public static getDefault(provisioned: boolean, single: boolean = true): ScanParameters {
        let parameters = new ScanParameters();
        if (provisioned) {
            parameters.filter.serviceUuid = SERVICE_PROXY
        } else {
            parameters.filter.serviceUuid = SERVICE_PROVISION
        }
        parameters.setScanFilter([parameters.filter]);
        parameters.singleMode(single);
        return parameters;
    }

    /**
     * Sets the scan mode to single or continuous.
     *
     * @param single - a boolean indicating if the scan is in single mode
     */
    public singleMode(single: boolean) {
        this.set(ScanParameters.SCAN_SINGLE_MODE, single);
    }
}