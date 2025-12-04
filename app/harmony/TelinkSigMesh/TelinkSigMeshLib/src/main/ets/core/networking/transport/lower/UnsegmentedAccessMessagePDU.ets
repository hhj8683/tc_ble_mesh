/********************************************************************************************************
 * @file UnsegmentedAccessMessagePDU.java
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
 * Created by kee on 2019/8/9.
 */

/**
 * This class represents an unsegmented access message PDU for lower transport layer.
 * It extends the LowerTransportPDU class.
 * <p>
 * The unsegmented access message PDU consists of the following fields:
 * - seg: 1 bit indicating whether the PDU is segmented or not (0: unsegmented, 1: segmented)
 * - akf: 1 bit indicating the application key flag
 * - aid: 6 bits representing the application key identifier
 * - upperTransportPDU: 40 to 120 bits of upper transport PDU data
 * <p>
 * The class provides methods to access and modify these fields, as well as methods to convert the PDU to a byte array and parse a byte array to populate the PDU fields.
 */
export class UnsegmentedAccessMessagePDU extends LowerTransportPDU {
    // segment
    /**
     * 1 bit
     * 0: unsegmented , means a single PDU
     * 1: segment
     */
    public seg = 0;
    /**
     * 1 bit
     * Application Key Flag
     */
    public akf = 0;
    /**
     * 6 bits
     * Application key identifier
     */
    public aid = 0;
    /**
     * 40 to 120 bits
     */
    public  upperTransportPDU: Uint8Array = new Uint8Array(0);

    /**
     * Constructor with parameters.
     *
     * @param akf               the application key flag
     * @param aid               the application key identifier
     * @param upperTransportPDU the upper transport PDU data
     */
    public constructor() {
        super();
    }
    // public constructor(akf: number, aid: number, upperTransportPDU: Uint8Array) {
    //     super();
    //     this.akf = akf;
    //     this.aid = aid;
    //     this.upperTransportPDU = upperTransportPDU;
    // }

    /**
     * Returns the type of the PDU.
     *
     * @return the type of the PDU
     */
    public getType(): number {
        return UnsegmentedAccessMessagePDU.TYPE_UNSEGMENTED_ACCESS_MESSAGE;
    }

    /**
     * Checks if the PDU is segmented or not.
     *
     * @return true if the PDU is segmented, false otherwise
     */
    public segmented(): boolean {
        return false;
    }

    /**
     * Converts the PDU to a byte array.
     *
     * @return the byte array representation of the PDU
     */
    public toByteArray(): Uint8Array {
        let lowerTransportBuffer = new Uint8Array(1 + this.upperTransportPDU.length)
        lowerTransportBuffer[0] = (this.seg << 7) | (this.akf << 6) | this.aid
        lowerTransportBuffer.set(this.upperTransportPDU, 1);
        return lowerTransportBuffer
    }

    /**
     * Parses a network layer PDU to populate the fields of the unsegmented access message PDU.
     *
     * @param networkLayerPDU the network layer PDU to parse
     * @return true if the parsing is successful, false otherwise
     */
    public parse(networkLayerPDU: NetworkLayerPDU): boolean {
        let lowerTransportData = networkLayerPDU.transportPDU
        let header = lowerTransportData[0]; //Lower transport pdu starts here
        this.akf = ((header >> 6) & 0x01);
        this.aid = (header & 0x3F);
        this.upperTransportPDU = lowerTransportData.slice(1)
        return this.upperTransportPDU.length != 0;
    }
}
