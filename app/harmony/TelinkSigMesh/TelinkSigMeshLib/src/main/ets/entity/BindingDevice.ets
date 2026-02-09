/********************************************************************************************************
 * @file     BindingDevice.ets 
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
 * @file BindingDevice.ets
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
import { BindingBearer } from "../core/access/BindingBearer";
import { CompositionData } from "./CompositionData";
import { ArrayList } from "@kit.ArkTS";

/**
 * Created by kee on 2019/9/6.
 */

export class BindingDevice {
    /**
     * network key index,
     * if the index value is -1, it would be replaced by {@link com.telink.ble.mesh.foundation.MeshConfiguration#netKeyIndex}
     */
    public netKeyIndex: number = -1;
    /**
     * device unicast address
     */
    public meshAddress: number = 0
    /**
     * UUID of the device.
     */
    public deviceUUID: Uint8Array = new Uint8Array(0);
    /**
     * model and appKey map, null means bind all models
     */
    //    public SparseIntArray modelAppKeyMap;

    /**
     * app key index, should be contained in NetworkingController#appKeyMap
     */
    public appKeyIndex: number = 0;
    /**
     * models bound at this key
     */
    public models?: ArrayList<number>
    /**
     * binding bearer
     * {@link BindingBearer#GattOnly} and {@link BindingBearer#Any}
     */
    public bearer = BindingBearer.GattOnly;
    /**
     * default bound is public action defined by telink, for faster binding
     * if valued by true, when node received app key, it will bind all models automatically;
     */
    public defaultBound = false;
    /**
     * Composition data of the device.
     */
    public compositionData?: CompositionData;

    /**
     * Default constructor.
     */
    public constructor() {
    }

    /**
     * Constructor with parameters.
     *
     * @param meshAddress The unicast address of the device.
     * @param deviceUUID  The UUID of the device.
     * @param appKeyIndex The index of the application key to be used for binding.
     */
    // public BindingDevice(int meshAddress, byte[] deviceUUID, int appKeyIndex) {
    //     this.meshAddress = meshAddress;
    //     this.deviceUUID = deviceUUID;
    //     this.appKeyIndex = appKeyIndex;
    //     this.models = null;
    //     this.bearer = BindingBearer.GattOnly;
    // }

    /**
     * Constructor with parameters.
     *
     * @param meshAddress The unicast address of the device.
     * @param deviceUUID  The UUID of the device.
     * @param appKeyIndex The index of the application key to be used for binding.
     * @param models      Array of model IDs to be bound.
     * @param bearer      The binding bearer.
     */
    // public BindingDevice(int meshAddress, byte[] deviceUUID, int appKeyIndex, int[] models, BindingBearer bearer) {
    //     this.meshAddress = meshAddress;
    //     this.deviceUUID = deviceUUID;
    //     this.appKeyIndex = appKeyIndex;
    //     this.models = models;
    //     this.bearer = bearer;
    // }

}