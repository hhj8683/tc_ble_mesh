/********************************************************************************************************
 * @file     MeshPrivateBeacon.ets 
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
/********************************************************************************************************
 * @file MeshPrivateBeacon.ets
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
import { ByteOrder, bytes2Integer, bytesEquals, bytesToHexString, num2bytes } from "../../../utils/ArrayUtils";
import { aesEcb } from "../../../utils/Encipher";
import { logd, logw } from "../../../utils/MeshLogger";
import { generateRandom } from "../../../utils/MeshUtils";
import { MeshBeaconPDU }from "./MeshBeaconPDU";

/**
 * This class represents a Mesh Private Beacon, which is a type of Mesh Beacon PDU.
 * It extends the MeshBeaconPDU class.
 * <p>
 * The Mesh Private Beacon has a payload length of 27 bytes.
 */

const  LENGTH_PAYLOAD = 27;
const MASK_IV_UPDATE = 0b10;
const MASK_KEY_REFRESH = 0b01;
export class MeshPrivateBeacon extends MeshBeaconPDU {

    protected beaconType = MeshPrivateBeacon.BEACON_TYPE_MESH_PRIVATE;

    private  flags = 0;

    public ivIndex = 0;

    /**
     * 13 bytes
     * Random number used as an entropy for obfuscation and authentication of the Mesh Private beacon
     */
    private random = new Uint8Array(0);

    /**
     * 5 bytes
     * Obfuscated Private Beacon Data
     */
    private  obfuscatedData: Uint8Array= new Uint8Array(0)

    /**
     * 8 bytes
     * Authentication tag for the beacon
     */
    private  authenticationTag: Uint8Array= new Uint8Array(0)

    /**
     * Creates a MeshPrivateBeacon object from the given payload and private beacon key.
     *
     * @param payload          The payload of the Mesh Private Beacon.
     * @param privateBeaconKey The private beacon key used for authentication.
     * @return The MeshPrivateBeacon object if the payload is valid, null otherwise.
     */
    public static  from(payload: Uint8Array,  privateBeaconKey: Uint8Array):MeshPrivateBeacon|undefined {
        if (payload.length != LENGTH_PAYLOAD) {
            return undefined;
        }
        let index = 0;
        let beaconType = payload[index++];
        if (beaconType != MeshPrivateBeacon.BEACON_TYPE_MESH_PRIVATE) return undefined;
        let beacon = new MeshPrivateBeacon();

        let rdnLen = 13;
        let random = payload.slice(index, rdnLen + index)
        index += rdnLen;

        beacon.random = random;
        let obfLen = 5;
        beacon.obfuscatedData = payload.slice(index, index + obfLen)
        index += obfLen;

        let authLen = 8;
        beacon.authenticationTag = payload.slice(index, index + authLen)

        let c1 = new Uint8Array(16)
        c1[0] = 0x01
        c1.set(random, 1)
        c1.set(new Uint8Array([0x00, 0x01]), 1 + random.length)

        let s = aesEcb(c1, privateBeaconKey);
        let privateBeaconData = new Uint8Array(5)
        for (let i = 0; i < privateBeaconData.length; i++) {
            privateBeaconData[i] = s[i] ^ beacon.obfuscatedData[i]
        }

        beacon.flags = privateBeaconData[0];
        beacon.ivIndex = bytes2Integer(privateBeaconData, 1, 4, ByteOrder.BIG_ENDIAN);

        let authTag = MeshPrivateBeacon.calcAuthTag(privateBeaconData, random, privateBeaconKey);

        if (bytesEquals(beacon.authenticationTag, authTag)) {
            return beacon;
        } else {
            logw("private beacon auth tag check err");
            return undefined;
        }
    }

    /**
     * Creates a MeshPrivateBeacon object for an IV updating beacon.
     *
     * @param curIvIndex       The current IV index.
     * @param privateBeaconKey The private beacon key used for authentication.
     * @param updating         True if the IV is updating, false otherwise.
     * @return The MeshPrivateBeacon object.
     */
    public static  createIvUpdatingBeacon(curIvIndex: number, privateBeaconKey: Uint8Array, updating: boolean):MeshPrivateBeacon {
        let meshPrivateBeacon = new MeshPrivateBeacon();

        let flags = updating ? 0b10 : 0
        meshPrivateBeacon.flags = flags;
        let ivIndex = updating ? curIvIndex + 1 : curIvIndex;
        meshPrivateBeacon.ivIndex = ivIndex;
        let privateBcnData = new Uint8Array(5)
        privateBcnData[0] = flags
        privateBcnData.set(num2bytes(ivIndex, 4, ByteOrder.BIG_ENDIAN), 1)
        logd("beacon data: " + bytesToHexString(privateBcnData));
        let random = generateRandom(13);

        let authTag = MeshPrivateBeacon.calcAuthTag(privateBcnData, random, privateBeaconKey);
        logd("authTag: " + bytesToHexString(authTag));
        let c1 = new Uint8Array(16)
        c1[0] = 0x01
        c1.set(random, 1)
        c1.set(new Uint8Array([0x00, 0x01]), 1 + random.length)

        /*
         S = e (PrivateBeaconKey, C1)
         */
        let s = aesEcb(c1, privateBeaconKey);

        /*
        Obfuscated_Private_Beacon_Data = (S [0-4]) ⊕ (Private Beacon Data)
         */
        let obfData = new Uint8Array(5);
        for (let i = 0; i < obfData.length; i++) {
            obfData[i] =s[i] ^ privateBcnData[i]
        }

        meshPrivateBeacon.random = random;
        meshPrivateBeacon.obfuscatedData = obfData;
        meshPrivateBeacon.authenticationTag = authTag;
        return meshPrivateBeacon;
    }

    /**
     * Calculates the authentication tag for the private beacon data.
     *
     * @param privateBeaconData The private beacon data.
     * @param random            The random number.
     * @param privateBeaconKey  The private beacon key.
     * @return The authentication tag.
     */
    private static  calcAuthTag(privateBeaconData: Uint8Array,  random: Uint8Array, privateBeaconKey: Uint8Array): Uint8Array {

        /*
        B0 = 0x19 || Random || 0x0005
        C0 = 0x01 || Random || 0x0000
        C1 = 0x01 || Random || 0x0001
        P = Private Beacon Data || 0x0000000000000000000000 (11-octets of Zero padding)
         */

        let b0 = new Uint8Array(16)
        b0[0] = 0x19
        b0.set(random, 1)
        b0.set([0x00, 0x05], random.length + 1)


        let c0 = new Uint8Array(16)
        c0[0] = 0x01
        b0.set(random, 1)
        b0.set([0x00, 0x00], random.length + 1)


        let p = new Uint8Array(16)
        p.set(privateBeaconData, 0)
        let t0 = aesEcb(b0, privateBeaconKey);
        let t1Input = new Uint8Array(t0.length)
        for (let i = 0; i < t0.length; i++) {
            t1Input[i] = t0[i] ^ p[i]
        }

        let t1 = aesEcb(t1Input, privateBeaconKey);

        let c0Enc = aesEcb(c0, privateBeaconKey);
        let t2 = new Uint8Array(t1.length)
        for (let i = 0; i < t1.length; i++) {
            t2[i] = t1[i] ^ c0Enc[i]
        }

        let authTag = t2.slice(0, 8)
        return authTag;
    }


    /**
     * Converts the MeshPrivateBeacon object to a byte array.
     *
     * @return The byte array representation of the MeshPrivateBeacon object.
     */
    public toBytes() : Uint8Array{
        let buffer1 = new Uint8Array(LENGTH_PAYLOAD)
        let offset = 0
        buffer1[offset] = this.beaconType
        offset +=1
        buffer1.set(this.random, offset)
        offset +=this.random.length

        buffer1.set(this.obfuscatedData, offset)
        offset += this.obfuscatedData.length

        buffer1.set(this.authenticationTag, offset)

        return buffer1
    }


    /**
     * Checks if the MeshPrivateBeacon is an IV updating beacon.
     *
     * @return True if the beacon is an IV updating beacon, false otherwise.
     */
    public  isIvUpdating(): boolean {
        return (this.flags & MASK_IV_UPDATE) != 0;
    }
}

