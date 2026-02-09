/********************************************************************************************************
 * @file     ModelPublicationSetMessage.ets 
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
 * @file ModelPublicationSetMessage.ets
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
import { ModelPublication } from '../../../entity/ModelPublication';
import { Opcode } from '../Opcode';
import { ConfigMessage } from './ConfigMessage';

/**
 * The Config Model Publication Set is an acknowledged message used to set the Model Publication state of an outgoing message that originates from a model.
 * <p>
 * The response to a Config Model Publication Set message is a Config Model Publication Status message.
 * {@link ModelPublicationStatusMessage}
 * <p>
 * The Config Model Publication Set Message class represents an outgoing message used to set the Model Publication state of a model.
 * It is used to configure the publication parameters for a specific model on a destination address.
 * The response to this message is a Config Model Publication Status message.
 * Please refer to the ModelPublicationStatusMessage class for more information.
 */
export class ModelPublicationSetMessage extends ConfigMessage {
    private modelPublication: ModelPublication;

    /**
     * Constructs a ModelPublicationSetMessage with the specified destination address and model publication parameters.
     *
     * @param destinationAddress The destination address of the message.
     * @param modelPublication   The model publication parameters to be set.
     */
    public constructor(destinationAddress: number, modelPublication: ModelPublication) {
        super(destinationAddress);
        this.modelPublication = modelPublication;
        this.responseOpcode = Opcode.CFG_MODEL_PUB_STATUS;
        this.responseMax = 1;
    }

    /**
     * Returns the opcode value for the Model Publication Set message.
     *
     * @return The opcode value for the message.
     */
    public getOpcode() {
        return Opcode.CFG_MODEL_PUB_SET;
    }

    /**
     * Returns the response opcode value for the Model Publication Set message.
     *
     * @return The response opcode value for the message.
     */
    public getResponseOpcode() {
        return Opcode.CFG_MODEL_PUB_STATUS;
    }

    /**
     * Returns the byte array representation of the model publication parameters.
     *
     * @return The byte array representation of the model publication parameters.
     */
    public getParams() {
        return this.modelPublication.toBytes();
    }
}