import { bytesToHex, UUID_OTA_CHARACTERISTIC, UUID_OTA_SERVICE } from '../../../../Index';
import { GattConnection } from './GattConnection';
import { GattOtaOpcode } from './GattOtaOpcode';
import { OtaPacketParser } from './OtaPacketParser';
import { OtaResultCode } from './OtaResultCode';
import { OtaStatusCode } from './OtaStatusCode';
import { readBinaryFile } from '../utils/FileSystem';
import { ByteOrder, bytes2Integer, hexToBytes } from '../utils/ArrayUtils';
import { calCrc32 } from '../utils/Crc';
import { CHARACTERISTIC_UUID_OTA, SERVICE_UUID_OTA } from './UuidInfo';


const LOG_TAG = "GATT-OTA";


const OTA_TIMEOUT = 5 * 60 * 1000 // 5 minutes

const DEFAULT_READ_INTERVAL = 8;
/**
 * command tags
 */
const TAG_OTA_WRITE = 1
const TAG_OTA_READ = 2;
const TAG_OTA_LAST = 3;
const TAG_OTA_START = 6;
const TAG_OTA_END = 7;
/**
 * send after send ota start or extend start
 */
const TAG_OTA_START_READ = 13;

export class GattOtaController {
    /**
     * timer for version request
     */
    private TIMEOUT_VERSION_RSP = 10 * 1000;
    private mOtaParser: OtaPacketParser = new OtaPacketParser()
    private realPduLen: number = 16
    private otaRunning = false;
    protected otaTimeoutId = 0 //  Handler mTimeoutHandler;

    protected versionRspTimeoutId = 0 //  Handler mTimeoutHandler;

    private mConnection?: GattConnection = undefined
    // private GattOtaCallback mCallback;
    private otaStateCallback?: (state: number, extra: string) => void
    private otaProgressCallback?: (progress: number) => void
    private otaLogCallback?: (log: string) => void
    private readInterval = 8

    constructor(gattConnection: GattConnection,
        otaStateCallback?: (state: number, extra: string) => void,
        otaProgressCallback?: (progress: number) => void) {
        this.mConnection = gattConnection
        this.otaStateCallback = otaStateCallback
        this.otaProgressCallback = otaProgressCallback
    }


    private clear() {
        this.mOtaParser.clear();
    }

    public async startOta(fwData: Uint8Array, readInterval: number = DEFAULT_READ_INTERVAL) {
        console.log("start ota, data len = : " + fwData.length)
        if (this.otaRunning) {
            this.onOtaFailure(OtaStatusCode.BUSY, "busy");
            return;
        }

        if (!this.mConnection || !this.mConnection.isConnected()) {
            this.onOtaFailure(OtaStatusCode.FAIL_UNCONNECTED, "OTA fail: device not connected");
            return;
        }

        this.resetOta();

        if (!await this.validateFwData(fwData)) {
            return;
        }
        console.log("start ota: processing");
        this.otaRunning = true;
        this.readInterval = readInterval
        clearTimeout(this.otaTimeoutId)
        this.otaTimeoutId = setTimeout(() => {
            this.onOtaFailure(OtaStatusCode.FAIL_FLOW_TIMEOUT, "OTA fail: flow timeout")
        }, OTA_TIMEOUT)
        await this.mConnection.enableNotify(SERVICE_UUID_OTA, CHARACTERISTIC_UUID_OTA);
        this.onOtaStart();
        await this.sendOtaStartCmd();
    }

    public pushNotification(notificationData: Uint8Array) {
        if (notificationData.length < 2) {
            return;
        }

        let opcode = (notificationData[0] & 0xFF) | ((notificationData[1] & 0xFF) << 8);
        console.info("ota notify: " + opcode.toString(16).padStart(4, '0'));
        if (opcode == GattOtaOpcode.CMD_OTA_RESULT) {
            if (!this.otaRunning) {
                return;
            }
            if (notificationData.length < 3) {
                return;
            }
            let result = notificationData[2] & 0xFF;
            if (result != OtaResultCode.OTA_SUCCESS.code) {
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
            this.mConnection?.disconnect();
        }
    }

    public async validateFwData(data: Uint8Array): Promise<boolean> {
        if (data.length < 16) {
            this.onOtaFailure(OtaStatusCode.FAIL_FIRMWARE_CHECK_ERR, "OTA fail: check selected firmware data error");
            return false
        }

        if (!this.mConnection) {
            this.onOtaFailure(OtaStatusCode.FAIL_UNCONNECTED, "check connection err");
            return false
        }

        let serviceUUID = SERVICE_UUID_OTA
        let service = this.mConnection.findService(serviceUUID)
        if (!service) {
            this.onOtaFailure(OtaStatusCode.FAIL_SERVICE_NOT_FOUND, "OTA fail: service not found");
            return false;
        }
        let characteristicUUID = CHARACTERISTIC_UUID_OTA
        let characteristic = service.characteristics.find((char) => {
            return char.characteristicUuid == characteristicUUID
        })
        if (!characteristic) {
            this.onOtaFailure(OtaStatusCode.FAIL_CHARACTERISTIC_NOT_FOUND, "OTA fail: characteristic not found");
            return false;
        }

        this.mOtaParser.setData(data);
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


    // OTA 开始时发送的命令
    private sendOtaStartCmd() {
        this.onLog("send OTA start cmd(FF01)");
        return this.sendOtaCmd(GattOtaOpcode.CMD_OTA_START, TAG_OTA_START);
    }

    private sendOtaStartReadCmd() {
        this.onLog("send OTA start read");
        return this.sendGattReadCmd(TAG_OTA_START_READ);
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

        return this.sendOtaCmd(GattOtaOpcode.CMD_OTA_END, TAG_OTA_END, data);
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


    private async sendFirmwareData() {
        let readInterval = this.readInterval
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
                    await this.sendGattCmd(data, TAG_OTA_LAST);
                } else {
                    await this.sendGattCmd(data, TAG_OTA_WRITE);
                    index++
                    if (readInterval != 0 && (index % readInterval == 0)) {
                        await this.sendGattReadCmd(TAG_OTA_READ)
                    }
                }
            }
        } catch (error) {
            console.error("OTA failed:", error.message)
        }
        console.log("sendFirmwareData complete")
    }

    private async sendGattReadCmd(tag: number): Promise<void> {
        if (!this.mConnection) {
            return
        }
        let rsp = await this.mConnection.readCharacteristic(SERVICE_UUID_OTA, CHARACTERISTIC_UUID_OTA)
        if (rsp) {
            this.onOtaCmdSuccess(tag)
        } else {
            this.onOtaCmdFail(tag)
        }
    }

    private async sendGattCmd(cmdData: Uint8Array, tag: number) {
        if (!this.mConnection) {
            return
        }
        let serviceUuid = UUID_OTA_SERVICE
        let characteristicUuid = UUID_OTA_CHARACTERISTIC
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
        this.setOtaProgressChanged();
        this.onOtaSuccess();
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
        if (cmdTag == TAG_OTA_START_READ) {
            this.onLog("OTA start read rsp");
            this.sendFirstFwPacket();
        } else if (cmdTag == TAG_OTA_START) {
            this.sendOtaStartReadCmd();
        } else if (cmdTag == TAG_OTA_END) {
            // ota success
            this.onEndCmdComplete(true);
        } else if (cmdTag == TAG_OTA_LAST) {
            this.sendOtaEndCommand();
        }
    }
}