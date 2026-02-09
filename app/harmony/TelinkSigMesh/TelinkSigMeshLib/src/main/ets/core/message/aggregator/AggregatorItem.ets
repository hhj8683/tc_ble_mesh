/********************************************************************************************************
 * @file AggregatorItem.ets
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
import { bytesToHexString, num2bytes, num2Hex } from "../../../utils/ArrayUtils";
import { getByFirstByte, OpcodeType } from "../OpcodeType";

/**
 * This class represents an item in an aggregator.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 */
export class AggregatorItem  {
    public static readonly  LENGTH_SHORT = 0x00;

    public static readonly  LENGTH_LONG = 0x01;
    /**
     * bit0: 0: Length_Short field is present 1: Length_Long field is present
     * if opcodeAndParameters's length <= 127, length is 8 bits
     * if opcodeAndParameters's length > 127, length is 16 bits
     */
//    public int length;

    public  opcode = 0;

    public parameters?: Uint8Array;

    /**
     * Default constructor for the AggregatorItem class.
     */
    public constructor(opcode: number,  parameters?: Uint8Array) {
        this.opcode = opcode;
        this.parameters = parameters;
    }


    /**
     * converts the AggregatorItem object to a byte array.
     *
     * @return result
     */
    public  toBytes() : Uint8Array{
        let opcodeLen = getByFirstByte(this.opcode);
        let len = opcodeLen +  (this.parameters?.length ?? 0)
        let isLong = len > 127;
        let bufLen = (isLong ? 2 : 1) + len;
        let buffer = new Uint8Array(bufLen)

        let offset = 0
        len <<= 1 | (isLong ? 1 : 0);
        if (isLong) {
            buffer.set(num2bytes(len, 2), offset);
            offset += 2
        } else {
            buffer[offset++] = len
        }
        buffer.set(num2bytes(this.opcode, opcodeLen), offset);
        offset += opcodeLen
        if (this.parameters) {
            buffer.set(this.parameters, offset);
        }
        return buffer
    }

    /**
     * converts a byte array to an AggregatorItem object.
     *
     * @param data byte array
     * @return result
     */
    public static  fromBytes(data:Uint8Array):AggregatorItem {
        let opType = getByFirstByte(data[0]);

        let opcode = 0;
        let index = 0;
        for (let i = 0; i < opType; i++) {
            opcode |= (data[index++] & 0xFF) << (8 * i);
        }

        let paramLen = data.length - opType;
        let params = data.slice(index, paramLen)

        let item = new AggregatorItem(opcode, params);
        // item.opcode = opcode;
        // item.parameters = params;
        return item;
    }

    /**
     * string representation of this object.
     *
     * @return a string representation of the AggregatorItem object.
     */
    public  toString(): string {
        return `opcode=${num2Hex(this.opcode, 4)} params=${bytesToHexString(this.parameters)}`
    }
}
