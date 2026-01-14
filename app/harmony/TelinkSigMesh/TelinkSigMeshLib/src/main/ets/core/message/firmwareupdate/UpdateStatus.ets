/********************************************************************************************************
 * @file UpdateStatus.ets
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
 * This enum represents the possible status codes for an update operation.
 * Each status code is associated with a description.
 */
export enum UpdateStatus {
    SUCCESS = 0x00,
    INSUFFICIENT_RESOURCES = 0x01,
    WRONG_PHASE = 0x02,
    INTERNAL_ERROR = 0x03,
    WRONG_FIRMWARE_INDEX = 0x04,
    METADATA_CHECK_FAILED = 0x05,
    TEMPORARILY_UNAVAILABLE = 0x06,
    BLOB_TRANSFER_BUSY = 0x07,
    UNKNOWN_ERROR = 0xFF
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfUpdateStatus(code: number): string | undefined {
    switch (code) {
        case UpdateStatus.SUCCESS:
            return "The message was processed successfully";
        case UpdateStatus.INSUFFICIENT_RESOURCES:
            return "Insufficient resources on the node";
        case UpdateStatus.WRONG_PHASE:
            return "The operation cannot be performed while the server is in the current phase.";
        case UpdateStatus.INTERNAL_ERROR:
            return "An internal error occurred on the node.";
        case UpdateStatus.WRONG_FIRMWARE_INDEX:
            return "The message contains a firmware index value that is not expected.";
        case UpdateStatus.METADATA_CHECK_FAILED:
            return "The metadata check failed.";
        case UpdateStatus.TEMPORARILY_UNAVAILABLE:
            return "The server cannot start a firmware update.";
        case UpdateStatus.BLOB_TRANSFER_BUSY:
            return "Another BLOB transfer is in progress.";
        case UpdateStatus.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the UpdateStatus associated with the given code.
 * If no matching status is found, returns UNKNOWN_ERROR.
 *
 * @param code The code to lookup.
 * @returns The UpdateStatus associated with the code, or UNKNOWN_ERROR if not found.
 */
function valueOf(code: number): UpdateStatus {
    switch (code) {
        case 0x00:
            return UpdateStatus.SUCCESS;
        case 0x01:
            return UpdateStatus.INSUFFICIENT_RESOURCES;
        case 0x02:
            return UpdateStatus.WRONG_PHASE;
        case 0x03:
            return UpdateStatus.INTERNAL_ERROR;
        case 0x04:
            return UpdateStatus.WRONG_FIRMWARE_INDEX;
        case 0x05:
            return UpdateStatus.METADATA_CHECK_FAILED;
        case 0x06:
            return UpdateStatus.TEMPORARILY_UNAVAILABLE;
        case 0x07:
            return UpdateStatus.BLOB_TRANSFER_BUSY;
        case 0xFF:
            return UpdateStatus.UNKNOWN_ERROR;
        default:
            return UpdateStatus.UNKNOWN_ERROR;
    }
}