/********************************************************************************************************
 * @file TimeSetMessage.java
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
import { ByteOrder, num2bytes } from "../../../../../../Index";
import { GenericMessage } from "../generic/GenericMessage";
import { Opcode } from "../Opcode";

/**
 * time set
 * Created by kee on 2019/8/14.
 */
export class TimeSetMessage extends GenericMessage {
    /**
     * TAI seconds
     * 40 bits
     * The current TAI time in seconds
     */
    public taiSeconds = 0
    /**
     * 8 bits
     * The sub-second time in units of 1/256th second
     */
    public subSecond = 0
    /**
     * 8 bits
     * The estimated uncertainty in 10 millisecond steps
     */
    public uncertainty = 0
    /**
     * 1 bit
     * 0 = No Time Authority, 1 = Time Authority
     */
    public timeAuthority = 0
    /**
     * TAI-UTC Delta
     * 15 bits
     * Current difference between TAI and UTC in seconds
     */
    public delta = 0
    /**
     * Time Zone Offset
     * 8 bits
     * The local time zone offset in 15-minute increments
     */
    public zoneOffset = 0
    /**
     * no-ack for time-status message
     */
    public ack = false;

    /**
     * Creates a new TimeSetMessage object with the given destination address and application key index.
     *
     * @param address     The destination address for the message.
     * @param appKeyIndex The application key index for the message.
     */
    public static getSimple(address: number, appKeyIndex: number, taiSeconds: number, zoneOffset: number,
        rspMax: number): TimeSetMessage {
        let message = new TimeSetMessage(address, appKeyIndex)
        message.taiSeconds = taiSeconds
        message.zoneOffset = zoneOffset
        message.responseMax = rspMax
        return message;
    }

    /**
     * Creates a new TimeSetMessage object with the given destination address and application key index.
     *
     * @param destinationAddress The destination address for the message.
     * @param appKeyIndex        The application key index for the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the response opcode for the message.
     * If the ack flag is true, it returns the opcode for the time-status message.
     * Otherwise, it returns an invalid opcode.
     *
     * @return The response opcode.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.TIME_STATUS : TimeSetMessage.OPCODE_INVALID;
    }

    /**
     * Returns the opcode for the message.
     * If the ack flag is true, it returns the opcode for the time-set message.
     * Otherwise, it returns the opcode for the time-status message.
     *
     * @return The opcode.
     */
    public getOpcode() {
        return this.ack ? Opcode.TIME_SET : Opcode.TIME_STATUS
    }

    /**
     * Returns the parameters of the message as a byte array.
     * The parameters include the TAI seconds, sub-second time, uncertainty, time authority, delta, and zone offset.
     *
     * @return The parameters as a byte array.
     */
    public getParams() {
        let buf = new Uint8Array(10)
        let offset = 0
        buf.set(num2bytes(this.taiSeconds, 5, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 5
        buf[offset++] = this.subSecond
        buf[offset++] = this.uncertainty
        buf.set(num2bytes((this.delta << 1) | this.timeAuthority, 2, ByteOrder.LITTLE_ENDIAN), offset)
        offset += 2
        buf[offset] = this.zoneOffset
        return buf
    }
}

