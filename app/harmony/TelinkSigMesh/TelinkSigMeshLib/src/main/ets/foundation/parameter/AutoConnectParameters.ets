/********************************************************************************************************
 * @file AutoConnectParameters.ets
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
import { SERVICE_PROXY } from "../../ble/UuidInfo";
import { ActionParameters } from "./ActionParameters";

/**
 * This class represents the parameters for auto-connecting to a device.
 * It extends the base class Parameters.
 * The class sets a scan filter for the specified UUID service proxy.
 */
export class AutoConnectParameters extends ActionParameters {
    public constructor() {
        super();
        this.setScanFilter([this.createScanFilter(SERVICE_PROXY)]);
    }
}
