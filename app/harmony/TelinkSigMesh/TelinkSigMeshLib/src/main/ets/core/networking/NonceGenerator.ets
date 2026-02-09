/********************************************************************************************************
 * @file     NonceGenerator.ets 
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
 * @file NonceGenerator.ets
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
import { ByteOrder, num2bytes } from "../../utils/ArrayUtils";
import { AccessType } from "./AccessType";

const NONCE_LENGTH = 13;

    /**
     * Used with an encryption key for network authentication and encryption
     */
    const NONCE_TYPE_NETWORK = 0x00;

    /**
     * Used with an application key for upper transport authentication and encryption
     */
    const NONCE_TYPE_APPLICATION = 0x01;

    /**
     * Used with a device key for upper transport authentication and encryption
     */
    const NONCE_TYPE_DEVICE = 0x02;

    /**
     * Used with an encryption key for proxy authentication and encryption
     */
    const NONCE_TYPE_PROXY = 0x03;

    /**
     * Used with an encryption key for proxy authentication and encryption
     */
    const NONCE_TYPE_SOLICITATION = 0x04;

    const NONCE_PADDING = 0x00;

    export function   generateNetworkNonce( ctlTTL: number,  sequenceNumber: Uint8Array, src: number, ivIndex: number) : Uint8Array{
        let networkNonce = new Uint8Array(13) // order(ByteOrder.BIG_ENDIAN);
    let offset = 0
        networkNonce[offset] = NONCE_TYPE_NETWORK //Nonce typeValue
        offset +=1
        networkNonce[offset] = ctlTTL
        offset += 1

        networkNonce.set(sequenceNumber, offset)
        offset += sequenceNumber.length

        networkNonce.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN), offset)
        offset += 2

        networkNonce.set(new Uint8Array([0x00, 0x00]), offset) //PADDING
        offset+= 2

        networkNonce.set(num2bytes(ivIndex, 4, ByteOrder.BIG_ENDIAN), offset)

        return networkNonce
    }

    /**
     * output application or device nonce
     *
     * @param aszmic     SZMIC if a Segmented Access message or 0 for all other message formats
     * @param accessType if Application or Device command
     */
    export function  generateAccessNonce(aszmic: number,  sequenceNumber: Uint8Array,  src: number,  dst: number,
        ivIndex: number,  accessType: AccessType) {
        let accessNonceBuf = new Uint8Array(NONCE_LENGTH) // .order(ByteOrder.BIG_ENDIAN);
        let type = accessType == AccessType.APPLICATION ? NONCE_TYPE_APPLICATION : NONCE_TYPE_DEVICE;
        let offset= 0
        accessNonceBuf[offset] = type
        offset += 1

        accessNonceBuf[offset] = (aszmic << 7) | NONCE_PADDING //ASZMIC (SZMIC if a segmented access message) and PAD
        offset += 1

        accessNonceBuf.set(sequenceNumber, offset)
        offset += sequenceNumber.length


        accessNonceBuf.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN), offset)
        offset += 2
        accessNonceBuf.set(num2bytes(dst, 2, ByteOrder.BIG_ENDIAN), offset)
        offset += 2
        accessNonceBuf.set(num2bytes(ivIndex, 4, ByteOrder.BIG_ENDIAN), offset)

        return accessNonceBuf
    }

    /**
     * output proxy nonce
     */
    export function  generateProxyNonce(sequenceNumber: Uint8Array,  src: number,  ivIndex: number): Uint8Array {
        let nonceBuffer = new Uint8Array(NONCE_LENGTH);
        let offset = 0
        nonceBuffer[offset] = NONCE_TYPE_PROXY
        offset += 1

        nonceBuffer[offset] = NONCE_PADDING
        offset += 1


        nonceBuffer.set(sequenceNumber, offset)
        offset += sequenceNumber.length

        nonceBuffer.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN), offset)
        offset += 2


        nonceBuffer.set(new Uint8Array([NONCE_PADDING, NONCE_PADDING]), offset)
        offset += 2

        nonceBuffer.set(num2bytes(ivIndex, 4, ByteOrder.BIG_ENDIAN), offset)

        return nonceBuffer
    }

    /**
     * output proxy nonce
     */
    export function generateSolicitationNonce(sequenceNumber: Uint8Array,  src: number): Uint8Array {
        let nonceBuffer = new Uint8Array(NONCE_LENGTH);
        let offset = 0
        nonceBuffer[offset] = (NONCE_TYPE_SOLICITATION); //Nonce typeValue
        offset+=1
        nonceBuffer[offset] = NONCE_PADDING //PAD
        offset +=1
        nonceBuffer.set(sequenceNumber, offset)
        offset += 3
        nonceBuffer.set(num2bytes( src, 2, ByteOrder.BIG_ENDIAN), offset);
        offset+=2
        nonceBuffer.set(new Uint8Array([0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), offset);
        return nonceBuffer
    }
