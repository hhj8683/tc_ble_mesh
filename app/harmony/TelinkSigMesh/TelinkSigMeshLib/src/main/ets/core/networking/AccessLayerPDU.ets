/********************************************************************************************************
 * @file AccessLayerPDU.ets
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
import { ByteOrder, bytesToHexString, num2bytes } from '../../utils/ArrayUtils';
import { logw } from '../../utils/MeshLogger';
import { getByFirstByte } from '../message/OpcodeType';
import { NetworkingPDU } from './NetworkingPDU';

/**
 * This class represents a PDU (Protocol Data Unit) for the Access Layer in a networking protocol.
 * An access payload may be sent in up to 32 segments of 12 octets each.
 * This implies that the maximum number of octets is 384 including the TransMIC
 * <p>
 * 12 * 32
 * packet-len * packet-cnt
 * <p>
 * transMIC 4 bytes
 * at least 1 byte opcode
 */
export class AccessLayerPDU implements NetworkingPDU {
    // 1, 2 or 3 bytes
    public opcode = 0
    // 0 ~ 379 bytes
    public params? = new Uint8Array(0)

    /**
     * Constructs an AccessLayerPDU object with the given opcode and params.
     *
     * @param opcode The opcode value of the PDU.
     * @param params The parameters of the PDU.
     */
    public constructor(opcode: number, params?: Uint8Array) {
        this.opcode = opcode;
        this.params = params;
    }

    /**
     * Parses the given payload byte array and returns an AccessLayerPDU object.
     *
     * @param payload The payload byte array to be parsed.
     * @return An AccessLayerPDU object representing the parsed payload.
     */
    public static parse(payload: Uint8Array): AccessLayerPDU {
        // logw(`access layer # parse : ${bytesToHexString(payload)}`)
        let opType = getByFirstByte(payload[0]);
        let opcode = 0;
        let index = 0;
        for (let i = 0; i < opType; i++) {
            opcode |= (payload[index++] & 0xFF) << (8 * i);
        }
        let params = payload.slice(index)
        return new AccessLayerPDU(opcode, params);
    }


    /**
     * Converts the AccessLayerPDU object to a byte array.
     *
     * @return A byte array representing the AccessLayerPDU object.
     */
    public toByteArray(): Uint8Array {
        let opcodeLen = getByFirstByte(this.opcode)
        if (this.params == undefined || this.params.length == 0) {
            return num2bytes(this.opcode, opcodeLen, ByteOrder.LITTLE_ENDIAN);
        } else {
            let buf = new Uint8Array(opcodeLen + this.params.length)
            buf.set(num2bytes(this.opcode, opcodeLen, ByteOrder.LITTLE_ENDIAN), 0)
            buf.set(this.params, opcodeLen)
            return buf
        }
    }
}
