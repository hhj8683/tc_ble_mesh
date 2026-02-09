/********************************************************************************************************
 * @file     MeshLogger.ets 
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
 * @file MeshLogger.ets
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
import { LogInfo } from "./LogInfo";

/**
 * @see Log#v(String, String)
 */
export const LOG_LEVEL_VERBOSE = 0;

/**
 * @see Log#d(String, String)
 */
export const LOG_LEVEL_DEBUG = 1;

/**
 * @see Log#i(String, String)
 */
export const LOG_LEVEL_INFO = 2;

/**
 * @see Log#w(String, String)
 */
export const LOG_LEVEL_WARN = 3;

/**
 * @see Log#e(String, String)
 */
export const LOG_LEVEL_ERROR = 4;

/**
 * used to cache log info list
 */
export let logInfoList = new Array<LogInfo>();

/**
 * default log tag
 */
export const LOG_DEFAULT_TAG = "SIG-Mesh";

/**
 * default level: debug
 */
export const LOG_DEFAULT_LEVEL = LOG_LEVEL_DEBUG;

//    public static Logger logger = Logger.getLogger(GLOBAL_TAG);

/**
 * Used to set whether to output
 */
let print_log_enable = true;

/**
 * Used to set whether to cache
 */
let record_log_enable = true;


/**
 * @param enable new value
 */
export function enableRecord(enable: boolean) {
    record_log_enable = enable;
}

/**
 * @param enable new value
 */
export function enablePrint(enable: boolean) {
    print_log_enable = enable;
}

export function logv(logMessage: string, tag: string = LOG_DEFAULT_TAG){
    log(logMessage, tag, LOG_LEVEL_VERBOSE)
}

export function logi(logMessage: string, tag: string = LOG_DEFAULT_TAG){
    log(logMessage, tag, LOG_LEVEL_INFO)
}

export function logd(logMessage: string, tag: string = LOG_DEFAULT_TAG){
    log(logMessage, tag, LOG_LEVEL_DEBUG)
}

export function logw(logMessage: string, tag: string = LOG_DEFAULT_TAG){
    log(logMessage, tag, LOG_LEVEL_WARN)
}

export function loge(logMessage: string, tag: string = LOG_DEFAULT_TAG){
    log(logMessage, tag, LOG_LEVEL_ERROR)
}

export function log(logMessage: string, tag: string = LOG_DEFAULT_TAG, level: number = LOG_LEVEL_DEBUG) {
    if (print_log_enable) {
        switch (level) {
            case LOG_LEVEL_VERBOSE:
                console.log(tag, logMessage)
                break;
            case LOG_LEVEL_INFO:
                console.info(tag, logMessage)
                break;

            case LOG_LEVEL_WARN:
                console.warn(tag, logMessage)
                break;

            case LOG_LEVEL_ERROR:
                console.error(tag, logMessage)
                break;

            case LOG_LEVEL_DEBUG:
            default:
                console.debug(tag, logMessage)
        }
    }

    if (record_log_enable) {
        logInfoList.push(new LogInfo(tag, level, logMessage));
    }
}

