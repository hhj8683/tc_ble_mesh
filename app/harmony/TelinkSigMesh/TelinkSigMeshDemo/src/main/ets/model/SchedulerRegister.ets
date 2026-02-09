/********************************************************************************************************
 * @file     SchedulerRegister.ets 
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
 * @file SchedulerRegister.ets
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
export class SchedulerRegister {
    public year = 0
    public month = 0
    public day = 0
    public hour = 0
    public minute = 0
    public second = 0
    public week = 0
    public action = 0
    public transTime = 0
    public sceneId = 0

    public constructor() {

    }

    public  static getByParams(year: number,
        month: number,
        day: number,
        hour: number,
        minute: number,
        second: number,
        week: number,
        action: number,
        transTime: number,
        sceneId: number): SchedulerRegister {
        let reg = new SchedulerRegister()
        reg.year = year & 0xFF;
        reg.month = month & 0xFFFF;
        reg.day = day & 0xFF;
        reg.hour = hour & 0xFF;
        reg.minute = minute & 0xFF;
        reg.second = second & 0xFF;
        reg.week = week & 0xFF;
        reg.action = action & 0xFF;
        reg.transTime = transTime & 0xFF;
        reg.sceneId = sceneId & 0xFFFF;
        return reg
    }
}