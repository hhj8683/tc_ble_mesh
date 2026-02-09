/********************************************************************************************************
 * @file     Gatt.test.ets 
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
import { GattConnection, UUID_OTA_CHARACTERISTIC, UUID_OTA_SERVICE } from 'telinksigmeshlib';
import localUnitTest from './LocalUnit.test';
import { ble } from '@kit.ConnectivityKit';

// not for test, only for backup
async function testReadWrite() {
    let deviceId = ""
    let connection: GattConnection = new GattConnection((state: ble.ProfileConnectionState) => {
    })
    let testData: Uint8Array = new Uint8Array(100)
    for (let i = 0; i < testData.length; i++) {
        testData[i] = i
    }

    for (let i = 0; i < 50; i++) {
        let writeRe = await connection.writeCharacteristic(UUID_OTA_SERVICE, UUID_OTA_CHARACTERISTIC, testData,
            ble.GattWriteType.WRITE_NO_RESPONSE)
        // console.log("write re : ", writeRe)
        let readRe = await connection.readCharacteristic(UUID_OTA_SERVICE, UUID_OTA_CHARACTERISTIC)
    }
}