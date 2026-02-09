/********************************************************************************************************
 * @file OnlineStatusInfo.ets
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
 * online status
 * This class represents the online status information of a user.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 */
export class OnlineStatusInfo {
    public address: number = 0;
    // The address of the user
    public sn = 0;
    // The serial number indicating the online status (0 for offline)
    public status: Uint8Array = new Uint8Array(0);
    // The additional status information
}