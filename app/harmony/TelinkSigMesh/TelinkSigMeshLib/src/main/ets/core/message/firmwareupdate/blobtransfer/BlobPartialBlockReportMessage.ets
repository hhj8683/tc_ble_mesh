/********************************************************************************************************
 * @file     BlobPartialBlockReportMessage.ets 
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
 * @file BlobPartialBlockReportMessage.ets
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

import { StatusMessage } from "../../../message/StatusMessage";
import { util } from "@kit.ArkTS";

/**
 * This class represents a message for reporting partial blocks of a blob.
 * It extends the StatusMessage class.
 * The message contains a list of chunks that are requested by the server.
 * The chunks are encoded using UTF-8 encoding.
 */
export class BlobPartialBlockReportMessage extends StatusMessage {
    public static readonly STATUS_NAME = "BlobPartialBlockReportMessage"

    public statusName(): string {
        return BlobPartialBlockReportMessage.STATUS_NAME
    }

    private encodedMissingChunks: Array<number> = [];

    /**
    * Default constructor for BlobPartialBlockReportMessage.
    */
    constructor() {
        super();
    }

    /**
    * Parses the byte array parameter to populate the encoded missing chunks list.
    *
    * @param params The byte array containing the encoded missing chunks.
    */
    public parse(params: Uint8Array): void {
        this.encodedMissingChunks = [];
        // Convert bytes to string and then to numeric values
        const decoder = new util.TextDecoder('utf-8');
        const decodedString = decoder.decode(params);
        for (const char of decodedString) {
            this.encodedMissingChunks.push(char.charCodeAt(0) & 0xFFFF);
        }
    }

    /**
    * Returns the encoded missing chunks list.
    *
    * @return The encoded missing chunks list.
    */
    public getEncodedMissingChunks(): Array<number> {
        return this.encodedMissingChunks;
    }
}