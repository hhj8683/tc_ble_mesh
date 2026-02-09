/********************************************************************************************************
 * @file     MeshFirmwareParser.ets 
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
 * @file MeshFirmwareParser.ets
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

import { logd } from '../../../ets/utils/MeshLogger';
import { calCrc32 } from '../../../ets/utils/Crc';

export class MeshFirmwareParser {

    private static readonly DEFAULT_BLOCK_SIZE = 4 * 1024;

    private static readonly DEFAULT_CHUNK_SIZE = 256;

    private firmwareData: Uint8Array = new Uint8Array();

    private objectSize: number = 0;

    private mBlockSize: number = MeshFirmwareParser.DEFAULT_BLOCK_SIZE;

    private mChunkSize: number = MeshFirmwareParser.DEFAULT_CHUNK_SIZE;

    private curBlockIndex: number = -1;

    private curChunkIndex: number = -1;

    private totalBlockNumber: number = 0;

    private totalChunkNumber: number = 0;

    private progress: number = -1;

    public reset(data: Uint8Array) {
        this.firmwareData = data;
        this.objectSize = data.length;

        this.curBlockIndex = -1;
        this.curChunkIndex = -1;
        this.progress = -1;
        this.totalBlockNumber = Math.ceil(this.objectSize / this.mBlockSize);
        this.totalChunkNumber = Math.ceil(this.objectSize / this.mChunkSize);
    }

    public resetWithParams(data: Uint8Array, blockSize: number, chunkSize: number) {
        this.mBlockSize = blockSize;
        this.mChunkSize = chunkSize;
        this.reset(data);
    }


    /**
     * prepare for next block
     *
     * @return if has next
     */
    public nextBlock(): number {
        this.curChunkIndex = -1;
        return ++this.curBlockIndex;
    }

    public resetBlock() {
        this.curChunkIndex = -1;
        logd("reset block : " + this.curBlockIndex + " -- " + this.curChunkIndex);
        // curBlockIndex = -1;
    }

    public hasNextBlock(): boolean {
        return this.curBlockIndex + 1 < this.totalBlockNumber;
    }

    public getCurBlockSize(): number {
        let blockSize: number;

        if (this.hasNextBlock() || (this.objectSize % this.mBlockSize) === 0) {
            // not the last block or last block size is mBlockSize
            blockSize = this.mBlockSize;
        } else {
            blockSize = this.objectSize % this.mBlockSize;
        }
        return blockSize;
    }


    /**
     * refresh progress by chunk/total
     *
     * @return progress
     */
    public validateProgress(): boolean {
        // Math.ceil(mBlockSize/mChunkSize)
        const MAX_PROGRESS = 99; // 99 or 100
        const chunkNumberOffset = this.curBlockIndex * (this.mBlockSize / this.mChunkSize) + (this.curChunkIndex + 1);
        // max 99
        const progress = Math.floor(chunkNumberOffset * MAX_PROGRESS / this.totalChunkNumber);
        if (progress <= this.progress) {
            return false;
        }
        this.progress = progress;
        return true;
    }

    public getProgressAt(blockIndex: number, chunkIndex: number): number {
        const MAX_PROGRESS = 99; // 99 or 100
        const chunkNumberOffset = blockIndex * (this.mBlockSize / this.mChunkSize) + (chunkIndex + 1);
        return Math.floor(chunkNumberOffset * MAX_PROGRESS / this.totalChunkNumber);
    }

    public getProgress(): number {
        return this.progress;
    }

    /**
     * generate next chunk at current block
     *
     * @return chunk-message or null when all chunk sent
     */
    public nextChunk(): Uint8Array | null {
        let chunkNumber: number;
        const blockSize = this.getCurBlockSize();

        chunkNumber = Math.ceil(blockSize / this.mChunkSize);

        if (this.curChunkIndex + 1 < chunkNumber) {
            // has next
            this.curChunkIndex++;
            let chunkSize: number;
            if (this.curChunkIndex + 1 < chunkNumber || blockSize % this.mChunkSize === 0) {
                chunkSize = this.mChunkSize;
            } else {
                chunkSize = blockSize % this.mChunkSize;
            }

            const chunkData = new Uint8Array(chunkSize);
            const firmwareView = this.firmwareData;
            const offset = this.curBlockIndex * this.mBlockSize + this.curChunkIndex * this.mChunkSize;
            
            for (let i = 0; i < chunkSize; i++) {
                chunkData[i] = firmwareView[offset + i];
            }

            return chunkData;
        } else {
            return null;
        }
    }


    public chunkAt(chunkIndex: number): Uint8Array | null {
        let chunkNumber: number;

        const blockSize = this.getCurBlockSize();

        chunkNumber = Math.ceil(blockSize / this.mChunkSize);
        if (chunkIndex >= chunkNumber) return null;

        let chunkSize: number;
        if (chunkIndex + 1 < chunkNumber || blockSize % this.mChunkSize === 0) {
            chunkSize = this.mChunkSize;
        } else {
            chunkSize = blockSize % this.mChunkSize;
        }

        const chunkData = new Uint8Array(chunkSize);
        const firmwareView = this.firmwareData;
        const offset = this.curBlockIndex * this.mBlockSize + chunkIndex * this.mChunkSize;
        
        for (let i = 0; i < chunkSize; i++) {
            chunkData[i] = firmwareView[offset + i];
        }

        return chunkData;
    }

    public currentBlockIndex(): number {
        return this.curBlockIndex;
    }

    public currentChunkIndex(): number {
        return this.curChunkIndex;
    }

    public getObjectSize(): number {
        return this.objectSize;
    }

    public getBlockSize(): number {
        return this.mBlockSize;
    }

    public getChunkSize(): number {
        return this.mChunkSize;
    }

    /**
     * get current block checksum
     */
    public getBlockChecksum(): number {
        const blockSize = this.getCurBlockSize();
        const blockData = new Uint8Array(blockSize);
        const firmwareView = this.firmwareData;
        const offset = this.curBlockIndex * this.mBlockSize;
        
        for (let i = 0; i < blockSize; i++) {
            blockData[i] = firmwareView[offset + i];
        }
        
        let crcValue = calCrc32(blockData);
        return crcValue;
    }
}