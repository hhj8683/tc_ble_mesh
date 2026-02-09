/********************************************************************************************************
 * @file     Element.ets 
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
 * @file Element.ets
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
 * Represents an element in a Bluetooth mesh network.
 * Implements the Serializable and Parcelable interfaces for object serialization and passing between activities.
 */
export class Element  {
    /**
     * 2 bytes
     * Contains a location descriptor
     */
    public  location = 0;

    /**
     * 1 byte
     * Contains a count of SIG Model IDs in this element
     */
    public sigNum = 0;

    /**
     * 1 byte
     * Contains a count of Vendor Model IDs in this element
     */
    public vendorNum = 0;

    /**
     * Contains a sequence of NumS SIG Model IDs
     * Uint16Array
     */
    public  sigModels: number[] = []

    /**
     * Contains a sequence of NumV Vendor Model IDs
     * Uint32Array
     */
    public vendorModels:number[] = []

    /**
     * not in composition data, only for UI selection
     */

    public  selected = false;

    /**
     * Default constructor for the Element class.
     */
    public constructor() {
    }

    /**
     * Checks if the element contains a specific SIG Model ID.
     *
     * @param sigModelId The SIG Model ID to check for.
     * @return true if the element contains the specified SIG Model ID, false otherwise.
     */
    public  containModel(sigModelId: number):boolean {
        if (this.sigModels.length == 0) return false;
        for (let modelId of this.sigModels) {
            if (sigModelId == modelId) return true;
        }
        return false;
    }

}
