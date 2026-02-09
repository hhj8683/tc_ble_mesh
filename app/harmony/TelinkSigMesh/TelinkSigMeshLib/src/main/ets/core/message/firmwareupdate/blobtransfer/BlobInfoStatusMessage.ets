/********************************************************************************************************
 * @file     BlobInfoStatusMessage.ets 
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
 * @file BlobInfoStatusMessage.ets
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

import { StatusMessage } from "../../../message/StatusMessage";
import { TransferMode } from './TransferMode';
import { ByteOrder, bytes2Integer } from '../../../../utils/ArrayUtils';

/**
 * This class represents a status message containing information about a Blob.
 * It extends the StatusMessage class and implements the Parcelable interface for easy serialization.
 * The class includes various attributes such as the minimum and maximum block sizes supported by the server,
 * the maximum number of chunks in a block, the maximum chunk size, the maximum BLOB size, the MTU size supported by the server,
 * and the supported transfer modes.
 * The class provides methods to get and set these attributes, as well as methods to check if push and pull transfer modes are supported.
 * The class also overrides the parse, describeContents, writeToParcel, and toString methods for proper functionality and string representation.
 */
export class BlobInfoStatusMessage extends StatusMessage {
  public static readonly STATUS_NAME = "BlobInfoStatusMessage"

  public statusName(): string {
      return BlobInfoStatusMessage.STATUS_NAME
  }

  /**
    * Minimum block size supported by the server
    * 1 byte
    */
  private minBlockSizeLog: number = 0;

  /**
    * Maximum block size supported by the server
    * 1 byte
    */
  private maxBlockSizeLog: number = 0;

  /**
    * Maximum number of chunks in block supported by the server
    * 2 bytes
    */
  private maxTotalChunks: number = 0;

  /**
    * Maximum chunk size supported by the server
    * 2 bytes
    */
  private maxChunkSize: number = 0;

  /**
    * Maximum BLOB size supported by the server
    * 4 bytes
    */
  private maxBLOBSize: number = 0;

  /**
    * MTU size supported by the server
    * 2 bytes
    */
  private serverMTUSize: number = 0;

  /**
    * BLOB transfer modes supported by the server
    * 1 byte
    */
  private supportedTransferMode: number = 0;

  /**
    * Default constructor for the BlobInfoStatusMessage class.
    */
  constructor() {
      super();
  }

  /**
    * Parses the given byte array and sets the attributes of the BlobInfoStatusMessage object accordingly.
    *
    * @param params The byte array to parse.
    */
  public parse(params: Uint8Array): void {
      let index = 0;
      this.minBlockSizeLog = params[index++] & 0xFF;
      this.maxBlockSizeLog = params[index++] & 0xFF;

      this.maxTotalChunks = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
      index += 2;

      this.maxChunkSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
      index += 2;

      this.maxBLOBSize = bytes2Integer(params, index, 4, ByteOrder.LITTLE_ENDIAN);
      index += 4;

      this.serverMTUSize = bytes2Integer(params, index, 2, ByteOrder.LITTLE_ENDIAN);
      index += 2;

      this.supportedTransferMode = params[index];
  }

  /**
    * Returns the minimum block size log supported by the server.
    *
    * @return The minimum block size log.
    */
  public getMinBlockSizeLog(): number {
      return this.minBlockSizeLog;
  }

  /**
    * Returns the maximum block size log supported by the server.
    *
    * @return The maximum block size log.
    */
  public getMaxBlockSizeLog(): number {
      return this.maxBlockSizeLog;
  }

  /**
    * Returns the maximum number of chunks in a block supported by the server.
    *
    * @return The maximum number of chunks in a block.
    */
  public getMaxTotalChunks(): number {
      return this.maxTotalChunks;
  }

  /**
    * Returns the maximum chunk size supported by the server.
    *
    * @return The maximum chunk size.
    */
  public getMaxChunkSize(): number {
      return this.maxChunkSize;
  }

  /**
    * Returns the maximum BLOB size supported by the server.
    *
    * @return The maximum BLOB size.
    */
  public getMaxBLOBSize(): number {
      return this.maxBLOBSize;
  }

  /**
    * Returns the MTU size supported by the server.
    *
    * @return The MTU size.
    */
  public getServerMTUSize(): number {
      return this.serverMTUSize;
  }

  /**
    * Returns the supported transfer mode bitmask.
    *
    * @return The supported transfer mode bitmask.
    */
  public getSupportedTransferMode(): number {
      return this.supportedTransferMode;
  }

  /**
    * Sets the minimum block size log supported by the server.
    *
    * @param minBlockSizeLog The minimum block size log to set.
    */
  public setMinBlockSizeLog(minBlockSizeLog: number): void {
      this.minBlockSizeLog = minBlockSizeLog;
  }

  /**
    * Sets the maximum block size log supported by the server.
    *
    * @param maxBlockSizeLog The maximum block size log to set.
    */
  public setMaxBlockSizeLog(maxBlockSizeLog: number): void {
      this.maxBlockSizeLog = maxBlockSizeLog;
  }

  /**
    * Sets the maximum number of chunks in a block supported by the server.
    *
    * @param maxTotalChunks The maximum number of chunks in a block to set.
    */
  public setMaxTotalChunks(maxTotalChunks: number): void {
      this.maxTotalChunks = maxTotalChunks;
  }

  /**
    * Sets the maximum chunk size supported by the server.
    *
    * @param maxChunkSize The maximum chunk size to set.
    */
  public setMaxChunkSize(maxChunkSize: number): void {
      this.maxChunkSize = maxChunkSize;
  }

  /**
    * Sets the maximum BLOB size supported by the server.
    *
    * @param maxBLOBSize The maximum BLOB size to set.
    */
  public setMaxBLOBSize(maxBLOBSize: number): void {
      this.maxBLOBSize = maxBLOBSize;
  }

  /**
    * Sets the MTU size supported by the server.
    *
    * @param serverMTUSize The MTU size to set.
    */
  public setServerMTUSize(serverMTUSize: number): void {
      this.serverMTUSize = serverMTUSize;
  }

  /**
    * Sets the supported transfer mode bitmask.
    *
    * @param supportedTransferMode The supported transfer mode bitmask to set.
    */
  public setSupportedTransferMode(supportedTransferMode: number): void {
      this.supportedTransferMode = supportedTransferMode;
  }

  /**
    * Checks if the push transfer mode is supported.
    *
    * @return True if the push transfer mode is supported, false otherwise.
    */
  public isPushModeSupported(): boolean {
      return (this.supportedTransferMode & TransferMode.PUSH) !== 0;
  }

  /**
    * Checks if the pull transfer mode is supported.
    *
    * @return True if the pull transfer mode is supported, false otherwise.
    */
  public isPullModeSupported(): boolean {
      return (this.supportedTransferMode & TransferMode.PULL) !== 0;
  }

  /**
    * Returns a string representation of the BlobInfoStatusMessage object.
    *
    * @return A string representation of the object.
    */
  public toString(): string {
      return `BlobInfoStatusMessage{minBlockSizeLog=${this.minBlockSizeLog}, maxBlockSizeLog=${this.maxBlockSizeLog}, maxTotalChunks=${this.maxTotalChunks}, maxChunkSize=${this.maxChunkSize}, maxBLOBSize=${this.maxBLOBSize}, serverMTUSize=${this.serverMTUSize}, supportedTransferMode=${this.supportedTransferMode}, isPushModeSupported=${this.isPushModeSupported()}, isPullModeSupported=${this.isPullModeSupported()}}`;
  }
}