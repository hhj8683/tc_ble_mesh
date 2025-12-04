/********************************************************************************************************
 * @file SegmentAcknowledgmentMessage.java
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

import { ByteOrder, bytes2Integer, num2bytes } from "../../../../utils/ArrayUtils";
import { buffer } from "@kit.ArkTS";
import { UnsegmentedControlMessagePDU } from "./UnsegmentedControlMessagePDU";

/**
 * This class represents a Segment Acknowledgment Message, which is a type of Unsegmented Control Message PDU.
 * It contains the necessary fields and methods to parse and generate the byte array representation of the message.
 */
const DATA_LEN = 7;
export class SegmentAcknowledgmentMessage extends UnsegmentedControlMessagePDU {


    /**
     * 1 bit
     */
    readonly  seg = 0;

    /**
     * 7 bits
     */
     opcode = 0x00;

    /**
     * The OBO field shall be set to 0 by a node that is directly addressed by the received message
     * and shall be set to 1 by a Friend node that is acknowledging this message on behalf of a Low Power node.
     * <p>
     * As provisioner, obo is always 0
     * 1 bit
     */
    private  obo = 0;

    /**
     * SeqZero of the Upper Transport PDU
     */
    public   seqZero= 0

    private  rfu = 0;

    /**
     * Block acknowledgment for segments
     * 32 bits
     * If bit n is set to 0, then segment n is not being acknowledged.
     * Any bits for segments larger than SegN shall be set to 0 and ignored upon receipt.
     */
    public blockAck = 0;

    /**
     * Parses the byte array representation of the message and populates the fields accordingly.
     * Returns true if the parsing is successful, false otherwise.
     *
     * @param lowerTransportData The byte array representation of the message
     * @return True if parsing is successful, false otherwise
     */
    public  parse(lowerTransportData: Uint8Array) :boolean{
        if (lowerTransportData.length != DATA_LEN) return false;
//        int seqZero = ((lowerTransportData[1] & 0x7F) << 6) | ((lowerTransportData[2] & 0xFF) >> 2);
        let seqZero = bytes2Integer(lowerTransportData, 1, 2, ByteOrder.BIG_ENDIAN)
        seqZero = (seqZero & 0x7FFF) >> 2;
        this.seqZero = seqZero;
        this.blockAck = bytes2Integer(lowerTransportData, 3, 4, ByteOrder.BIG_ENDIAN);
        return true;
    }


    /**
     * Constructor for SegmentAcknowledgmentMessage.
     *
     * @param seqZero  The SeqZero of the Upper Transport PDU
     * @param blockAck The block acknowledgment for segments
     */
    public constructor( ) {
        super();

    }

    /**
     * Converts the message to its byte array representation.
     *
     * @return The byte array representation of the message
     */
    public toByteArray():Uint8Array {
        let buf = new Uint8Array(DATA_LEN)
        let offset = 0
        buf[offset++] = (this.seg << 7) | this.opcode
        buf[offset++] = (this.obo << 7) | ((this.seqZero >> 6) & 0x7F)
        buf[offset++] =((this.seqZero << 2) & 0xFC) | this.rfu
        buf.set(num2bytes(this.blockAck, 4, ByteOrder.BIG_ENDIAN), offset)
       return buf
    }


    /**
     * Returns the SeqZero of the Upper Transport PDU.
     *
     * @return The SeqZero value
     */
    public  getSeqZero() : number{
        return this.seqZero;
    }

    /**
     * Returns the block acknowledgment for segments.
     *
     * @return The block acknowledgment value
     */
    public getBlockAck(): number {
        return this.blockAck;
    }
}
