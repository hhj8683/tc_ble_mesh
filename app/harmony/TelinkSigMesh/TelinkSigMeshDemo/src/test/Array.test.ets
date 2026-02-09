/********************************************************************************************************
 * @file     Array.test.ets 
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
import {
    bytesToHex,
    GattConnection,
    UUID_OTA_CHARACTERISTIC,
    UUID_OTA_SERVICE,
    generateRandom
} from 'telinksigmeshlib';
import { expect } from '@ohos/hypium';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Queue, util } from '@kit.ArkTS';

export function testU16ToU8() {
    let u16Arr = new Uint16Array([0x1234, 0x5678])
    let len = 1 + u16Arr.length * 2; // Calculate the length of the byte array
    let buffer = new Uint8Array(len) // Create a byte buffer with the calculated length
    buffer[0] = 0xaa
    let dv = new DataView(buffer.buffer)
    for (let i = 0; i < u16Arr.length; i++) {
        dv.setUint16(i * 2 + 1, u16Arr[i], false)
    }
    console.log("test arr : " + bytesToHex(buffer))
    let exp = 'aa12345678';
    let re = bytesToHex(buffer);
    expect(exp).assertContain(re);
}

export function testBuffer() {
    // let random = generateRandom(13);
    let random = new Uint8Array(13);
    console.log("random init : ", bytesToHex(random))
    for (let i = 0; i < random.length; i++) {
        random[i] = i + 1
    }
    let b0 = new Uint8Array(16)
    b0[0] = 0x19
    b0.set(random, 1)
    b0.set([0x00, 0x05], random.length + 1)

    console.log("random : ", bytesToHex(random))
    console.log("buffer : ", bytesToHex(b0))
}

/**
 * generateRandom 需要实机运行才能正确赋值
 */
export function testGenRdn() {

    let uuid1: string = util.generateRandomUUID(false);
    console.info("random uuid : " + uuid1)

    let rand = cryptoFramework.createRandom();
    let len = 24; // Generate a 24-byte random number
    try {
        let randData = rand.generateRandomSync(len);
        if (randData) {
            console.info('[Sync]: rand result: ' + randData.data);
            console.info('[Sync]: rand result: ' + randData.data.length)
        } else {
            console.error('[Sync]: get rand result fail!');
        }
    } catch (error) {
        let e: BusinessError = error as BusinessError;
        console.error(`do rand failed, ${e.code}, ${e.message}`);
    }
}

// concat 测试正常, 不过由于执行效率不高, 不建议使用
export function testArrayConcat(){
    let buf1 = new Uint8Array([0x34, 0x56, 0x78])
    console.log("test concat")
    console.log(bytesToHex(new Uint8Array([0x12].concat(...buf1))))
}


// concat 测试正常, 不过由于执行效率不高, 不建议使用
export function testQueue(){
    console.log("test queue")
    let queue: Queue<Uint8Array> = new Queue()
    queue.add(new Uint8Array([0x12, 0x34]))
    queue.add(new Uint8Array([0x56, 0x78]))

    for (let i = 0; i < 10; i++) {
        let item: Uint8Array|undefined = queue.pop()
        if (item) {
            console.log("pop queue : " + bytesToHex(item))
        }else{
            console.log("pop queue : no data"  )
        }
    }
}