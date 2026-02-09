/********************************************************************************************************
 * @file     SegmentedAccessMessagePDU.ets 
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
 * @file SegmentedAccessMessagePDU.ets
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
import { NetworkLayerPDU } from '../../NetworkLayerPDU';
import { LowerTransportPDU }from './LowerTransportPDU';


/**
 * The class represents a segmented access message Protocol Data Unit (PDU) used in a mesh network.
 * It contains various attributes and methods to handle and manipulate the PDU.
 */
export class SegmentedAccessMessagePDU extends LowerTransportPDU {


    /**
     * 1 = Segmented MeshCommand
     */
    public   seg = 1;

    /**
     * Application Key Flag
     */
    public  akf = 0;

    /**
     * Application key identifier
     */
    public  aid = 0;

    /**
     * Size of TransMIC
     */
    public  szmic = 0;

    /**
     * Least significant bits of SeqAuth
     */
    public  seqZero = 0;

    /**
     * Segment Offset number
     */
    public  segO = 0;

    /**
     * Last Segment number
     */
    public  segN = 0;

    /**
     * Segment m of the Upper Transport Access PDU
     */
    public segmentM = new Uint8Array(0);

    /**
     * Returns the type of this PDU.
     *
     * @return The type of this PDU (TYPE_SEGMENTED_ACCESS_MESSAGE).
     */
    public  getType() : number {
        return SegmentedAccessMessagePDU.TYPE_SEGMENTED_ACCESS_MESSAGE;
    }

    /**
     * Indicates whether this PDU is segmented.
     *
     * @return True, as this PDU is segmented.
     */
    public  segmented() :boolean{
        return true;
    }

    /**
     * convert to byte array
     *
     * @return byte array
     */
    public  toByteArray(): Uint8Array {
        let headerLength = 4;
        const akfAid = ((this.akf << 6) | this.aid);
        let payloadLength = this.segmentM.length;

        let resultBuffer = new Uint8Array(headerLength + payloadLength)
        // .order(ByteOrder.BIG_ENDIAN);

        let offset = 0
        resultBuffer[offset++] = (this.seg << 7) | akfAid
        resultBuffer[offset++] = (this.szmic << 7) | ((this.seqZero >> 6) & 0x7F)
        resultBuffer[offset++] =((this.seqZero << 2) & 0xFC) | ((this.segO >> 3) & 0x03)
        resultBuffer[offset++] =((this.segO << 5) & 0xE0) | ((this.segN) & 0x1F)
        resultBuffer.set(this.segmentM, offset)
        return resultBuffer
    }

    /**
     * Parses the given NetworkLayerPDU and extracts the information to populate this PDU.
     *
     * @param networkLayerPDU The NetworkLayerPDU to parse.
     * @return True if the parsing was successful, false otherwise.
     */
    public  parse( networkLayerPDU: NetworkLayerPDU) : boolean{
        let lowerTransportPdu = networkLayerPDU.transportPDU
        this.akf = (lowerTransportPdu[0] >> 6) & 0x01
        this.aid = lowerTransportPdu[0] & 0x3F
        this.szmic = (lowerTransportPdu[1] >> 7) & 0x01;
        this.seqZero = ((lowerTransportPdu[1] & 0x7F) << 6) | ((lowerTransportPdu[2] & 0xFC) >> 2);
        this.segO = ((lowerTransportPdu[2] & 0x03) << 3) | ((lowerTransportPdu[3] & 0xE0) >> 5);
        this.segN = ((lowerTransportPdu[3]) & 0x1F);

        this.segmentM = lowerTransportPdu.slice(4)
        return this.segmentM != null && this.segmentM.length >= 1;
    }

}
