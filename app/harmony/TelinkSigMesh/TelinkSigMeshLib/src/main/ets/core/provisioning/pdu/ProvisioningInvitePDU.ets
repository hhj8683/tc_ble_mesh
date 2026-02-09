/********************************************************************************************************
 * @file     ProvisioningInvitePDU.ets 
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
 * @file ProvisioningInvitePDU.ets
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
import { ProvisioningPDU } from './ProvisioningPDU';
import { ProvisioningStatePDU } from './ProvisioningStatePDU';


/**
 * This class represents a Provisioning Invite PDU (Protocol Data Unit) used in the provisioning process.
 * It implements the ProvisioningStatePDU interface.
 * The attentionDuration field represents the duration of attention required by the receiver of the invite.
 * The toBytes() method converts the PDU object to a byte array.
 * The getState() method returns the type of the PDU, which is TYPE_INVITE for the Provisioning Invite PDU.
 */
export class ProvisioningInvitePDU implements ProvisioningStatePDU {
  // Attention Timer state
  public attentionDuration: number;

  /**
   * constructor
   *
   * @param attentionDuration attention
   */
  public constructor(attentionDuration: number) {
    this.attentionDuration = attentionDuration;
  }

  /**
   * Converts the PDU to a byte array.
   *
   * @return The byte array representation of the PDU.
   */
  public toBytes() {
    return new Uint8Array([this.attentionDuration])
  }

  /**
   * Gets the state of the PDU.
   *
   * @return The state of the PDU.
   */
  public getState() {
    return ProvisioningPDU.TYPE_INVITE;
  }
}
