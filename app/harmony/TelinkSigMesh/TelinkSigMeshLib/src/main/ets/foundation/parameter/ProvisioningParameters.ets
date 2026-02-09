/********************************************************************************************************
 * @file     ProvisioningParameters.ets 
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
 * @file ProvisioningParameters.ets
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
import { SERVICE_PROVISION } from '../../ble/UuidInfo';
import { ProvisioningDevice } from '../../entity/ProvisioningDevice';
import { ActionParameters } from './ActionParameters';

/**
 * This is a class called ProvisioningParameters that extends the Parameters class.
 * used in {@link com.telink.ble.mesh.foundation.MeshService#startProvisioning(ProvisioningParameters)}
 */
export class ProvisioningParameters extends ActionParameters {
    /**
     * constructor that takes a ProvisioningDevice object as a parameter.
     *
     * @param device ProvisioningDevice
     */
    public constructor(device: ProvisioningDevice) {
        super();
        this.setScanFilter([this.createScanFilter(SERVICE_PROVISION)]);
        this.set(ProvisioningParameters.ACTION_PROVISIONING_TARGET, device);
    }
}
