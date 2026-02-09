/********************************************************************************************************
 * @file     Encipher.ets 
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
 * @file Encipher.ets
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
import { ByteOrder, bytesToHexString, hexToBytes, num2bytes, string2Array } from './ArrayUtils';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { cert } from '@kit.DeviceCertificateKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { logd, loge } from './MeshLogger';
import { ccmAesDecrypt, ccmAesEncrypt } from './Ccm_c';

/**
 * Created by kee on 2019/7/19.
 */

const SALT_INPUT_K2 = string2Array("smk2") // is a salt input for generating a key.

const SALT_INPUT_K3 = string2Array("smk3") // is a salt input for generating a key.

const SALT_INPUT_K4 = string2Array("smk4") // is a salt input for generating a key.

//    private static final byte[] SALT_INPUT_SMK4 = "smk4".getBytes();
//  “id6” || 0x01
const SALT_K3_M = new Uint8Array([0x69, 0x64, 0x36, 0x34,
    0x01]) // is a salt input used in combination with an identifier for generating a key.

// //  “id64” || 0x01
const SALT_K4_M = new Uint8Array([0x69, 0x64, 0x36,
    0x01]) // is a salt input used in combination with an identifier for generating a key.

const SALT_NKIK = string2Array("nkik") // is a salt input for generating a key.

const SALT_NKBK = string2Array("nkbk") // is a salt input for generating a key.

const SALT_NKPK = string2Array("nkpk") // is a salt input for generating a key.

const SALT_ID128 = string2Array("id128") // is a salt input for generating a key.

// 48 bit
const NODE_IDENTITY_HASH_PADDING =
    new Uint8Array([0, 0, 0, 0, 0, 0]) // is a padding used for generating a cryptographic hash of a node's identity.

// 40 bit
const NODE_PRIVATE_IDENTITY_HASH_PADDING = new Uint8Array([0, 0, 0, 0,
    0]) // is a padding used for generating a cryptographic hash of a node's private identity.

export const PRCK = string2Array("prck") //  is a cryptographic key.

export const PRSK = string2Array("prsk") //  is a cryptographic key.

export const PRSN = string2Array("prsn") //  is a cryptographic key.

export const PRDK = string2Array("prdk") //  is a cryptographic key.

export const PRCK256 = string2Array("prck256") //  is a cryptographic key.

const SALT_KEY_ZERO = new Uint8Array([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
])

const SALT_KEY_ZERO_32 =
    new Uint8Array([
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ])

const CMAC_BLOCK_SIZE = 16;

const CMAC_BUF_ZERO = new Uint8Array([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]);
const CMAC_BUF_RB = new Uint8Array([
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87]);

const ECC256_PUB_KEY_DER_PREFIX = new Uint8Array([
    0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86,
    0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a,
    0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
    0x42, 0x00, 0x04]
)

/**
 * Generates a key pair using the elliptic curve cryptography (ECC) algorithm.
 * It specifically uses the secp256r1 curve, also known as P-256.
 *
 * @return key pair
 */
export function generateKeyPair(): cryptoFramework.KeyPair | undefined {
    let keyGenerator = cryptoFramework.createAsyKeyGenerator('ECC256');
    try {
        return keyGenerator.generateKeyPairSync();
    } catch (e) {
        loge(`get key pair failed, ${e.code}, ${e.message}`);
        return undefined
    }
}


/**
 * Generates a shared secret key using the Elliptic Curve Diffie-Hellman (ECDH) algorithm.
 *
 * @param xy                    a byte array containing the x and y coordinates of a public key. The x coordinate is the first 32 bytes, and the y coordinate is the next 32 bytes.
 * @param provisionerPrivateKey the private key of the provisioner.
 * @return secret
 */
export function generateECDH(publicKey: Uint8Array, localKeyPair: cryptoFramework.KeyPair): Uint8Array | undefined {
    try {
        let pubDer = new Uint8Array(ECC256_PUB_KEY_DER_PREFIX.length + publicKey.length)
        pubDer.set(ECC256_PUB_KEY_DER_PREFIX, 0)
        pubDer.set(publicKey, ECC256_PUB_KEY_DER_PREFIX.length)

        let eccKeyAgreement = cryptoFramework.createKeyAgreement('ECC256');
        let eccGen = cryptoFramework.createAsyKeyGenerator('ECC256');
        let remoteKeyPair = eccGen.convertKeySync({ data: pubDer }, null)
        return eccKeyAgreement.generateSecretSync(localKeyPair.priKey, remoteKeyPair.pubKey).data
    } catch (e) {
        loge(`generateECDH failed, ${e.code}, ${e.message}`);
        return undefined
    }
}


export function aesCmac(message: Uint8Array, key: Uint8Array): Uint8Array {
    // Step 1 generate sub key
    let l = aesCbc(key, CMAC_BUF_ZERO)
    let subKey1 = cmacShiftLeft(l);
    if ((l[0] & 0x80) != 0) {
        subKey1 = xor16(CMAC_BUF_RB, subKey1);
    }
    let subKey2 = cmacShiftLeft(subKey1);
    if ((subKey1[0] & 0x80) != 0) {
        subKey2 = xor16(CMAC_BUF_RB, subKey2);
    }

    // Step 2 (we perform ceil(x/y) by doing: (x + y - 1) / y).
    let blockNum = (message.length + CMAC_BLOCK_SIZE - 1) / CMAC_BLOCK_SIZE;
    // 向下取整
    blockNum = Math.floor(blockNum);

    // Step 3
    let isLastBlockComplete: boolean;
    if (blockNum == 0) {
        blockNum = 1;
        isLastBlockComplete = false;
    } else {
        isLastBlockComplete = message.length % CMAC_BLOCK_SIZE == 0;
    }

    // Step 4
    let lastBlock = new Uint8Array(16);
    if (isLastBlockComplete) {
        lastBlock = xor16(message.slice((blockNum - 1) * 16, message.length), subKey1);
    } else {
        lastBlock = cmacPadding(message.slice((blockNum - 1) * 16, message.length));
        lastBlock = xor16(lastBlock, subKey2);
    }

    // step 5
    let outBlock = new Uint8Array(16);

    // Step 6
    for (let index = 0; index < blockNum - 1; index++) {
        outBlock = xor16(outBlock, message.slice(index * CMAC_BLOCK_SIZE, (index + 1) * CMAC_BLOCK_SIZE));
        outBlock = aesCbc(key, outBlock);
    }
    outBlock = xor16(outBlock, lastBlock);
    outBlock = aesCbc(key, outBlock);
    return outBlock;
}


function cmacShiftLeft(input: Uint8Array): Uint8Array {
    const output = new Uint8Array(input.length);
    let overflow = 0;
    for (let i = input.length - 1; i >= 0; i--) {
        output[i] = (input[i] << 1) | overflow;
        overflow = input[i] & 0x80 ? 1 : 0;
    }
    return output;
}

export function xor16(a: Uint8Array, b: Uint8Array): Uint8Array {
    const output = new Uint8Array(16);
    for (let i = 0; i < 16; i++) {
        output[i] = a[i] ^ b[i];
    }
    return output;
}


function cmacPadding(message: Uint8Array): Uint8Array {
    const block = new Uint8Array(CMAC_BLOCK_SIZE);
    for (let index = 0; index < CMAC_BLOCK_SIZE; index++) {
        if (index < message.length) {
            block[index] = message[index];
        } else if (index == message.length) {
            block[index] = 0x80;
        } else {
            block[index] = 0x00;
        }
    }
    return block;
}

/**
 * aes-cmac
 * <p>
 * k is the 128-bit key
 * m is the variable length data to be authenticated
 */
// export function aesCmac(content: Uint8Array, key: Uint8Array): Uint8Array {
//     try {
//         logd(`aes cmac : ${bytesToHexString(content)} => ${bytesToHexString(key)}`)
//         const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES128');
//         const symKey = symKeyGenerator.convertKeySync({ data: key });
//         let spec: cryptoFramework.CmacSpec = {
//             algName: "cmac",
//             cipherName: "aes128",
//         }
//         const mac = cryptoFramework.createMac(spec);
//         // mac.initSync(symKey);
//         // mac.updateSync({ data: content });
//         // const macResult = mac.doFinalSync();
//         // return macResult.data;
//     } catch (e) {
//         loge(`acs cmac fail, ${e.code}, ${e.message}`);
//         return new Uint8Array(0);
//     }
//     return new Uint8Array(0);
// }

/**
 * S1
 * s1(M) = AES-CMAC ZERO (M)
 *
 * @param m input
 * @return re
 */
export function generateSalt(m: Uint8Array): Uint8Array {
    return aesCmac(m, SALT_KEY_ZERO);
}

/**
 * s2
 *
 * @param m input
 * @return result
 */
export function s2(m: Uint8Array): Uint8Array {
    return hMacSha256(m, SALT_KEY_ZERO_32);
}

/**
 * @param data    target data
 * @param k       key
 * @param n       nonce
 * @param micSize mic
 * @param encrypt true: encryption, false: decryption
 * @return result
 */
export function ccm(text: Uint8Array, key: Uint8Array, nonce: Uint8Array, micSize: number,
    encrypt: boolean): Uint8Array {

    // logd(`ccm : text=${bytesToHexString(text)} ==> key=${bytesToHexString(key)} ==> nonce=${bytesToHexString(nonce)}
    //         micSize=${micSize} ==> enc=${encrypt}`)

    if (encrypt) {
        return ccmAesEncrypt(text, key, nonce, new Uint8Array(0), micSize)
    } else {
        return ccmAesDecrypt(text, key, nonce, new Uint8Array(0), micSize) ?? new Uint8Array(0)
    }

    // below are
    try {
        let cipher = cryptoFramework.createCipher('AES128|CCM|NoPadding');
        let aesGenerator = cryptoFramework.createSymKeyGenerator('AES128');
        let symKey = aesGenerator.convertKeySync({ data: key });

        let aad = new Uint8Array(8)
        let iv = new Uint8Array(0)
        // let iv = nonce
        let authTag = new Uint8Array(micSize)
        logd(`aad=${bytesToHexString(aad)}  authTag=${bytesToHexString(authTag)}`)

        let ccmParamsSpec: cryptoFramework.CcmParamsSpec = {
            iv: { data: iv },
            aad: { data: aad },
            authTag: { data: authTag },
            algName: "CcmParamsSpec"
        };
        cipher.initSync(encrypt ? cryptoFramework.CryptoMode.ENCRYPT_MODE : cryptoFramework.CryptoMode.DECRYPT_MODE,
            symKey,
            ccmParamsSpec);
        // let encryptUpdate = cipher.updateSync({ data: text });
        let encryptUpdate = cipher.doFinalSync({ data: text });
        // ccmParamsSpec.authTag = cipher.doFinalSync(null);
        logd("ccm # authTag : " + bytesToHexString(ccmParamsSpec.authTag.data))
        logd("ccm # aad : " + bytesToHexString(ccmParamsSpec.aad.data))
        return encryptUpdate.data;
    } catch (error) {
        let e: BusinessError = error as BusinessError;
        loge(`ccm failed, errCode: ${e.code} , errMsg:${e.message}`);
        return new Uint8Array()
    }
}


/**
 * implements the AES encryption algorithm to encrypt the given data using the provided key.
 *
 * @param data text
 * @param key  key
 * @return encrypted text
 */
export function aesEcb(data: Uint8Array, key: Uint8Array): Uint8Array {
    let cipher = cryptoFramework.createCipher('AES128|ECB|NoPadding');
    let aesGenerator = cryptoFramework.createSymKeyGenerator('AES128');
    let symKey = aesGenerator.convertKeySync({ data: key });
    cipher.initSync(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, null);
    let cipherData = cipher.doFinalSync({ data: data });
    return cipherData.data;
}


export function aesCbc(key: Uint8Array, message: Uint8Array): Uint8Array {
    let cipher = cryptoFramework.createCipher('AES128|CBC|NoPadding');
    let aesGenerator = cryptoFramework.createSymKeyGenerator("AES128");
    let symKey = aesGenerator.convertKeySync({ data: key })
    let ivParamsSpec: cryptoFramework.IvParamsSpec = {
        algName: "IvParamsSpec",
        iv: { data: CMAC_BUF_ZERO }
    };
    cipher.initSync(cryptoFramework.CryptoMode.ENCRYPT_MODE, symKey, ivParamsSpec);
    let cipherData = cipher.doFinalSync({ data: message });
    return cipherData.data;
}

/**
 * k1
 *
 * @param ecdh ecdh
 * @param salt salt
 * @param text text
 * @return result
 */
export function k1(ecdh: Uint8Array, salt: Uint8Array, text: Uint8Array): Uint8Array {
    return aesCmac(text, aesCmac(ecdh, salt));
}

/**
 * calculate k2 by network key
 *
 * @param netKey network key
 * @return result
 */
export function calculateNetKeyK2(netKey: Uint8Array): Array<Uint8Array> {
    return k2(netKey, new Uint8Array([0]));
}

/**
 * k2
 *
 * @param data text
 * @param p    p
 * @return result
 */
export function k2(data: Uint8Array, p: Uint8Array): Array<Uint8Array> {

    let salt = generateSalt(SALT_INPUT_K2);
    let t = aesCmac(data, salt);

    let inputBufferT0 = new Uint8Array(p.length + 1)
    inputBufferT0.set(p, 0);
    inputBufferT0.set([0x01], p.length);
    let t1 = aesCmac(inputBufferT0, t);

    let inputBufferT1 = new Uint8Array(t1.length + p.length + 1);
    inputBufferT1.set(t1, 0);
    inputBufferT1.set(p, t1.length);
    inputBufferT1.set([0x02], t1.length + p.length);
    // encryptionKey
    let t2 = aesCmac(inputBufferT1, t);

    let inputBufferT2 = new Uint8Array(t2.length + p.length + 1);
    inputBufferT2.set(t2, 0);
    inputBufferT2.set(p, t2.length);
    inputBufferT2.set([0x03], t2.length + p.length);
    // privacyKey //
    let t3 = aesCmac(inputBufferT2, t);
    return [t1, t2, t3]
}

/**
 * k3
 *
 * @param n n
 * @return result
 */
export function k3(n: Uint8Array): Uint8Array {
    let salt = generateSalt(SALT_INPUT_K3);
    let t = aesCmac(n, salt);
    let result = aesCmac(SALT_K3_M, t)
    let networkId = new Uint8Array(8)
    let srcOffset = result.length - networkId.length;
    networkId.set(result.slice(srcOffset), 0)
    return networkId;
}

/**
 * k4
 *
 * @param n n
 * @return result
 */
export function k4(n: Uint8Array): number {
    let salt = generateSalt(SALT_INPUT_K4);
    let t = aesCmac(n, salt);
    let result = aesCmac(SALT_K4_M, t);
    return (result[15]) & 0x3F
}


/**
 * N is 32 or more octets
 * SALT is 256 bits
 * P is 1 or more octets
 * The key (T) is computed as follows:
 * T = HMAC-SHA-256 SALT (N)
 * The output of the derivation function k5 is as follows:
 * k5(N, SALT, P) = HMAC-SHA-256T (P)
 */
export function k5(n: Uint8Array, salt: Uint8Array, p: Uint8Array): Uint8Array {
    let t = hMacSha256(n, salt);
    return hMacSha256(p, t);
}

/**
 * The Hash field is calculated as shown below:
 * Hash = e(IdentityKey, Padding || Random || Address) mod 264
 * Where:
 * Padding – 48 bits of padding, all bits set to 0.
 * Random – 64-bit random value.
 * Address – The unicast address of the node.
 * The Random field is the 64-bit random value used in the Hash field calculation
 */
export function generateNodeIdentityHash(identityKey: Uint8Array, random: Uint8Array, src: number): Uint8Array {
    let length = NODE_IDENTITY_HASH_PADDING.length + random.length + 2;
    let bufferHashInput = new Uint8Array(length)
    bufferHashInput.set(NODE_IDENTITY_HASH_PADDING, 0);
    bufferHashInput.set(random, NODE_IDENTITY_HASH_PADDING.length);
    bufferHashInput.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN), NODE_IDENTITY_HASH_PADDING.length + random.length);
    let hash = aesEcb(bufferHashInput, identityKey);
    return hash.slice(8, 16)
}

/**
 * The Hash field is calculated as shown below:
 * Hash = e(IdentityKey, Padding || 0x03 || Random || Address) mod 264
 * Where:
 * Padding – 40 bits of padding, all bits set to 0
 * Random – 64-bit random value
 * Address – The unicast address of the node
 * The Random field is the 64-bit random value used in the Hash field calculation
 */
export function generatePrivateNodeIdentityHash(identityKey: Uint8Array, random: Uint8Array, src: number): Uint8Array {
    let length = NODE_PRIVATE_IDENTITY_HASH_PADDING.length + random.length + 3;
    let bufferHashInput = new Uint8Array(length);
    bufferHashInput.set(NODE_PRIVATE_IDENTITY_HASH_PADDING, 0)
    bufferHashInput.set([0x03], NODE_PRIVATE_IDENTITY_HASH_PADDING.length);
    bufferHashInput.set(random, 1 + NODE_PRIVATE_IDENTITY_HASH_PADDING.length);
    bufferHashInput.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN),
        random.length + 1 + NODE_PRIVATE_IDENTITY_HASH_PADDING.length);

    let hash = aesEcb(bufferHashInput, identityKey);
    return hash.slice(8, 16)
}

/**
 * generates an identity key using a given network key
 *
 * @param networkKey network key
 * @return result
 */
export function generateIdentityKey(networkKey: Uint8Array): Uint8Array {
    let salt = generateSalt(SALT_NKIK);
    let buffer = new Uint8Array(SALT_ID128.length + 1);
    buffer.set(SALT_ID128, 0);
    buffer.set([0x01], SALT_ID128.length);
    return k1(networkKey, salt, buffer);
}

/**
 * generates a beacon key using a given network key.
 *
 * @param networkKey network key
 * @return result
 */
export function generateBeaconKey(networkKey: Uint8Array): Uint8Array {
    let salt = generateSalt(SALT_NKBK);
    let buffer = new Uint8Array(SALT_ID128.length + 1);
    buffer.set(SALT_ID128, 0);
    buffer.set([0x01], SALT_ID128.length);
    return k1(networkKey, salt, buffer);
}

/**
 * generates a private beacon key using a given network key
 *
 * @param networkKey network key
 * @return result
 */
export function generatePrivateBeaconKey(networkKey: Uint8Array): Uint8Array {
    let salt = generateSalt(SALT_NKPK);
    let buffer = new Uint8Array(SALT_ID128.length + 1);
    buffer.set(SALT_ID128, 0);
    buffer.set([0x01], SALT_ID128.length);
    return k1(networkKey, salt, buffer);
}

/**
 * @param data online status data
 * @param key  netKey->beaconKey
 * @return decryption result
 */
export function decryptOnlineStatus(data: Uint8Array, key: Uint8Array): Uint8Array | null {
    let ivLen = 4;
    let iv = new Uint8Array(ivLen);
    iv.set(data.slice(0, ivLen), 0)

    let micLen = 2;
    let mic = new Uint8Array(micLen);
    let micIndex = data.length - micLen;
    mic.set(data.slice(micIndex, micIndex + micLen), 0)

    let len = data.length - ivLen - micLen;
    let status = new Uint8Array(len);
    status.set(data.slice(ivLen, ivLen + len), 0)

    let e = new Uint8Array(16), r = new Uint8Array(16)

    ///////////////// calculate enc ////////////////////////
    r.set(iv, 1)

    for (let i = 0; i < len; i++) {
        if ((i & 15) == 0) {
            e = aesEcb(r, key);
            r[0]++;
        }
        status[i] ^= e[i & 15];
    }
    ///////////// calculate mic ///////////////////////
    r = new Uint8Array(16)
    r.set(iv, 0)
    //        memcpy(r, iv, iv_len);
    r[ivLen] = len
    r = aesEcb(r, key);

    for (let i = 0; i < len; i++) {
        r[i & 15] ^= status[i];

        if ((i & 15) == 15 || i == len - 1) {
            r = aesEcb(r, key);
        }
    }

    for (let i = 0; i < micLen; i++) {
        if (mic[i] != r[i]) {
            return null; //Failed
        }
    }
    data.set(status, ivLen)
    return data;
}

/**
 * sha256
 *
 * @param text text
 * @return result
 */
export function sha256(text: Uint8Array): Uint8Array {
    let md = cryptoFramework.createMd("SHA256");
    md.updateSync({ data: text });
    let mdResult = md.digestSync();
    return mdResult.data
}


/**
 * hmac sha256
 *
 * @param text text
 * @param key  key
 * @return result
 */
export function hMacSha256(text: Uint8Array, key: Uint8Array): Uint8Array {
    let aesGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
    let symKey = aesGenerator.convertKeySync({ data: key });
    let macAlgName = 'SHA256';
    let mac = cryptoFramework.createMac(macAlgName);
    mac.initSync(symKey);
    mac.updateSync({ data: text });
    let macResult = mac.doFinalSync();
    return macResult.data
}


/**
 * "ecdsa-with-SHA256"
 * check certificate data and return inner public key
 *
 * @param cerData certificate data formatted by x509 der
 * @return public key
 */
export async function checkCertificate(certData: Uint8Array): Promise<cert.X509Cert | undefined> {
    let encodingBlob: cert.EncodingBlob = {
        data: certData,
        encodingFormat: cert.EncodingFormat.FORMAT_DER
    };
    let crt = await cert.createX509Cert(encodingBlob)
    let version = crt.getVersion()

    if (!crt) {
        console.log("cert : " + crt)
        return undefined
    }
    console.log("cert : " + crt)
    try {
        await crt.verify(crt.getPublicKey());
    } catch (error) {

        let e: BusinessError = error as BusinessError;
        loge(`getPublicKey failed, errCode: ${e.code} , errMsg:${e.message}`);
        return undefined
    }

    return crt;
}

/**
 * check certificate by CA
 *
 * @param cerData certificate data formatted by x509 der
 */
export async function checkCertificateByCa(certData: Uint8Array, caData: Uint8Array): Promise<cert.X509Cert | null> {
    let crt = await cert.createX509Cert({
        data: certData,
        encodingFormat: cert.EncodingFormat.FORMAT_DER
    })
    let caCrt = await cert.createX509Cert({
        data: caData,
        encodingFormat: cert.EncodingFormat.FORMAT_DER
    })

    if (!crt) {
        loge("parse cert error")
        return null
    }
    if (!caCrt) {
        loge("parse ca cert error")
        return null
    }
    try {
        await crt.verify(caCrt.getPublicKey());
    } catch (error) {
        let e: BusinessError = error as BusinessError;
        loge(`getPublicKey failed, errCode: ${e.code} , errMsg:${e.message}`);
        return null
    }
    return crt
}

/**
 * get public key in cert
 *
 * @param certificate certificate
 * @return public key
 */
export function getPublicKeyInCert(certificate: cert.X509Cert): Uint8Array {
    return certificate.getPublicKey().getEncoded().data
}

/**
 * get static oob in cert
 *
 * @param certificate certificate
 * @return static oob data
 */
export function getStaticOOBInCert(certificate: cert.X509Cert): Uint8Array | undefined {
    //        Set<String> nces = certificate.getNonCriticalExtensionOIDs();
    let staticOOBKey = "2.25.234763379998062148653007332685657680359";
    let oid = new Uint8Array([0x32, 0x2e, 0x35, 0x2e, 0x32, 0x39, 0x2e, 0x31, 0x35]);
    let oidBlob: cert.DataBlob = {
        data: string2Array(staticOOBKey)
    }
    try {
        let entry =
            certificate.getExtensionsObject().getEntry(cert.ExtensionEntryType.EXTENSION_ENTRY_TYPE_ENTRY, oidBlob);
        return entry.data
    } catch (err) {
        let e: BusinessError = err as BusinessError;
        loge('ext getEntry failed, errCode: ' + e.code + ', errMsg: ' + e.message);
        return undefined
    }
}

/**
 * calculate UUID by mac address
 *
 * @param mac mac address
 * @return device UUID
 */
export function calcUuidByMac(mac: string): Uint8Array {
    let macBytes = hexToBytes(mac.replace(":", ""));
    return calcUuidByMacBytes(macBytes);
}

/**
 * calculate UUID by mac address
 *
 * @param input mac address byte array
 * @return device UUID
 */
export function calcUuidByMacBytes(input: Uint8Array): Uint8Array {

    let nameSpace = hexToBytes("10b8a76bad9dd11180b400c04fd430c8");

    input = input.reverse()
    let tmp = new Uint8Array(15)
    tmp.set(input, 0)
    input = tmp
    let md = cryptoFramework.createMd('MD5');
    md.updateSync({ data: nameSpace });
    md.updateSync({ data: input });
    let hashBytes = md.digestSync().data;
    hashBytes[7] &= 0x0F;
    hashBytes[7] |= 0x30;
    hashBytes[8] &= 0x3F;
    hashBytes[8] |= 0x80;
    return hashBytes;


}
