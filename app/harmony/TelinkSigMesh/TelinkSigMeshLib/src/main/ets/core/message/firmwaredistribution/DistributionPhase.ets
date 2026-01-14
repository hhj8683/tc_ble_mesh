/********************************************************************************************************
 * @file DistributionPhase.ets
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
 * This enum represents the different phases of a firmware update process.
 */
export enum DistributionPhase {
    IDLE = 0x00,
    TRANSFER_ACTIVE = 0x01,
    TRANSFER_SUCCESS = 0x02,
    APPLYING_UPDATE = 0x03,
    COMPLETED = 0x04,
    FAILED = 0x05,
    CANCELING_UPDATE = 0x06
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfDistributionPhase(code: number): string | undefined {
    switch (code) {
        case DistributionPhase.IDLE:
            return "No firmware distribution is in progress.";
        case DistributionPhase.TRANSFER_ACTIVE:
            return "Firmware distribution is in progress.";
        case DistributionPhase.TRANSFER_SUCCESS:
            return "The Transfer BLOB procedure has completed successfully.";
        case DistributionPhase.APPLYING_UPDATE:
            return "The Apply Firmware on Updating Nodes procedure is being executed.";
        case DistributionPhase.COMPLETED:
            return "The Distribute Firmware procedure has completed successfully.";
        case DistributionPhase.FAILED:
            return "The Distribute Firmware procedure has failed.";
        case DistributionPhase.CANCELING_UPDATE:
            return "The Cancel Firmware Update procedure is being executed.";
        default:
            return undefined;
    }
}

/**
 * Returns the DistributionPhase enum corresponding to the given code.
 * If no matching DistributionPhase is found, IDLE is returned.
 *
 * @param code The code to retrieve the DistributionPhase for.
 * @returns The DistributionPhase enum for the given code, or IDLE if not found.
 */
function valueOf(code: number): DistributionPhase {
    switch (code) {
        case 0x00:
            return DistributionPhase.IDLE;
        case 0x01:
            return DistributionPhase.TRANSFER_ACTIVE;
        case 0x02:
            return DistributionPhase.TRANSFER_SUCCESS;
        case 0x03:
            return DistributionPhase.APPLYING_UPDATE;
        case 0x04:
            return DistributionPhase.COMPLETED;
        case 0x05:
            return DistributionPhase.FAILED;
        case 0x06:
            return DistributionPhase.CANCELING_UPDATE;
        default:
            return DistributionPhase.IDLE;
    }
}