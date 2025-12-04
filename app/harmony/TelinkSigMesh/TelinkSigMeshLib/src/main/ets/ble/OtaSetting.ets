import { OtaProtocol } from "./OtaProtocol"
import { UUID_OTA_CHARACTERISTIC, UUID_OTA_SERVICE } from "./UuidInfo"

export class OtaSetting {
  /**
   * selected protocol
   */
  public protocol: OtaProtocol = OtaProtocol.Legacy
  /**
   * selected firmware data
   */
  public firmwarePath: string = ""
  /**
   * need to check firmware crc
   */
  public checkFirmwareCrc = false
  /**
   * selected serviceUUID for OTA
   */
  public serviceUUID: string = UUID_OTA_SERVICE
  /**
   * selected characteristicUUID for OTA
   */
  public characteristicUUID: string = UUID_OTA_CHARACTERISTIC
  /**
   * read interval: read every [x] write packets
   * if value <= 0, no read check will be sent
   */
  public readInterval: number = 16
  /**
   * PDU length used in extend protocol, should be 16 * n (1~15)
   */
  public pduLength: number = 240
  /**
   * version compare used in extend protocol
   */
  public versionCompare = false
  /**
   * selected firmware bin version
   * should be 4 bytes
   */
  public firmwareVersion: string = '0000'
  /**
   * OTA flow timeout
   * default 5 minutes
   */
  public timeout = 5 * 60 * 1000
  public sendOTAVersion = true
  /**
   * send firmware index ?
   */
  public sendFwIndex = false
  public fwIndex: number = 0x01
  /**
   * secure boot
   */
  public secureBootEnable = false
  /**
   * selected descriptor file path
   */
  public descriptorPath: string = ""
}
