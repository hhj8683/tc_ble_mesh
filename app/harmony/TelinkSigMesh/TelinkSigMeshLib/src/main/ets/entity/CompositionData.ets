/********************************************************************************************************
 * @file CompositionData.java
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
import { ByteOrder, bytes2Integer, bytesToHexString, num2bytes, num2Hex } from "../utils/ArrayUtils";
import { loge } from "../utils/MeshLogger";
import { Element } from "./Element";
import { ArrayList } from "@kit.ArkTS";
import { getModelName, MeshSigModel } from "../foundation/MeshSigModel";

/**
 * CompositionData class represents the composition data of a Bluetooth device in a mesh network.
 * It implements the Serializable and Parcelable interfaces for data serialization and deserialization.
 */
export class CompositionData {
    /**
     * bit 0 Relay feature support: 0 = False, 1 = True
     */
    private static readonly FEATURE_RELAY = 0b0001;
    /**
     * bit 1 Proxy feature support: 0 = False, 1 = True
     */
    private static readonly FEATURE_PROXY = 0b0010;
    /**
     * bit 2 Friend feature support: 0 = False, 1 = True
     */
    private static readonly FEATURE_FRIEND = 0b0100;
    /**
     * bit 3 Low Power feature support: 0 = False, 1 = True
     */
    private static readonly FEATURE_LOW_POWER = 0b1000;
    /**
     * Contains a 16-bit company identifier assigned by the Bluetooth SIG
     */
    public cid = 0;
    /**
     * Contains a 16-bit vendor-assigned product identifier
     */
    public pid = 0;
    /**
     * Big-endian
     * Contains a 16-bit vendor-assigned product version identifier
     */
    public vid = 0;
    /**
     * Contains a 16-bit value representing the minimum number of replay protection list entries in a device
     */
    public crpl = 0;
    /**
     * supported features
     * 16 bits
     */
    public features = 0;
    /**
     * The list of elements present in the device.
     */
    public elements: Element[] = []
    /**
     * The raw byte array representation of the composition data.
     */
    public raw = ''

    /**
     * Default constructor for the CompositionData class.
     */
    public constructor() {

    }

    /**
     * Creates a CompositionData object from the given byte array.
     *
     * @param data The byte array representing the composition data.
     * @return The CompositionData object created from the byte array.
     */
    public static from(data: Uint8Array): CompositionData | undefined {
        // length 10 means cid + pid + vid + crpl + features
        if (data == null || data.length < 10) {
            return undefined;
        }

        let index = 0;
        let cpsData = new CompositionData();
        cpsData.raw = bytesToHexString(data)
        cpsData.cid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.pid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        //        cpsData.vid = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.vid = bytes2Integer(data, index, 2, ByteOrder.BIG_ENDIAN); // // big endian
        index += 2;

        cpsData.crpl = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
        cpsData.features = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);

        cpsData.elements = []
        try {
            while (index < data.length) {
                let element = new Element();
                element.location = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8);
                element.sigNum = (data[index++] & 0xFF);
                element.vendorNum = (data[index++] & 0xFF);


                element.sigModels = new Array(element.sigNum);
                for (let i = 0; i < element.sigNum; i++) {
                    element.sigModels[i] = (data[index++] & 0xFF) | ((data[index++] & 0xFF) << 8)
                }

                element.vendorModels = new Array(element.vendorNum);
                for (let j = 0; j < element.vendorNum; j++) {
                    //sample 11 02 01 00 cid: 11 02 modelId: 01 00 -> 0x00010211
                    element.vendorModels[j] = ((data[index++] & 0xFF)) | ((data[index++] & 0xFF) << 8) |
                        ((data[index++] & 0xFF) << 16) | ((data[index++] & 0xFF) << 24)
                }
                cpsData.elements.push(element);
            }

            return cpsData;
        } catch (e) {
            loge("parse cps err")
        }
        return undefined
    }

    /**
     * Converts the CompositionData object to a byte array.
     *
     * @return The byte array representation of the CompositionData object.
     */
    public toBytes(): Uint8Array {
        //        if (raw != null) return raw;
        let re = new Uint8Array(10)
        re.set(num2bytes(this.cid, 2, ByteOrder.LITTLE_ENDIAN))
        re.set(num2bytes(this.pid, 2, ByteOrder.LITTLE_ENDIAN))
        re.set(num2bytes(this.vid, 2, ByteOrder.BIG_ENDIAN))
        re.set(num2bytes(this.crpl, 2, ByteOrder.LITTLE_ENDIAN))
        re.set(num2bytes(this.features, 2, ByteOrder.LITTLE_ENDIAN))
        let eleLen: number;
        let bf: Uint8Array;
        for (let ele of this.elements) {
            eleLen = 4 + ele.sigNum * 2 + ele.vendorNum * 4;
            let offset = 0
            bf = new Uint8Array(re.length + eleLen)
            bf.set(re, 0)
            offset += re.length
            bf.set(num2bytes(ele.location, 2), offset)
            offset += 2
            bf[offset++] = ele.sigNum
            bf[offset++] = ele.vendorNum

            for (let modelId of ele.sigModels) {
                bf.set(num2bytes(modelId, 2), offset)
                offset += 2
            }
            for (let modelId of ele.vendorModels) {
                bf.set(num2bytes(modelId, 4), offset)
                offset += 4
            }
            re = bf
        }
        return re;
    }


    /**
     * Retrieves the element offset of the specified model.
     *
     * @param modelId The model identifier.
     * @return The element offset of the specified model, or -1 if not found.
     */
    public getElementOffset(modelId: number): number {
        let offset = 0;
        for (let ele of this.elements) {
            if (ele.sigModels != null && ele.sigModels.includes(modelId)) {
                return offset;
            }
            if (ele.vendorModels != null && ele.vendorModels.includes(modelId)) {
                return offset;
            }
            offset++;
        }
        return -1;
    }

    /**
     * Checks if the device supports the relay feature.
     *
     * @return True if the device supports the relay feature, false otherwise.
     */
    public relaySupport(): boolean {
        return (this.features & CompositionData.FEATURE_RELAY) != 0;
    }

    /**
     * Checks if the device supports the proxy feature.
     *
     * @return True if the device supports the proxy feature, false otherwise.
     */
    public proxySupport(): boolean {
        return (this.features & CompositionData.FEATURE_PROXY) != 0;
    }

    /**
     * Checks if the device supports the friend feature.
     *
     * @return True if the device supports the friend feature, false otherwise.
     */
    public friendSupport(): boolean {
        return (this.features & CompositionData.FEATURE_FRIEND) != 0;
    }

    /**
     * Checks if the device supports the low power feature.
     *
     * @return True if the device supports the low power feature, false otherwise.
     */
    public lowPowerSupport(): boolean {
        return (this.features & CompositionData.FEATURE_LOW_POWER) != 0;
    }

    public toString(): string {
        let elementInfo: string = ""
        let element: Element;
        for (let i = 0; i < this.elements.length; i++) {
            element = this.elements[i]
            elementInfo += ("element ") + (i) + (" : \n");
            elementInfo += ("location: ") + (element.location) + ("\n");
            elementInfo += ("SIG models-") + (element.sigModels.length) + (":");
            let sig: string;
            for (let j = 0; j < element.sigModels.length; j++) {
                sig = num2Hex(element.sigModels[j])
                elementInfo += sig + " "
            }
            elementInfo += ("\n");
            //            elementInfo.append("VENDOR\n");
            elementInfo += ("Vendor models-") + (element.vendorModels.length) + (":");
            for (let j = 0; j < element.vendorModels.length; j++) {
                elementInfo += num2Hex(element.vendorModels[j], 8)
            }
            elementInfo += "\n"
        }

        return "CompositionData{" +
            "cid=" + num2Hex(this.cid, 4) +
            ", pid=" + num2Hex(this.pid, 4) +
            ", vid=" + num2Hex(this.vid, 4) +
            ", crpl=" + num2Hex(this.crpl, 4) +
            ", features=" + num2Hex(this.features, 4) +
            ", elements=\n" + elementInfo +
            '}';
    }


    public toFormatString(): string {
        let sb = `Composition-Data:\n
        cid: ${num2Hex(this.cid, 4)}\n
        pid: ${num2Hex(this.pid, 4)}\n
        vid: ${num2Hex(this.vid, 4)}\n
        crpl: ${num2Hex(this.crpl, 4)}\n
        features: ${num2Hex(this.features, 4)}\n

        \t: relay support:  ${this.relaySupport()}\n
        \t: proxy support:  ${this.proxySupport()}\n
        \t: friend support:  ${this.friendSupport()}\n
        \t: low power support:  ${this.lowPowerSupport()}\n
        `
        // elements
        sb += `elements: (${this.elements.length})\n`
        let elementList = this.elements;
        for (let i = 0; i < elementList.length; i++) {
            let ele = elementList[i]
            sb += `\t element : ${i}\n`
            let meshSigModel: MeshSigModel
            for (let sigModel of ele.sigModels) {
                sb += `\t\tSIG model -- 0x${num2Hex(sigModel, 4)}`
                meshSigModel = sigModel
                if (meshSigModel) {
                    sb += " -- " + getModelName(meshSigModel)
                }
                sb += "\n"
            }

            for (let vendorModel of ele.vendorModels) {
                sb += `\t\tvendor model -- 0x${num2Hex(vendorModel, 6)}\n`
            }
        }

        return sb.toString();
    }
}


