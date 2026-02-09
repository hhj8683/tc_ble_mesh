/********************************************************************************************************
 * @file     JsonParser.ets 
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
 * @file JsonParser.ets
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

import { CompositionData, Element, logd, loge } from "telinksigmeshlib"
import { GroupInfo } from "../GroupInfo"
import { MeshInfo } from "../MeshInfo"
import { NodeInfo } from "../NodeInfo"
import { PublishModel } from "../PublishModel"
import { Scene } from "../Scene"
import { Scheduler } from "../Scheduler"
import { SchedulerRegister } from "../SchedulerRegister"

export function objectifyMeshInfo(meshStr: string) {
    logd(`objectifyMeshInfo : ${meshStr}`)
    let mesh: MeshInfo | undefined = JSON.parse(meshStr)
    if (mesh) {
        let re = new MeshInfo()
        re.id = mesh.id
        re.meshName = mesh.meshName
        re.timestamp = mesh.timestamp
        re.meshUUID = mesh.meshUUID
        re.provisionerUUID = mesh.provisionerUUID
        re.unicastRange = mesh.unicastRange

        re.nodes = [];
        for (let node of mesh.nodes) {
            re.nodes.push(objectifyNodeInfo(node))
        }

        re.meshNetKeyList = mesh.meshNetKeyList
        re.appKeyList = mesh.appKeyList
        re.ivIndex = mesh.ivIndex
        re.sequenceNumber = mesh.sequenceNumber
        re.localAddress = mesh.localAddress
        re.provisionIndex = mesh.provisionIndex
        re.addressTopLimit = mesh.addressTopLimit
        re.scenes = []
        for (let scene of mesh.scenes) {
            re.scenes.push(objectifyScene(scene))
        }

        re.groups = []
        for (let group of mesh.groups) {
            re.groups.push(objectifyGroupInfo(group))
        }
        re.extendGroups = []
        for (let group of mesh.extendGroups) {
            re.extendGroups.push(objectifyGroupInfo(group))
        }
        re.allProvisioners = mesh.allProvisioners

        re.excludedNodes = []
        for (let node of mesh.excludedNodes) {
            re.excludedNodes.push(objectifyNodeInfo(node))
        }

        re.provisionerNodes = []
        for (let node of mesh.provisionerNodes) {
            re.provisionerNodes.push(objectifyNodeInfo(node))
        }
        re.solSeq = mesh.solSeq
        return re
    }
    return undefined
}

function objectifyNodeInfo(node: NodeInfo) {
    let re = new NodeInfo()

    re.name = node.name
    re.meshAddress = node.meshAddress
    re.deviceUUID = node.deviceUUID
    re.netKeyIndexes = node.netKeyIndexes
    re.elementCnt = node.elementCnt
    re.bound = node.bound
    re.deviceKey = node.deviceKey
    re.timePublishConfigured = node.timePublishConfigured
    re.subList = node.subList
    re.lum = node.lum
    re.temp = node.temp
    re.onlineState = node.onlineState
    if (node.compositionData) {
        re.compositionData = objectifyCompositionData(node.compositionData)
    } else {
        loge("composition data err : " + node.name)
    }
    re.schedulers = []
    for (let scd of node.schedulers) {
        re.schedulers.push(objectifyScheduler(scd))
    }

    if (node.publishModel) {
        re.publishModel = new PublishModel()
        re.publishModel.elementAddress = node.publishModel.elementAddress
        re.publishModel.modelId = node.publishModel.modelId
        re.publishModel.address = node.publishModel.address
        re.publishModel.period = node.publishModel.period
        re.publishModel.ttl = node.publishModel.ttl
        re.publishModel.credential = node.publishModel.credential
        re.publishModel.transmit = node.publishModel.transmit
    }
    re.defaultBind = node.defaultBind
    re.subnetBridgeEnabled = node.subnetBridgeEnabled
    re.defaultTTL = node.defaultTTL
    re.relayEnable = node.relayEnable
    re.relayRetransmit = node.relayRetransmit
    re.beaconOpened = node.beaconOpened
    re.gattProxyEnable = node.gattProxyEnable
    re.privateBeaconOpened = node.privateBeaconOpened
    re.privateGattProxyEnable = node.privateGattProxyEnable
    re.friendEnable = node.friendEnable
    re.networkRetransmit = node.networkRetransmit
    re.onDemandPrivateGattProxy = node.onDemandPrivateGattProxy
    re.directForwardingEnabled = node.directForwardingEnabled
    re.directRelayEnabled = node.directRelayEnabled
    re.directProxyEnabled = node.directProxyEnabled
    re.directFriendEnabled = node.directFriendEnabled
    re.lcEnabled = node.lcEnabled
    return re;
}


function objectifyCompositionData(cpsData: CompositionData) {
    let re = new CompositionData()
    re.cid = cpsData.cid
    re.pid = cpsData.pid
    re.vid = cpsData.vid
    re.crpl = cpsData.crpl
    re.features = cpsData.features
    re.elements = []
    for (let ele of cpsData.elements) {
        re.elements.push(objectifyElement(ele))
    }
    re.raw = cpsData.raw
    return re;
}


function objectifyElement(ele: Element) {
    let re = new Element()
    re.location = ele.location
    re.sigNum = ele.sigNum
    re.vendorNum = ele.vendorNum
    re.sigModels = ele.sigModels
    re.vendorModels = ele.vendorModels
    return re;
}

function objectifyScheduler(org: Scheduler) {
    let re = new Scheduler()
    re.index = org.index

    re.register = new SchedulerRegister()
    re.register.year = org.register.year
    re.register.month = org.register.month
    re.register.day = org.register.day
    re.register.hour = org.register.hour
    re.register.minute = org.register.minute
    re.register.second = org.register.second
    re.register.week = org.register.week
    re.register.action = org.register.action
    re.register.transTime = org.register.transTime
    re.register.sceneId = org.register.sceneId
    re.elementOffset = org.elementOffset

    return re;
}

function objectifyScene(scene: Scene) {
    let re = new Scene()
    re.name = scene.name
    re.sceneId = scene.sceneId
    re.addressList = scene.addressList
    return re;
}


function objectifyGroupInfo(group: GroupInfo) {
    let re = new GroupInfo()
    re.name = group.name
    re.address = group.address
    return re;
}
