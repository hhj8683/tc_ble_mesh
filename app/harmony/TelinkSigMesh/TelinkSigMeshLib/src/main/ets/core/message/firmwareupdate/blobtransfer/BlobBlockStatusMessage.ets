/********************************************************************************************************
 * @file BlobBlockStatusMessage.ets
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

import { ByteOrder, bytes2Integer } from '../../../../utils/ArrayUtils';
import { StatusMessage } from "../../../message/StatusMessage";
import { TransferStatus } from './TransferStatus';
import { util } from "@kit.ArkTS";

/**
 * This class represents a Blob Block Status Message.
 * It extends the StatusMessage class and implements the Parcelable interface for serialization.
 * The Blob Block Status Message is used to provide information about the status of a block in a blob transfer.
 */
export class BlobBlockStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "BlobBlockStatusMessage"

    public statusName(): string {
        return BlobBlockStatusMessage.STATUS_NAME
    }

    /**
     * All chunks in the block are missing.
     */
    public static readonly FORMAT_ALL_CHUNKS_MISSING: number = 0x00;

    /**
     * All chunks in the block have been received.
     */
    public static readonly FORMAT_NO_CHUNKS_MISSING: number = 0x01;

    /**
     * At least one chunk has been received and at least one chunk is missing.
     */
    public static readonly FORMAT_SOME_CHUNKS_MISSING: number = 0x02;

    /**
     * List of chunks requested by the server
     */
    public static readonly FORMAT_ENCODED_MISSING_CHUNKS: number = 0x03;

    /**
     * Status Code for the requesting message
     * lower 4 bits in first byte
     *
     * @see TransferStatus
     */
    private status: number = 0;

    /**
     * Indicates the format used to report missing chunks
     * higher 2 bits in first byte
     */
    private format: number = 0;

    /**
     * Block number of the current block
     * 16 bits
     */
    private blockNumber: number = 0;

    /**
     * Chunk Size (in octets) for the current block
     * 16 bits
     */
    private chunkSize: number = 0;

    /**
     * Bit field of missing chunks for this block
     */
    private missingChunks: Array<number> = [];

    /**
     * List of chunks requested by the server
     * using UTF-8
     */
    private encodedMissingChunks: Array<number> = [];

    /**
     * Default constructor for the BlobBlockStatusMessage class.
     */
    constructor() {
        super();
    }

    /**
     * Parses the given byte array and sets the attributes of the object accordingly.
     *
     * @param params The byte array to parse.
     */
    public parse(params: Uint8Array) {
        let index = 0;
        this.status = params[index] & 0x0F;
        this.format = (params[index++] >> 6) & 0x03;

        this.blockNumber = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.chunkSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        if (this.format === BlobBlockStatusMessage.FORMAT_SOME_CHUNKS_MISSING) {
            this.missingChunks = this.parseMissingBitField(params, index);
        } else if (this.format === BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS) {
            this.encodedMissingChunks = [];
            const missingLength = params.length - index;
            // const missingBytes = new Uint8Array(missingLength);
            for (let i = 0; i < missingLength; i++) {
                // missingBytes[i] = params[index + i];
                this.encodedMissingChunks.push(params[index + i]);
            }
            // console.log("getEncodedMissingChunks=", encodedMissingChunks)
            // const decodeMissingChunks = new util.TextDecoder('utf-8').decode(missingBytes);
            // for (const c of decodeMissingChunks) {
            //     this.encodedMissingChunks.push(c.charCodeAt(0) & 0xFFFF);
            // }
            //待验证实际效果。
            console.log("警告⚠️：验证是否正常解包成功。getEncodedMissingChunks=", this.encodedMissingChunks)
        }
    }

    /**
     * Parses the missing bit field from the byte array.
     *
     * @param params The byte array containing the bit field.
     * @param index The starting index in the byte array.
     * @returns The list of missing chunks.
     */
    private parseMissingBitField(params: Uint8Array, index: number): Array<number> {
        const missingChunks: Array<number> = [];
        let bitIndex = 0;
        for (let i = index; i < params.length; i++) {
            const byte = params[i];
            for (let j = 0; j < 8; j++) {
                if ((byte & (1 << j)) !== 0) {
                    missingChunks.push(bitIndex);
                }
                bitIndex++;
            }
        }
        return missingChunks;
    }

    /**
     * Gets the status of the object.
     *
     * @return The status of the object.
     */
    public getStatus(): number {
        return this.status;
    }

    /**
     * Gets the format of the object.
     *
     * @return The format of the object.
     */
    public getFormat(): number {
        return this.format;
    }

    /**
     * Gets the block number of the object.
     *
     * @return The block number of the object.
     */
    public getBlockNumber(): number {
        return this.blockNumber;
    }

    /**
     * Gets the chunk size of the object.
     *
     * @return The chunk size of the object.
     */
    public getChunkSize(): number {
        return this.chunkSize;
    }

    /**
     * Gets the missing chunks of the object.
     *
     * @return The missing chunks of the object.
     */
    public getMissingChunks(): Array<number> {
        return this.missingChunks;
    }

    /**
     * Gets the encoded missing chunks of the object.
     *
     * @return The encoded missing chunks of the object.
     */
    public getEncodedMissingChunks(): Array<number> {
        return this.encodedMissingChunks;
    }

    /**
     * Sets the status of the object.
     *
     * @param status The status to be set.
     */
    public setStatus(status: number): void {
        this.status = status;
    }

    /**
     * Sets the format of the object.
     *
     * @param format The format to be set.
     */
    public setFormat(format: number): void {
        this.format = format;
    }

    /**
     * Sets the block number of the object.
     *
     * @param blockNumber The block number to be set.
     */
    public setBlockNumber(blockNumber: number): void {
        this.blockNumber = blockNumber;
    }

    /**
     * Sets the chunk size of the object.
     *
     * @param chunkSize The chunk size to be set.
     */
    public setChunkSize(chunkSize: number): void {
        this.chunkSize = chunkSize;
    }

    /**
     * Sets the missing chunks of the object.
     *
     * @param missingChunks The missing chunks to be set.
     */
    public setMissingChunks(missingChunks: Array<number>): void {
        this.missingChunks = missingChunks;
    }

    /**
     * Sets the encoded missing chunks of the object.
     *
     * @param encodedMissingChunks The encoded missing chunks to be set.
     */
    public setEncodedMissingChunks(encodedMissingChunks: Array<number>): void {
        this.encodedMissingChunks = encodedMissingChunks;
    }

    /**
     * Returns a string representation of the BlobBlockStatusMessage object.
     *
     * @return A string representation of the object.
     */
    public toString(): string {
        return `BlobBlockStatusMessage{status=${this.status}, format=${this.format}, blockNumber=${this.blockNumber}, chunkSize=${this.chunkSize}, missingChunks=${this.missingChunks.length}, encodedMissingChunks=${this.encodedMissingChunks.length}}`;
    }
}