/********************************************************************************************************
 * @file IconGenerator.java
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
import { logd } from "telinksigmeshlib";
import { NodeInfo } from "../model/NodeInfo";
import { OnlineState } from "../model/OnlineState";

/**
 * Created by kee on 2018/9/29.
 */

export class IconGenerator {
    /**
     * @return resId
     */
    public static getIcon(device?: NodeInfo): Resource {
        if (device == null) {
            return $r('app.media.ic_question')
        }
        return IconGenerator.getIconWithState(device, device.getOnlineState());
    }


    /**
     * @return resId
     */
    public static getIconWithState(device: NodeInfo | undefined, onlineState: OnlineState): Resource {
        if (device == null) {
            return $r('app.media.ic_question')
        }
        // logd("get icon : " + device.onlineState)
        let pid = device?.compositionData?.pid ?? 0;
        if (onlineState == OnlineState.OFFLINE) {
            return $r('app.media.ic_bulb_offline')
        } else if (onlineState == OnlineState.OFF) {
            return $r('app.media.ic_bulb_off')
        } else {
            return $r('app.media.ic_bulb_on')
        }
    }
}
