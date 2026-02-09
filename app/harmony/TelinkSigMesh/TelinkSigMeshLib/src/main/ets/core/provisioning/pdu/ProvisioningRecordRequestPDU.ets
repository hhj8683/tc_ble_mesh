/********************************************************************************************************
 * @file     ProvisioningRecordRequestPDU.ets 
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
 * @file ProvisioningRecordRequestPDU.ets
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
 * The Provisioner sends a Provisioning Record Request PDU to request a provisioning record fragment
 */
export class ProvisioningRecordRequestPDU implements ProvisioningStatePDU {
    /**
     * Identifies the provisioning record for which the request is made
     * 2 bytes
     */
    public recordID: number;
    /**
     * The starting offset of the requested fragment in the provisioning record data
     * 2 bytes
     */
    public fragmentOffset: number;
    /**
     * The maximum size of the provisioning record fragment that the Provisioner can receive
     * 2 bytes
     */
    public fragmentMaxSize: number

    /**
     * Constructs a ProvisioningRecordRequestPDU object with the specified parameters.
     *
     * @param recordID        The identifier of the provisioning record.
     * @param fragmentOffset  The starting offset of the requested fragment.
     * @param fragmentMaxSize The maximum size of the provisioning record fragment.
     */
    public constructor(recordID: number, fragmentOffset: number, fragmentMaxSize: number) {
        this.recordID = recordID;
        this.fragmentOffset = fragmentOffset;
        this.fragmentMaxSize = fragmentMaxSize;
    }

    /**
     * Converts the ProvisioningRecordRequestPDU object to a byte array.
     *
     * @return The byte array representation of the ProvisioningRecordRequestPDU object.
     */
    public toBytes() {
        let buffer = new ArrayBuffer(6);
        let dataView = new DataView(buffer);
        dataView.setUint16(0, this.recordID, false);
        dataView.setUint16(2, this.fragmentOffset, false);
        dataView.setUint16(4, this.fragmentMaxSize, false);
        return new Uint8Array(buffer);
    }

    /**
     * Returns the type of the ProvisioningRecordRequestPDU.
     *
     * @return The type of the ProvisioningRecordRequestPDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_RECORD_REQUEST;
    }
}
