/********************************************************************************************************
 * @file ModelPublication.ets
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
import { num2bytes } from "../utils/ArrayUtils";
import { TransitionTime } from "./TransitionTime";


/**
 * This class represents a model publication in the Bluetooth Mesh network.
 * publication entity used when send publicationSet message or receive publication status message
 * Created by kee on 2018/9/17.
 */
export class ModelPublication {
    /**
     * changed from 1 to 0, because of device may not have friend key
     */
    public static readonly CREDENTIAL_FLAG_DEFAULT = 0b0;
    public static readonly RFU_DEFAULT = 0x00;
    // use default ttl in firmware
    public static readonly TTL_DEFAULT = 0xFF;
    /**
     * default retransmit: 0x15
     * 0b 00010 101
     * count: 0x05, step: 0x02
     */
    public static readonly RETRANSMIT_COUNT_DEFAULT = 0x05;
    // unit: 50ms, from 0x02 to 0x00
    public static readonly RETRANSMIT_INTERVAL_STEP_DEFAULT = 0x00;
    /**
     * element address
     * 16 bits
     */
    public elementAddress = 0;
    /**
     * Value of the publish address
     * 16 bits
     */
    public publishAddress = 0;
    /**
     * Index of the application key
     * 12 bits
     */
    public appKeyIndex = 0;
    /**
     * Value of the Friendship Credential Flag
     * 1 bit
     * 0 Master security material is used for Publishing
     * 1 Friendship security material is used for Publishing， used on LPN
     */
    public credentialFlag = ModelPublication.CREDENTIAL_FLAG_DEFAULT;
    /**
     * 3 bits
     * reserved for future use
     */
    public rfu = ModelPublication.RFU_DEFAULT;
    /**
     * Default TTL value for the outgoing messages
     * 8 bits
     */
    public ttl = ModelPublication.TTL_DEFAULT;
    /**
     * Period for periodic status publishing
     * 8 bits
     */
    public period = 0;
    /**
     * Number of retransmissions for each published message
     * 3 bits
     */
    public retransmitCount = ModelPublication.RETRANSMIT_COUNT_DEFAULT;
    /**
     * Number of 50-millisecond steps between retransmissions
     * 5 bits
     */
    public retransmitIntervalSteps = ModelPublication.RETRANSMIT_INTERVAL_STEP_DEFAULT;
    /**
     * SIG Model ID or Vendor Model ID
     * 16 or 32 bits
     */
    public modelId = 0;
    /**
     * if sig model
     * #modelId
     */
    public sig = true;

    /**
     * Constructs a new ModelPublication object.
     * This is used for creating a default instance of the class.
     */
    public constructor() {
    }

    /**
     * Creates a default ModelPublication object with the specified parameters.
     *
     * @param elementAddress    The element address.
     * @param publishAddress    The publish address.
     * @param appKeyIndex       The index of the application key.
     * @param periodMillisecond The period for periodic status publishing in milliseconds.
     * @param modelId           The SIG Model ID or Vendor Model ID.
     * @param sig               Indicates whether the model is a SIG model.
     * @return A new instance of the ModelPublication class with the specified parameters.
     */
    public static createDefault(elementAddress: number, publishAddress: number,
        appKeyIndex: number, periodMillisecond: number, modelId: number, sig: boolean): ModelPublication {
        let instance = new ModelPublication();
        instance.elementAddress = elementAddress;
        instance.publishAddress = publishAddress;
        instance.appKeyIndex = appKeyIndex;
        instance.period = TransitionTime.fromTime(periodMillisecond).getValue();
        instance.modelId = modelId;
        instance.sig = sig;
        return instance;
    }

    /**
     * Converts the ModelPublication object to a byte array.
     *
     * @return The byte array representation of the ModelPublication object.
     */
    public toBytes(): Uint8Array {
        const len = this.sig ? 11 : 13;
        // ByteBuffer bf = ByteBuffer.allocate(len).order(ByteOrder.LITTLE_ENDIAN);
        let bf = new Uint8Array(len)
        let offset = 0
        bf.set(num2bytes(this.elementAddress, 2), offset)
        offset += 2
        bf.set(num2bytes(this.publishAddress, 2), offset)
        offset += 2
        bf.set(num2bytes(((this.appKeyIndex & 0xFFF) | ((this.credentialFlag & 0b01) << 12) |
            ((this.rfu & 0b111) << 13)), 2), offset)
        offset += 2
        bf[offset++] = this.ttl
        bf[offset++] = this.period
        bf[offset++] = ((this.retransmitCount & 0b111) | (this.retransmitIntervalSteps << 3))
        bf.set(num2bytes(this.modelId, this.sig ? 2 : 4), offset)

        return bf
    }
}
