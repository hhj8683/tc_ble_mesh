/********************************************************************************************************
 * @file NotificationMessage.ets
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
import { MeshStatus } from "./MeshStatus";
import { StatusMessage } from "./StatusMessage";

/**
 * The NotificationMessage class is used to notify changes in the mesh status.
 * <p>
 * It contains information such as the source, destination, opcode, and raw parameters data.
 * The statusMessage field stores the parsed message based on the opcode and parameters.
 * If the opcode is registered in the MeshStatus.Container class, the statusMessage will be populated.
 * Otherwise, it will be null.
 * <p>
 * This class implements the Parcelable interface to allow for easy serialization and deserialization.
 * <p>
 * Created by kee on 2019/9/3.
 */
export class NotificationMessage {
    public src = 0;
    public dst = 0;
    public opcode = 0;
    // params raw data
    public params?: Uint8Array
    /**
     * parsed message by params, if opcode is registered in {@link MeshStatus}
     * otherwise statusMessage will be null
     */
    public statusMessage?: StatusMessage;

    /**
     * Constructs a new NotificationMessage with the specified source, destination, opcode, and parameters.
     *
     * @param src    the source of the message
     * @param dst    the destination of the message
     * @param opcode the opcode of the message
     * @param params the raw parameters data of the message
     */
    public constructor(src: number, dst: number, opcode: number, params?: Uint8Array) {
        this.src = src;
        this.dst = dst;
        this.opcode = opcode;
        this.params = params;
        this.parseStatusMessage();
    }

    private parseStatusMessage() {
        this.statusMessage =
            MeshStatus.getStatusMessage(this.opcode, this.params) // StatusMessage.createByAccessMessage(opcode, params);
    }
}
