import { bufferToHex, bytesToHex } from "../../../../Index"

export class OtaSignParser {
  private OP_SIGN_START: number = 0xFF10;
  private OP_SIGN_END: number = 0xFF17;
  private total: number = 8;
  private index: number = -1;
  private data: Uint8Array | undefined = undefined;

  public set(publicKey: Uint8Array, sign: Uint8Array) {
    this.clear();

    this.data = new Uint8Array(publicKey.length + sign.length)

    this.data.set(publicKey, 0);
    this.data.set(sign, publicKey.length)
  }

  public clear() {
    this.index = -1;
    this.data = undefined;
  }

  public hasNextPacket(): boolean {
    return this.total > 0 && (this.index + 1) < this.total;
  }

  public isLast(): boolean {
    return (this.index + 1) == this.total;
  }

  public getNextPacketIndex(): number {
    return this.index + 1;
  }

  public getNextPacket(): Uint8Array | undefined {
    let index = this.getNextPacketIndex()
    let packet = this.getPacket(index)
    this.index = index
    return packet
  }

  public getPacket(index: number): Uint8Array | undefined {
    if (!this.data) {
      return undefined
    }
    let length = this.data?.length
    let packetSize: number

    let pduLength = 16
    if (length > pduLength) {
      if ((index + 1) == this.total) {
        packetSize = length - index * pduLength // 剩余 data
      } else {
        packetSize = pduLength
      }
    } else {
      packetSize = length
    }


    let totalSize: number
    if (packetSize == pduLength) {
      totalSize = pduLength + 4
    } else {
      let dataSize = (packetSize % 16 == 0) ? packetSize : ((packetSize / 16 + 1) * 16)
      totalSize = dataSize + 4
      console.info("last: " + totalSize)
    }

    let packet = new Uint8Array(totalSize)
    packet.fill(0xFF)
    packet.set(this.data.subarray(index * pduLength, index * pduLength + packetSize), 2)

    this.fillIndex(packet, index)
    let crc = this.crc16(packet)
    this.fillCrc(packet, crc)
    console.info("sign packet ---> index : %d  total : %d crc : %04X content : %s", index, this.total, crc,
      bytesToHex(packet, ""))
    return packet
  }

  public fillIndex(packet: Uint8Array, index: number) {
    let offset = 0
    index += this.OP_SIGN_START
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


  public getIndex(): number {
    return this.index
  }
}
