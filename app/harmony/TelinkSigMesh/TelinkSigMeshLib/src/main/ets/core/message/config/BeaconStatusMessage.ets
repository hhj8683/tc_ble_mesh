/********************************************************************************************************
 * @file BeaconStatusMessage.ets
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
import { StatusMessage } from "../StatusMessage";

/**
 * The Config Beacon Status is an unacknowledged message used to report the current Secure Network Beacon state of a node
 * <p>
 * response of {@link BeaconGetMessage} {@link BeaconSetMessage}
 * <p>
 * {@link com.telink.ble.mesh.core.message.Opcode#CFG_BEACON_STATUS}
 */
export class BeaconStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "BeaconStatusMessage"

    public statusName(): string {
        return BeaconStatusMessage.STATUS_NAME
    }
    public beacon = 0;

    /**
     * Parses the parameters of the BeaconStatusMessage from a byte array.
     *
     * @param params the byte array containing the parameters of the BeaconStatusMessage
     */
    public parse(params: Uint8Array) {
        this.beacon = params[0];
    }
}
