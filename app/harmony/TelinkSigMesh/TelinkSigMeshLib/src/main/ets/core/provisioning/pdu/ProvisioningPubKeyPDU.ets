/********************************************************************************************************
 * @file ProvisioningPubKeyPDU.java
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
import { ProvisioningPDU } from './ProvisioningPDU';
import { ProvisioningStatePDU } from './ProvisioningStatePDU';


const LEN = 64;

/**
 * provision public key PDU
 * Created by kee on 2019/7/18.
 */
export class ProvisioningPubKeyPDU implements ProvisioningStatePDU {
    // 32 bytes
    /**
     * X
     */
    public x: Uint8Array | undefined
    /**
     * Y
     */
    public y: Uint8Array | undefined
    /**
     * raw data
     */
    private rawData: Uint8Array | undefined

    /**
     * takes in a byte array as input and returns a ProvisioningPubKeyPDU object.
     *
     * @param data key data
     * @return PDU
     */
    public static fromBytes(data: Uint8Array): ProvisioningPubKeyPDU | undefined {
        if (data.length != LEN) {
            return undefined;
        }
        // 4816e37c215bb362e3140cd9cf25b68c73befc95b8e5c52dd4e1e47e13090eb41f26cb7e0477423dca1ce7c70521efee1e9be8f85db8160db0549b8da1171dcd
        let pubKeyPDU = new ProvisioningPubKeyPDU();
        pubKeyPDU.rawData = data;
        pubKeyPDU.x = data.slice(0, 32)
        pubKeyPDU.y = data.slice(32, 64)
        return pubKeyPDU;
    }

    /**
     * Converts the PDU to a byte array.
     *
     * @return The byte array representation of the PDU.
     */
    public toBytes() {
        if (this.rawData) {
            return this.rawData;
        }
        if (this.x == null || this.y == null) {
            return undefined;
        }
        let re = new Uint8Array(LEN);

        re.set(this.x, 0)
        re.set(this.y, 32)
        return re;
    }

    /**
     * Gets the state of the PDU.
     *
     * @return The state of the PDU.
     */
    public getState() {
        return ProvisioningPDU.TYPE_PUBLIC_KEY;
    }
}
