/********************************************************************************************************
 * @file     FDUploadStatusMessage.ets 
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
 * @file FDUploadStatusMessage.ets
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

import { StatusMessage } from '../../message/StatusMessage';
import { bytesToHexString } from "../../../utils/ArrayUtils";

/**
 * This class represents a status message for the firmware image upload to a Firmware Distribution Server.
 * It extends the StatusMessage class and implements the Parcelable interface for easy data transfer.
 */
export class FDUploadStatusMessage extends StatusMessage {
  public static readonly STATUS_NAME = "FDUploadStatusMessage"

  public statusName(): string {
      return FDUploadStatusMessage.STATUS_NAME
  }

  /**
   * Status Code for the requesting message
   * 1 byte
   */
  public status: number = 0;

  /**
   * Upload Phase
   * Phase of the firmware image upload to a Firmware Distribution Server
   * 1 byte
   */
  public uploadPhase: number = 0;

  /**
   * Upload Progress
   * A percentage indicating the progress of the firmware image upload (Optional)
   * 0x00 -> 0x64
   * 0 -> 100
   * 7 bits
   */
  public uploadProgress: number = 0;

  /**
   * Upload Progress
   * A bit indicating whether the Upload is done in-band or out-of-band
   * 1 bit
   * 0x0	In-band	The firmware upload is executed in-band.
   * 0x1	Out-of-band 	The firmware upload is executed out-of-band.
   */
  public uploadType: number = 0;

  /**
   * Upload Firmware ID
   * The Firmware ID identifying the firmware image being uploaded
   * Variable
   */
  public uploadFirmwareID: Uint8Array = new Uint8Array(0);

  /**
   * Default constructor.
   */
  constructor() {
    super();
  }

  /**
   * Parses the byte array data and sets the corresponding fields of the FDUploadStatusMessage object.
   * @param params The byte array containing the data to be parsed.
   */
  public override parse(params: Uint8Array): void {
    let index = 0;
    this.status = params[index++] & 0xFF;
    this.uploadPhase = params[index++] & 0xFF;
    if (params.length === 2) return;
    this.uploadProgress = (params[index] & 0x7F) >> 1;
    this.uploadType = params[index++] & 0x01;
    this.uploadFirmwareID = new Uint8Array(params.length - index);
    this.uploadFirmwareID.set(params.slice(index));
  }

  /**
   * Returns a string representation of the FDUploadStatusMessage object.
   * @return A string containing the values of the status, uploadPhase, uploadProgress, uploadType, and uploadFirmwareID fields.
   */
  public override toString(): string {
    return `FDUploadStatusMessage{status=${this.status}, uploadPhase=${this.uploadPhase}, uploadProgress=${this.uploadProgress}, uploadType=${this.uploadType}, uploadFirmwareID=${bytesToHexString(this.uploadFirmwareID)}}`;
  }
}