/********************************************************************************************************
 * @file     TimeStatusMessage.ets 
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
 * @file TimeStatusMessage.ets
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
import { ByteOrder, bytes2Long } from '../../../../../../Index';
import { StatusMessage } from '../StatusMessage';

/**
 * This class represents a Time Status Message, which is a type of Status Message that contains information about the current time.
 * It extends the StatusMessage class and implements the Parcelable interface for easy serialization and deserialization.
 * The Time Status Message includes fields for the current TAI time in seconds, sub-second time, uncertainty, time authority,
 * TAI-UTC delta, and time zone offset. These fields are optional and may be omitted if the TAI Seconds field is set to 0.
 * The class provides methods for parsing the message from a byte array, as well as getters and setters for accessing and modifying
 * the message fields.
 */

const DATA_LEN_COMPLETE = 10;
export class TimeStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "TimeStatusMessage"

    public statusName(): string {
        return TimeStatusMessage.STATUS_NAME
    }

    /**
     * TAI seconds
     * 40 bits
     * The current TAI time in seconds
     * <p>
     * If the TAI Seconds field is 0x0000000000
     * the Subsecond, Uncertainty, Time Authority, TAI-UTC Delta and Time Zone Offset fields shall be omitted;
     * otherwise these fields shall be present.
     */
    private taiSeconds = 0;

    /**
     * 8 bits
     * The sub-second time in units of 1/256th second
     */
    private  subSecond = 0;

    /**
     * 8 bits
     * The estimated uncertainty in 10 millisecond steps
     */
    private uncertainty = 0;

    /**
     * 1 bit
     * 0 = No Time Authority, 1 = Time Authority
     */
    private  timeAuthority = 0;

    /**
     * TAI-UTC Delta
     * 15 bits
     * Current difference between TAI and UTC in seconds
     */
    private delta = 0;

    /**
     * Time Zone Offset
     * 8 bits
     * The local time zone offset in 15-minute increments
     */
    private  zoneOffset = 0;

    /**
     * tag of is complete message
     */
    private isComplete = false;


    /**
     * Parses the TimeStatusMessage fields from a byte array.
     *
     * @param params The byte array containing the TimeStatusMessage fields.
     */
    public  parse( params: Uint8Array) {
        let index = 0;
        this.taiSeconds = bytes2Long(params, index, 5, ByteOrder.LITTLE_ENDIAN);
        index += 5;
        // tai
        if (params.length >= DATA_LEN_COMPLETE) {
            this.isComplete = true;
            this.subSecond = params[index++];
            this.uncertainty = params[index++];
            this.timeAuthority = (params[index] & 0b01);
            this.delta = (params[index++] & 0xEF) | ((params[index++] & 0xFF) << 8);
            this.zoneOffset = params[index] & 0xFF;
        }
    }
}