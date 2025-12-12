/********************************************************************************************************
 * @file SceneRecallMessage.java
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
import { num2bytes } from "../../../../../../Index";
import { GenericMessage } from "../generic/GenericMessage";
import { Opcode } from "../Opcode";

/**
 * SceneRecallMessage is a class that represents a scene recall message in a smart home system.
 * It extends the GenericMessage class and is used to recall a specific scene based on the scene number.
 * This message can be sent with or without acknowledgment.
 * Acknowledgment is used to ensure that the message has been received and processed successfully.
 * The scene number, transition ID, transition time, and delay can be set for the message.
 * The isComplete flag indicates whether the message is complete or not.
 * This class provides methods to get and set the scene number, transition ID, transition time, delay, acknowledgment, and completeness of the message.
 * It also provides methods to get the response opcode and the opcode of the message.
 * The getParams method returns the parameters of the message as a byte array.
 * The SceneRecallMessage class also provides a static method to create a simple scene recall message with the given parameters.
 */
export class SceneRecallMessage extends GenericMessage {
    public sceneNumber = 0
    public tid = 0;
    public transitionTime = 0;
    public delay = 0;
    public ack = false;
    public isComplete = false;

    /**
     * Creates a simple scene recall message with the given address, application key index, scene number, acknowledgment flag, and maximum response time.
     *
     * @param address     The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @param sceneNumber The scene number to be recalled.
     * @param ack         The acknowledgment flag indicating whether the message requires acknowledgment or not.
     * @param rspMax      The maximum response time for the message.
     * @return The created SceneRecallMessage object.
     */
    public static getSimple(address: number, appKeyIndex: number, sceneNumber: number, ack: boolean,
        rspMax: number): SceneRecallMessage {
        let message = new SceneRecallMessage(address, appKeyIndex);
        message.sceneNumber = sceneNumber
        message.ack = ack
        message.responseMax = rspMax
        return message;
    }

    /**
     * Constructs a SceneRecallMessage object with the given destination address and application key index.
     *
     * @param destinationAddress The destination address of the message.
     * @param appKeyIndex        The application key index of the message.
     */
    public constructor(destinationAddress: number, appKeyIndex: number) {
        super(destinationAddress, appKeyIndex);
        this.tidPosition = 2
    }

    /**
     * Returns the response opcode of the message.
     * If the acknowledgment flag is true, the response opcode is SCENE_STATUS.
     * Otherwise, it is the super class's response opcode.
     *
     * @return The response opcode of the message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.SCENE_STATUS : super.getResponseOpcode();
    }

    /**
     * Returns the opcode of the message.
     * If the acknowledgment flag is true, the opcode is SCENE_RECALL.
     * Otherwise, it is SCENE_RECALL_NOACK.
     *
     * @return The opcode of the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.SCENE_RECALL : Opcode.SCENE_RECALL_NOACK
    }

    /**
     * Returns the parameters of the message as a byte array.
     * If the message is complete, the byte array includes the scene number, tid, transition time, and delay.
     * Otherwise, it only includes the scene number and tid.
     *
     * @return The parameters of the message as a byte array.
     */
    public getParams() {
        let buf = new Uint8Array(this.isComplete ? 5 : 3)
        let offset = 0
        buf.set(num2bytes(this.sceneNumber, 2), offset)
        offset += 2
        buf[offset++] = this.tid
        if (this.isComplete) {
            buf[offset++] = this.transitionTime
            buf[offset++] = this.delay
        }
        return buf
    }
}