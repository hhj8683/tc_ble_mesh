/********************************************************************************************************
 * @file     OnlineStatusEvent.ets 
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
 * @file OnlineStatusEvent.ets
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
import { Event } from '../Event';
import { ArrayList } from '@kit.ArkTS';
import { OnlineStatusInfo } from '../../entity/OnlineStatusInfo';

/**
 * OnlineStatusEvent class represents an event that notifies the online status of a device.
 * It extends the Event class and implements the Parcelable interface.
 */
export class OnlineStatusEvent implements Event   {

    public static readonly  EVENT_TYPE_ONLINE_STATUS_NOTIFY = "com.telink.ble.mesh.EVENT_TYPE_ONLINE_STATUS_NOTIFY"

    public type: string = OnlineStatusEvent.EVENT_TYPE_ONLINE_STATUS_NOTIFY
    private onlineStatusInfoList?: ArrayList<OnlineStatusInfo>

    /**
     * Constructor for creating an OnlineStatusEvent object.
     *
     * @param sender           the object that sends the event
     * @param onlineStatusData the raw data of the online status
     */
    public constructor( onlineStatusData: Uint8Array) {
        this.onlineStatusInfoList = this.parseOnlineStatusData(onlineStatusData);
    }


    /**
     * Parses the raw online status data and returns a list of OnlineStatusInfo objects.
     *
     * @param rawData the raw online status data
     * @return a list of OnlineStatusInfo objects
     */

    private parseOnlineStatusData(rawData: Uint8Array):ArrayList<OnlineStatusInfo> | undefined  {
        if (rawData == null || rawData.length < 4) return undefined
        let len = rawData.length;
        const MIN_NODE_LEN = 3;
        let index = 0;
        let type = rawData[index++];
        if (type != 0x62) {
            return undefined
        }

        // low 4 bit
        let nodeLen = rawData[index++] & 0x0F;

        let statusLen = nodeLen - MIN_NODE_LEN;
        if (statusLen <= 0) return undefined;

        let sno = (rawData[index++] & 0xFF) | ((rawData[index++] & 0xFF) << 8);

        let statusInfoList:ArrayList<OnlineStatusInfo> = new ArrayList();

        let address: number;
        let sn: number;
        let status: Uint8Array;
        let statusInfo: OnlineStatusInfo ;
        while (index + nodeLen <= len) {
            // 15 bit
            address = (rawData[index++] & 0xFF) | ((rawData[index++] & 0x7F) << 8);

            sn = rawData[index++];
            status = rawData.slice(index, index + statusLen)

            index += statusLen;

            if (address == 0x00)
                break;

            statusInfo = new OnlineStatusInfo();
            statusInfo.address = address;
            statusInfo.sn = sn;
            statusInfo.status = status;
            statusInfoList.add(statusInfo);
        }

        return statusInfoList;
    }

}