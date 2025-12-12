/********************************************************************************************************
 * @file SchedulerActionStatusMessage.java
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
 * This class represents a status message for a scheduler action.
 * It extends the StatusMessage class and implements the Parcelable interface.
 * It contains a byte array to store the scheduler parameters.
 *
 * @since 2019-08-20
 */
export class SchedulerActionStatusMessage extends StatusMessage {
    public static readonly STATUS_NAME = "SchedulerActionStatusMessage"

    public statusName(): string {
        return SchedulerActionStatusMessage.STATUS_NAME
    }

    public schedulerParams: Uint8Array = new Uint8Array(0);

    /**
     * Parses the given byte array and sets it as the scheduler parameters.
     *
     * @param params The byte array representing the scheduler parameters.
     */
    public parse(params: Uint8Array) {
        this.schedulerParams = params;
    }
}