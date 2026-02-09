/********************************************************************************************************
 * @file AccessType.ets
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


/**
 * Access Command
 * This enum represents the access type for encryption/decryption in a Bluetooth mesh network.
 * the value is akf
 */
export  enum AccessType {

    /**
     * for config model settings
     * use device key for encryption/decryption
     */
    DEVICE = (0),

    /**
     * for common model and vendor model
     * use application key for encryption/decryption
     */
    APPLICATION = (1),

}
