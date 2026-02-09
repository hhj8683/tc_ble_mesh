/********************************************************************************************************
 * @file     ProvisioningCapabilityPDU.ets 
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
 * @file ProvisioningCapabilityPDU.ets
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
import { ProvisioningPDU } from "./ProvisioningPDU";
import { ProvisioningStatePDU } from "./ProvisioningStatePDU";


// 03:01:
// 02:00:01:00:00:00:00:00:00:00:00
// from device

const ALG_BIT_MASK_HMAC: number = 0b10;
/**
 * The ProvisioningCapabilityPDU class represents a Provisioning State PDU containing Capability data.
 * It implements the ProvisioningStatePDU interface.
 */
export class ProvisioningCapabilityPDU implements ProvisioningStatePDU {

    private static readonly LEN = 11;

    /**
     * Algorithm - BTM_ECDH_P256_CMAC_AES128_AES_CCM
     */
    private static readonly  ALG_BIT_MASK_CMAC = 0b01;

    /**
     * Algorithm - BTM_ECDH_P256_HMAC_SHA256_AES_CCM
     */
    // private static final int ALG_BIT_MASK_HMAC = 0b10;


    // raw data
    private rawData: Uint8Array | undefined = undefined;

    /**
     * Number of elements supported by the device
     * 1 byte
     * 0: Prohibited
     * 0x01-0xFF
     */
    public  eleNum: number = 0;

    /**
     * Supported algorithms and other capabilities
     * 2 bytes
     * bit-0: FIPS P-256 Elliptic Curve
     * bit-1--15: Reserved for Future Use
     * <p>
     * <p>
     * update EPA
     * 0	BTM_ECDH_P256_CMAC_AES128_AES_CCM
     * 1	BTM_ECDH_P256_HMAC_SHA256_AES_CCM
     */
    public  algorithms = 0;

    /**
     * Supported public key types
     * 1 byte
     * bit-0: Public Key OOB information available
     * bit-1--7: Prohibited
     */
    public publicKeyType = 0;

    /**
     * Supported static OOB Types
     * 1 byte
     * bit 0: Static OOB information available
     * bit 1–7: Prohibited
     */
    public  staticOOBType = 0;

    /**
     * Maximum size of Output OOB supported
     * 1 byte
     * 0x00: The device does not support output OOB
     * 0x01–0x08: Maximum size in octets supported by the device
     * 0x09–0xFF: Reserved for Future Use
     */
    public  outputOOBSize = 0;

    /**
     * Supported Output OOB Actions
     * 2 bytes
     * bit-0: Blink
     * bit-1: Beep
     * bit-2: Vibrate
     * bit-3: Output Numeric
     * bit-4: Output Alphanumeric, Array of octets
     * other bits are RFU
     */
    public  outputOOBAction = 0;

    /**
     * Maximum size in octets of Input OOB supported
     * 1 byte
     * 0x00: The device does not support Input OOB
     * 0x01–0x08: Maximum supported size in octets supported by the device
     * 0x09–0xFF: Reserved for Future Use
     */
    public  inputOOBSize = 0;

    /**
     * Supported Input OOB Actions
     * 2 bytes
     * bit-0: Push
     * bit-1: Twist
     * bit-2:Input Number
     * bit-3: Input Alphanumeric, Array of octets
     * bit-4--15 Reserved for Future Use
     */
    public  inputOOBAction = 0;

    /**
     * create instance from byte array
     *
     * @param data data
     * @return instance
     */
    public static  fromBytes(data: Uint8Array): ProvisioningCapabilityPDU | undefined{
        if (data == null || data.length < ProvisioningCapabilityPDU.LEN) {
            return undefined;
        }

        let capability = new ProvisioningCapabilityPDU();
        capability.rawData = data;
        let index = 0;
        capability.eleNum = data[index++];
        capability.algorithms = (((data[index++] & 0xFF) << 8) | (data[index++] & 0xFF));
        capability.publicKeyType = data[index++];
        capability.staticOOBType = data[index++];
        capability.outputOOBSize = data[index++];
        capability.outputOOBAction =  (((data[index++] & 0xFF) << 8) | (data[index++] & 0xFF));
        capability.inputOOBSize = data[index++];
        capability.inputOOBAction =  (((data[index++] & 0xFF) << 8) | (data[index] & 0xFF));
        return capability;
    }


    /**
     * @return the raw byte array representation of the  ProvisioningCapabilityPDU  object.
     */

    public toBytes() : Uint8Array | undefined {
        return this.rawData;
    }



    /**
     * Gets the state of the PDU.
     *
     * @return The state of the PDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_CAPABILITIES;
    }

    /**
     * checks if the static Out-of-Band (OOB) type is supported by the  ProvisioningCapabilityPDU  object.
     *
     * @return true  if the  staticOOBType  attribute is not equal to 0.
     */
    public isStaticOOBSupported() {
        return this.staticOOBType != 0;
    }

    /**
     * method checks if the HMAC algorithm is supported by the  ProvisioningCapabilityPDU  object.
     *
     * @return true  if the  algorithms  attribute has the  ALG_BIT_MASK_HMAC  bit set.
     */
    public isHMacAlgorithmSupported() {
        return (this.algorithms & ALG_BIT_MASK_HMAC) != 0;
    }
}
