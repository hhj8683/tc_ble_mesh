/********************************************************************************************************
 * @file BleScanner.java
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
import { ble } from "@kit.ConnectivityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { logd, loge } from "../utils/MeshLogger";
import { SERVICE_PROVISION, SERVICE_UUID_OTA } from "./UuidInfo";
import { bufferToHex } from "../utils/ArrayUtils";

/**
 * used to scan bluetooth device
 */
export class BleScanner {
    private isScanning = false;
    private scanTimerId = 0
    private onScanStartFail: () => void
    private onScanStarted: () => void
    private onScanTimeout: () => void
    private onDeviceFound: (scanResult: ble.ScanResult) => void
    private map: Map<number, Uint8Array> = new Map()

    constructor(onScanStartFail: () => void, onScanStarted: () => void, onScanTimeout: () => void,
        onDeviceFound: (scanResult: ble.ScanResult) => void) {
        this.onScanStartFail = onScanStartFail;
        this.onScanStarted = onScanStarted;
        this.onScanTimeout = onScanTimeout;
        this.onDeviceFound = onDeviceFound;
    }


    onReceiveEvent(data: Array<ble.ScanResult>) {
        // logd('device found: ' + JSON.stringify(data))
        data.forEach((item) => {
            logd(`adv device : name=${item.deviceName} , rssi=${item.rssi} , data=${bufferToHex(item.data)}`)
            // console.log("device adv data : ", bufferToHex(item.data))
            const deviceId = item.deviceId
            this.onDeviceFound(item)
        })
        // this.bleDeviceList.push(...data)
    }


    public startScan(filter?: ble.ScanFilter[], timeoutMills: number = 10 * 1000) {
        let scanOptions: ble.ScanOptions = {
            interval: 0,
            reportMode: ble.ScanReportMode.NORMAL
            // dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
            // matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
        }
        if (this.isScanning) {
            this.stopScan()
        }

        logd(`scanner start scan filter=${JSON.stringify(filter)}, timeout=${timeoutMills}`)
        clearTimeout(this.scanTimerId)
        this.scanTimerId = setTimeout(() => {
            logd("scan timeout")
            this.onScanTimeout()
            this.stopScan()
        }, timeoutMills)
        try {
            ble.on("BLEDeviceFind", (data) => {
                this.onReceiveEvent(data)
            })
            ble.startBLEScan(filter ?? null, scanOptions);
            logd('startBleScan success');
        } catch (err) {
            clearTimeout(this.scanTimerId)
            loge('errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
            this.onScanStartFail()
            return
        }
        this.isScanning = true
        this.onScanStarted()
        logd('start scan success');
    }


    public stopScan() {
        // stop scan
        this.isScanning = false
        clearTimeout(this.scanTimerId)
        ble.off("BLEDeviceFind", this.onReceiveEvent)
        ble.stopBLEScan()
        logd('stop scan success');
    }
}
