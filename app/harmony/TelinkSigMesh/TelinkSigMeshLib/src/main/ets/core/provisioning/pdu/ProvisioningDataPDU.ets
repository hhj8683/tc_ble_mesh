/********************************************************************************************************
 * @file ProvisioningDataPDU.ets
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
import { ProvisioningPDU } from './ProvisioningPDU';
import { ProvisioningStatePDU } from './ProvisioningStatePDU';

/**
 * The ProvisioningDataPDU class represents a Provisioning State PDU containing encrypted data.
 * It implements the ProvisioningStatePDU interface.
 */
export class ProvisioningDataPDU implements ProvisioningStatePDU {

    // including mic
    public encryptedData: Uint8Array;
    /**
     * constructor
     *
     * @param encryptedData encryptedData
     */
    constructor(encryptedData: Uint8Array) {
        this.encryptedData = encryptedData;
    }



    /**
     * Converts the PDU to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toBytes() {
        return this.encryptedData;
    }

    /**
     * Gets the state of the PDU.
     *
     * @return The state of the PDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_DATA;
    }
}
