/********************************************************************************************************
 * @file TransferMode.ets
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
 * The TransferMode enum represents the different modes of BLOB transfer.
 * It is a 2-bit value that indicates the current mode of the transfer.
 * The enum has four possible values:
 * - NONE: Represents no active transfer mode.
 * - PUSH: Represents the push BLOB transfer mode.
 * - PULL: Represents the pull BLOB transfer mode.
 * - Prohibited: Represents a prohibited transfer mode.
 * Each enum value has a corresponding integer value and description.
 * The TransferMode class provides a static method valueOf() that returns the TransferMode enum value
 * based on the given integer mode.
 */
export enum TransferMode {
    NONE = 0x00,
    PUSH = 0x01,
    PULL = 0x02,
    PROHIBITED = 0x03
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
function getDescriptionByCode(code: number): string | undefined {
    switch (code) {
        case TransferMode.NONE:
            return "No Active Transfer";
        case TransferMode.PUSH:
            return "Push BLOB Transfer Mode";
        case TransferMode.PULL:
            return "Pull BLOB Transfer Mode";
        case TransferMode.PROHIBITED:
            return "Prohibited";
        default:
            return undefined;
    }
}

/**
 * Returns the TransferMode associated with the given code.
 * If no matching mode is found, returns PROHIBITED.
 *
 * @param code The code to lookup.
 * @returns The TransferMode associated with the code, or PROHIBITED if not found.
 */
function valueOf(code: number): TransferMode {
    // Apply 2-bit mask to ensure only valid bits are considered
    const maskedCode = code & 0x03;
    
    switch (maskedCode) {
        case 0x00:
            return TransferMode.NONE;
        case 0x01:
            return TransferMode.PUSH;
        case 0x02:
            return TransferMode.PULL;
        default:
            return TransferMode.PROHIBITED;
    }
}