/********************************************************************************************************
 * @file GattOtaParameters.ets
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
import { ConnectionFilter } from "../../entity/ConnectionFilter";
import { ActionParameters } from "./ActionParameters";

/**
 * This class represents the parameters for GATT OTA (Over-The-Air) functionality.
 * It extends the Parameters class.
 */
export class GattOtaParameters extends ActionParameters {
    /**
     * Constructs a new GattOtaParameters object with the specified connection filter and firmware.
     *
     * @param filter   The connection filter to be used.
     * @param firmware The firmware to be used for OTA.
     */
    public constructor(filter: ConnectionFilter, firmware: Uint8Array) {
        super();
        this.set(GattOtaParameters.COMMON_PROXY_FILTER_INIT_NEEDED, true);
        this.set(GattOtaParameters.ACTION_CONNECTION_FILTER, filter);
        this.setFirmware(firmware);
    }

    /**
     * Sets the firmware for OTA.
     *
     * @param firmware The firmware to be used for OTA.
     */
    public setFirmware(firmware: Uint8Array) {
        this.set(GattOtaParameters.ACTION_OTA_FIRMWARE, firmware);
    }
}