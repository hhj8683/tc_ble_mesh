/********************************************************************************************************
 * @file UpdatePhase.ets
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
 * This enum represents the different phases of an update process.
 * Each phase is associated with a unique code and description.
 * The enum provides methods to retrieve the phase based on its code.
 */
export enum UpdatePhase {
    IDLE = 0x00,
    TRANSFER_ERROR = 0x01,
    TRANSFER_ACTIVE = 0x02,
    VERIFYING_UPDATE = 0x03,
    VERIFICATION_SUCCEEDED = 0x04,
    VERIFICATION_FAILED = 0x05,
    APPLYING_UPDATE = 0x06,
    TRANSFER_CANCELED = 0x07,
    APPLY_SUCCESS = 0x08,
    APPLY_FAILED = 0x09,
    UNKNOWN_ERROR = 0xFF
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
 export function getDescriptionByCodeOfUpdatePhase(code: number): string | undefined {
    switch (code) {
        case UpdatePhase.IDLE:
            return "No firmware transfer is in progress";
        case UpdatePhase.TRANSFER_ERROR:
            return "Firmware transfer was not completed";
        case UpdatePhase.TRANSFER_ACTIVE:
            return "Firmware transfer is in progress";
        case UpdatePhase.VERIFYING_UPDATE:
            return "Verification of the firmware image is in progress";
        case UpdatePhase.VERIFICATION_SUCCEEDED:
            return "Firmware image verification succeeded";
        case UpdatePhase.VERIFICATION_FAILED:
            return "Firmware image verification failed";
        case UpdatePhase.APPLYING_UPDATE:
            return "Firmware applying is in progress";
        case UpdatePhase.TRANSFER_CANCELED:
            return "Firmware transfer has been canceled";
        case UpdatePhase.APPLY_SUCCESS:
            return "Firmware applying succeeded";
        case UpdatePhase.APPLY_FAILED:
            return "Firmware applying failed";
        case UpdatePhase.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the UpdatePhase associated with the given code.
 * If no matching phase is found, returns UNKNOWN_ERROR.
 *
 * @param code The code to lookup.
 * @returns The UpdatePhase associated with the code, or UNKNOWN_ERROR if not found.
 */
function valueOf(code: number): UpdatePhase {
    switch (code) {
        case 0x00:
            return UpdatePhase.IDLE;
        case 0x01:
            return UpdatePhase.TRANSFER_ERROR;
        case 0x02:
            return UpdatePhase.TRANSFER_ACTIVE;
        case 0x03:
            return UpdatePhase.VERIFYING_UPDATE;
        case 0x04:
            return UpdatePhase.VERIFICATION_SUCCEEDED;
        case 0x05:
            return UpdatePhase.VERIFICATION_FAILED;
        case 0x06:
            return UpdatePhase.APPLYING_UPDATE;
        case 0x07:
            return UpdatePhase.TRANSFER_CANCELED;
        case 0x08:
            return UpdatePhase.APPLY_SUCCESS;
        case 0x09:
            return UpdatePhase.APPLY_FAILED;
        case 0xFF:
            return UpdatePhase.UNKNOWN_ERROR;
        default:
            return UpdatePhase.UNKNOWN_ERROR;
    }
}