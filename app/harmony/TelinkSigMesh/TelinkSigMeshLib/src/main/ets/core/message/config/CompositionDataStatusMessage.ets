/********************************************************************************************************
 * @file CompositionDataStatusMessage.java
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
import { CompositionData } from '../../../entity/CompositionData';
import { bytesToHexString } from '../../../utils/ArrayUtils';
import { logd } from '../../../utils/MeshLogger';
import { StatusMessage } from '../StatusMessage';

/**
 * The Config Composition Data Status is an unacknowledged message used to report a single page of the Composition Data
 */
export  class CompositionDataStatusMessage extends StatusMessage  {
    public static readonly STATUS_NAME = "CompositionDataStatusMessage"

    public statusName(): string {
        return CompositionDataStatusMessage.STATUS_NAME
    }

    /**
     * Page number of the Composition Data
     */
    public   page = 0;

    /**
     * Composition Data for the identified page
     */
    public   compositionData?: CompositionData;

    /**
     * Constructs a new CompositionDataStatusMessage object.
     */
    public CompositionDataStatusMessage() {
    }

    /**
     * Parses the parameters of the CompositionDataStatusMessage from a byte array.
     *
     * @param params the byte array containing the parameters of the CompositionDataStatusMessage
     */
    public  parse( params: Uint8Array) {
        this.page = params[0];
        let cpsData = params.slice(1)
        logd("cps data - " + bytesToHexString(cpsData));
        this.compositionData = CompositionData.from(cpsData);
    }
}
