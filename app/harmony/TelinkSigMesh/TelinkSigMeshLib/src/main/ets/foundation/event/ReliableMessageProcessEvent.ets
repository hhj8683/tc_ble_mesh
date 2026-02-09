/********************************************************************************************************
 * @file     ReliableMessageProcessEvent.ets 
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
 * @file ReliableMessageProcessEvent.ets
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
import { Event } from "../Event";

/**
 * This class represents an event related to the processing of reliable messages in a mesh network.
 * It extends the Event class and implements the Parcelable interface for serialization purposes.
 */
export class ReliableMessageProcessEvent implements Event {
    public type: string;
    /**
     * mesh message send fail, because of busy or key not found
     * Event type for when a mesh message processing error occurs.
     */
    public static readonly EVENT_TYPE_MSG_PROCESS_ERROR = "com.telink.sig.mesh.EVENT_TYPE_CMD_ERROR";
    /**
     * Event type for when a mesh message is being processed.
     */
    public static readonly EVENT_TYPE_MSG_PROCESSING = "com.telink.sig.mesh.EVENT_TYPE_CMD_PROCESSING";
    /**
     * mesh message send complete, success or retry max
     * Event type for when a mesh message processing is complete, either successfully or after reaching the maximum number of retries.
     */
    public static readonly EVENT_TYPE_MSG_PROCESS_COMPLETE = "com.telink.sig.mesh.EVENT_TYPE_CMD_COMPLETE";
    public success = false;
    // Indicates if the message processing was successful
    public opcode = 0;
    // The opcode of the message
    public dest = 0;
    // The destination address of the message
    public rspMax = 0;
    // The maximum number of responses expected
    public rspCount = 0;
    // The number of responses received
    public rspArr: Uint16Array = new Uint16Array();
    public desc = "";

    // Description of the event


    /**
     * Constructor for creating a ReliableMessageProcessEvent object with additional parameters.
     *
     * @param sender   the object that sends the event
     * @param type     the type of the event
     * @param success  indicates if the message processing was successful
     * @param opcode   the opcode of the message
     * @param rspMax   the maximum number of responses expected
     * @param rspCount the number of responses received
     * @param desc     the description of the event
     */
    public constructor(type: string) {
        this.type = type
    }
}