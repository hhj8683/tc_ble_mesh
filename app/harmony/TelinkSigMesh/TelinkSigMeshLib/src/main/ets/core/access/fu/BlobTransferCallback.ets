/********************************************************************************************************
 * @file BlobTransferCallback.ets
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

import { TransferMode } from '../../message/firmwareupdate/blobtransfer/TransferMode';
import { MeshMessage } from '../../message/MeshMessage';
import { BlobTransferType } from './BlobTransferType';

/**
 * Callback interface for blob transfer events
 */
export interface BlobTransferCallback {
    /**
     * progress of chunk sending
     *
     * @param progress 0-100
     */
    onTransferProgressUpdate(progress: number, transferType: BlobTransferType): void;

    /**
     * transfer start
     */
    onTransferStart(transferMode: TransferMode): void;

    /**
     * blob transfer complete
     *
     * @param success if at least one device blob transfer success
     */
    onTransferComplete(success: boolean, desc: string): void;

    /**
     * @param address failed device address
     */
    onTransferringDeviceFail(address: number, desc: string): void;

    /**
     * holder should send message
     *
     * @return if message sent
     */
    onMeshMessagePrepared(meshMessage: MeshMessage): Promise<boolean>;

    onTransferLog(tag: string, log: string, logLevel: number): void;
}