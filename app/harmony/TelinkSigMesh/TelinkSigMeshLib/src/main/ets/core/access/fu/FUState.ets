/********************************************************************************************************
 * @file     FUState.ets 
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
 * @file FUState.ets
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
 * firmware-update state
 */
export enum FUState {
  /**
   * initiating distributor ...
   */
  IDLE = 0x0100,
  
  /**
   * initiating distributor ...
   */
  INITIATING = 0,
  
  /**
   * initiate distributor success
   */
  INITIATE_SUCCESS = 1,
  
  /**
   * initiate distributor fail
   */
  INITIATE_FAIL = 2,
  
  /**
   * distributing by phone...
   */
  DISTRIBUTING_BY_PHONE = 3,
  
  /**
   * distributing by device...
   */
  DISTRIBUTING_BY_DEVICE = 4,
  
  /**
   * firmware update applying
   */
  UPDATE_APPLYING = 7,
  
  /**
   * getting distribute status util complete
   */
  DISTRIBUTE_CONFIRMING = 8,
  
  /**
   * firmware update rechecking...
   */
  UPDATE_RECHECKING = 9,
  
  /**
   * update complete
   */
  UPDATE_COMPLETE = 10,
  
  /**
   * update fail
   */
  UPDATE_FAIL = 11,
  
  /**
   * blob transferring...
   */
  TRANSFER_START = 12
}

/**
 * Get the description of a firmware update state
 * @param state - The FUState enum value
 * @returns The description string
 */
export function getDescriptionByCodeOfFUState(state: FUState): string {
  switch (state) {
    case FUState.IDLE:
      return "initiating distributor ...";
    case FUState.INITIATING:
      return "initiating distributor ...";
    case FUState.INITIATE_SUCCESS:
      return "initiate distributor success";
    case FUState.INITIATE_FAIL:
      return "initiate distributor fail";
    case FUState.DISTRIBUTING_BY_PHONE:
      return "distributing by phone...";
    case FUState.DISTRIBUTING_BY_DEVICE:
      return "distributing by device...";
    case FUState.UPDATE_APPLYING:
      return "firmware update applying";
    case FUState.DISTRIBUTE_CONFIRMING:
      return "getting distribute status util complete";
    case FUState.UPDATE_RECHECKING:
      return "firmware update rechecking...";
    case FUState.UPDATE_COMPLETE:
      return "update complete";
    case FUState.UPDATE_FAIL:
      return "update fail";
    case FUState.TRANSFER_START:
      return "blob transferring...";
    default:
      return "Unknown firmware update state";
  }
}