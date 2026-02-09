/********************************************************************************************************
 * @file     DistributionStatus.ets 
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
 * @file DistributionStatus.ets
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
 * The DistributionStatus enum represents the possible statuses of a message during the distribution process.
 * Each status has a corresponding code and description.
 */
export enum DistributionStatus {
    SUCCESS = 0x00,
    INSUFFICIENT_RESOURCES = 0x01,
    WRONG_PHASE = 0x02,
    INTERNAL_ERROR = 0x03,
    FIRMWARE_NOT_FOUND = 0x04,
    INVALID_APPKEY_INDEX = 0x05,
    RECEIVERS_LIST_EMPTY = 0x06,
    BUSY_WITH_DISTRIBUTION = 0x07,
    BUSY_WITH_UPLOAD = 0x08,
    URI_NOT_SUPPORTED = 0x09,
    URI_MALFORMED = 0x0A,
    URI_UNREACHABLE = 0x0B,
    NEW_FIRMWARE_NOT_AVAILABLE = 0x0C,
    SUSPEND_FAILED = 0x0D,
    UNKNOWN_ERROR = 0xFF,
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfDistributionStatus(code: number): string | undefined {
    switch (code) {
        case DistributionStatus.SUCCESS:
            return "The message was processed successfully";
        case DistributionStatus.INSUFFICIENT_RESOURCES:
            return "Insufficient resources on the node";
        case DistributionStatus.WRONG_PHASE:
            return "The operation cannot be performed while the server is in the current phase";
        case DistributionStatus.INTERNAL_ERROR:
            return "An internal error occurred on the node";
        case DistributionStatus.FIRMWARE_NOT_FOUND:
            return "The requested firmware image is not stored on the Distributor";
        case DistributionStatus.INVALID_APPKEY_INDEX:
            return "The AppKey identified by the AppKey Index is not known to the node";
        case DistributionStatus.RECEIVERS_LIST_EMPTY:
            return "There are no Updating nodes in the Distribution Receivers List state";
        case DistributionStatus.BUSY_WITH_DISTRIBUTION:
            return "Another firmware image distribution is in progress";
        case DistributionStatus.BUSY_WITH_UPLOAD:
            return "Another upload is in progress";
        case DistributionStatus.URI_NOT_SUPPORTED:
            return "The URI scheme name indicated by the Update URI is not supported";
        case DistributionStatus.URI_MALFORMED:
            return "The format of the Update URI is invalid";
        case DistributionStatus.URI_UNREACHABLE:
            return "The URI is unreachable.";
        case DistributionStatus.NEW_FIRMWARE_NOT_AVAILABLE:
            return "The Check Firmware OOB procedure did not find any new firmware.";
        case DistributionStatus.SUSPEND_FAILED:
            return "The suspension of the Distribute Firmware procedure failed.";
        case DistributionStatus.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the DistributionStatus enum value corresponding to the given code.
 * If no matching status is found, returns UNKNOWN_ERROR.
 *
 * @param code The code to find the corresponding status for.
 * @returns The DistributionStatus enum value.
 */
function valueOf(code: number): DistributionStatus {
    switch (code) {
        case 0x00:
            return DistributionStatus.SUCCESS;
        case 0x01:
            return DistributionStatus.INSUFFICIENT_RESOURCES;
        case 0x02:
            return DistributionStatus.WRONG_PHASE;
        case 0x03:
            return DistributionStatus.INTERNAL_ERROR;
        case 0x04:
            return DistributionStatus.FIRMWARE_NOT_FOUND;
        case 0x05:
            return DistributionStatus.INVALID_APPKEY_INDEX;
        case 0x06:
            return DistributionStatus.RECEIVERS_LIST_EMPTY;
        case 0x07:
            return DistributionStatus.BUSY_WITH_DISTRIBUTION;
        case 0x08:
            return DistributionStatus.BUSY_WITH_UPLOAD;
        case 0x09:
            return DistributionStatus.URI_NOT_SUPPORTED;
        case 0x0A:
            return DistributionStatus.URI_MALFORMED;
        case 0x0B:
            return DistributionStatus.URI_UNREACHABLE;
        case 0x0C:
            return DistributionStatus.NEW_FIRMWARE_NOT_AVAILABLE;
        case 0x0D:
            return DistributionStatus.SUSPEND_FAILED;
        case 0xFF:
            return DistributionStatus.UNKNOWN_ERROR;
        default:
            return DistributionStatus.UNKNOWN_ERROR;
    }
}