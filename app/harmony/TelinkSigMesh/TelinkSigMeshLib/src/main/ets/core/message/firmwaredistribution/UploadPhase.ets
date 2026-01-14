/********************************************************************************************************
 * @file UploadPhase.ets
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
 * This enum represents the different phases of firmware upload.
 * Each phase is defined by a unique code and a corresponding description.
 * The enum also provides a method to retrieve the UploadPhase based on its code.
 */
export enum UploadPhase {
    IDLE = 0x00,
    TRANSFER_ACTIVE = 0x01,
    TRANSFER_ERROR = 0x02,
    TRANSFER_SUCCESS = 0x03
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfUploadPhase(code: number): string | undefined {
    switch (code) {
        case UploadPhase.IDLE:
            return "No firmware upload is in progress.";
        case UploadPhase.TRANSFER_ACTIVE:
            return "The Store Firmware or Store Firmware OOB procedure is being executed.";
        case UploadPhase.TRANSFER_ERROR:
            return "The Store Firmware procedure or Store Firmware OOB procedure failed.";
        case UploadPhase.TRANSFER_SUCCESS:
            return "The Store Firmware procedure or the Store Firmware OOB procedure completed successfully.";
        default:
            return undefined;
    }
}

/**
 * Returns the UploadPhase enum corresponding to the given code.
 * If no matching UploadPhase is found, IDLE is returned.
 *
 * @param code The code to retrieve the UploadPhase for.
 * @returns The UploadPhase enum for the given code, or IDLE if not found.
 */
function valueOf(code: number): UploadPhase {
    switch (code) {
        case 0x00:
            return UploadPhase.IDLE;
        case 0x01:
            return UploadPhase.TRANSFER_ACTIVE;
        case 0x02:
            return UploadPhase.TRANSFER_ERROR;
        case 0x03:
            return UploadPhase.TRANSFER_SUCCESS;
        default:
            return UploadPhase.IDLE;
    }
}