/********************************************************************************************************
 * @file     ArrayUtils.ets 
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
import { buffer, util } from "@kit.ArkTS";

export function bytesEquals(array1: Uint8Array, array2: Uint8Array) {

    if (array1 === array2) {
        return true;
    }

    if (array1.length !== array2.length) {
        return false;
    }

    for (let i = 0; i < array1.length; i++) {
        if (array1[i] !== array2[i]) {
            return false;
        }
    }

    return true;
}

export function bytesToString(val: Uint8Array): string {
    return util.TextDecoder.create().decodeToString(val)
}

export function string2Array(val: string): Uint8Array {
    return new Uint8Array(buffer.from(val).buffer)
}

export function bufferToHex(buffer: ArrayBuffer, separator: string = ''): string {
    const byteArray = new Uint8Array(buffer);
    return bytesToHex(byteArray, separator);
}

export function bytesToHex(bytes?: Uint8Array, separator: string = ''): string {
    if (!bytes) {
        return ""
    }
    return Array.from(bytes).map(byte => byte.toString(16).padStart(2, '0'))
        .join(separator);
}

// 兼容之前的方法名
export function bytesToHexString(bytes?: Uint8Array, separator: string = ''): string {
    return bytesToHex(bytes, separator)
}


/**
 * @param buffer target buffer
 * @param offset buffer start position
 * @param size   selected bytes length
 * @param order  ByteOrder
 * @return int value
 */
export function bytes2Integer(buffer: Uint8Array, offset: number = 0, size?: number,
    order: ByteOrder = ByteOrder.LITTLE_ENDIAN): number {
    let re = 0;
    if (!size) {
        size = buffer.length
    }
    let valLen = Math.min(4, size);
    for (let i = 0; i < valLen; i++) {
        if (order == ByteOrder.LITTLE_ENDIAN) {
            re |= (buffer[i + offset] & 0xFF) << (8 * i);
        } else if (order == ByteOrder.BIG_ENDIAN) {
            re |= (buffer[i + offset] & 0xFF) << (8 * (valLen - i - 1));
        }
    }
    return re;
}


/**
 * Converts a portion of a byte array to a long value.
 *
 * @param buffer the byte array containing the data
 * @param offset the starting index of the portion in the byte array
 * @param size   the size of the portion in bytes
 * @param order  the byte order of the data (either ByteOrder.LITTLE_ENDIAN or ByteOrder.BIG_ENDIAN)
 * @return the long value converted from the byte array portion
 */
export function bytes2Long(buffer: Uint8Array, offset: number, size: number, order: ByteOrder) {
    let re = 0;
    let valLen = Math.min(8, size);
    for (let i = 0; i < valLen; i++) {
        if (order == ByteOrder.LITTLE_ENDIAN) {
            re |= (buffer[i + offset] & 0xFF) << (8 * i);
        } else if (order == ByteOrder.BIG_ENDIAN) {
            re |= (buffer[i + offset] & 0xFF) << (8 * (valLen - i - 1));
        }
    }
    return re;
}

/**
 * Converts an number value to a byte array of specified size and byte order.
 *
 * @param i     the integer value to convert
 * @param size  the size of the resulting byte array (limited to maximum of 4 bytes)
 * @param order the byte order to use for the conversion (either ByteOrder.LITTLE_ENDIAN or ByteOrder.BIG_ENDIAN)
 * @return the byte array representation of the integer value
 */
export function num2bytes(i: number, size: number, order: ByteOrder = ByteOrder.LITTLE_ENDIAN) {
    if (size > 8) {
        size = 8;
    }
    let re = new Uint8Array(size);
    for (let j = 0; j < size; j++) {
        if (order == ByteOrder.LITTLE_ENDIAN) {
            re[j] = (i >> (8 * j));
        } else {
            re[size - j - 1] = (i >> (8 * j));
        }
    }
    return re;
}


export function hexToBytes(hexString: string) {
    const byteLength = hexString.length / 2
    const result = new Uint8Array(byteLength)
    for (let i = 0; i < byteLength; i++) {
        const byteStart = i * 2;
        result[i] = parseInt(hexString.substring(byteStart, byteStart + 2), 16);
    }
    return result;
}

export function num2Hex(num: number, formatLen?: number) {
    if (formatLen) {
        return num.toString(16).padStart(formatLen, '0')
    } else {
        return num.toString(16)
    }
}


export function hexToUuid(hexStr: string): string {
    return bytesToUuid(hexToBytes(hexStr))
}

export function bytesToUuid(array: Uint8Array): string {
    // 1. 验证输入是否为16字节
    if (array.length !== 16) {
        throw new Error('The Uint8Array must be exactly 16 bytes long.');
    }

    // 2. 将每个字节转换为十六进制字符串
    const hexParts: string[] = [];
    for (let i = 0; i < array.length; i++) {
        // 使用toString(16)将字节转换为16进制，并使用padStart确保总是两位
        hexParts.push(array[i].toString(16).padStart(2, '0'));
    }

    // 3. 按照UUID格式拼接字符串并插入连字符
    // 格式：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    return `${hexParts.slice(0, 4).join('')}-` +        // 时间低位 (8字符)
        `${hexParts.slice(4, 6).join('')}-` +        // 时间高位 (4字符)
        `${hexParts.slice(6, 8).join('')}-` +        // 时钟序列高位和低位 (4字符)
        `${hexParts.slice(8, 10).join('')}-` +       // 节点高位 (4字符)
        `${hexParts.slice(10, 16).join('')}`;        // 节点低位 (12字符)
}

export enum ByteOrder {
    LITTLE_ENDIAN,
    BIG_ENDIAN
}