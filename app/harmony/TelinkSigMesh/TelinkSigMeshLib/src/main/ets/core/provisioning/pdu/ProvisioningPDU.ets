/********************************************************************************************************
 * @file     ProvisioningPDU.ets 
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
 * @file ProvisioningPDU.ets
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
import { PDU } from './PDU';

/**
 * Created by kee on 2019/7/18.
 */
// big endian
export  class ProvisioningPDU implements PDU {

    /**
     * Invites a device to join a mesh network
     */
    public static readonly TYPE_INVITE = 0x00;

    /**
     * Indicates the capabilities of the device
     */
    public static readonly TYPE_CAPABILITIES = 0x01;

    /**
     * Indicates the provisioning method selected by the Provisioner based on the capabilities of the device
     */
    public static readonly TYPE_START = 0x02;

    /**
     * Contains the Public Key of the device or the Provisioner
     */
    public static readonly TYPE_PUBLIC_KEY = 0x03;

    /**
     * Indicates that the user has completed inputting a value
     */
    public static readonly TYPE_INPUT_COMPLETE = 0x04;

    /**
     * Contains the provisioning confirmation value of the device or the Provisioner
     */
    public static readonly TYPE_CONFIRMATION = 0x05;

    /**
     * Contains the provisioning random value of the device or the Provisioner
     */
    public static readonly TYPE_RANDOM = 0x06;

    /**
     * Includes the assigned unicast address of the primary element, a network key, NetKey Index, Flags and the IV Index
     */
    public static readonly TYPE_DATA = 0x07;

    /**
     * Indicates that provisioning is complete
     */
    public static readonly TYPE_COMPLETE = 0x08;

    /**
     * Indicates that provisioning was unsuccessful
     */
    public static readonly TYPE_FAILED = 0x09;

    /**
     * Indicates a request to retrieve a provisioning record fragment from the device
     */
    public static readonly TYPE_RECORD_REQUEST = 0x0A;

    /**
     * Contains a provisioning record fragment or an error status,
     * sent in response to a Provisioning Record Request
     */
    public static readonly TYPE_RECORD_RESPONSE = 0x0B;

    /**
     * Indicates a request to retrieve the list of IDs of the provisioning records
     * that the unprovisioned device supports.
     */
    public static readonly TYPE_RECORDS_GET = 0x0C;

    /**
     * Contains the list of IDs of the provisioning records that the unprovisioned device supports.
     */
    public static readonly TYPE_RECORDS_LIST = 0x0D;


    /**
     * including :
     * padding : 2 bits 0b00
     * typeValue : 6 bits
     * 0x00 - 0x09 indicates provisioning state
     * 0x0A–0xFF Reserved for Future Use
     */
    private  type = 0;

    /**
     * provisioning params
     */
    private params: Uint8Array | undefined= undefined;

    /**
     * Converts the PDU to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toBytes(): undefined|Uint8Array {
        let len = this.params == undefined ? 1 : 1 + this.params.length;
        let re: Uint8Array = new Uint8Array(len);
        re[0] = this.type;
        if (this.params) {
            re.set(this.params, 0)
        }
        return re;
    }
}
