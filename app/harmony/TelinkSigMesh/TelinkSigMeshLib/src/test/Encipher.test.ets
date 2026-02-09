/********************************************************************************************************
 * @file     Encipher.test.ets 
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
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium'
import { bytesToHexString, hexToBytes, string2Array } from '../main/ets/utils/ArrayUtils'
import { aesCmac, aesEcb, ccm, generateKeyPair, generateSalt } from '../main/ets/utils/Encipher'
import { logd, loge } from '../main/ets/utils/MeshLogger'

export default function EncipherTest() {
    describe('EncipherTest', () => {
        // testCcm()
        testCmac()
    })
}

function testCcm() {
    let a = 'test'
    console.log("ccm test ok")
    expect(a).assertEqual('test')
}

function testCmac() {
    let a = 'testCmac'
    let salt = generateSalt(string2Array("smk3"))
    logd(`salt : ${bytesToHexString(salt)}`)
}


function testCcm_c() {
    /*
     SIG-Mesh ccm : text=f9c1dde5f9f58aeffba6da6245675136000000000000000002 ==>
     * key=955b0adc64b8afc9141ea8f1359e1b70 ==>
     * nonce=9522512a9ef0a7e19f9716248e
       micSize=8
       enc = true
     *
     * */
    let text = hexToBytes("f9c1dde5f9f58aeffba6da6245675136000000000000000002")
    let key = hexToBytes("955b0adc64b8afc9141ea8f1359e1b70")
    let nonce = hexToBytes("9522512a9ef0a7e19f9716248e")
    let micSize = 8
    let enc = true
    let ccmRe = ccm(text, key, nonce, micSize, enc)

    // android re :
    // 217402DB9F003DABA60C39B7EAC2A1DCF26944930A733B424C E98D8CD9C45D599A

    // ccm c : 7a1b043d218d3698c7c5181552cf7c3797b3b751eadec2c980 9a32f62cc419b4b0
    // 217402db9f003daba60c39b7eac2a1dcf26944930a733b424ce98d8cd9c45d599a
    // 7a1b043d218d3698c7c5181552cf7c3797b3b751eadec2c980336994ddc8e6b466
    // logd("test ccm result : " + bytesToHexString(ccmRe))

}

function getPublicKey() {
    let pubKeyArray =
        new Uint8Array([48, 89, 48, 19, 6, 7, 42, 134, 72, 206, 61, 2, 1, 6, 8, 42, 134, 72, 206, 61, 3, 1, 7, 3,
            66, 0, 4, 83, 96, 142, 9, 86, 214, 126, 106, 247, 233, 92, 125, 4, 128, 138, 105, 246, 162, 215, 71, 81,
            58, 202, 121, 26, 105, 211, 55, 130, 45, 236, 143, 55, 16, 248, 75, 167, 160, 167, 106, 2, 152, 243, 44,
            68, 66, 0, 167, 99, 92, 235, 215, 159, 239, 28, 106, 124, 171, 34, 145, 124, 174, 57, 92]);
    // 3059301306072a8648ce3d020106082a8648ce3d03010703420004 53608e0956d67e6af7e95c7d04808a69f6a2d747513aca791a69d337822dec8f3710f84ba7a0a76a0298f32c444200a7635cebd79fef1c6a7cab22917cae395c
    // 3059301306072a8648ce3d020106082a8648ce3d03010703420004 8b60b54a494d325999e2f8f806300bb5d4aaddcdb31098e3ba21457b8ec8ccff0537200cb59d9365a123a801b5fd8ae1d5f938f3c9e101f2fa8e64c42241e6a5
    logd("pub key : " + bytesToHexString(pubKeyArray))


    let provisionerKeyPair = generateKeyPair();
    if (provisionerKeyPair) {
        let key = provisionerKeyPair.pubKey.getEncoded().data;
        let x = key.slice(key.length - 64, key.length - 32)
        let y = key.slice(key.length - 32, key.length)
        // let key = publicKey.getAsyKeySpec(AsyKeySpecItem.DSA_PK_BN)
        // let x = key.slice(0, 32)
        // let y = key.slice(32)
        //
        // logd("get key : " + bytesToHexString(key, ""));
        logd("get key x: " + bytesToHexString(x, ""));
        logd("get key y: " + bytesToHexString(y, ""));
        // logd(('pubkey : ' + provisionerKeyPair.pubKey))


        // 3059301306072a8648ce3d020106082a8648ce3d030107034200048b60b54a494d325999e2f8f806300bb5d4aaddcdb31098e3ba21457b8ec8ccff0537200cb59d9365a123a801b5fd8ae1d5f938f3c9e101f2fa8e64c42241e6a5
        logd(('pubkey : ' + bytesToHexString(provisionerKeyPair.pubKey.getEncoded().data)))
    }
}


function testAesCmac() {
    let ecbRe = aesEcb(hexToBytes("9522512a9ef0a7e19f9716248e123456"),
        hexToBytes("955b0adc64b8afc9141ea8f1359e1b70"))
    // 3808b5b2fe2d73152d91711388719756
    logd("aes ecb re : " + bytesToHexString(ecbRe))

    let re = aesCmac(hexToBytes("9522512a9ef0a7e19f9716248e"),
        hexToBytes("955b0adc64b8afc9141ea8f1359e1b70"))
    // 55443645ca1bccc33c4e9e1166011e02
    logd("aes cmac re : " + bytesToHexString(re))
}

