/********************************************************************************************************
 * @file SecureNetworkBeacon.java
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
import {
    ByteOrder,
    bytes2Integer,
    bytesEquals,
    bytesToHexString,
    num2bytes,
    num2Hex
} from "../../../utils/ArrayUtils";
import { aesCmac } from "../../../utils/Encipher";
import { logw } from "../../../utils/MeshLogger";
import { MeshBeaconPDU } from "./MeshBeaconPDU";

/**
 * This class represents a secure network beacon in a mesh network.
 */

const LENGTH_PAYLOAD = 22;

const MASK_KEY_REFRESH = 0b01;

const MASK_IV_UPDATE = 0b10;

export class SecureNetworkBeacon extends MeshBeaconPDU {
    protected beaconType = SecureNetworkBeacon.BEACON_TYPE_SECURE_NETWORK;
    /**
     * Contains the Key Refresh Flag and IV Update Flag
     */
    private flags = 0;
    /**
     * Contains the value of the Network ID
     * 8 bytes
     */
    private networkID = new Uint8Array(0);
    /**
     * Contains the current IV Index
     * 4 bytes
     * big endian
     */
    public ivIndex = 0;
    /**
     * Authenticates security network beacon
     * 8 bytes
     */
    private authenticationValue = new Uint8Array(0);

    /**
     * Returns whether the beacon is currently performing key refreshing.
     *
     * @return true if key refreshing is enabled, false otherwise.
     */
    public isKeyRefreshing(): boolean {
        return (this.flags & MASK_KEY_REFRESH) != 0;
    }

    /**
     * Returns whether the beacon is currently performing IV updating.
     *
     * @return true if IV updating is enabled, false otherwise.
     */
    public isIvUpdating(): boolean {
        return (this.flags & MASK_IV_UPDATE) != 0;
    }

    /**
     * Creates a SecureNetworkBeacon object from the given payload and beacon key.
     *
     * @param payload   the payload of the beacon.
     * @param beaconKey the beacon key used for authentication.
     * @return a SecureNetworkBeacon object if the payload is valid and authentication is successful, null otherwise.
     */
    public static from(payload: Uint8Array, beaconKey: Uint8Array): SecureNetworkBeacon | undefined {
        if (payload.length != LENGTH_PAYLOAD) {
            return undefined
        }
        let index = 0;
        const beaconType = payload[index++];
        if (beaconType != SecureNetworkBeacon.BEACON_TYPE_SECURE_NETWORK) {
            return undefined;
        }
        let beacon = new SecureNetworkBeacon();
        beacon.flags = payload[index++];
        beacon.networkID = payload.slice(index, index + 8)
        index += 8;
        beacon.ivIndex = bytes2Integer(payload, index, 4, ByteOrder.BIG_ENDIAN);
        index += 4;
        beacon.authenticationValue = payload.slice(index, index + 8)
        let authCal = SecureNetworkBeacon.generateAuthValue(beacon, beaconKey);
        if (bytesEquals(authCal, beacon.authenticationValue)) {
            return beacon;
        } else {
            logw("network beacon check err");
            return undefined;
        }
    }

    /**
     * Creates a SecureNetworkBeacon object for IV updating.
     *
     * @param curIvIndex the current IV index.
     * @param networkId  the network ID.
     * @param beaconKey  the beacon key used for authentication.
     * @param updating   true if IV updating is enabled, false otherwise.
     * @return a SecureNetworkBeacon object for IV updating.
     */
    public static createIvUpdatingBeacon(curIvIndex: number, networkId: Uint8Array, beaconKey: Uint8Array,
        updating: boolean): SecureNetworkBeacon {
        let networkBeacon = new SecureNetworkBeacon();
        networkBeacon.flags = (updating ? 0b10 : 0);
        networkBeacon.networkID = networkId;
        networkBeacon.ivIndex = updating ? curIvIndex + 1 : curIvIndex;
        networkBeacon.authenticationValue = SecureNetworkBeacon.generateAuthValue(networkBeacon, beaconKey);
        return networkBeacon;
    }


    /**
     * Generates the authentication value for the given SecureNetworkBeacon and beacon key.
     *
     * @param networkBeacon the SecureNetworkBeacon object.
     * @param beaconKey     the beacon key used for authentication.
     * @return the authentication value.
     */
    private static generateAuthValue(networkBeacon: SecureNetworkBeacon, beaconKey: Uint8Array): Uint8Array {
        const calLen = 1 + 8 + 4;
        let buffer = new Uint8Array(calLen)
        buffer[0] = networkBeacon.flags
        buffer.set(networkBeacon.networkID, 1);
        buffer.set(num2bytes(networkBeacon.ivIndex, 4, ByteOrder.BIG_ENDIAN), 1 + networkBeacon.networkID.length);
        let auth = aesCmac(buffer, beaconKey);
        let authCal = auth.slice(0, 8)
        return authCal;
    }


    /**
     * Converts the SecureNetworkBeacon object to a byte array.
     *
     * @return the byte array representation of the object.
     */
    public toBytes(): Uint8Array {
        let buf = new Uint8Array(LENGTH_PAYLOAD)
        let offset = 0
        buf[offset++] = this.beaconType
        buf[offset++] = this.flags
        buf.set(this.networkID, offset)
        offset += this.networkID.length
        buf.set(num2bytes(this.ivIndex, 4, ByteOrder.BIG_ENDIAN), offset)
        offset += 4
        buf.set(this.authenticationValue, offset)
        return buf
    }

    toString(): string {
        return `SecureNetworkBeacon{beaconType=${this.beaconType}, flags=${this.flags}, networkID=${bytesToHexString(this.networkID)}, ivIndex=0x${num2Hex(this.ivIndex,
            8)}, authValue=${bytesToHexString(this.authenticationValue)}`
    }
}
