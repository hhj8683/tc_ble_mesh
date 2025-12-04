/********************************************************************************************************
 * @file MeshMessage.java
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
import { AccessType } from "../networking/AccessType";

/**
 * Created by kee on 2019/8/14.
 * This class represents a mesh message.
 */
export class MeshMessage {
    /**
     * access message
     */
    public static readonly CTL_ACCESS = 0;
    /**
     * control message
     * never used by api
     */
    public static readonly CTL_CONTROL = 1;
    /**
     * default retry count
     */
    public static readonly DEFAULT_RETRY_CNT = 2;
    /**
     * default szmic
     */
    public static readonly DEFAULT_ASZMIC = 0;
    /**
     * invalid opcode
     */
    public static readonly OPCODE_INVALID = -1;
    public static readonly DEFAULT_TTL = 10;
    /**
     * ms
     */
    public static readonly DEFAULT_RETRY_INTERVAL = 1280;
    /**
     * message opcode
     * {@link AccessLayerPDU#opcode}
     */
    protected opcode = 0;
    /**
     * message params
     * {@link AccessLayerPDU#params}
     */
    protected params?: Uint8Array;
    /**
     * device key or appliction key determined by accessType {@link #accessType}
     */
    public accessKey?: Uint8Array;
    /**
     * access typeValue
     *
     * @see AccessType#DEVICE for config message
     * @see AccessType#APPLICATION for common message
     */
    public accessType = AccessType.APPLICATION;
    /**
     * only used when accessType==APPLICATION
     */
    public appKeyIndex = 0;
    /**
     * 0: 4 bytes trans mic
     * 1: 8 bytes trans mic
     */
    public szmic = MeshMessage.DEFAULT_ASZMIC;
    /**
     * source address
     * Will be assigned by local address
     */
    public sourceAddress = 0;
    /**
     * dest address
     */
    public destinationAddress = 0;
    public ctl = MeshMessage.CTL_ACCESS;
    public ttl = MeshMessage.DEFAULT_TTL;
    public retryCnt = MeshMessage.DEFAULT_RETRY_CNT;
    public retryInterval = MeshMessage.DEFAULT_RETRY_INTERVAL;
    public responseMax = 0;
    /**
     * if message contains tid
     *
     * @see com.telink.ble.mesh.core.networking.NetworkingController#tid
     */
    //    protected boolean containsTid = false;


    //    boolean reliable = false;

    /**
     * message response opcode
     * defines message is reliable {@link #isReliable()}
     */
    public responseOpcode = MeshMessage.OPCODE_INVALID;
    /**
     * tid position in params
     * if message dose not contains tid, tid position should be invalid value (such as -1)
     */
    public tidPosition = -1;
    public isSegmented = false;

    /**
     * used to set whether the message needs to use a group
     */
    // protected MulticastMessageBroker.Config brokerConfig;

    /**
     * Checks if the message is reliable.
     * if true, message will be cached and checked completion by message response or retryCnt == 0
     * if false, message will not be cached and checked
     */
    public isReliable(): boolean {
        return this.responseOpcode != MeshMessage.OPCODE_INVALID;
    }

    /**
     * Gets the opcode of the message.
     *
     * @return the opcode.
     */
    public getOpcode(): number {
        return this.opcode;
    }

    /**
     * Gets the response opcode of the message.
     *
     * @return The response opcode value.
     */
    public getResponseOpcode(): number {
        return MeshMessage.OPCODE_INVALID
    }

    /**
     * Gets the parameters of the message.
     *
     * @return the parameters.
     */
    public getParams(): Uint8Array | undefined {
        return this.params;
    }


    // public boolean useMultiMessageBroker() {
    //     return !MeshUtils.validUnicastAddress(getDestinationAddress()) && isReliable() && brokerConfig != null;
    // }

    // public MulticastMessageBroker.Config getBrokerConfig() {
    //     return brokerConfig;
    // }
    //
    // public void setBrokerConfig(MulticastMessageBroker.Config brokerConfig) {
    //     this.brokerConfig = brokerConfig;
    // }


}
