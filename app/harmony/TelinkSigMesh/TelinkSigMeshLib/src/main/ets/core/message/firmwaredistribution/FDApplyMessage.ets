/********************************************************************************************************
 * @file     FDApplyMessage.ets 
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
 * @file FDApplyMessage.ets
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

import { UpdatingMessage } from '../firmwareupdate/UpdatingMessage';
import { Opcode } from "../Opcode";

/**
 * The Firmware Distribution Apply message is an acknowledged message
 * sent from a Firmware Distribution Client to a Firmware Distribution Server to apply the firmware image on the Updating nodes.
 * The response to a Firmware Distribution Apply message is a Firmware Distribution Status message.
 */
export class FDApplyMessage extends UpdatingMessage {
  /**
   * Constructs a FDApplyMessage object with the given destination address and app key index.
   * @param destinationAddress The address of the destination device.
   * @param appKeyIndex The app key index to be used for the firmware update.
   */
  constructor(destinationAddress: number, appKeyIndex: number) {
    super(destinationAddress, appKeyIndex);
  }

  /**
   * Creates a simple FDApplyMessage object with the given destination address and app key index.
   * Sets the maximum number of responses to 1.
   * @param destinationAddress The address of the destination device.
   * @param appKeyIndex The app key index to be used for the firmware update.
   * @returns The created FDApplyMessage object.
   */
  public static getSimple(destinationAddress: number, appKeyIndex: number): FDApplyMessage {
    const message = new FDApplyMessage(destinationAddress, appKeyIndex);
    message.responseMax = 1;
    return message;
  }

  /**
   * Gets the opcode value for the FD_APPLY message.
   * @returns The opcode value for the FD_APPLY message.
   */
  public override getOpcode(): number {
    return Opcode.FD_APPLY;
  }

  /**
   * Gets the opcode value for the FD_STATUS response message.
   * @returns The opcode value for the FD_STATUS response message.
   */
  public override getResponseOpcode(): number {
    return Opcode.FD_STATUS;
  }
}