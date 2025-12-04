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