/********************************************************************************************************
 * @file MeshConfiguration.ets
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
import { DeviceKey, MeshKey } from "../utils/MeshUtils";
import { ArrayList } from "@kit.ArkTS";
import { bytesToHexString } from "../utils/ArrayUtils";

/**
 * Mesh info use when provisioning/binding/auto connecting
 * NO variable can be NULL
 * Created by kee on 2019/9/6.
 */

export class MeshConfiguration {
    /**
     * network key index
     */
    public netKeyIndex = 0
    /**
     * network key
     */
    public networkKey = new Uint8Array(0);
    /**
     * appKeyIndex and appKey map
     */
    public appKeyMap: Array<MeshKey> = []
    /**
     * iv index
     */
    public ivIndex = 0
    /**
     * sequence number used in network pdu
     */
    public sequenceNumber = 0
    /**
     * provisioner address
     */
    public localAddress = 1
    /**
     * unicastAddress and deviceKey map, required for mesh configuration message
     */
    public deviceKeyMap: ArrayList<DeviceKey> = new ArrayList()
    /**
     * white list
     * should contains localAddress{@link #localAddress} and ADDRESS_BROADCAST {@link MeshUtils#ADDRESS_BROADCAST}
     */
    public proxyFilterWhiteList: Uint16Array = new Uint16Array(0)

    /**
     * get the default application key index
     *
     * @return
     */
    public getDefaultAppKeyIndex(): number {
        return this.appKeyMap.length > 0 ? this.appKeyMap[0].keyIndex : 0;
    }

    public getDefaultAppKey(): Uint8Array {
        return this.appKeyMap.length > 0 ? this.appKeyMap[0].key : new Uint8Array(16);
    }

    public addDeviceKey(unicastAddress: number, deviceKey: Uint8Array) {
        this.deviceKeyMap.add({ address: unicastAddress, key: deviceKey });
    }

    public removeDeviceKey(meshAddress: number): boolean {
        for (let devKey of this.deviceKeyMap) {
            if (devKey.address == meshAddress) {
                this.deviceKeyMap.remove(devKey)
                return true
            }
        }
        return false
    }

    public getAppKey(keyIndex: number) {
        for (let appKey of this.appKeyMap) {
            if (appKey.keyIndex == keyIndex) {
                return appKey.key
            }
        }
        return
    }

    public toString() {

        let netKeyDesc = `{ keyIndex=${this.netKeyIndex} , key=${bytesToHexString(this.networkKey)} }`
        let appKeyDesc = "{"
        for (let appKey of this.appKeyMap) {
            appKeyDesc += ` keyIndex=${appKey.keyIndex} , key=${bytesToHexString(appKey.key)} ,\n `
        }
        appKeyDesc += "}"
        let devKeyDesc = "{"
        for (let devKey of this.deviceKeyMap) {
            devKeyDesc += ` address=${devKey.address} , key=${bytesToHexString(devKey.key)} , \n`
        }
        devKeyDesc += "}"
        return `MeshConfiguration : ivIndex=${this.ivIndex} , sno=${this.sequenceNumber} , localAddress=${this.localAddress} , networkKey=${netKeyDesc} , appKeys=${appKeyDesc} , deviceKeys=${devKeyDesc} } `
    }
}
