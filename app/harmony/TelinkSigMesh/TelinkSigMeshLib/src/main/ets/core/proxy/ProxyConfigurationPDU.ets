/********************************************************************************************************
 * @file     ProxyConfigurationPDU.ets 
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
 * @file ProxyConfigurationPDU.ets
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
import { NetworkEncryptionSuite, NetworkLayerPDU } from "../networking/NetworkLayerPDU";
import { generateProxyNonce } from "../networking/NonceGenerator";

/**
 * Created by kee on 2019/8/26.
 */

/**
 * This class represents a Proxy Configuration Protocol Data Unit (PDU) in the network layer.
 * <p>
 * The ProxyConfigurationPDU constructor takes a NetworkEncryptionSuite object as a parameter.
 */
export class ProxyConfigurationPDU extends NetworkLayerPDU {
    public static readonly ctl = 1;
    /**
     * time to live
     */
    public static readonly ttl = 0;
    /**
     * destination
     */
    public static readonly dst = 0x00;

    public constructor(encryptionSuite: NetworkEncryptionSuite) {
        super(encryptionSuite);
    }

    /**
     * generate a nonce for the Proxy Configuration PDU.
     * uses the sequence number, source address, and encryption suite's initialization vector (ivIndex) to generate the nonce.
     *
     * @return
     */
    protected generateNonce(): Uint8Array {
        let seqNo = num2bytes(this.seq, 3, ByteOrder.BIG_ENDIAN);
        return generateProxyNonce(seqNo, this.src, this.encryptionSuite.ivIndex);
    }
}
