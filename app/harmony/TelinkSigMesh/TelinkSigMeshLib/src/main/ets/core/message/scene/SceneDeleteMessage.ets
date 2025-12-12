/********************************************************************************************************
 * @file SceneStoreMessage.java
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
 * This class represents a message for storing a scene in a scene store.
 * It extends the GenericMessage class.
 * <p>
 * The scene store message contains the following properties:
 * - sceneNumber: The ID of the scene to be stored.
 * - ack: A boolean value indicating whether an acknowledgement is requested for the message.
 * <p>
 * The SceneStoreMessage class provides methods for creating a simple scene store message, setting the scene number and acknowledgement status, and getting the response opcode and parameters.
 * <p>
 * Example usage:
 * SceneStoreMessage message = SceneStoreMessage.getSimple(address, appKeyIndex, sceneNumber, ack, rspMax);
 * message.setSceneNumber(sceneNumber);
 * message.setAck(ack);
 */
export class SceneDeleteMessage extends GenericMessage {
    public sceneNumber = 0
    public ack = false

    /**
     * Creates a simple scene store message with the specified address, application key index, scene number, acknowledgement status, and response maximum.
     *
     * @param address     The destination address of the message.
     * @param appKeyIndex The application key index of the message.
     * @param sceneNumber The ID of the scene to be stored.
     * @param ack         A boolean value indicating whether an acknowledgement is requested for the message.
     * @param rspMax      The maximum number of response messages allowed for the message.
     * @return The created SceneStoreMessage object.
     */
    public static getSimple(address: number, appKeyIndex: number, sceneNumber: number, ack: boolean,
        rspMax: number): SceneDeleteMessage {
        let message = new SceneDeleteMessage(address, appKeyIndex)
        message.sceneNumber = sceneNumber
        message.ack = ack
        message.responseMax = rspMax
        return message;
    }

    /**
     * Returns the response opcode for the message.
     * If an acknowledgement is requested, the opcode is SCENE_REG_STATUS; otherwise, it is the super class's response opcode.
     *
     * @return The response opcode for the message.
     */
    public getResponseOpcode() {
        return this.ack ? Opcode.SCENE_REG_STATUS : super.getResponseOpcode();
    }

    /**
     * Returns the opcode for the message.
     * If an acknowledgement is requested, the opcode is SCENE_STORE; otherwise, it is SCENE_STORE_NOACK.
     *
     * @return The opcode for the message.
     */
    public getOpcode() {
        return this.ack ? Opcode.SCENE_DEL : Opcode.SCENE_DEL_NOACK
    }

    /**
     * Returns the parameters for the message.
     * The parameters consist of the scene number in little-endian format.
     *
     * @return The parameters for the message.
     */
    public getParams(): Uint8Array {
        return num2bytes(this.sceneNumber, 2)
    }
}