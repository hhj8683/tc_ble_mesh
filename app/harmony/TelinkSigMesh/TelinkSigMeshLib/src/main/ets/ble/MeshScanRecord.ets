/********************************************************************************************************
 * @file MeshScanRecord.java
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

import { logw } from "../utils/MeshLogger";
import { SERVICE_PROVISION, SERVICE_PROXY } from "./UuidInfo";


const TAG = "mesh_scan_record"

// 参考蓝牙标准协议规范Core Assigned Numbers
const BLE_ADV_TYPE_FLAG = 0x01;
const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE = 0x02;
const BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE = 0x03;
const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE = 0x04;
const BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE = 0x05;
const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE = 0x06;
const BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE = 0x07;
const BLE_ADV_TYPE_LOCAL_NAME_SHORT = 0x08;
const BLE_ADV_TYPE_LOCAL_NAME_COMPLETE = 0x09;
const BLE_ADV_TYPE_TX_POWER_LEVEL = 0x0A;
const BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS = 0x14;
const BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS = 0x15;
const BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS = 0x1F;
const BLE_ADV_TYPE_16_BIT_SERVICE_DATA = 0x16;
const BLE_ADV_TYPE_32_BIT_SERVICE_DATA = 0x20;
const BLE_ADV_TYPE_128_BIT_SERVICE_DATA = 0x21;
const BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA = 0xFF;

const BLUETOOTH_UUID_16_BIT_LENGTH = 2;
const BLUETOOTH_UUID_32_BIT_LENGTH = 4;
const BLUETOOTH_UUID_128_BIT_LENGTH = 16;

const BLUETOOTH_MANUFACTURE_ID_LENGTH = 2;

export class MeshScanRecord {
    public advertiseFlags: number = -1;
    public txPowerLevel: number = -1;
    public localName: string = '';
    public serviceUuids: string[] = [];
    public serviceSolicitationUuids: string[] = [];
    public manufactureSpecificDatas: Record<number, Uint8Array> = {};
    public serviceDatas: Record<string, Uint8Array> = {};

    /**
     * Returns the manufacturer specific data associated with the manufacturer id. Returns
     * {@code null} if the {@code manufacturerId} is not found.
     */
    public getManufacturerSpecificData(manufacturerId: number): Uint8Array {
        return this.manufactureSpecificDatas[manufacturerId]
    }


    /**
     * Returns the service data byte array associated with the {@code serviceUuid}. Returns
     * {@code null} if the {@code serviceDataUuid} is not found.
     */
    public getServiceData(serviceUuid: string): Uint8Array {
        return this.serviceDatas[serviceUuid]
    }

    public getProvServiceData() {
        return this.getServiceData(SERVICE_PROVISION);
    }

    public getProxyServiceData() {
        return this.getServiceData(SERVICE_PROXY);
    }


    public static parseFromBytes(scanRecord: ArrayBuffer): MeshScanRecord | undefined {

        let curPos = 0;

        let advData = new Uint8Array(scanRecord);
        if (advData.byteLength == 0) {
            logw('adv data length is 0');
            return undefined;
        }
        let record: MeshScanRecord = new MeshScanRecord()

        while (curPos < advData.byteLength) {
            let length = advData[curPos++]; // 获取当前广播类型的长度（length+data），curPos指向下一个位置
            if (length == 0) {
                break;
            }

            // 获取当前广播类型内容长度（data）
            let advDataLength = length - 1;

            // 获取当前广播类型，curPos指向下一个位置，从该位置解析实际内容，参考Core Specification Supplement, PartA
            let advDataType = advData[curPos++];
            switch (advDataType) {
                case BLE_ADV_TYPE_FLAG:
                    record.advertiseFlags = advData[curPos];
                    break;
                case BLE_ADV_TYPE_LOCAL_NAME_SHORT:
                case BLE_ADV_TYPE_LOCAL_NAME_COMPLETE:
                    record.localName = advData.slice(curPos, curPos + advDataLength).toString();
                    break;
                case BLE_ADV_TYPE_TX_POWER_LEVEL:
                    record.txPowerLevel = advData[curPos];
                    break;
                case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_INCOMPLETE:
                case BLE_ADV_TYPE_16_BIT_SERVICE_UUIDS_COMPLETE:
                    MeshScanRecord.parseServiceUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceUuids);
                    break;
                case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_INCOMPLETE:
                case BLE_ADV_TYPE_32_BIT_SERVICE_UUIDS_COMPLETE:
                    MeshScanRecord.parseServiceUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceUuids);
                    break;
                case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_INCOMPLETE:
                case BLE_ADV_TYPE_128_BIT_SERVICE_UUIDS_COMPLETE:
                    MeshScanRecord.parseServiceUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceUuids);
                    break;
                case BLE_ADV_TYPE_16_BIT_SERVICE_SOLICITATION_UUIDS:
                    MeshScanRecord.parseServiceSolicitationUuid(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength,
                        advData, record.serviceSolicitationUuids);
                    break;
                case BLE_ADV_TYPE_32_BIT_SERVICE_SOLICITATION_UUIDS:
                    MeshScanRecord.parseServiceSolicitationUuid(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength,
                        advData, record.serviceSolicitationUuids);
                    break;
                case BLE_ADV_TYPE_128_BIT_SERVICE_SOLICITATION_UUIDS:
                    MeshScanRecord.parseServiceSolicitationUuid(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength,
                        advData, record.serviceSolicitationUuids);
                    break;
                case BLE_ADV_TYPE_16_BIT_SERVICE_DATA:
                    MeshScanRecord.parseServiceData(BLUETOOTH_UUID_16_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceDatas);
                    break;
                case BLE_ADV_TYPE_32_BIT_SERVICE_DATA:
                    MeshScanRecord.parseServiceData(BLUETOOTH_UUID_32_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceDatas);
                    break;
                case BLE_ADV_TYPE_128_BIT_SERVICE_DATA:
                    MeshScanRecord.parseServiceData(BLUETOOTH_UUID_128_BIT_LENGTH, curPos, advDataLength, advData,
                        record.serviceDatas);
                    break;
                case BLE_ADV_TYPE_MANUFACTURER_SPECIFIC_DATA:
                    MeshScanRecord.parseManufactureData(curPos, advDataLength, advData,
                        record.manufactureSpecificDatas);
                    break;
                default:
                    break;
            }
            curPos += advDataLength; // curPos指向下一个字段类型
        }
        // console.info(TAG, 'advertiseFlags: ' + record.advertiseFlags);
        // console.info(TAG, 'txPowerLevel: ' + record.txPowerLevel);
        // console.info(TAG, 'localName: ' + record.localName);
        // console.info(TAG, 'serviceUuids: ' + JSON.stringify(record.serviceUuids));
        // console.info(TAG, 'serviceSolicitationUuids: ' + JSON.stringify(record.serviceSolicitationUuids));
        // console.info(TAG, 'manufactureSpecificDatas: ' + JSON.stringify(record.manufactureSpecificDatas));
        // console.info(TAG, 'serviceDatas: ' + JSON.stringify(record.serviceDatas));

        return record
    }


    private static parseServiceUuid(uuidLength: number, curPos: number, advDataLength: number,
        advData: Uint8Array, serviceUuids: string[]) {
        while (advDataLength > 0) {
            let tmpData: Uint8Array = advData.slice(curPos, curPos + uuidLength);
            serviceUuids.push(MeshScanRecord.getUuidFromUint8Array(uuidLength, tmpData));
            advDataLength -= uuidLength;
            curPos += uuidLength;
        }
    }

    private static parseServiceSolicitationUuid(uuidLength: number, curPos: number, advDataLength: number,
        advData: Uint8Array, serviceSolicitationUuids: string[]) {
        while (advDataLength > 0) {
            let tmpData: Uint8Array = advData.slice(curPos, curPos + uuidLength);
            serviceSolicitationUuids.push(MeshScanRecord.getUuidFromUint8Array(uuidLength, tmpData));
            advDataLength -= uuidLength;
            curPos += uuidLength;
        }
    }

    private static getUuidFromUint8Array(uuidLength: number, uuidData: Uint8Array): string {
        let uuid = "";
        let temp: string = "";
        for (let i = uuidLength - 1; i > -1; i--) {
            temp += uuidData[i].toString(16).padStart(2, "0");
        }
        switch (uuidLength) {
            case BLUETOOTH_UUID_16_BIT_LENGTH:
                uuid = `0000${temp}-0000-1000-8000-00805F9B34FB`;
                break;
            case BLUETOOTH_UUID_32_BIT_LENGTH:
                uuid = `${temp}-0000-1000-8000-00805F9B34FB`;
                break;
            case BLUETOOTH_UUID_128_BIT_LENGTH:
                uuid = `${temp.substring(0, 8)}-${temp.substring(8, 12)}-${temp.substring(12, 16)}-${temp.substring(16,
                    20)}-${temp.substring(20, 32)}`;
                break;
            default:
                break;
        }
        return uuid;
    }

    private static parseServiceData(uuidLength: number, curPos: number, advDataLength: number,
        advData: Uint8Array, serviceDatas: Record<number, Uint8Array>) {
        let uuid: Uint8Array = advData.slice(curPos, curPos + uuidLength);
        let data: Uint8Array = advData.slice(curPos + uuidLength, curPos + advDataLength);
        serviceDatas[MeshScanRecord.getUuidFromUint8Array(uuidLength, uuid)] = data;
    }

    private static parseManufactureData(curPos: number, advDataLength: number,
        advData: Uint8Array, manufactureSpecificDatas: Record<number, Uint8Array>) {
        let manufactureId: number = (advData[curPos + 1] << 8) + advData[curPos];
        let data: Uint8Array = advData.slice(curPos + BLUETOOTH_MANUFACTURE_ID_LENGTH, curPos + advDataLength);
        manufactureSpecificDatas[manufactureId] = data;
    }
}
