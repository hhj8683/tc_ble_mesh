/********************************************************************************************************
 * @file     AdditionalInformation.ets 
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
 * @file AdditionalInformation.ets
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
 * Represents different additional information codes.
 * Each code has a corresponding description.
 */
export enum AdditionalInformation {
    No_changes = 0x00,
    CPS_CHANGED_1 = 0x01,
    CPS_CHANGED_2 = 0x02,
    NODE_UNPROVISIONED = 0x03,
    UNKNOWN_ERROR = 0xFF
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfAdditionalInformation(code: number): string | undefined {
    switch (code) {
        case AdditionalInformation.No_changes:
            return "No changes to node composition data";
        case AdditionalInformation.CPS_CHANGED_1:
            return "Node composition data changed. The node does not support remote provisioning.";
        case AdditionalInformation.CPS_CHANGED_2:
            return "Node composition data changed, and remote provisioning is supported. " +
                "The node supports remote provisioning and composition data page 0x80. Page 0x80 contains different composition data than page 0x0.";
        case AdditionalInformation.NODE_UNPROVISIONED:
            return "Node unprovisioned. The node is unprovisioned after successful application of a verified firmware image.";
        case AdditionalInformation.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the AdditionalInformation enum value corresponding to the given code.
 * If no matching status is found, returns UNKNOWN_ERROR.
 *
 * @param code The code to find the corresponding status for.
 * @return The AdditionalInformation enum value.
 */
function valueOf(code: number): AdditionalInformation {
    switch (code) {
        case 0x00:
            return AdditionalInformation.No_changes;
        case 0x01:
            return AdditionalInformation.CPS_CHANGED_1;
        case 0x02:
            return AdditionalInformation.CPS_CHANGED_2;
        case 0x03:
            return AdditionalInformation.NODE_UNPROVISIONED;
        case 0xFF:
            return AdditionalInformation.UNKNOWN_ERROR;
        default:
            return AdditionalInformation.UNKNOWN_ERROR;
    }
}