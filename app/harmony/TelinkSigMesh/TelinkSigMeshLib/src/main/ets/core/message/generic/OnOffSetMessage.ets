/********************************************************************************************************
 * @file     OnOffSetMessage.ets 
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
 * @file OnOffSetMessage.ets
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
import { Opcode } from "../Opcode";
import { GenericMessage } from "./GenericMessage";


/**
 * include on off set and on off set no ack
 * This class represents an On/Off Set Message, which is a type of Generic Message.
 * It contains methods to set the parameters of the message and generate the message payload.
 * The message payload includes the on/off value, transaction ID, transition time, and delay.
 * It also has methods to determine the response opcode and the opcode of the message.
 * The message can be created with or without acknowledgement, and can be marked as complete.
 */
export class OnOffSetMessage extends GenericMessage {
    public static readonly ON = 1;
    public static readonly OFF = 0;
    // 1: on, 0: off
    public onOff = OnOffSetMessage.ON;
    public tid = 0;
    public transitionTime = 0;
    public delay = 0;
    public ack = false;
    public isComplete = false;

    /**
     * Creates a simple On/Off Set Message with the given parameters.
     *
     * @param address     The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @param onOff       The on/off value of the message.
     * @param ack         The acknowledgement flag of the message.
     * @param rspMax      The maximum response time of the message.
     * @return The created OnOffSetMessage object.
     */
    public static getSimple(address: number, appKeyIndex: number, onOff: number, ack: boolean,
        rspMax: number): OnOffSetMessage {
        let message = new OnOffSetMessage(address, appKeyIndex);
        message.onOff = onOff;
        message.ack = ack;
        message.tidPosition = 1;
        message.responseMax = rspMax;
        return message;
    }

    /**
     * Creates a new On/Off Set Message with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The application key index of the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
    }

    /**
     * Returns the response opcode of the message.
     * If acknowledgement is enabled, it returns the opcode for On/Off Status.
     * Otherwise, it returns the super class's response opcode.
     *
     * @return The response opcode of the message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.G_ONOFF_STATUS : super.getResponseOpcode();
    }

    /**
     * Returns the opcode of the message.
     * If acknowledgement is enabled, it returns the opcode for On/Off Set.
     * Otherwise, it returns the opcode for On/Off Set No Acknowledgement.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.G_ONOFF_SET : Opcode.G_ONOFF_SET_NOACK;
    }

    /**
     * Generates the message payload parameters.
     * If the message is marked as complete, it includes the on/off value, transaction ID, transition time, and delay.
     * Otherwise, it includes only the on/off value and transaction ID.
     *
     * @return The byte array representing the message payload parameters.
     */
    public getParams() {
        return this.isComplete ?
            new Uint8Array([
                this.onOff,
                this.tid,
                this.transitionTime,
                this.delay
            ])
            :
            new Uint8Array([
                this.onOff,
                this.tid
            ])
    }
}