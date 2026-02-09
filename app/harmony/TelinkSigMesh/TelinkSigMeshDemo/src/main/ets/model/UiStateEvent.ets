/********************************************************************************************************
 * @file UiStateEvent.ets
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
import { Event } from "telinksigmeshlib";
import { NodeInfo } from "./NodeInfo";

/**
 * Created by kee on 2019/9/18.
 */

export class UiStateEvent implements Event {
    public static readonly EVENT_TYPE_NODE_LIST_CHANGED = "com.telink.ble.mesh.EVENT_TYPE_NODE_LIST_CHANGED";
    public type: string = UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED;

    public constructor(type: string) {
        this.type = type;
    }
}
