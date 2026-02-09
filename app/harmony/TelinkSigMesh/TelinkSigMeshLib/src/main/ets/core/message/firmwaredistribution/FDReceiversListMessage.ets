/********************************************************************************************************
 * @file     FDReceiversListMessage.ets 
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
 * @file FDReceiversListMessage.ets
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

import { StatusMessage } from '../../message/StatusMessage';
import { ByteOrder, bytes2Integer } from '../../../utils/ArrayUtils';

/**
 * response to a Firmware Distribution Receivers Get message
 *
 * @see FDReceiversGetMessage
 */
export class FDReceiversListMessage extends StatusMessage {
    public static readonly STATUS_NAME = "FDReceiversListMessage"

    public statusName(): string {
        return FDReceiversListMessage.STATUS_NAME
    }

    /**
     * Receivers List Count
     * The number of entries in the Distribution Receivers List state
     * 2 bytes
     */
    private receiversListCount: number = 0;

    /**
     * First Index
     * 2 bytes
     */
    private firstIndex: number = 0;

    /**
     * List of entries
     * Optional
     */
    private receiversList: Array<DistributionReceiver> = [];

    constructor() {
        super();
    }

    /**
     * Parses the byte array to extract the params.
     *
     * @param params The byte array containing the params.
     */
    public parse(params: Uint8Array): void {
        let index = 0;
        this.receiversListCount = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;
        this.firstIndex = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
        index += 2;

        this.receiversList = [];
        while (params.length - index >= 5) {
            const receiver = new DistributionReceiver();
            const misc = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
            receiver.address = misc & 0x7FFF;
            receiver.retrievedUpdatePhase = (misc >> 15) & 0x0F;
            receiver.updateStatus = (misc >> 19) & 0x07;
            receiver.transferStatus = (misc >> 22) & 0x0F;
            receiver.transferProgress = (misc >> 26) & 0x3F;
            index += 4;
            receiver.imageIndex = params[index++];
            this.receiversList.push(receiver);
        }
    }

    /**
     * Returns receivers list count.
     *
     * @return The receivers list count.
     */
    public getReceiversListCount(): number {
        return this.receiversListCount;
    }

    /**
     * Returns firstIndex.
     *
     * @return The firstIndex.
     */
    public getFirstIndex(): number {
        return this.firstIndex;
    }

    /**
     * Returns receiversList.
     *
     * @return The receiversList.
     */
    public getReceiversList(): Array<DistributionReceiver> {
        return this.receiversList;
    }
}

/**
 * DistributionReceiver class represents a receiver in the firmware distribution process.
 */
export class DistributionReceiver {
    /**
     * Address
     * 15 least significant bits of the unicast address of the Updating node
     * 15 bits
     */
    public address: number = 0;

    /**
     * Retrieved Update Phase
     * Retrieved Update Phase state of the Updating node
     * 4 bits
     *
     * @see UpdatePhase
     */
    public retrievedUpdatePhase: number = 0;

    /**
     * Update Status
     * Status of the last operation with the Firmware Update Server
     * 3 bits
     */
    public updateStatus: number = 0;

    /**
     * Transfer Status
     * Status of the last operation with the BLOB Transfer Server
     * 4 bits
     */
    public transferStatus: number = 0;

    /**
     * Transfer Progress
     * Progress of the BLOB transfer in 2 percent increments
     * 6 bits
     */
    public transferProgress: number = 0;

    /**
     * Update Firmware Image Index
     * Index of the firmware image on the Firmware Information List state that is being updated.
     * 8 bits
     */
    public imageIndex: number = 0;

    /**
     * Returns a string representation of the DistributionReceiver object.
     *
     * @return A string representation of the DistributionReceiver object.
     */
    public toString(): string {
        return `DistributionReceiver{address=${this.address}, retrievedUpdatePhase=${this.retrievedUpdatePhase}, updateStatus=${this.updateStatus}, transferStatus=${this.transferStatus}, transferProgress=${this.transferProgress}, imageIndex=${this.imageIndex}}`;
    }
}