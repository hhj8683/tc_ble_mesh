/********************************************************************************************************
 * @file     GattConnection.ets 
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
import { ble, constant } from "@kit.ConnectivityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { JSON } from "@kit.ArkTS";
import { bufferToHex, bytesToHex, UUID_OTA_SERVICE, UUID_VERSION_SERVICE } from "../../../../Index";
import {
    CHARACTERISTIC_ONLINE_STATUS,
    CHARACTERISTIC_PB_IN,
    CHARACTERISTIC_PB_OUT,
    CHARACTERISTIC_PROXY_IN,
    CHARACTERISTIC_PROXY_OUT,
    DESCRIPTOR_CFG_UUID,
    SERVICE_MESH_FLEX,
    SERVICE_ONLINE_STATUS,
    SERVICE_PROVISION,
    SERVICE_PROXY
} from "./UuidInfo";
import { logd, loge, logi, logw } from "../utils/MeshLogger";
import { ProxyPDU } from "../core/proxy/ProxyPDU";
import { bytesToHexString } from "../utils/ArrayUtils";

const TAG: string = 'GattConnection';
const MTU_MAX = 517

export class GattConnection {
    private connectionCallback: (state: ble.ProfileConnectionState) => void
    private gattNotifyCallback?: (serviceUuid: string, characteristicUuid: string, data: Uint8Array) => void
    private deviceId?: string
    private gattClient?: ble.GattClientDevice
    private connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED
    public services: Array<ble.GattService> = []
    public static mtu: number = 23

    constructor(connectionCb: (state: ble.ProfileConnectionState) => void
        , gattNotifyCallback?: (serviceUuid: string, characteristicUuid: string, data: Uint8Array) => void) {
        this.connectionCallback = connectionCb
        this.gattNotifyCallback = gattNotifyCallback
    }

    getDeviceId() {
        return this.deviceId
    }

    private onConnectStateChanged = (state: ble.BLEConnectionChangeState) => {
        this.updateConnectionState(state.state)
    }
    private onMtuChanged = (mtu: number) => {
        logd("mtu changed to : " + mtu)
        GattConnection.mtu = mtu
    }

    private updateConnectionState(state: ble.ProfileConnectionState) {
        logi(`update connection state , ${GattConnection.getConnectionStateDesc(state)}`);
        this.connectState = state

        if (this.isConnected()) {
            this.discoverServices()
        } else {
            if (this.isDisconnected()) {
                this.clearClient()
                this.gattClient = undefined
            }
            if (this.connectionCallback) {
                this.connectionCallback(state)
            }

        }
    }

    private onCharacteristicChange = (char: ble.BLECharacteristic) => {
        let data: Uint8Array = new Uint8Array(char.characteristicValue)
        logi(`onNotify: value=${bytesToHexString(data)} , characteristicUuid=${char.characteristicUuid}`);
        if (this.gattNotifyCallback) {
            this.gattNotifyCallback(char.serviceUuid, char.characteristicUuid, data)
        }
    }

    isConnected(): boolean {
        return this.connectState == constant.ProfileConnectionState.STATE_CONNECTED
    }

    isDisconnected(): boolean {
        return this.connectState == constant.ProfileConnectionState.STATE_DISCONNECTED
    }

    disconnect(): boolean {
        if (this.connectState == constant.ProfileConnectionState.STATE_DISCONNECTED) {
            return false;
        }
        if (this.gattClient) {
            if (this.connectState == constant.ProfileConnectionState.STATE_CONNECTED) {
                this.connectState = constant.ProfileConnectionState.STATE_DISCONNECTING;
                try {
                    this.gattClient.disconnect();
                } catch (err) {
                    loge(TAG,
                        'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
                }
                // this.startDisconnectionCheck();
                return true
            } else if (this.connectState == constant.ProfileConnectionState.STATE_CONNECTING) {
                this.gattClient.disconnect();
                this.gattClient.close();
                this.connectState = constant.ProfileConnectionState.STATE_DISCONNECTED;
                return false;
            }
        } else {
            this.connectState = constant.ProfileConnectionState.STATE_DISCONNECTED;
            return false;
        }
        return true
    }

    disconnectAndClear() {
        if (this.gattClient) {
            try {
                this.gattClient.disconnect();
                this.gattClient.off('BLEConnectionStateChange', this.onConnectStateChanged);
                this.gattClient.off('BLECharacteristicChange', this.onCharacteristicChange);
                this.gattClient.off("BLEMtuChange", this.onMtuChanged)
                this.gattClient.close()
            } catch (err) {
                loge(TAG,
                    'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
            }
        }
    }

    clearClient() {
        if (this.gattClient) {
            try {
                this.gattClient.off('BLEConnectionStateChange', this.onConnectStateChanged);
                this.gattClient.off('BLECharacteristicChange', this.onCharacteristicChange);
                this.gattClient.off("BLEMtuChange", this.onMtuChanged)
                this.gattClient.close()
            } catch (err) {
                loge(TAG,
                    'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);
            }
        }
    }

    connect(deviceId: string) {
        logd("GattController#connect")
        if (this.gattClient) {
            this.clearClient()
        }
        if (this.deviceId && this.gattClient && this.deviceId != deviceId) {
            this.gattClient.disconnect()
        }

        this.deviceId = deviceId;
        this.gattClient = ble.createGattClientDevice(deviceId);
        this.gattClient.on("BLEConnectionStateChange", this.onConnectStateChanged)
        this.gattClient.on('BLECharacteristicChange', this.onCharacteristicChange);
        this.gattClient.on("BLEMtuChange", this.onMtuChanged)
        try {
            this.gattClient.connect()
        } catch (err) {
            loge('errCode: ' + (err as BusinessError).code + ', errMessage: ' +
            (err as BusinessError).message);
        }
    }


    /**
     * @param type proxy pdu type
     * @param data data excluding type
     */
    public async sendMeshData(type: number, data: Uint8Array) {
        // opcode: 1 byte, handle: 2 bytes
        let segMtu = GattConnection.mtu - 3;
        let isProvisioningPdu = type == ProxyPDU.TYPE_PROVISIONING_PDU;
        if (data.length > segMtu - 1) {
            let pktNum = Math.ceil((data.length) / (segMtu - 1));
            let oct0: number;
            let pkt: Uint8Array;
            for (let i = 0; i < pktNum; i++) {
                if (i != pktNum - 1) {
                    if (i == 0) {
                        oct0 = (ProxyPDU.SAR_SEG_FIRST | type);
                    } else {
                        oct0 = (ProxyPDU.SAR_SEG_CONTINUE | type);
                    }
                    pkt = new Uint8Array(segMtu)
                    pkt[0] = oct0;
                    pkt.set(data.slice((segMtu - 1) * i, (segMtu - 1) * (i + 1)), 1)
                } else {
                    oct0 = (ProxyPDU.SAR_SEG_LAST | type);
                    let restSize = data.length - (segMtu - 1) * i;
                    pkt = new Uint8Array(restSize + 1)
                    pkt[0] = oct0;
                    pkt.set(data.slice((segMtu - 1) * i, (segMtu - 1) * i + restSize), 1)
                }
                logd("send segment pkt: " + bytesToHexString(pkt));
                if (isProvisioningPdu) {
                    await this.sendPvRequest(pkt);
                } else {
                    await this.sendProxyRequest(pkt);
                }
            }
        } else {
            let proxyData = new Uint8Array(data.length + 1)
            proxyData[0] = type;
            proxyData.set(data, 1)
            logd("send unsegment pkt: " + bytesToHexString(proxyData));
            if (isProvisioningPdu) {
                await this.sendPvRequest(proxyData);
            } else {
                await this.sendProxyRequest(proxyData);
            }
        }
    }


    private async sendPvRequest(data: Uint8Array) {

        let service = this.getProvisionService();
        if (!service) {
            return;
        }
        await this.writeCharacteristic(service.serviceUuid, CHARACTERISTIC_PB_IN, data)

    }

    private async sendProxyRequest(data: Uint8Array) {
        // await this.sendPvRequest(data)
        // return


        let service = this.getProxyService(false);
        if (!service) {
            return;
        }
        await this.writeCharacteristic(service.serviceUuid, CHARACTERISTIC_PROXY_IN, data)
    }

    public async proxyInit() {
        await this.enableProxyNotify();
    }

    public async provisionInit() {
        await this.enableProvisionNotify();
        await this.enableProxyNotify();
    }


    // 27 18
    public async enableProvisionNotify() {
        let provisionService = this.getProvisionService();
        if (provisionService == null) {
            logw("provision service not found");
            return;
        }
        logd("enable provision notify");
        await this.enableNotify(provisionService.serviceUuid, CHARACTERISTIC_PB_OUT)
        logd("write ccc to provision service");
        await this.writeDescriptor(provisionService.serviceUuid, CHARACTERISTIC_PB_OUT, DESCRIPTOR_CFG_UUID,
            new Uint8Array([0x01, 0x00]))
    }

    // 28 18
    public async enableProxyNotify() {
        let proxyService = this.getProxyService(false);
        if (proxyService == null) {
            logd("proxy service not found");
            return;
        }
        logd("enable proxy notify");
        await this.enableNotify(proxyService.serviceUuid, CHARACTERISTIC_PROXY_OUT)


        logd("write ccc to proxy service");

        await this.writeDescriptor(proxyService.serviceUuid, CHARACTERISTIC_PROXY_OUT, DESCRIPTOR_CFG_UUID,
            new Uint8Array([0x01, 0x00]))
    }


    public async enableOnlineStatus() {
        if (!this.checkOnlineStatusService()) {
            return;
        }
        await this.enableNotify(SERVICE_ONLINE_STATUS, CHARACTERISTIC_ONLINE_STATUS)
        // this.writeCharacteristic(SERVICE_ONLINE_STATUS, CHARACTERISTIC_ONLINE_STATUS, new Uint8Array([0x01]))
    }

    private getProvisionService(): ble.GattService | undefined {

        for (let service of
        this.services) {
            if (service.serviceUuid == SERVICE_PROVISION || service.serviceUuid == SERVICE_MESH_FLEX) {
                for (let characteristic of service.characteristics) {
                    if (characteristic.characteristicUuid == CHARACTERISTIC_PB_IN) {
                        return service;
                    }
                }
            }
        }
        return undefined;
    }


    public async getOnlineStatus(): Promise<boolean> {
        if (!this.isConnected()) {
            return false;
        }
        if (!this.checkOnlineStatusService()) {
            return false;
        }
        await this.writeCharacteristic(SERVICE_ONLINE_STATUS, CHARACTERISTIC_ONLINE_STATUS, new Uint8Array([0x01]))
        return true;
    }

    private checkOnlineStatusService(): boolean {
        if (this.services.length == 0) {
            return false;
        }
        for (let service of this.services) {
            if (service.serviceUuid == SERVICE_ONLINE_STATUS) {
                for (let characteristic of service.characteristics) {
                    if (characteristic.characteristicUuid == CHARACTERISTIC_ONLINE_STATUS) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public async discoverServices() {
        logi('discoverServices');
        try {
            if (!this.gattClient) {
                logw("discover service error : gatt client not init")
                return;
            }
            this.services = await this.gattClient.getServices();
            this.printServices(this.services)
            if (this.services.length != 0) {
                if (this.connectionCallback) {
                    this.connectionCallback(constant.ProfileConnectionState.STATE_CONNECTED)
                }
            }
            this.setMtu(MTU_MAX)
            // logd("services : ", JSON.stringify(this.services))
        } catch (err) {
            loge(TAG,
                'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message);

        }
    }

    private printServices(services: ble.GattService[]) {
        logd("services count : " + services.length)
        services.forEach((service) => {
            logd("service : ", service.serviceUuid)
            service.characteristics.forEach((characteristic) => {
                logd(" characteristic : ", characteristic.characteristicUuid)
                characteristic.descriptors.forEach((descriptor) => {
                    logd("   descriptor : ", descriptor.descriptorUuid)
                })
            })
        })
    }

    public isProxyNodeConnected(): boolean {
        return this.checkProxyConnection(false);
    }

    /**
     * @return proxy node connected
     */
    public checkProxyConnection(real: boolean): boolean {
        if (this.isConnected()) {
            return this.getProxyService(real) != null;
        }
        return false;
    }

    /**
     * @param real true: only check PROXY_SERVICE_UUID,
     *             false: check PROXY_SERVICE_UUID and MESH_FLEX_SERVICE_UUID
     */
    private getProxyService(real: boolean): ble.GattService | undefined {
        let services = this.services;
        for (let service of services) {
            if ((service.serviceUuid == SERVICE_PROXY)
                || (!real && service.serviceUuid == SERVICE_MESH_FLEX)) {
                for (let characteristic of service.characteristics) {
                    if (characteristic.characteristicUuid == CHARACTERISTIC_PROXY_IN) {
                        return service;
                    }
                }
            }
        }
        return undefined;
    }

    async enableNotify(serviceUuid: string, charUuid: string, enable: boolean = true): Promise<boolean> {
        let characteristic = this.findCharacteristic(serviceUuid, charUuid)
        if (!characteristic) {
            logd("enableNotify error : characteristic not found")
            return false
        }

        try {
            if (!this.gattClient) {
                logw("enable notify error : gatt client not init")
                return false;
            }
            await this.gattClient.setCharacteristicChangeNotification(characteristic, enable);
            logi("enableNotify success")
            return true
        } catch (err) {
            loge('errCode: ' + err.code + ', errMessage: ' + err.message);
            return false
        }
    }

    async writeCharacteristic(serviceUuid: string, charUuid: string, data: Uint8Array
        , writeType: ble.GattWriteType = ble.GattWriteType.WRITE_NO_RESPONSE): Promise<boolean> {
        logd(`write characteristic :  data=${bytesToHexString(data)} , serviceUuid=${serviceUuid} charUuid=${charUuid}`)
        let char = this.findCharacteristic(serviceUuid, charUuid)
        if (!char) {
            loge("write characteristic error : characteristic not found")
            return false
        }

        let writeChar: ble.BLECharacteristic = {
            serviceUuid: serviceUuid,
            characteristicUuid: charUuid,
            characteristicValue: data.buffer,
            descriptors: char.descriptors
        }
        try {
            if (!this.gattClient) {
                logw("write characteristic error : gatt client not init")
                return false;
            }
            await this.gattClient.writeCharacteristicValue(writeChar, writeType)
            logi("write characteristic success : " + bytesToHex(data))
            return true
        } catch (e) {
            loge('writeCharacteristic error : ' + e.code + ', errMessage: ' + e.message);
            return false
        }
    }


    async readCharacteristic(serviceUuid: string, charUuid: string): Promise<Uint8Array | undefined> {
        let char = this.findCharacteristic(serviceUuid, charUuid)
        if (!char) {
            loge("readCharacteristic error : characteristic not found")
            return undefined
        }

        try {
            if (!this.gattClient) {
                logw("read characteristic error : gatt client not init")
                return;
            }
            let bleChar = await this.gattClient.readCharacteristicValue(char)
            logi("readCharacteristic success : ", bufferToHex(bleChar.characteristicValue))
            return new Uint8Array(bleChar.characteristicValue)
        } catch (e) {
            loge('readCharacteristic error : ' + e.code + ', errMessage: ' + e.message);
            return undefined
        }

        // let outData: ble.BLECharacteristic = await this.gattClient.readCharacteristicValue(char)
    }

    async writeDescriptor(serviceUuid: string, characteristicUuid: string, descriptorUuid: string,
        data: Uint8Array): Promise<boolean> {
        const char = this.findCharacteristic(serviceUuid, characteristicUuid)
        if (!char) {
            loge("writeDescriptor error : characteristic not found")
            return false
        }

        const descriptor = this.findDescriptor(char, descriptorUuid)
        if (!descriptor) {
            loge("writeDescriptor error : descriptor not found")
            return false
        }

        let writeDesc: ble.BLEDescriptor = {
            serviceUuid: serviceUuid,
            characteristicUuid: characteristicUuid,
            descriptorUuid: descriptorUuid,
            descriptorValue: data.buffer
        }

        try {
            if (!this.gattClient) {
                logw("write descriptor error : gatt client not init")
                return false;
            }
            await this.gattClient.writeDescriptorValue(writeDesc);
            logi('writeDescriptor success')
            return true
        } catch (e) {
            loge('writeDescriptor error : ' + e.code + ', errMessage: ' + e.message);
            return false
        }
    }

    setMtu(mtu: number): boolean {
        try {
            if (!this.gattClient) {
                logw("set mtu error : gatt client not init")
                return false;
            }
            this.gattClient.setBLEMtuSize(mtu)
            logi("setMtu success")
            return true
        } catch (e) {
            loge('setMtu error : ' + e.code + ', errMessage: ' + e.message)
            return false
        }
    }

    getMtu(): number {
        return GattConnection.mtu
    }


    findService(serviceUuid: string): ble.GattService | undefined {
        return this.services.find(ele => ele.serviceUuid == serviceUuid)
    }

    findCharacteristic(serviceUuid: string, charUuid: string): ble.BLECharacteristic | undefined {
        let service = this.services.find(ele => ele.serviceUuid == serviceUuid)
        if (service) {
            let bleChar = service.characteristics.find((char) => {
                return char.characteristicUuid == charUuid
            })
            return bleChar
        }
        return undefined
    }

    findDescriptor(characteristic: ble.BLECharacteristic, descriptorUuid: string): ble.BLEDescriptor | undefined {
        return characteristic.descriptors.find((desc) => {
            return desc.descriptorUuid == descriptorUuid
        })
    }


    static getConnectionStateDesc(state: constant.ProfileConnectionState) {
        switch (state) {
            case constant.ProfileConnectionState.STATE_DISCONNECTED:
                return "disconnected"

            case constant.ProfileConnectionState.STATE_CONNECTING:
                return "connecting"

            case constant.ProfileConnectionState.STATE_CONNECTED:
                return "connected"

            case constant.ProfileConnectionState.STATE_DISCONNECTING:
                return "disconnecting"
        }
    }
}

