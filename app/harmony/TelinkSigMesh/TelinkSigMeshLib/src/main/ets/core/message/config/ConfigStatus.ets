/********************************************************************************************************
 * @file     ConfigStatus.ets 
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
 * @file ConfigStatus.ets
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
 * This enum defines status codes for messages that contain a Status parameter.
 * Status messages are sent only in response to properly formatted messages
 */
export enum ConfigStatus {

    SUCCESS = 0x00, //Success

    // error codes

    INVALID_ADDRESS = 0x01, //Invalid Address

    INVALID_MODEL = 0x02, //Invalid Model

    INVALID_APPKEY_INDEX = 0x03, //Invalid AppKey Index

    INVALID_NETKEY_INDEX = 0x04, //Invalid NetKey Index

    INSUFFICIENT_RESOURCES = 0x05, //Insufficient Resources

    KEY_INDEX_ALREADY_STORED = 0x06, //Key Index Already Stored

    INVALID_PUBLISH_PARAMETERS = 0x07, //Invalid Publish Parameters

    NOT_A_SUBSCRIBE_MODEL = 0x08, //Not a Subscribe Model

    STORAGE_FAILURE = 0x09, //Storage Failure

    FEATURE_NOT_SUPPORTED = 0x0A, //Feature Not Supported

    CANNOT_UPDATE = 0x0B, //Cannot Update

    CANNOT_REMOVE = 0x0C, //Cannot Remove

    CANNOT_BIND = 0x0D, //Cannot Bind

    TEMPORARILY_UNABLE_TO_CHANGE_STATE = 0x0E, //Temporarily Unable to Change State

    CANNOT_SET = 0x0F, //Cannot Set

    UNSPECIFIED_ERROR = 0x10, //Unspecified Error

    INVALID_BINDING = 0x11, //Invalid Binding

    UNKNOWN_ERROR = 0xFF, //unknown error

}
