/********************************************************************************************************
 * @file MeshStorage.ets
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

import {
    CompositionData,
    hexListContains,
    hexToBytes,
    hexToIntB,
    uuidToByteArray,
    Element as MElement,
    MeshMessage,
    uuidToRawHex
} from "telinksigmeshlib";
import { GroupInfo } from "../GroupInfo";
import { MeshInfo } from "../MeshInfo";
import { NodeInfo } from "../NodeInfo";
import { Provisioner } from "../Provisioner";
import { PublishModel } from "../PublishModel";
import { Scene as MScene } from "../Scene";
import { ArrayList } from "@kit.ArkTS";
import { Scheduler } from "../Scheduler";
import { faceDetector } from "@kit.CoreVisionKit";

/**
 * json format
 * Created by kee on 2018/9/10.
 * <p>
 * change type of period in publish from integer to object
 * add HeartbeatPublication and HeartbeatSubscription
 */

const SCHEMA = "http://json-schema.org/draft-04/schema#";
const VERSION = "1.0.0";
const ID = "http://www.bluetooth.com/specifications/assigned-numbers/mesh-profile/cdb-schema.json#";
const MESH_NAME = "Telink-Sig-Mesh";

const IV_INDEX = 0;

const KEY_INVALID = "00000000000000000000000000000000";

const ADDRESS_INVALID = "0000";

const LOCAL_DEVICE_KEY = "00112233445566778899AABBCCDDEEFF";

export class MeshStorage {
    public $schema = SCHEMA;
    public id = ID;
    public version = VERSION;
    public meshName = MESH_NAME;
    public meshUUID = "";
    public timestamp = "";
    public partial = false;
    public provisioners: Array<Provisioner> = []
    public netKeys: Array<NetworkKey> = []
    public appKeys: Array<ApplicationKey> = []
    /**
     * contains a local node (phone), its UUID is the same with provisioner uuid
     */
    public nodes: Array<Node> = []
    public groups: Array<Group> = []
    public scenes: Array<Scene> = []

}


/**
 * custom
 */
// remove
//    public String ivIndex = String.format("%08X", Defaults.IV_INDEX);

// export class Provisioner {
//     //        public long id;
//
//     public  provisionerName: string = "";
//
//     public UUID = "";
//
//     public  allocatedUnicastRange: Array<AddressRange> = []
//     public  allocatedGroupRange: Array<AddressRange> = []
//
//     public  allocatedSceneRange: Array<SceneRange> = []
// }

export class NetworkKey {
    public name: string = "";
    // 0 -- 4095
    public index = 0;
    // 0,1,2
    public phase = 0;
    public key = "";
    public minSecurity = "";
    //        public String oldKey = Defaults.KEY_INVALID;
    public timestamp = "";
}

export class ApplicationKey {
    public name = "";
    public index = 0;
    public boundNetKey = 0;
    public key = '';
    public oldKey = KEY_INVALID;
}

/**
 * only contains one netKey and appKey currently
 */
export class Node {
    // custom: not in doc
    //        public String macAddress;

    /**
     * sequence number
     * custom value
     * big endian string convert by mesh.sno
     * valued only when node is provisioner
     *
     * @see com.telink.ble.mesh.model.MeshInfo#sequenceNumber
     */
    //        public String sno;

    public UUID = '';
    public unicastAddress = '';
    public deviceKey = '';
    public security = '';
    public netKeys: Array<NodeKey> = [];
    public excluded = false;
    public configComplete = false;
    public name = '';
    public cid = '';
    public pid = '';
    public vid = '';
    public crpl = '';
    public features: Features = new Features(0, 0, 0, 0);
    public secureNetworkBeacon = true;
    public defaultTTL = MeshMessage.DEFAULT_TTL;
    public networkTransmit?: Transmit
    public relayRetransmit?: Transmit
    public appKeys: Array<NodeKey> = [];
    public elements: Array<Element> = [];
    //        public boolean blacklisted; // removed in R10

    // heartbeatPub
    public heartbeatPub?: HeartbeatPublication;
    // heartbeatSub
    public heartbeatSub?: Array<HeartbeatSubscription>;
    // custom data for scheduler
    public schedulers?: Array<Scheduler>
}


export class Features {
    relay: number = 0;
    proxy: number = 0;
    friend: number = 0;
    lowPower: number = 0;

    constructor(relay: number, proxy: number, friend: number, lowPower: number) {
        this.relay = relay;
        this.proxy = proxy;
        this.friend = friend;
        this.lowPower = lowPower;
    }
}

//Network transmit && Relay retransmit
export class Transmit {
    // 0--7
    count: number = 0;
    // 10--120
    interval: number = 0;

    constructor(count: number, interval: number) {
        this.count = count;
        this.interval = interval;
    }
}

// node network key && node application key
export class NodeKey {
    index: number = 0;
    updated: boolean = false;

    constructor(index: number, updated: boolean) {
        this.index = index;
        this.updated = updated;
    }
}

export class Element {
    public name: string = "";
    public index = 0;
    public location = "";
    public models: Array<Model> = [];
}

export class Model {
    public modelId: string = ""
    public subscribe: Array<string> = []
    public publish?: Publish;
    public bind: Array<number> = []
}

export class Publish {
    public address: string = "";
    public index: number = 0;
    public ttl = 0;
    public period: PublishPeriod = new PublishPeriod();
    public credentials = 0;
    public retransmit: Transmit = new Transmit(0, 0);
}

export class PublishPeriod {
    /**
     * The numberOfStepa property contains an integer from 0 to 63 that represents the number of steps used
     * to calculate the publish period .
     */
    public numberOfSteps = 0
    /**
     * The resolution property contains an integer that represents the publish step resolution in milliseconds.
     * The allowed values are: 100, 1000, 10000, and 600000.
     */
    public resolution = 0
}

export class HeartbeatPublication {
    public address = "";
    public period = 0;
    public ttl = 0;
    public index = 0;
    public features: Array<string> = []
}

export class HeartbeatSubscription {
    public source = "";
    public destination = "";
    public period = 0;
}


export class Group {
    public name = "";
    public address = "";
    public parentAddress = ADDRESS_INVALID;
}

export class Scene {
    public name = "";
    public addresses: Array<string> = []
    public number = "";
}

// convert - start

/**
 * convert json to MeshInfo {@link MeshInfo}
 * all provisioners will be saved in provisioner list {@link MeshInfo#allProvisioners},
 * nodes will be save in three list:
 * 1. {@link MeshInfo#provisionerNodes} for all provisioner nodes
 * 2. {@link MeshInfo#excludedNodes} for all excluded nodes, that are kickout
 * 3. others nodes {@link MeshInfo#nodes}
 */
export function convertToMeshInfo(meshStorage: MeshStorage): MeshInfo {
    let meshInfo = new MeshInfo();
    meshInfo.meshUUID = meshStorage.meshUUID;
    meshInfo.meshName = meshStorage.meshName;
    meshInfo.timestamp = meshStorage.timestamp;
    /*
     * convert all provisioners
     */
    meshInfo.allProvisioners.push(...meshStorage.provisioners)

    /*
     * convert all network keys
     */
    for (let networkKey of meshStorage.netKeys) {
        meshInfo.meshNetKeyList.push({
            name: networkKey.name,
            index: networkKey.index,
            key: networkKey.key
        });
    }

    /*
     * convert all application keys
     */
    for (let applicationKey of meshStorage.appKeys) {
        meshInfo.appKeyList.push({
            name: applicationKey.name,
            index: applicationKey.index,
            key: applicationKey.key,
            boundNetKeyIndex: applicationKey.boundNetKey
        });
    }


    /*
     * convert all groups
     */
    let group: GroupInfo;
    for (let gp of meshStorage.groups) {
        group = new GroupInfo();
        group.name = gp.name;
        group.address = hexToIntB(gp.address);
        if (group.name.includes("subgroup")) {
            meshInfo.extendGroups.push(group);
        } else {
            meshInfo.groups.push(group);
        }
    }


    /*
     * convert all groups
     */
    let scene: MScene;
    for (let outerScene of meshStorage.scenes) {
        scene = new MScene()
        scene.sceneId = hexToIntB(outerScene.number);
        scene.name = outerScene.name;
        for (let adr of outerScene.addresses) {
            scene.addressList.push(adr)
        }
        meshInfo.scenes.push(scene);
    }

    /**
     * convert all nodes,
     * the exclude nodes will be saved in meshInfo.excludedNodes,
     * other will be saved in
     * ignore provisioner nodes
     */
    for (let node of meshStorage.nodes) {
        let nodeInfo: NodeInfo = nodeToNodeInfo(node);
        //            nodeInfo.save();
        if (isProvisionerNode(meshStorage, node)) {
            meshInfo.provisionerNodes.push(nodeInfo);
        } else if (node.excluded) {
            meshInfo.excludedNodes.push(nodeInfo);
        } else {
            meshInfo.nodes.push(nodeInfo);
        }
    }

    return meshInfo;

}

/**
 * convert node to {@link NodeInfo}
 */
export function nodeToNodeInfo( node: Node): NodeInfo {
    let nodeInfo = new NodeInfo();
    nodeInfo.meshAddress = hexToIntB(node.unicastAddress);
    //                    deviceInfo.deviceUUID =  Arrays.hexToBytes(node.UUID.replace(":", "").replace("-", ""));
    nodeInfo.deviceUUID = uuidToRawHex(node.UUID);
    nodeInfo.name = node.name;
    nodeInfo.elementCnt = node.elements == null ? 0 : node.elements.length;
    nodeInfo.deviceKey = node.deviceKey

    let subList: Array<string> = []
    let publishModel: PublishModel;
    if (node.elements != null) {
        for (let element of node.elements) {
            if (element.models == null) {
                continue;
            }
            for (let model of element.models) {

                if (model.subscribe != null) {
                    for (let sub of model.subscribe) {
                        let subAdr = parseInt(sub, 16);
                        if (subAdr >= 0xD000) {
                            continue;
                        }
                        if (!hexListContains(subList, sub)) {
                            subList.push(sub);
                        }
                    }
                }
                if (model.publish != null) {
                    let publish = model.publish;
                    let pubAddress = hexToIntB(publish.address);
                    // pub address from vc-tool， default is 0
                    if (pubAddress != 0 && publish.period != null) {
                        let elementAddress = element.index + hexToIntB(node.unicastAddress);
                        let interval = (publish.retransmit.interval / 50) - 1;
                        let transmit = publish.retransmit.count | (interval << 3);
                        let periodTime = publish.period.numberOfSteps * publish.period.resolution;
                        publishModel = new PublishModel();
                        publishModel.elementAddress = elementAddress
                        publishModel.modelId = hexToIntB(model.modelId)
                        publishModel.address = hexToIntB(publish.address)
                        publishModel.period = periodTime
                        publishModel.ttl = publish.ttl
                        publishModel.credential = publish.credentials
                        publishModel.transmit = transmit
                        nodeInfo.setPublishModel(publishModel)
                    }
                }
            }
        }
    }

    for (let subAdr of subList) {
        nodeInfo.subList.push(subAdr)
    }
    nodeInfo.bound = node.appKeys.length != 0

    nodeInfo.compositionData = nodeToCompositionData(node);

    if (node.schedulers && node.schedulers.length != 0) {
        for (let nodeScheduler of node.schedulers) {
            nodeInfo.schedulers.push(nodeScheduler);
        }
    }
    return nodeInfo;
}

/**
 * convert node
 *
 * @param node
 * @return
 */
export function nodeToCompositionData(node: Node): CompositionData {

    let compositionData = new CompositionData();

    compositionData.cid = node.cid == "" ? 0 : hexToIntB(node.cid);
    compositionData.pid = node.pid == "" ? 0 : hexToIntB(node.pid);
    compositionData.vid = node.vid == "" ? 0 : hexToIntB(node.vid);
    compositionData.crpl = node.crpl == "" ? 0 : hexToIntB(node.crpl);

    //value 2 : unsupported
    let relaySpt = 0, proxySpt = 0, friendSpt = 0, lowPowerSpt = 0;
    if (node.features != null) {
        relaySpt = node.features.relay == 1 ? 0b0001 : 0;
        proxySpt = node.features.proxy == 1 ? 0b0010 : 0;
        friendSpt = node.features.friend == 1 ? 0b0100 : 0;
        lowPowerSpt = node.features.lowPower == 1 ? 0b1000 : 0;
    }
    compositionData.features = relaySpt | proxySpt | friendSpt | lowPowerSpt;

    compositionData.elements = []

    if (node.elements != null) {
        let infoEle: MElement;
        for (let element of node.elements) {
            infoEle = new MElement();
            let sigModels: Array<number> = []
            let vendorModels: Array<number> = []
            if (element.models.length != 0) {
                let modelId: number;
                for (let model of element.models) {

                    // check if is vendor model
                    if (model.modelId != "") {
                        modelId = hexToIntB(model.modelId);
                        // Integer.valueOf(model.modelId, 16);
                        if (model.modelId.length > 4) {
                            vendorModels.push(modelId);
                        } else {
                            sigModels.push(modelId);
                        }
                    }
                }
                infoEle.sigNum = sigModels.length;
                infoEle.vendorNum = vendorModels.length;

                infoEle.sigModels = new Array(sigModels.length)
                for (let i = 0; i < sigModels.length; i++) {
                    infoEle.sigModels[i] = sigModels[i]
                }

                infoEle.vendorModels = new Array(vendorModels.length)
                for (let i = 0; i < vendorModels.length; i++) {
                    infoEle.vendorModels[i] = vendorModels[i]
                }

            } else {
                infoEle.sigNum = 0;
                infoEle.vendorNum = 0;
            }


            infoEle.location = element.location == "" ? 0 : hexToIntB(element.location);
            compositionData.elements.push(infoEle);
        }
    }
    return compositionData;
}


/**
 * check
 *
 * @param node
 * @return
 */
export function  isProvisionerNode(meshStorage: MeshStorage, node: Node): boolean {
    for (let provisioner of meshStorage.provisioners) {
        if (provisioner.UUID.toUpperCase() == node.UUID.toUpperCase()) {
            return true;
        }
    }
    return false;
}


// convert - end