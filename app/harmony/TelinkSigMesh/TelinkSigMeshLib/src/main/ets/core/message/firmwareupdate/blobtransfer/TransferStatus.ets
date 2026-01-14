/********************************************************************************************************
 * @file TransferStatus.ets
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
 * This enum defines a set of constants representing different transfer statuses.
 * Each constant has a code and a description associated with it.
 */
export enum TransferStatus {
    SUCCESS = 0x00,
    INVALID_BLOCK_NUMBER = 0x01,
    INVALID_BLOCK_SIZE = 0x02,
    INVALID_CHUNK_SIZE = 0x03,
    INVALID_STATE = 0x04,
    INVALID_PARAMETER = 0x05,
    WRONG_BLOB_ID = 0x06,
    BLOB_TOO_LARGE = 0x07,
    UNSUPPORTED_TRANSFER_MODE = 0x08,
    INTERNAL_ERROR = 0x09,
    UNKNOWN_ERROR = 0x0A
}

/**
 * Gets the description for a given code.
 * 
 * @param code The code to get the description for.
 * @returns The description for the given code, or undefined if not found.
 */
export function getDescriptionByCodeOfTransferStatus(code: number): string | undefined {
    switch (code) {
        case TransferStatus.SUCCESS:
            return "The message was processed successfully";
        case TransferStatus.INVALID_BLOCK_NUMBER:
            return "The Block Number field value is not within the range of blocks being transferred";
        case TransferStatus.INVALID_BLOCK_SIZE:
            return "The block size is smaller than the size indicated by the Min Block Size Log state or is larger than the size indicated by the Max Block Size Log state.";
        case TransferStatus.INVALID_CHUNK_SIZE:
            return " The chunk size exceeds the size indicated by the Max Chunk Size state, or the number of chunks exceeds the number specified by the Max Total Chunks state.";
        case TransferStatus.INVALID_STATE:
            return "The operation cannot be performed while the server is in the current phase.";
        case TransferStatus.INVALID_PARAMETER:
            return "A parameter value in the message cannot be accepted.";
        case TransferStatus.WRONG_BLOB_ID:
            return "The message contains a BLOB ID value that is not expected.";
        case TransferStatus.BLOB_TOO_LARGE:
            return "There is not enough space available in memory to receive the BLOB.";
        case TransferStatus.UNSUPPORTED_TRANSFER_MODE:
            return "The transfer mode is not supported by the BLOB Transfer Server model.";
        case TransferStatus.INTERNAL_ERROR:
            return "An internal error occurred on the node";
        case TransferStatus.UNKNOWN_ERROR:
            return "unknown error";
        default:
            return undefined;
    }
}

/**
 * Returns the TransferStatus enum value corresponding to the given code.
 * If no matching status is found, returns UNKNOWN_ERROR.
 *
 * @param code The code to find the corresponding status for.
 * @returns The TransferStatus enum value.
 */
function valueOf(code: number): TransferStatus {
    switch (code) {
        case 0x00:
            return TransferStatus.SUCCESS;
        case 0x01:
            return TransferStatus.INVALID_BLOCK_NUMBER;
        case 0x02:
            return TransferStatus.INVALID_BLOCK_SIZE;
        case 0x03:
            return TransferStatus.INVALID_CHUNK_SIZE;
        case 0x04:
            return TransferStatus.INVALID_STATE;
        case 0x05:
            return TransferStatus.INVALID_PARAMETER;
        case 0x06:
            return TransferStatus.WRONG_BLOB_ID;
        case 0x07:
            return TransferStatus.BLOB_TOO_LARGE;
        case 0x08:
            return TransferStatus.UNSUPPORTED_TRANSFER_MODE;
        case 0x09:
            return TransferStatus.INTERNAL_ERROR;
        case 0x0A:
            return TransferStatus.UNKNOWN_ERROR;
        default:
            return TransferStatus.UNKNOWN_ERROR;
    }
}