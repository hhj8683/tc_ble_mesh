/********************************************************************************************************
 * @file     ProvisioningRecordResponsePDU.ets 
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
 * @file ProvisioningRecordResponsePDU.ets
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2017
 *
 * @par Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License")

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
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils'

import { ProvisioningPDU } from './ProvisioningPDU'

import { ProvisioningStatePDU } from './ProvisioningStatePDU'


/**
 * This class represents a Provisioning Record Response PDU.
 * It implements the ProvisioningStatePDU interface.
 * It contains fields for the raw data, status, record ID, fragment offset, total length, and data.
 * It provides methods to convert the PDU to bytes and to parse bytes into a PDU object.
 */
export class ProvisioningRecordResponsePDU implements ProvisioningStatePDU {
    /**
     * status success
     */
    public static readonly STATUS_SUCCESS = 0x00
    /**
     * status Requested Record Is Not Present
     */
    public static readonly STATUS_RECORD_NOT_PRESENT = 0x01
    /**
     * status Requested Offset Is Out Of Bounds
     */
    public static readonly STATUS_OFFSET_OUT_OF_BOUNDS = 0x02
    /**
     * The raw data of the PDU.
     */
    public rawData: Uint8Array | undefined
    /**
     * Indicates whether or not the request was handled successfully
     */
    public status: number | undefined
    /**
     * The ID of the record.
     */
    public recordID: number | undefined
    /**
     * The fragment offset of the record.
     */
    public fragmentOffset: number | undefined
    /**
     * The total length of the record.
     */
    public totalLength: number | undefined
    /**
     * The data of the record.
     */
    public data: Uint8Array | undefined

    /**
     * Constructs a ProvisioningRecordResponsePDU object from a byte array.
     *
     * @param data The byte array representing the PDU.
     * @return The ProvisioningRecordResponsePDU object.
     */
    public static fromBytes(data: Uint8Array): ProvisioningRecordResponsePDU {

        let index = 0
        let responsePDU = new ProvisioningRecordResponsePDU()
        responsePDU.rawData = data
        responsePDU.status = data[index++]
        responsePDU.recordID = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN)
        index += 2

        responsePDU.fragmentOffset = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN)
        index += 2

        responsePDU.totalLength = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN)
        index += 2

        responsePDU.data = new Uint8Array(data.length - index)
        responsePDU.data.set(data.subarray(index, index + responsePDU.data.length))
        return responsePDU

    }

    /**
     * Gets the state of the PDU.
     *
     * @return The state of the PDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_RECORD_RESPONSE
    }

    /**
     * Converts the PDU to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toBytes() {
        return this.rawData
    }
}
