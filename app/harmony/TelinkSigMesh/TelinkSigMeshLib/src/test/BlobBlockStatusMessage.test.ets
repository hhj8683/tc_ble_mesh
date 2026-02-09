/********************************************************************************************************
 * @file     BlobBlockStatusMessage.test.ets 
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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { log } from '../../Index';
import { BlobBlockStatusMessage } from '../main/ets/core/message/firmwareupdate/blobtransfer/BlobBlockStatusMessage';

export default function BlobBlockStatusMessageTest() {
    describe('BlobBlockStatusMessageTest', () => {
        beforeEach(() => {
            // Setup code if needed
        });

        afterEach(() => {
            // Cleanup code if needed
        });

        it('should parse format 0x00 (all chunks missing) correctly', 0, () => {
            const message = new BlobBlockStatusMessage();
            // Format 0x00, Status 0x00, BlockNumber 0x1234, ChunkSize 0x5678
            const params = new Uint8Array([0x00, 0x34, 0x12, 0x78, 0x56]);

            message.parse(params);

            expect(message.getStatus()).assertEqual(0x00);
            expect(message.getFormat()).assertEqual(BlobBlockStatusMessage.FORMAT_ALL_CHUNKS_MISSING);
            expect(message.getBlockNumber()).assertEqual(0x1234);
            expect(message.getChunkSize()).assertEqual(0x5678);
            expect(message.getMissingChunks().length).assertEqual(0);
            expect(message.getEncodedMissingChunks().length).assertEqual(0);
        });

        it('should parse format 0x01 (no chunks missing) correctly', 0, () => {
            const message = new BlobBlockStatusMessage();
            // Format 0x01, Status 0x00, BlockNumber 0x9ABC, ChunkSize 0xDEF0
            const params = new Uint8Array([0x40, 0xBC, 0x9A, 0xF0, 0xDE]);

            message.parse(params);

            expect(message.getStatus()).assertEqual(0x00);
            expect(message.getFormat()).assertEqual(BlobBlockStatusMessage.FORMAT_NO_CHUNKS_MISSING);
            expect(message.getBlockNumber()).assertEqual(0x9ABC);
            expect(message.getChunkSize()).assertEqual(0xDEF0);
            expect(message.getMissingChunks().length).assertEqual(0);
            expect(message.getEncodedMissingChunks().length).assertEqual(0);
        });

        it('should parse format 0x02 (some chunks missing with bit field) correctly', 0, () => {
            const message = new BlobBlockStatusMessage();
            // Format 0x02, Status 0x0F, BlockNumber 0x1122, ChunkSize 0x3344
            // Bit field 0x05 (binary 00000101) indicates chunks 0 and 2 are missing
            const params = new Uint8Array([0x8F, 0x22, 0x11, 0x44, 0x33, 0x05]);

            message.parse(params);

            expect(message.getStatus()).assertEqual(0x0F);
            expect(message.getFormat()).assertEqual(BlobBlockStatusMessage.FORMAT_SOME_CHUNKS_MISSING);
            expect(message.getBlockNumber()).assertEqual(0x1122);
            expect(message.getChunkSize()).assertEqual(0x3344);
            console.log("getMissingChunks=", message.getMissingChunks()) // getMissingChunks= 0,2
            // expect(message.getMissingChunks()).assertEqual([0, 2]);
            expect(message.getMissingChunks()[0]).assertEqual(0);
            expect(message.getMissingChunks()[1]).assertEqual(2);
            expect(message.getEncodedMissingChunks().length).assertEqual(0);
        });

        it('should parse format 0x03 (encoded missing chunks) correctly', 0, () => {
            const message = new BlobBlockStatusMessage();
            // Format 0x03, Status 0x05, BlockNumber 0x6677, ChunkSize 0x8899
            // Encoded missing chunks: "1,3,5" (UTF-8 bytes: 0x31,0x2C,0x33,0x2C,0x35)
            const params = new Uint8Array([0xC5, 0x77, 0x66, 0x99, 0x88, 0x31, 0x2C, 0x33, 0x2C, 0x35]);

            message.parse(params);

            expect(message.getStatus()).assertEqual(0x05);
            expect(message.getFormat()).assertEqual(BlobBlockStatusMessage.FORMAT_ENCODED_MISSING_CHUNKS);
            expect(message.getBlockNumber()).assertEqual(0x6677);
            expect(message.getChunkSize()).assertEqual(0x8899);
            expect(message.getMissingChunks().length).assertEqual(0);
            console.log("getEncodedMissingChunks=", message.getEncodedMissingChunks()) // getEncodedMissingChunks=
            // expect(message.getEncodedMissingChunks()).assertEqual([49, 44, 51, 44, 53]); // Char codes for "1,3,5"
            expect(message.getEncodedMissingChunks()[0]).assertEqual(49);
            expect(message.getEncodedMissingChunks()[1]).assertEqual(44);
            expect(message.getEncodedMissingChunks()[2]).assertEqual(51);
            expect(message.getEncodedMissingChunks()[3]).assertEqual(44);
            expect(message.getEncodedMissingChunks()[4]).assertEqual(53);

        });
    });
}