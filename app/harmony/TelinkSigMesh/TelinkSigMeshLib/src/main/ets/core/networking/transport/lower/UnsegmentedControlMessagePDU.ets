/********************************************************************************************************
 * @file     UnsegmentedControlMessagePDU.ets 
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
 * @file UnsegmentedControlMessagePDU.ets
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
import { LowerTransportPDU }from "./LowerTransportPDU";

/**
 * Created by kee on 2019/8/16.
 */

/**
 * This class represents an unsegmented control message PDU (Protocol Data Unit)
 * in the lower transport layer.
 * It extends the LowerTransportPDU class.
 */
export class UnsegmentedControlMessagePDU extends LowerTransportPDU {
    /**
     * 1 bit
     */
    readonly seg = 0;
    /**
     * 0x00 = Segment Acknowledgment
     * 0x01 to 0x7F = Opcode of the Transport Control message
     * 7 bits
     */
    readonly opcode: number = 0;
    /**
     * 0 ~ 88 bits
     */
    params?: Uint8Array;

    /**
     * Converts the PDU to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toByteArray(): Uint8Array {
        let header = (this.seg << 7) | (this.opcode);
        if (!this.params) {
            return new Uint8Array([header])
        }
        let buf = new Uint8Array(1 + this.params.length)
        buf[0] = header
        buf.set(this.params, 1)
        return buf
    }

    /**
     * Gets the type of the PDU.
     *
     * @return The type of the PDU.
     */

    public getType(): number {
        return UnsegmentedControlMessagePDU.TYPE_UNSEGMENTED_CONTROL_MESSAGE;
    }

    /**
     * Checks if the PDU is segmented.
     *
     * @return True if the PDU is segmented, false otherwise.
     */
    public segmented(): boolean {
        return false;
    }
}
