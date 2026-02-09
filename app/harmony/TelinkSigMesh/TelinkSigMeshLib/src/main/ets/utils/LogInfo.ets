/********************************************************************************************************
 * @file LogInfo.ets
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

/**
 * Log Info
 * Created by kee on 2019/1/11.
 */
export  class  LogInfo  {
    /**
     * log tag
     */
    public tag = "";

    /**
     * current time
     */
    public millis = 0;

    /**
     * log level
     *
     * @see MeshLogger#LEVEL_VERBOSE
     * @see MeshLogger#LEVEL_DEBUG
     * @see MeshLogger#LEVEL_INFO
     * @see MeshLogger#LEVEL_WARN
     * @see MeshLogger#LEVEL_ERROR
     */
    public  level: number ;

    /**
     * message
     */
    public logMessage= "";

    constructor(tag: string, level: number, logMessage: string) {
        this.tag = tag;
        this.millis = new Date().getTime();
        this.level = level;
        this.logMessage = logMessage;
    }




}
