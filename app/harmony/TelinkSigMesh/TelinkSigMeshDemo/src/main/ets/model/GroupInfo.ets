/********************************************************************************************************
 * @file GroupInfo.ets
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
import { num2Hex } from 'telinksigmeshlib';

/**
 * Created by kee on 2017/8/18.
 */

export class GroupInfo {
    /**
     * Group name
     */
    public name: string = ""
    /**
     * Group address
     */
    public address: number = 0
    public selected = false;

    public getExtendAddress(offset: number) {
        return (this.address - 0xC000) * 0x10 + 0xD000 + offset; // 0xC000 -> 0xD000
    }


    public static getExtendAddressWithParams(address: number, offset: number) {
        return (address - 0xC000) * 0x10 + 0xD000 + offset; // 0xC000 -> 0xD000
    }

    /**
     * get formatted name and address
     * %s(%04X)
     *
     * @return
     */
    public getFmtNameAdr(): string {
        return `name(${num2Hex(this.address, 4)})`
    }
}
