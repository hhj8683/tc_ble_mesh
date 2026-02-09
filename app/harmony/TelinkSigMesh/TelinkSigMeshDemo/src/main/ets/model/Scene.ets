/********************************************************************************************************
 * @file     Scene.ets 
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
 * @file Scene.ets
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
import { ArrayList } from "@kit.ArkTS";
import { num2Hex } from "telinksigmeshlib";
import { NodeInfo } from "./NodeInfo";

/**
 * scene
 * Created by kee on 2018/10/8.
 */



export class Scene {

    /**
     * scene name
     */
    public name = "Telink-Scene";

    /**
     * scene id
     */
    public  sceneId = 0;

    /**
     * element address(unicast address) list, hex big endian
     */
    public  addressList: Array<string> = []


    public Scene() {
    }

    // public Scene(String name, int sceneId, List<String> addressList) {
    //     this.name = name;
    //     this.sceneId = sceneId;
    //     this.addressList = addressList;
    // }

    public  save( address: number) {
        let adrStr = num2Hex(address, 4)
        for (let adr of this.addressList) {
            if (adr.toUpperCase() == (adrStr.toUpperCase())) {
                return;
            }
        }
        this.addressList.push(adrStr);
    }

    public remove( address: number) {
        let formatAdr = num2Hex(address, 4);
        this.addressList = this.addressList.filter((item)=>{
            return item != formatAdr
        })
    }

    public  removeNode(nodeInfo: NodeInfo ) : boolean{
        let anyRemoved = false;
        if (nodeInfo.compositionData) {
            let adr: number;
            for (let i = 0; i < nodeInfo.compositionData.elements.length; i++) {
                adr = i + nodeInfo.meshAddress;
                if (this.contains(adr)) {
                    this.remove(adr);
                    anyRemoved = true;
                }
            }
        }
        return anyRemoved;
    }

    public  contains(address: number) : boolean{
        if (this.addressList.length == 0) return false;
        let formatAdr = num2Hex(address, 4);
        return this.addressList.includes(formatAdr);
    }
}
