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
import { util } from '@kit.ArkTS';

export function formatTestMain() {
    stringFormat();
}

export function stringFormat() {
    let intVal = 0x1234
    let longVal = 0x1234567890abcdefedcba // 0x1234567890abce0000000 , 测试有问题, 待实机测试
    console.log(`save complete seqAuth src: 0x${intVal.toString(16).padStart(8, '0')} -- seqAuth: 0x${longVal.toString(16)}`);
}

/**
 * generateRandom 需要实机运行才能正确赋值
 */
export function testGenRdn() {

}