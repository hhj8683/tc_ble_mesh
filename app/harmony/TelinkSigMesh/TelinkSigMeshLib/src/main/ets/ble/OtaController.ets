import { bytesToHex, UUID_OTA_SERVICE, UUID_OTA_CHARACTERISTIC } from "../../../../Index";
import { GattConnection } from "./GattConnection";
import { Opcode } from "./Opcode";
import { OtaPacketParser } from "./OtaPacketParser";
import { OtaProtocol } from "./OtaProtocol";
import { OtaResultCode } from "./OtaResultCode";
import { OtaSetting } from "./OtaSetting";
import { OtaSignParser } from "./OtaSignParser";
import { OtaStatusCode } from "./OtaStatusCode";
import { ble } from "@kit.ConnectivityKit";
import { readBinaryFile } from "../utils/FileSystem";
import { ByteOrder, bytes2Integer, hexToBytes } from "../utils/ArrayUtils";
import { calCrc32 } from "../utils/Crc";


const LOG_TAG = "GATT-OTA";

export enum OtaState {
  OTA_STATE_FAILURE = 0,
  OTA_STATE_SUCCESS = 1,
  OTA_STATE_PROGRESS = 2
}

export class OtaController {
  /**
   * command tags
   */
  private TAG_OTA_WRITE = 1
  private TAG_OTA_READ = 2;
  private TAG_OTA_LAST = 3;
  private TAG_OTA_REQUEST_MTU = 4;
  private TAG_OTA_VERSION = 5;
  private TAG_OTA_START = 6;
  private TAG_OTA_END = 7;
  private TAG_OTA_START_EXT = 8;
  private TAG_OTA_FW_VERSION_REQ = 9;
  private TAG_OTA_SET_FW_INDEX = 10;
  /**
   * send sign(with public key) data
   */
  private TAG_OTA_SIGN_WRITE = 11;
  /**
   * send last sign packet
   */
  private TAG_OTA_SIGN_LAST = 12;
  /**
   * send after send ota start or extend start
   */
  private TAG_OTA_START_READ = 13;
  /**
   * timer for version request
   */
  private TIMEOUT_VERSION_RSP = 10 * 1000;
  private mOtaParser: OtaPacketParser = new OtaPacketParser();
  private mSignParser: OtaSignParser = new OtaSignParser();
  private otaSetting!: OtaSetting;
  private realPduLen: number = 16;
  private otaProtocol: OtaProtocol = OtaProtocol.Legacy;
  private otaRunning = false;
  protected otaTimeoutId = 0 //  Handler mTimeoutHandler;

  protected versionRspTimeoutId = 0 //  Handler mTimeoutHandler;

  private mConnection!: GattConnection;
  // private GattOtaCallback mCallback;
  private otaStateCallback?: (state: number, extra: string) => void
  private otaProgressCallback?: (progress: number) => void
  private otaLogCallback?: (log: string) => void
  private DEFAULT_READ_INTERVAL = 8;

  constructor(gattConnection: GattConnection,
    otaStateCallback?: (state: number, extra: string) => void,
    otaProgressCallback?: (progress: number) => void,
    otaLogCallback?: (log: string) => void) {
    this.mConnection = gattConnection
    this.otaStateCallback = otaStateCallback
    this.otaProgressCallback = otaProgressCallback
    this.otaLogCallback = otaLogCallback
  }


  private clear() {
    this.mOtaParser.clear();
  }

  public async startOta(otaSetting: OtaSetting) {
    console.log("start ota - 0: " + JSON.stringify(otaSetting))
    if (this.otaRunning) {
      this.onOtaFailure(OtaStatusCode.BUSY, "busy");
      return;
    }

    if (!this.mConnection || !this.mConnection.isConnected()) {
      this.onOtaFailure(OtaStatusCode.FAIL_UNCONNECTED, "OTA fail: device not connected");
      return;
    }

    this.otaSetting = otaSetting;
    this.resetOta();

    if (!await this.validateOtaSettings()) {
      return;
    }
    console.log("start ota: " + otaSetting.toString());
    this.otaRunning = true;
    clearTimeout(this.otaTimeoutId)
    this.otaTimeoutId = setTimeout(() => {
      this.onOtaFailure(OtaStatusCode.FAIL_FLOW_TIMEOUT, "OTA fail: flow timeout")
    }, this.otaSetting.timeout)
    await this.mConnection.enableNotify(otaSetting.serviceUUID, otaSetting.characteristicUUID);
    this.onOtaStart();


    // this.sendFirstFwPacket()
    if (otaSetting.sendFwIndex) {
      await this.sendSetFwIndexCmd();
    }

    if (otaSetting.sendOTAVersion) {
      await this.sendOTAVersionCmd();
    }
    if (this.isLegacyProtocol()) {
      await this.sendOtaStartCmd();
    } else {
      await this.sendOtaFwVersionReqCommand();
    }
  }

  public pushNotification(notificationData: Uint8Array) {
    if (notificationData.length < 2) {
      return;
    }

    let opcode = (notificationData[0] & 0xFF) | ((notificationData[1] & 0xFF) << 8);
    console.info("ota notify: " + opcode.toString(16).padStart(4, '0'));
    if (opcode == Opcode.CMD_OTA_FW_VERSION_RSP) {
      // cancel rsp timer
      if (notificationData.length < 5) {
        this.onOtaFailure(OtaStatusCode.FAIL_VERSION_RSP_ERROR, "version response command format error");
        return;
      }
      let index = 2;
      let deviceVersion = notificationData.subarray(2, 4);

      index += 2;
      let accept = notificationData[index] == 1;
      console.log("version response: version-%s accept-%b",
        bytesToHex(deviceVersion, ":"), accept);
      clearTimeout(this.versionRspTimeoutId)

      // mTimeoutHandler.removeCallbacks(OTA_FW_VERSION_RSP_TASK);
      if (accept) {
        this.sendOtaStartExtCmd();
      } else {
        this.onOtaFailure(OtaStatusCode.FAIL_VERSION_COMPARE_ERR, "device version compare fail");
      }

      // check is notification data format err
    } else if (opcode == Opcode.CMD_OTA_RESULT) {
      if (!this.otaRunning) {
        return;
      }
      if (notificationData.length < 3) {
        return;
      }
      let result = notificationData[2] & 0xFF;
      if (result == OtaResultCode.OTA_SUCCESS.code) {
        if (!this.isLegacyProtocol()) {
          this.onOtaSuccess();
        }
      } else {
        let resultCode = OtaResultCode.getResultCode(result);
        this.onOtaFailure(OtaStatusCode.FAIL_OTA_RESULT_NOTIFICATION,
          resultCode == undefined ? "unknown result code" : OtaResultCode.getDescription(resultCode));
      }
    }
  }


  public stopOta() {
    this.sendOtaEndCommand();
  }

  public reset(disconnect: boolean) {
    this.resetOta();
    if (disconnect) {
      this.mConnection.disconnect();
    }
  }

  private calcRealPduLen(): number {
    let maxPduLen = this.mConnection.getMtu() - 7; // 7 : 1 byte opcode, 2 byte handle, 2 byte pdu index, 2 byte crc
    let checkedLen = Math.min(this.otaSetting?.pduLength || 16, maxPduLen);
    return Math.floor(checkedLen / 16) * 16;
  }

  public async validateOtaSettings(): Promise<boolean> {
    if (!this.otaSetting) {
      this.onOtaFailure(OtaStatusCode.FAIL_PARAMS_ERR, "OTA fail: params error");
      return false;
    }

    let serviceUUID = this.otaSetting.serviceUUID
    let service = this.mConnection.findService(serviceUUID)
    if (!service) {
      this.onOtaFailure(OtaStatusCode.FAIL_SERVICE_NOT_FOUND, "OTA fail: service not found");
      return false;
    }
    let characteristicUUID = this.otaSetting.characteristicUUID
    let characteristic = service.characteristics.find((char) => {
      return char.characteristicUuid == characteristicUUID
    })
    if (!characteristic) {
      this.onOtaFailure(OtaStatusCode.FAIL_CHARACTERISTIC_NOT_FOUND, "OTA fail: characteristic not found");
      return false;
    }

    let firmwarePath = this.otaSetting.firmwarePath;
    let firmwareData: Uint8Array | undefined = await this.parseFirmware(firmwarePath, this.otaSetting.checkFirmwareCrc);
    if (!firmwareData) {
      this.onOtaFailure(OtaStatusCode.FAIL_FIRMWARE_CHECK_ERR, "OTA fail: check selected firmware bin error");
      return false;
    }
    console.log("parse firmware success : " + firmwareData.length)

    if (this.otaSetting.secureBootEnable) {
      if (!this.parseDescriptor(this.otaSetting.descriptorPath)) {
        this.onOtaFailure(OtaStatusCode.FAIL_DESCRIPTOR_CHECK_ERR, "OTA fail: check selected descriptor bin error");
        return false;
      }
    }

    this.otaProtocol = this.otaSetting.protocol;
    this.mOtaParser.setData(firmwareData);
    return true;
  }


  private async parseFirmware(fileName: string, checkFirmwareCrc: boolean): Promise<Uint8Array | undefined> {
    let firmware = await readBinaryFile(fileName)
    if (firmware) {
      // check firmware crc
      if (checkFirmwareCrc && !this.checkCRC(firmware)) {
        console.log("check firmware fail");
        return undefined;
      }
      return firmware
    }
    return undefined
  }

  private async parseDescriptor(fileName: string | undefined): Promise<boolean> {
    if (!fileName) {
      return false;
    }
    let data = await readBinaryFile(fileName)
    if (!data) {
      return false
    }
    try {
      let length = data.length
      let offset = length - 32; // Read from the last 32 bytes
      let pubKeyOffset = bytes2Integer(data, offset, 2, ByteOrder.LITTLE_ENDIAN); // public key offset = offset[0-1]
      offset += 2;
      let signOffset = bytes2Integer(data, offset, 2, ByteOrder.LITTLE_ENDIAN); // sign offset = offset[2-3]

      let publicKey = data.subarray(pubKeyOffset, pubKeyOffset + 64)
      console.log("parsed public key: " + bytesToHex(publicKey));

      let sign = data.subarray(signOffset, signOffset + 64)
      console.log("parsed sign: " + bytesToHex(sign));
      this.mSignParser.set(publicKey, sign);
      return true;
    } catch (e) {
      console.log("parseDescriptor error ")
    }
    return false;
  }


  /**
   * calculate firmware crc
   *
   * @param firmware selected bin
   * @return check result
   */
  private checkCRC(firmware: Uint8Array | undefined): boolean {
    if (!firmware || firmware.length < 4) {
      return false;
    }

    let len = firmware.length;
    let buffer = firmware.subarray(0, len - 4)
    // System.arraycopy(firmware, 0, buffer, 0, buffer.length);
    // calc value
    let crcValue = calCrc32(buffer);

    // read from firmware
    let crcInFirmware = ((firmware[len - 1] & 0xFF) << 24) +
      ((firmware[len - 2] & 0xFF) << 16) +
      ((firmware[len - 3] & 0xFF) << 8) +
      (firmware[len - 4] & 0xFF);
    console.log("crc check compare: crc : " + crcValue + " local : " + crcInFirmware);
    if (crcValue != crcInFirmware) {
      console.log("crc check err");
      return false;
    }
    return true;
  }


  updateOtaState(code: number, extra: string) {
    if (this.otaStateCallback) {
      this.otaStateCallback(code, extra);
    }
  }


  protected onOtaStart() {
    this.updateOtaState(OtaStatusCode.STARTED, "OTA started");
  }

  protected onOtaSuccess() {
    this.resetOta();
    this.updateOtaState(OtaStatusCode.SUCCESS, "OTA success");
  }

  private onOtaFailure(statusCode: number, extraInfo: string) {
    console.log("on ota fail : " + extraInfo)
    this.resetOta();
    this.updateOtaState(statusCode, extraInfo);
  }

  protected onOtaProgress() {
    if (this.otaProgressCallback) {
      this.otaProgressCallback(this.getOtaProgress());
    }
  }


  public getOtaProgress(): number {
    return this.mOtaParser.getProgress();
  }

  private resetOta() {
    this.otaRunning = false;
    clearTimeout((this.otaTimeoutId))
    clearTimeout(this.versionRspTimeoutId)
    this.mOtaParser.clear();
  }

  private setOtaProgressChanged() {
    if (this.mOtaParser.invalidateProgress()) {
      this.onOtaProgress();
    }
  }

  private isLegacyProtocol() {
    return this.otaProtocol == OtaProtocol.Legacy;
  }

  private sendSetFwIndexCmd() {
    this.onLog("send OTA fw idx cmd(FF80)");
    return this.sendOtaCmd(Opcode.CMD_OTA_SET_FW_INDEX, this.TAG_OTA_SET_FW_INDEX,
      new Uint8Array([this.otaSetting.fwIndex]));
  }

  private sendOTAVersionCmd() {
    this.onLog("send OTA version cmd(FF00)");
    return this.sendOtaCmd(Opcode.CMD_OTA_VERSION, this.TAG_OTA_VERSION);
  }

  // OTA 开始时发送的命令
  private sendOtaStartCmd() {
    this.realPduLen = this.calcRealPduLen();
    this.onLog("use pdu len(legacy): " + this.realPduLen);
    this.onLog("send OTA start cmd(FF01)");
    return this.sendOtaCmd(Opcode.CMD_OTA_START, this.TAG_OTA_START);
  }

  private sendOtaStartExtCmd() {
    this.realPduLen = this.calcRealPduLen();
    this.onLog("use pdu len(extend): " + this.realPduLen);
    this.onLog("send OTA start extend cmd(FF03)");
    let extData = new Uint8Array(18)
    extData[0] = this.realPduLen;
    extData[1] = (this.otaSetting?.versionCompare ? 0x01 : 0x00);
    return this.sendOtaCmd(Opcode.CMD_OTA_START_EXT, this.TAG_OTA_START_EXT, extData);
  }

  private sendOtaStartReadCmd() {
    this.onLog("send OTA start read");
    return this.sendGattReadCmd(this.TAG_OTA_START_READ);
  }

  private sendOtaFwVersionReqCommand() {
    this.onLog("send OTA fw ver req cmd(FF04)");
    let reqData = new Uint8Array(3)
    let version = hexToBytes(this.otaSetting.firmwareVersion)
    reqData.set(version, 0)

    // System.arraycopy(otaSetting.firmwareVersion, 0, reqData, 0, 2);
    reqData[2] = this.otaSetting?.versionCompare ? 0x01 : 0x00
    return this.sendOtaCmd(Opcode.CMD_OTA_FW_VERSION_REQ, this.TAG_OTA_FW_VERSION_REQ, reqData);
  }

  private checkReqVersionRsp() {
    clearTimeout(this.versionRspTimeoutId)
    this.versionRspTimeoutId = setTimeout(() => {
      this.onOtaFailure(OtaStatusCode.FAIL_FW_VERSION_REQ_TIMEOUT,
        "OTA fail: firmware version request timeout(please check whether the notify property exists)")
    }, this.TIMEOUT_VERSION_RSP)
  }

  private sendOtaEndCommand() {
    this.onLog("send OTA end cmd(FF02)");

    let index = this.mOtaParser.getIndex();
    let data = new Uint8Array(18)
    data[0] = index & 0xFF
    data[1] = index >> 8 & 0xFF
    data[2] = ~index & 0xFF
    data[3] = ~index >> 8 & 0xFF

    return this.sendOtaCmd(Opcode.CMD_OTA_END, this.TAG_OTA_END, data);
  }

  private sendOtaCmd(opcode: number, tag: number, data?: Uint8Array): Promise<void> {
    let cmdData: Uint8Array;
    if (data) {
      cmdData = new Uint8Array(2 + data.length)
      cmdData[0] = opcode & 0xFF
      cmdData[1] = (opcode >> 8) & 0xFF
      cmdData.set(data, 2)
    } else {
      cmdData = new Uint8Array([opcode & 0xFF, (opcode >> 8) & 0xFF])
    }
    return this.sendGattCmd(cmdData, tag);
  }


  private sendFirstFwPacket() {
    this.onLog("send first fw data packet")
    this.mOtaParser.resetPduLen(this.realPduLen);
    this.sendFirmwareData()
  }


  private sendNextSignCommand() {
    if (this.mSignParser.hasNextPacket()) {
      let data = this.mSignParser.getNextPacket();
      if (!data) {
        console.log("get sign packet error ")
        return
      }
      if (this.mSignParser.isLast()) {
        this.sendGattCmd(data, this.TAG_OTA_SIGN_LAST);
      } else {
        this.sendGattCmd(data, this.TAG_OTA_SIGN_WRITE);
      }
    } else {
      console.log("no other sign packet");
    }
  }

  private async sendFirmwareData() {
    let readInterval = this.otaSetting?.readInterval || 0
    console.log("sendFirmwareData : read interval = " + readInterval)
    let index = 0
    try {
      while (this.mOtaParser.hasNextPacket()) {
        console.log("next packet")
        let data = this.mOtaParser.getNextPacket();
        if (!data) {
          console.log("get packet error ")
          return
        }

        this.setOtaProgressChanged();
        if (this.mOtaParser.isLast()) {
          await this.sendGattCmd(data, this.TAG_OTA_LAST);
        } else {
          await this.sendGattCmd(data, this.TAG_OTA_WRITE);
          index++
          if (readInterval != 0 && (index % readInterval == 0)) {
            await this.sendGattReadCmd(this.TAG_OTA_READ)
          }
        }
      }
    } catch (error) {
      console.error("OTA failed:", error.message)
    }
    console.log("sendFirmwareData complete")
  }

  private async sendGattReadCmd(tag: number): Promise<void> {
    let serviceUuid = this.otaSetting.serviceUUID
    let characteristicUuid = this.otaSetting.characteristicUUID
    let rsp = await this.mConnection.readCharacteristic(serviceUuid, characteristicUuid)
    if (rsp) {
      this.onOtaCmdSuccess(tag)
    } else {
      this.onOtaCmdFail(tag)
    }
  }

  private async sendGattCmd(cmdData: Uint8Array, tag: number) {
    let serviceUuid = this.otaSetting?.serviceUUID || UUID_OTA_SERVICE
    let characteristicUuid = this.otaSetting?.characteristicUUID || UUID_OTA_CHARACTERISTIC
    const ret = await this.mConnection.writeCharacteristic(serviceUuid, characteristicUuid, cmdData)
    if (ret) {
      this.onOtaCmdSuccess(tag)
    } else {
      this.onOtaCmdFail(tag)
    }

  }

  private onLog(log: string) {
    if (this.otaLogCallback) {
      this.otaLogCallback(log);
    }
  }

  /**
   * OTA End command send complete
   *
   * @param success is cmd send success
   */
  private onEndCmdComplete(success: boolean) {
    // if (isLegacyProtocol() || success) {
    if (this.isLegacyProtocol()) {
      this.setOtaProgressChanged();
      this.onOtaSuccess();
    } else if (!success) {
      this.onOtaFailure(OtaStatusCode.FAIL_PACKET_SENT_ERR, "OTA fail: end packet sent err");
    }
  }

  private onOtaCmdFail(cmdTag: number) {
    if (!this.otaRunning) {
      return
    }
    this.onOtaFailure(OtaStatusCode.FAIL_PACKET_SENT_ERR, "ota fail, cmd fail : " + cmdTag)
  }

  private onOtaCmdSuccess(cmdTag: number) {
    console.log("ota command success : " + cmdTag + " running : " + this.otaRunning)
    if (!this.otaRunning) {
      return
    }
    if (cmdTag == this.TAG_OTA_VERSION) {

    } else if (cmdTag == this.TAG_OTA_START_READ) {
      this.onLog("OTA start read rsp");
      if (this.otaSetting?.secureBootEnable) {
        console.log("start read rsp - 1")
        this.sendNextSignCommand();
      } else {
        console.log("start read rsp - 2")
        this.sendFirstFwPacket();
      }

    } else if (cmdTag == this.TAG_OTA_START) {
      this.sendOtaStartReadCmd();
    } else if (cmdTag == this.TAG_OTA_START_EXT) {
      this.sendOtaStartReadCmd();
    } else if (cmdTag == (this.TAG_OTA_END)) {
      // ota success
      this.onEndCmdComplete(true);
    } else if (cmdTag == (this.TAG_OTA_LAST)) {
      this.sendOtaEndCommand();
    } else if (cmdTag == (this.TAG_OTA_SIGN_WRITE)) {
      this.sendNextSignCommand();
    } else if (cmdTag == (this.TAG_OTA_SIGN_LAST)) {
      this.onLog("sing data send complete");
      this.sendFirstFwPacket();
    } else if (cmdTag == (this.TAG_OTA_FW_VERSION_REQ)) {
      this.checkReqVersionRsp();
    }
  }
}