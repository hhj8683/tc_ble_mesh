/********************************************************************************************************
 * @file TransferPhase.ets
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
 * This enum represents the different phases of a BLOB transfer process.
 * Each phase is defined by a unique code and a corresponding description.
 * The enum also provides a method to retrieve the TransferPhase based on its code.
 */
export enum TransferPhase {
    INACTIVE = 0x00,
    WAITING_FOR_TRANSFER_START = 0x01,
    WAITING_FOR_NEXT_BLOCK = 0x02,
    WAITING_FOR_NEXT_CHUNK = 0x03,
    COMPLETE = 0x04,
    SUSPENDED = 0x05,
    UNKNOWN_ERROR = 0x0A
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfTransferPhase(code: number): string | undefined {
    switch (code) {
        case TransferPhase.INACTIVE:
            return "The BLOB Transfer Server is awaiting configuration and cannot receive a BLOB.";
        case TransferPhase.WAITING_FOR_TRANSFER_START:
            return "The BLOB Transfer Server is ready to receive the BLOB identified by the Expected BLOB ID.";
        case TransferPhase.WAITING_FOR_NEXT_BLOCK:
            return "The BLOB Transfer Server is waiting for the next block of data.";
        case TransferPhase.WAITING_FOR_NEXT_CHUNK:
            return "The BLOB Transfer Server is waiting for the next chunk of data.";
        case TransferPhase.COMPLETE:
            return "The BLOB was transferred successfully.";
        case TransferPhase.SUSPENDED:
            return "The Initialize and Receive BLOB procedure is paused.";
        case TransferPhase.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the TransferPhase enum corresponding to the given code.
 * If no matching TransferPhase is found, UNKNOWN_ERROR is returned.
 *
 * @param code The code to retrieve the TransferPhase for.
 * @returns The TransferPhase enum for the given code, or UNKNOWN_ERROR if not found.
 */
function valueOf(code: number): TransferPhase {
    switch (code) {
        case 0x00:
            return TransferPhase.INACTIVE;
        case 0x01:
            return TransferPhase.WAITING_FOR_TRANSFER_START;
        case 0x02:
            return TransferPhase.WAITING_FOR_NEXT_BLOCK;
        case 0x03:
            return TransferPhase.WAITING_FOR_NEXT_CHUNK;
        case 0x04:
            return TransferPhase.COMPLETE;
        case 0x05:
            return TransferPhase.SUSPENDED;
        case 0x0A:
            return TransferPhase.UNKNOWN_ERROR;
        default:
            return TransferPhase.UNKNOWN_ERROR;
    }
}