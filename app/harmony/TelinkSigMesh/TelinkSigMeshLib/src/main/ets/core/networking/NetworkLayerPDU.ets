/********************************************************************************************************
 * @file NetworkLayerPDU.java
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
import { ByteOrder, bytes2Integer, bytesToHexString, num2bytes, num2Hex } from "../../utils/ArrayUtils";
import { aesEcb, ccm } from "../../utils/Encipher";
import { logi } from "../../utils/MeshLogger";
import { generateNetworkNonce } from "./NonceGenerator";

export class NetworkLayerPDU {
    /**
     * Least significant bit of IV Index
     * 1 bit
     */
    public ivi: number = 0;
    /**
     * network id
     * 7 bits
     * Value derived from the NetKey used to identify the Encryption Key and Privacy Key used to secure this PDU
     */
    public nid: number = 0;
    /**
     * Network Control
     * 1 bit
     * determine if the message is part of a Control MeshCommand or an Access MeshCommand
     */
    public ctl = 0;
    /**
     * Time To Live
     * 7 bits
     * value:
     * 0 = has not been relayed and will not be relayed
     * 1 = may have been relayed, but will not be relayed
     * 2 to 126 = may have been relayed and can be relayed
     * 127 = has not been relayed and can be relayed
     */
    public ttl = 0;
    /**
     * Sequence Number
     * 24 bits == 3 bytes
     */
    public seq = 0;
    /**
     * Source Address
     * 16 bits == 2 bytes
     * shall be unicast address
     */
    public src = 0;
    /**
     * Destination Address
     * 16 bits == 2 bytes
     * shall be a unicast address, a group address, or a virtual address
     */
    public dst = 0;
    /**
     * Transport Protocol Data Unit
     * 8 to 128 bits
     * When the CTL bit is 0, the TransportPDU field shall be a maximum of 128 bits.
     * When the CTL bit is 1, the TransportPDU field shall be a maximum of 96 bits.
     */
    public transportPDU = new Uint8Array(0)
    /**
     * MeshCommand Integrity Check for Network
     * 32 or 64 bits
     * When the CTL bit is 0, the NetMIC field shall be 32 bits.
     * When the CTL bit is 1, the NetMIC field shall be 64 bits.
     */
    //    private int transMic;
    public encryptionSuite: NetworkEncryptionSuite;

    /**
     * This constructor initializes a NetworkLayerPDU object with the specified encryption suite.
     * The encryption suite is used to provide security measures for the network layer protocol data unit.
     *
     * @param encryptionSuite enc
     */
    public constructor(encryptionSuite: NetworkEncryptionSuite) {
        this.encryptionSuite = encryptionSuite;
    }

    /*public NetworkLayerPDU(int ivIndex, byte[] encryptionKey, byte[] privacyKey, int nid) {
        this.ivIndex = ivIndex;
        this.encryptionKey = encryptionKey;
        this.privacyKey = privacyKey;
        this.nid = nid;
    }*/

    /**
     * generates an encrypted payload for a network PDU
     *
     * @return pdu data
     */
    public generateEncryptedPayload(): Uint8Array {
        const iviNid = ((this.ivi << 7) | (this.nid & 0x7F));
        const ctlTTL = ((this.ctl << 7) | (this.ttl & 0x7F));

        let encryptedPayload = this.encryptNetworkPduPayload(this.transportPDU);
        //        MeshLogger.log("encryptedPayload: " + Arrays.bytesToHexString(encryptedPayload, ""));
        let privacyRandom = this.createPrivacyRandom(encryptedPayload);
        const pecb = this.createPECB(privacyRandom);
        //        MeshLogger.log("pecb: " + Arrays.bytesToHexString(pecb, ""));

        const header: Uint8Array = this.createObfuscatedNetworkHeader(ctlTTL, this.seq, this.src, pecb);
        //        MeshLogger.log("obfuscateNetworkHeader: " + Arrays.bytesToHexString(header, ""));
        let buf = new Uint8Array(1 + header.length + encryptedPayload.length)
        buf[0] = iviNid
        buf.set(header, 1)
        buf.set(encryptedPayload, 1 + header.length)
        return buf
    }

    /**
     * creates an obfuscated network header by combining various parameters.
     *
     * @param ctlTTL control TTL (Time to Live)
     * @param sno    sequence number
     * @param src    source address
     * @param pecb   pecb
     * @return header
     */
    private createObfuscatedNetworkHeader(ctlTTL: number, sno: number, src: number, pecb: Uint8Array): Uint8Array {

        let seqNo = num2bytes(sno, 3, ByteOrder.BIG_ENDIAN);
        let headerBuf = new Uint8Array(1 + seqNo.length + 2)
        headerBuf[0] = ctlTTL
        headerBuf.set(seqNo, 1)
        headerBuf.set(num2bytes(src, 2, ByteOrder.BIG_ENDIAN), 4)

        const obfuscated = new Uint8Array(6)
        for (let i = 0; i < 6; i++) {
            obfuscated[i] = headerBuf[i] ^ pecb[i]
        }
        return obfuscated;
    }

    /**
     * This method creates a PECB (Privacy Encryption and Control Block) by combining the privacy random value with other parameters.
     * It first creates a ByteBuffer with a specific size and order.
     * Then, it populates the buffer with a sequence of bytes, including the privacy random value.
     * Finally, it encrypts the buffer using AES encryption with the privacy key and returns the encrypted data.
     *
     * @param privacyRandom random
     * @return PECB
     */
    private createPECB(privacyRandom: Uint8Array): Uint8Array {
        let buffer = new Uint8Array(5 + privacyRandom.length + 4);
        buffer.set(new Uint8Array([0x00, 0x00, 0x00, 0x00, 0x00]), 0);
        buffer.set(num2bytes(this.encryptionSuite.ivIndex, 4, ByteOrder.BIG_ENDIAN), 5)
        buffer.set(privacyRandom, 9)
        return aesEcb(buffer, this.encryptionSuite.privacyKey);
    }

    /**
     * This method extracts the privacy random value from the encrypted upper transport PDU (Protocol Data Unit)
     * and returns it as a byte array.
     *
     * @param encryptedUpperTransportPDU PDU
     * @return random
     */
    private createPrivacyRandom(encryptedUpperTransportPDU: Uint8Array): Uint8Array {
        const privacyRandom = new Uint8Array(7);
        privacyRandom.set(encryptedUpperTransportPDU.slice(0, 7))
        return privacyRandom;
    }

    /**
     * This method encrypts the payload of a network PDU by combining it with other parameters.
     * It first generates a network nonce using specific parameters.
     * Then, it creates an unencrypted network payload by combining the destination address and the lower PDU.
     * Finally, it encrypts the unencrypted payload using CCM (Counter with CBC-MAC) mode with the encryption key, network nonce, and a specific MIC (Message Integrity Code) length,
     * and returns the encrypted data.
     *
     * @param lowerPDU lower transport PDU
     * @return payload
     */
    private encryptNetworkPduPayload(lowerPDU: Uint8Array): Uint8Array {
        let networkNonce = this.generateNonce();
        //        MeshLogger.log("networkNonce: " + Arrays.bytesToHexString(networkNonce, ""));
        let unencryptedNetworkPayload = new Uint8Array(2 + lowerPDU.length)
        unencryptedNetworkPayload.set(num2bytes(this.dst, 2, ByteOrder.BIG_ENDIAN), 0)
        unencryptedNetworkPayload.set(lowerPDU, 2)
        return ccm(unencryptedNetworkPayload, this.encryptionSuite.encryptionKey, networkNonce, this.getMicLen(), true);
    }

    /**
     * This method generates a network nonce by
     * combining the CTL (Control) and TTL (Time to Live) values,
     * the sequence number, the source address, and the IV Index (Initialization Vector Index).
     * It returns the generated nonce as a byte array.
     *
     * @return nonce
     */
    protected generateNonce(): Uint8Array {
        let ctlTTL = (this.ctl << 7) | this.ttl
        let seqNo = num2bytes(this.seq, 3, ByteOrder.BIG_ENDIAN);
        return generateNetworkNonce(ctlTTL, seqNo, this.src, this.encryptionSuite.ivIndex);
    }

    /**
     * This method determines the MIC length based on the value of the CTL.
     * If the CTL is 0, the MIC length is 4; otherwise, it is 8.
     *
     * @return mic length
     */
    private getMicLen(): number {
        return this.ctl == 0 ? 4 : 8;
    }

    /**0
     * parse header
     *
     * @param pdu input pdu
     */
    public parseObfuscatedNetworkHeader(pdu: Uint8Array): Uint8Array {
        const obfuscatedData = new Uint8Array(6)
        // obfuscatedNetworkBuffer.order(ByteOrder.BIG_ENDIAN);
        obfuscatedData.set(pdu.slice(1, 7), 0);

        let privacyRandomBuffer = new Uint8Array(7)
        privacyRandomBuffer.set(pdu.slice(7, 14), 0);
        const privacyRandom = this.createPrivacyRandom(privacyRandomBuffer);

        const pecb = this.createPECB(privacyRandom);
        const deobfuscatedData = new Uint8Array(6);

        for (let i = 0; i < 6; i++) {
            deobfuscatedData[i] = obfuscatedData[i] ^ pecb[i]
        }

        return deobfuscatedData;
    }

    /**
     * parse pdu
     *
     * @param pduData data
     * @return parse result
     */
    public parse(pduData: Uint8Array): boolean {

        let iviNid = pduData[0] & 0xFF;
        let ivi = iviNid >> 7;
        let nid = iviNid & 0x7F;
        //        MeshLogger.i("ivi -- " + ivi + " nid -- " + nid);
        if (!this.validateNetworkPdu(ivi, nid)) {
            logi("ivi or nid invalid: ivi -- " + ivi + " nid -- " + nid +
                " encryptSuit : ivi -- " + this.encryptionSuite.ivIndex + " nid -- " + this.encryptionSuite.nid);
            return false;
        }

        let originalHeader = this.parseObfuscatedNetworkHeader(pduData);
        let ctlTtl = originalHeader[0];
        let ctl = (ctlTtl >> 7) & 0x01;
        let ttl = ctlTtl & 0x7F;
        let sequenceNumber = originalHeader.slice(1, 4)
        let src = (((originalHeader[4] & 0xFF) << 8) + (originalHeader[5] & 0xFF));
        this.ivi = ivi
        this.nid = nid
        this.ctl = ctl
        this.ttl = ttl
        this.seq = bytes2Integer(sequenceNumber, 0, 3, ByteOrder.BIG_ENDIAN);
        this.src = src

        let networkNonce = this.generateNonce();
        //        byte[] networkNonce = NonceGenerator.generateNetworkNonce((byte) ctlTtl, sequenceNumber, src, this.encryptionSuite.ivIndex);


        let dstTransportLen = pduData.length - (1 + originalHeader.length);

        let dstTransportPayload = pduData.slice(7, 7 + dstTransportLen)

        // decrypted dest + transport(lower) payload
        let decDstTransportPayload =
            ccm(dstTransportPayload, this.encryptionSuite.encryptionKey, networkNonce, this.getMicLen(), false);

        if (decDstTransportPayload == null) {
            logi("network layer decrypt err");
            return false;
        }

        let dstAdr = ((decDstTransportPayload[0] & 0xFF) << 8) | (decDstTransportPayload[1] & 0xFF);

        let lowerTransportPdu = decDstTransportPayload.slice(2, decDstTransportPayload.length)
        this.dst = dstAdr;
        this.transportPDU = lowerTransportPdu
        return true;
    }

    /**
     * used to validate a network PDU (Protocol Data Unit) based on the given IVI (Initialization Vector Index) and NID (Network Identifier). It checks if the NID matches the encryption suite's NID and if the IVI matches the least significant bit of the encryption suite's IV Index.
     *
     * @param ivi ivi
     * @param nid nid
     * @return check result
     */
    private validateNetworkPdu(ivi: number, nid: number): boolean {
        return nid == this.encryptionSuite.nid && ivi == (this.encryptionSuite.ivIndex & 0b01);
    }

    public toString() {
        return `NetworkLayerPDU{ivi=${this.ivi} , nid=${this.nid} , ctl=${this.ctl} , ttl=${this.ttl} , seq=0x${num2Hex(this.seq,
            8)} , src=0x${num2Hex(this.src, 4)}, dst=0x${num2Hex(this.dst,
            4)} , transportPDU=${bytesToHexString(this.transportPDU)}}`
    }
}


export interface NetworkEncryptionSuite {

    // for encryption
    ivIndex: number;
    encryptionKey: Uint8Array;
    privacyKey: Uint8Array;
    nid: number;

}

