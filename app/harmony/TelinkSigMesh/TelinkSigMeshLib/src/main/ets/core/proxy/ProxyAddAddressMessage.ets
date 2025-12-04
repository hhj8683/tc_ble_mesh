/********************************************************************************************************
 * @file ProxyAddAddressMessage.java
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
import { ProxyConfigurationMessage } from "./ProxyConfigurationMessage";


/**
 * Created by kee on 2019/8/26.
 */

/**
 * This class represents a message to add addresses to a proxy configuration.
 * It extends the ProxyConfigurationMessage class.
 */
export  class ProxyAddAddressMessage extends ProxyConfigurationMessage {

    private addressArray: Uint16Array; // Array of addresses to be added

    /**
     * Constructs a new ProxyAddAddressMessage with the given address array.
     *
     * @param addressArray the array of addresses to be added
     */
    public constructor( addressArray: Uint16Array) {
        super();
        this.addressArray = addressArray;
    }

    /**
     * Returns the opcode for this message.
     *
     * @return the opcode for adding addresses
     */
    public  getOpcode(): number {
        return ProxyAddAddressMessage.OPCODE_ADD_ADDRESS;
    }

    /**
     * Converts the message to a byte array for transmission.
     *
     * @return the byte array representation of the message
     */
    public  toByteArray(): Uint8Array {
        let len = 1 + this.addressArray.length * 2; // Calculate the length of the byte array
        let buffer = new Uint8Array(len) // Create a byte buffer with the calculated length
        buffer[0] = this.getOpcode()
        let dv = new DataView(buffer.buffer)
        for (let i = 0; i < this.addressArray.length; i++) {
            dv.setUint16(i * 2 + 1, this.addressArray[i], false)
        }
        return buffer
    }
}