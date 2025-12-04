/********************************************************************************************************
 * @file StatusMessage.java
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
import { ClassFilter } from "@ohos/hypium/src/main/module/config/Filter";

/**
 * status notification by acknowledged message
 * This is an abstract class for status notification messages.
 * Created by kee on 2019/8/20.
 */
export abstract class StatusMessage {
    public abstract statusName(): string

    /**
     * parse status message with access layer pdu params
     * This method should be implemented by subclasses to parse the status message using the provided access layer PDU params.
     * {@link AccessLayerPDU#params}
     *
     * @param params The parameters used to parse the status message.
     */
    public abstract parse(params: Uint8Array);
}