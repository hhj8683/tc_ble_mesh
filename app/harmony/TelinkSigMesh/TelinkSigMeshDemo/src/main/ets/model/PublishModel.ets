/********************************************************************************************************
 * @file PublishModel.ets
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
import { ModelPublication, TransitionTime } from 'telinksigmeshlib';

/**
 * for model status publication
 * Created by kee on 2018/12/18.
 */
export class PublishModel {
    public static readonly CREDENTIAL_FLAG_DEFAULT = 0b0;
    public static readonly RFU_DEFAULT = 0x0C;
    // 0 for time model
    // 30 s
    // use default ttl in device
    public static readonly TTL_DEFAULT = 0xFF;
    // 0 for time model
    /**
     * default retransmit: 0x15
     * 0b 00010 101
     * count: 0x05, step: 0x02
     */
    public static readonly RETRANSMIT_COUNT_DEFAULT = 0x05;
    public static readonly RETRANSMIT_INTERVAL_STEP_DEFAULT = 0x02;
    public elementAddress = 0
    public modelId: number = 0
    // publish address
    public address: number = 0
    public period: number = 0
    public ttl: number = 0
    public credential: number = 0
    public transmit: number = 0

    public constructor() {

    }

    public static getSimple(elementAddress: number, modelId: number, address: number, period: number): PublishModel {
        return PublishModel.getByParams(elementAddress, modelId, address, period, PublishModel.TTL_DEFAULT,
            PublishModel.CREDENTIAL_FLAG_DEFAULT,
            ((PublishModel.RETRANSMIT_COUNT_DEFAULT & 0b111) | (PublishModel.RETRANSMIT_INTERVAL_STEP_DEFAULT << 3)));
    }

    public static getByParams(elementAddress: number, modelId: number, address: number, period: number, ttl: number,
        credential: number, transmit: number): PublishModel {
        let re = new PublishModel()
        re.elementAddress = elementAddress;
        re.modelId = modelId;
        re.address = address;
        re.period = period;
        re.ttl = ttl;
        re.credential = credential;
        re.transmit = transmit;
        return re
    }

    // higher 5 bit
    public getTransmitInterval() {
        return (this.transmit & 0xFF) >> 3;
    }

    // lower 3 bit
    public getTransmitCount() {
        return (this.transmit & 0xFF) & 0b111;
    }

    public static fromPublication(publication: ModelPublication): PublishModel {
        let publishModel = new PublishModel();
        publishModel.elementAddress = publication.elementAddress;
        publishModel.address = publication.publishAddress;
        publishModel.modelId = publication.modelId;
        publishModel.transmit = ((publication.retransmitCount & 0b111) | (publication.retransmitIntervalSteps << 3));
        publishModel.period = TransitionTime.getTimeMilliseconds(publication.period);
        publishModel.credential = publication.credentialFlag;
        publishModel.ttl = publication.ttl;
        return publishModel;
    }
}
