/********************************************************************************************************
 * @file DistributorCapabilities.ets
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
 * This is an interface called DistributorCapabilities that defines an enumeration called OOBRetrievalSupported.
 */
export enum OOBRetrievalSupported {
    /**
     * OOB retrieval is supported
     */
    SUPPORTED = 1,

    /**
     * OOB retrieval is not supported
     */
    NOT_SUPPORTED = 0
}