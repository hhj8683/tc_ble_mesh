/********************************************************************************************************
 * @file     ProvisioningRecordsListPDU.ets 
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
 * @file ProvisioningRecordsListPDU.ets
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
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';
import { ProvisioningPDU } from './ProvisioningPDU';
import { ProvisioningStatePDU } from './ProvisioningStatePDU';


/**
 * This class represents a Provisioning Records List PDU (Protocol Data Unit).
 * It implements the ProvisioningStatePDU interface.
 * The Provisioning Records List PDU contains information about the provisioning extensions supported by the device
 * and a list of the Record IDs of the provisioning records stored on the device.
 * The class includes methods to convert the PDU to and from a byte array.
 */
export class ProvisioningRecordsListPDU implements ProvisioningStatePDU {
    public rawData: Uint8Array | undefined;
    /**
     * Bitmask indicating the provisioning extensions supported by the device
     * 2 bytes
     */
    public provisioningExtensions: number | undefined;
    /**
     * Lists the Record IDs of the provisioning records stored on the device
     */
    // public List<Integer> recordsList;
    public recordsList: Array<number> = []

    /**
     * Converts a byte array to a ProvisioningRecordsListPDU object.
     *
     * @param data The byte array containing the PDU data.
     * @return The ProvisioningRecordsListPDU object.
     */
    public static fromBytes(data: Uint8Array): ProvisioningRecordsListPDU {

        let index = 0;
        let recordsListPDU = new ProvisioningRecordsListPDU();
        recordsListPDU.rawData = data;
        recordsListPDU.provisioningExtensions = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
        index += 2;

        if (data.length > index) {
            const listSize = (data.length - index) / 2;
            recordsListPDU.recordsList = []
            let recordID: number;
            for (let i = 0; i < listSize; i++) {
                recordID = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN);
                recordsListPDU.recordsList.push(recordID);
                index += 2;
            }
        }
        return recordsListPDU;

    }

    /**
     * Returns the state of the PDU.
     *
     * @return The state of the PDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_RECORDS_LIST;
    }

    /**
     * Converts the ProvisioningRecordsListPDU object to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toBytes() {
        return this.rawData;
    }
}
