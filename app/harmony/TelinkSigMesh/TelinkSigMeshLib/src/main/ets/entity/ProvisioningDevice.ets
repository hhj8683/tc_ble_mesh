/********************************************************************************************************
 * @file     ProvisioningDevice.ets 
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
 * @file ProvisioningDevice.ets
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

import { ProvisioningCapabilityPDU } from "../core/provisioning/pdu/ProvisioningCapabilityPDU";

/**
 * Model for provisioning flow
 * Created by kee on 2019/9/4.
 */

const DATA_PDU_LEN = 16 + 2 + 1 + 4 + 2; // Length of the data PDU
export  class ProvisioningDevice {
    /**
     * 16: key
     * 2: key index
     * 1: flags
     * 4: iv index
     * 2: unicast adr
     */
    public bluetoothDeviceId: string; // The Bluetooth device associated with this provisioning device

    public deviceUUID: Uint8Array; // The UUID of the device

    /**
     * OOB Information
     * Bit - Description
     * 0 - Other
     * 1 - Electronic / URI
     * 2 - 2D machine-readable code
     * 3 - Bar code
     * 4 - Near Field Communication (NFC)
     * 5 - Number
     * 6 - String
     * 7 - Support for certificate-based provisioning
     * 8 - Support for provisioning records
     * 9 - Reserved for Future Use
     * 10 - Reserved for Future Use
     * 11 - On box
     * 12 - Inside box
     * 13 - On piece of paper
     * 14 - Inside manual
     * 15 - On device
     */
    public oobInfo = 0; // Out-of-Band (OOB) information


    public networkKey = new Uint8Array(0); // The network key used for provisioning


    public networkKeyIndex = 0; // The index of the network key


    /**
     * 1 bit
     * The key refresh flag
     */
    public keyRefreshFlag = 0;


    /**
     * 1 bit
     * The IV update flag
     */
    public ivUpdateFlag = 0;


    /**
     * 4 bytes
     * The IV index
     */
    public ivIndex = 0;


    /**
     * unicast address for primary element
     * 2 bytes
     */
    public unicastAddress = 0;


    /**
     * auth value for static oob AuthMethod
     * {@link com.telink.ble.mesh.core.provisioning.AuthenticationMethod#StaticOOB}
     */
    public authValue: Uint8Array | undefined;


    /**
     * Flag indicating whether to automatically use no-OOB if auth value is null
     */
    public autoUseNoOOB = false;

    /**
     * The current provisioning state of the device
     */
    public provisioningState = 0;

    /**
     * The device key
     */
    public deviceKey: Uint8Array | undefined;

    /**
     * The root certificate
     */
    public rootCert: Uint8Array | undefined;


    /**
     * Whether to automatically send start after receiving the Capability
     * if true, the provision-controller will send start pdu
     * otherwise, the user should call
     */
    public autoStart = true;

    public deviceCapability: ProvisioningCapabilityPDU | undefined; // The device capability

    public attentionDuration = 0;

    /**
     * Constructor for ProvisioningDevice.
     *
     * @param bluetoothDevice The Bluetooth device associated with this provisioning device
     * @param deviceUUID      The UUID of the device
     * @param unicastAddress  The unicast address of the device
     */
    public constructor(bluetoothDeviceId : string, deviceUUID : Uint8Array) {
        this.bluetoothDeviceId = bluetoothDeviceId;
        this.deviceUUID = deviceUUID;
    }

    /**
     * Generates the provisioning data for the device.
     *
     * @return The provisioning data as a byte array
     */
    public generateProvisioningData() : Uint8Array{
        let flags =  (this.keyRefreshFlag & 0b01) | (this.ivUpdateFlag & 0b10)
        // 创建 ArrayBuffer 和 DataView
        let buffer: ArrayBuffer = new ArrayBuffer(DATA_PDU_LEN);
        let view: DataView = new DataView(buffer)
        let offset = 0

        // 放入 networkKey (byte[])
        for (let i = 0; i < this.networkKey.length; i++) {
            view.setUint8(offset, this.networkKey[i]);
            offset++;
        }

        view.setUint16(offset, this.networkKeyIndex, false)
        offset += 2
        view.setUint8(offset, flags)
        offset += 1
        view.setUint32(offset, this.ivIndex, false)
        offset+= 4

        view.setUint16(offset, this.unicastAddress, false);
        offset += 2;

        return new Uint8Array(view.buffer)
    }


}