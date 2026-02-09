/********************************************************************************************************
 * @file     UpperTransportAccessPDU.ets 
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
 * @file UpperTransportAccessPDU.ets
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
import ArrayList from '@ohos.util.ArrayList';
import { SegmentedAccessMessagePDU } from '../lower/SegmentedAccessMessagePDU';
import { UnsegmentedAccessMessagePDU } from '../lower/UnsegmentedAccessMessagePDU';
import { AccessType } from '../../AccessType';
import { ByteOrder, num2bytes } from '../../../../utils/ArrayUtils';
import { generateAccessNonce } from '../../NonceGenerator';
import { generateAid, getMicSize, sequenceNumber2Buffer } from '../../../../utils/MeshUtils';
import { loge } from '../../../../utils/MeshLogger';
import { ccm } from '../../../../utils/Encipher';

/**
 * This class represents the Upper Transport Access PDU (Protocol Data Unit).
 * It is responsible for encrypting and decrypting the payload data of the Upper Transport Layer.
 * The encrypted and decrypted payload data can be accessed through the corresponding getter methods.
 * The encryption suite used for encrypting and decrypting the payload is provided during object instantiation.
 */
export class UpperTransportAccessPDU {
    /**
     * 384 bytes total
     * 4 or 8 bytes transMIC
     * transMIC
     * for unsegmented message: 4 bytes
     * for segmented message, determined by lower transport pdu:
     * 4 bytes if SZMIC == 0, 8 bytes if SZMIC == 1
     */
    public  encryptedPayload?: Uint8Array;

    /**
     * decrypted payload
     */
    public   decryptedPayload?: Uint8Array;

    private  mEncryptionSuite:UpperTransportEncryptionSuite;

    /**
     * Constructor for the UpperTransportAccessPDU class.
     *
     * @param mEncryptionSuite The encryption suite used for encrypting and decrypting the payload.
     */
    public constructor(mEncryptionSuite:UpperTransportEncryptionSuite) {
        this.mEncryptionSuite = mEncryptionSuite;
    }


    /**
     * Parses and decrypts a segmented message from a given message buffer.
     *
     * @param messageBuffer  The buffer containing the segmented message.
     * @param sequenceNumber The sequence number of the message.
     * @param src            The source address of the message.
     * @param dst            The destination address of the message.
     * @return True if the decryption is successful, false otherwise.
     */
    public  parseAndDecryptSegmentedMessage( messageBuffer: Map<number, SegmentedAccessMessagePDU>,  sequenceNumber: number, src: number,  dst: number):boolean {
        let len = 0;
        let message0: SegmentedAccessMessagePDU | undefined = undefined
        messageBuffer.forEach((msg, segO)=>{
            len += msg.segmentM.length;
            if (!message0) {
                message0 = msg
            }
        })

        let upperTransportPdu = new Uint8Array(len);
        let offset = 0;
        let tmpLen: number;

        messageBuffer.forEach((msg, segO)=>{
            tmpLen = msg.segmentM.length;
            upperTransportPdu.set(msg.segmentM, offset)
            offset += tmpLen;
        })


//        MeshLogger.log("upper pdu raw: " + Arrays.bytesToHexString(upperTransportPdu, ""));
        // Set the encrypted payload to the concatenated Upper Transport PDU
        this.encryptedPayload = upperTransportPdu;

        // Decrypt the first segment of the message to obtain the decrypted payload
        // let message0 = messageBuffer.values().next().value
        this.decryptedPayload = this.decrypt(message0!.akf, message0!.aid, message0!.szmic, sequenceNumber, src, dst);

        return this.decryptedPayload != null;
    }

    /**
     * Parses and decrypts an unsegmented message.
     *
     * @param unsegmentedAccessMessagePDU The unsegmented message.
     * @param sequenceNumber              The sequence number of the message.
     * @param src                         The source address of the message.
     * @param dst                         The destination address of the message.
     * @return True if the decryption is successful, false otherwise.
     */
    public  parseAndDecryptUnsegmentedMessage( unsegmentedAccessMessagePDU: UnsegmentedAccessMessagePDU, sequenceNumber: number, src: number, dst: number):boolean {
        this.encryptedPayload = unsegmentedAccessMessagePDU.upperTransportPDU
        this.decryptedPayload = this.decrypt(unsegmentedAccessMessagePDU.akf, unsegmentedAccessMessagePDU.aid, 0, sequenceNumber, src, dst);
        return this.decryptedPayload != undefined;
    }


    /**
     * Encrypts the given access PDU data.
     *
     * @param accessPduData The access PDU data to be encrypted.
     * @param szmic         The size of the message integrity check (MIC).
     * @param accessType    The type of access (application or device).
     * @param seqNo         The sequence number of the message.
     * @param src           The source address of the message.
     * @param dst           The destination address of the message.
     * @return True if the encryption is successful, false otherwise.
     */
    public  encrypt( accessPduData: Uint8Array,  szmic: number,  accessType:AccessType,  seqNo: number,  src: number,  dst: number) : boolean{
        this.decryptedPayload = accessPduData;
        let seqNoBuffer = num2bytes(seqNo, 3, ByteOrder.BIG_ENDIAN);
        let nonce = generateAccessNonce(szmic, seqNoBuffer, src, dst, this.mEncryptionSuite.ivIndex, accessType);
        let mic  = getMicSize(szmic);
        let key: Uint8Array;
        if (accessType == AccessType.APPLICATION) {
            key = this.mEncryptionSuite.appKeyList![0];
        } else {
            key = this.mEncryptionSuite.deviceKey!
        }
        if (key == null) {
            loge("upper transport encryption err: key null");
            return false;
        }
        this.encryptedPayload = ccm(this.decryptedPayload, key, nonce, mic, true);
        return this.encryptedPayload != null;
    }


    /**
     * Decrypts the encrypted payload data.
     *
     * @param akf            The authentication and key refresh flag.
     * @param aid            The application identifier.
     * @param aszmic         The size of the message integrity check (MIC).
     * @param sequenceNumber The sequence number of the message.
     * @param src            The source address of the message.
     * @param dst            The destination address of the message.
     * @return The decrypted payload data if the decryption is successful, null otherwise.
     */
    private  decrypt(
            akf: number,
            aid: number,
            aszmic: number,
            sequenceNumber: number,
            src: number,
             dst: number) : Uint8Array | undefined{
        let key: Uint8Array | undefined;
        // device key or application key
        let nonce: Uint8Array | undefined
        let seqNo = sequenceNumber2Buffer(sequenceNumber);
        if (AccessType.DEVICE == akf) {
            nonce = generateAccessNonce(aszmic, seqNo, src, dst, this.mEncryptionSuite.ivIndex, AccessType.DEVICE);
            key = this.mEncryptionSuite.deviceKey
            if (!key) {
                loge("decrypt err: device key null");
                return undefined;
            }
            return this.decryptPayload(this.encryptedPayload!, key, nonce, aszmic);
        } else {

            if (this.mEncryptionSuite.appKeyList) {
                let decAid: number
                let decResult: Uint8Array
                for (let appKey of this.mEncryptionSuite.appKeyList) {
                    decAid = generateAid(appKey);
                    if (decAid == aid) {
                        if (!nonce) {
                            nonce = generateAccessNonce(aszmic, seqNo, src, dst, this.mEncryptionSuite.ivIndex, AccessType.APPLICATION);
                        }

                        decResult = this.decryptPayload(this.encryptedPayload!, appKey, nonce, aszmic);
                        if (decResult != null) {
                            return decResult;
                        }
                    }
                }
            }

        }

        return undefined;
    }

    /**
     * Decrypts the payload data using CCM mode.
     *
     * @param payload The payload data to be decrypted.
     * @param key     The encryption key.
     * @param nonce   The nonce for encryption.
     * @param aszmic  The size of the message integrity check (MIC).
     * @return The decrypted payload data if the decryption is successful, null otherwise.
     */
    private  decryptPayload(payload: Uint8Array, key: Uint8Array, nonce: Uint8Array, aszmic: number):Uint8Array {
        if (aszmic == 1) {
            return ccm(payload, key, nonce, 8, false);
        } else {
            return ccm(payload, key, nonce, 4, false);
        }
    }

}


/**
 * This class represents the encryption suite used for encrypting and decrypting the payload.
 */
export  interface  UpperTransportEncryptionSuite {
     appKeyList?: ArrayList<Uint8Array>;
      deviceKey?: Uint8Array;
     ivIndex: number;
}

