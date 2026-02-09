/********************************************************************************************************
 * @file     OtaPacketParser.ets 
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
import { bufferToHex, bytesToHex } from "../../../../Index"

export class OtaPacketParser {
  private total: number = 0
  private index: number = -1
  private data: Uint8Array | null = null
  private progress: number = 0
  private pduLength: number = 16

  public setData(data: Uint8Array) {
    this.clear()
    this.data = data
  }

  public resetPduLen(pduLen: number) {
    this.pduLength = pduLen
    let length = this.data?.length || 0
    if (length % pduLen == 0) {
      this.total = length / pduLen
    } else {
      this.total = Math.ceil(length / pduLen)
    }
  }


  public clear() {
    this.progress = 0
    this.total = 0
    this.index = -1
    this.data = null
  }

  public getFirmwareVersion(): Uint8Array | null {
    if (!this.data || this.data.length < 6) {
      return null
    }
    let version: Uint8Array = new Uint8Array(4)
    version.set(this.data.subarray(2, 6), 0)
    return version
  }

  public hasNextPacket(): boolean {
    // console.log("has next ? " + this.index + " -- " + this.total)
    return this.total > 0 && (this.index + 1) < this.total
  }

  public isLast(): boolean {
    return (this.index + 1) == this.total
  }

  public getNextPacketIndex(): number {
    return this.index + 1
  }

  public getNextPacket(): Uint8Array | null {

    let index = this.getNextPacketIndex()
    let packet = this.getPacket(index)
    this.index = index
    return packet
  }

  public getPacket(index: number): Uint8Array | null {
    if (!this.data) {
      return null
    }
    let length = this.data.length
    let packetSize: number

    if (length > this.pduLength) {
      if ((index + 1) == this.total) {
        packetSize = length - index * this.pduLength
      } else {
        packetSize = this.pduLength
      }
    } else {
      packetSize = length
    }


    let totalSize: number
    if (packetSize == this.pduLength) {
      totalSize = this.pduLength + 4; //
    } else {
      let dataSize = Math.ceil(packetSize / 16) * 16
      totalSize = dataSize + 4
      console.log("last: " + totalSize)
    }

    let packet: Uint8Array = new Uint8Array(totalSize)
    packet.fill(0xFF)

    packet.set(this.data.subarray(index * this.pduLength, index * this.pduLength + packetSize), 2)
    // System.arraycopy(this.data.subarray(), index * pduLength, packet, 2, packetSize) 

    this.fillIndex(packet, index)
    let crc: number = this.crc16(packet)
    this.fillCrc(packet, crc)
    console.log("ota packet ---> index : %d  total : %d crc : %s content : %s", index, this.total, crc.toString(16).padStart(4, '0'),
      bytesToHex(packet, ""))
    return packet
  }

  public fillIndex(packet: Uint8Array, index: number) {
    let offset = 0
    packet[offset++] = index & 0xFF
    packet[offset] = index >> 8 & 0xFF
  }

  public fillCrc(packet: Uint8Array, crc: number) {
    let offset = packet.length - 2
    packet[offset++] = crc & 0xFF
    packet[offset] = crc >> 8 & 0xFF
  }

  public crc16(packet: Uint8Array): number {

    let length = packet.length - 2
    let poly: Uint16Array = new Uint16Array([0, 0xA001])
    let crc = 0xFFFF
    let ds: number

    for (let j = 0; j < length; j++) {
      ds = packet[j]
      for (let i = 0; i < 8; i++) {
        crc = (crc >> 1) ^ poly[(crc ^ ds) & 1] & 0xFFFF
        ds = ds >> 1
      }
    }

    return crc
  }

  public invalidateProgress(): boolean {

    let a = this.getNextPacketIndex()
    let b = this.total
    console.log("invalidate progress: " + a + " -- " + b)
    let progress = Math.floor((a / b * 100))

    if (progress == this.progress) {
      return false
    }

    this.progress = progress

    return true
  }

  public getProgress(): number {
    return this.progress
  }

  public getIndex(): number {
    return this.index
  }
}
