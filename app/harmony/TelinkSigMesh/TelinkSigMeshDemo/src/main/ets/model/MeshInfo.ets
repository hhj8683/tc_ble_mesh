/********************************************************************************************************
 * @file MeshInfo.java
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
    ADDRESS_BROADCAST,
    bytesEquals,
    bytesToHexString,
    CompositionData,
    generateRandom,
    hexToBytes,
    hexToIntB,
    logd,
    MeshConfiguration,
    num2Hex,
    UNICAST_ADDRESS_MAX,
    uuidToByteArray,
    uuidToRawHex
} from "telinksigmeshlib";
import { GroupInfo } from "./GroupInfo";
import { Scene } from "./Scene";
import { MeshAppKey } from "./MeshAppKey";
import { MeshNetKey } from "./MeshNetKey";
import { NodeInfo } from "./NodeInfo";
import { Provisioner } from "./Provisioner";
import { ArrayList, util } from "@kit.ArkTS";
import { AddressRange } from "./AddressRange";
import { formatDateToISOString } from "../utils/ContextUtils";
import { common } from "@kit.AbilityKit";
import { MeshStorageService } from "./json/MeshStorageService";
import { PreferencesHelper } from "../utils/PreferencesHelper";
import { MeshInfoService } from "./MeshInfoService";

/**
 * Created by kee on 2019/8/22.
 */

export class MeshInfo {
    public static readonly MESH_NAME_DEFAULT = "Telink-SIG-mesh-oh";
    public static readonly PROVISIONER_NAME_DEFAULT = "Default-Provisioner";
    public id = 0;
    /**
     * the same with {@link com.telink.ble.mesh.model.json.MeshStorage#meshName}
     */
    public meshName = "";
    /**
     * the same with {@link com.telink.ble.mesh.model.json.MeshStorage#timestamp}
     */
    public timestamp = "";
    /**
     * if the {@link #ivIndex} is uninitialized, provision is not permitted
     * once received the ivIndex in beacon , the ivIndex should be replaced
     */
    public static readonly UNINITIALIZED_IVI = -1;
    /**
     * save meshUUID in json
     */
    public meshUUID = "";
    /**
     * local provisioner UUID
     */
    public provisionerUUID = "";
    /**
     * unicast address range
     */

    public unicastRange: Array<AddressRange> = [];
    /**
     * nodes saved in mesh network
     */
    public nodes: Array<NodeInfo> = []
    /**
     * network key and network key index
     */
    public meshNetKeyList: Array<MeshNetKey> = []
    /**
     * application key list
     */
    public appKeyList: Array<MeshAppKey> = []
    /**
     * ivIndex and sequence number are used in NetworkPDU
     *
     * @see NetworkLayerPDU#getSeq()
     * <p>
     * should be updated and saved when {@link NetworkInfoUpdateEvent} received
     */
    public ivIndex = MeshInfo.UNINITIALIZED_IVI;
    /**
     * provisioner sequence number
     */
    public sequenceNumber = 0;
    /**
     * provisioner address
     */
    public localAddress = 1;
    /**
     * unicast address prepared for node provisioning
     * increase by [element count] when provisioning success
     *
     * @see NodeInfo#elementCnt
     */
    public provisionIndex = 2;
    public addressTopLimit = 0xFF;
    /**
     * scenes saved in mesh
     */
    public scenes: Array<Scene> = []
    /**
     * groups (group address 0xC000~0xC0FF)
     */
    public groups: Array<GroupInfo> = [];
    /**
     * extend groups
     */
    public extendGroups: Array<GroupInfo> = [];
    /**
     * all provisioners , include local provisioner and others parsed from json
     */
    public allProvisioners: Array<Provisioner> = []
    /**
     * excluded nodes, not show on UI
     * the deleted device by kick out
     */
    public excludedNodes: Array<NodeInfo> = []
    /**
     * provisioner nodes
     */
    public provisionerNodes: Array<NodeInfo> = []
    /**
     * solicitation sequence number
     * used when sending {@link SolicitationPDU} over ble adv
     */
    public solSeq = 1;

    /**
     * nlc unions , configured in {@link com.telink.ble.mesh.ui.fragment.NlcUnionListFragment} or import from json.
     * should export to json
     */
    // public nlcUnions: Array<NlcUnion>

    public getDefaultNetKey(): MeshNetKey {
        return this.meshNetKeyList[0]
    }

    public getDefaultAppKeyIndex() {
        if (this.appKeyList.length == 0) {
            return 0;
        }
        return this.appKeyList[0].index;
    }

    public getDeviceByMeshAddress(meshAddress: number): NodeInfo | undefined {
        if (this.nodes.length == 0) {
            return undefined;
        }

        for (let info of this.nodes) {
            if (info.meshAddress == meshAddress) {
                return info;
            }
        }
        return undefined;
    }

    public getDeviceByElementAddress(elementAddress: number): NodeInfo | undefined {
        if (this.nodes.length == 0) {
            return undefined;
        }

        for (let info of this.nodes) {
            if (elementAddress >= info.meshAddress && elementAddress < info.meshAddress + info.elementCnt) {
                return info;
            }
        }
        return undefined;
    }

    /**
     * @param deviceUUID 16 bytes uuid
     */
    public getDeviceByUUID(deviceUUID: string): NodeInfo | undefined {
        for (let info of this.nodes) {
            if (deviceUUID == info.deviceUUID) {
                return info;
            }
        }
        return undefined;
    }

    public insertDevice(deviceInfo: NodeInfo, updatePvIndex: boolean) {
        let local = this.getDeviceByUUID(deviceInfo.deviceUUID);
        if (local != null) {
            this.removeDeviceByUUID(deviceInfo.deviceUUID);
        }

        if (deviceInfo.name == '') {
            deviceInfo.addDefaultName();
        }
        this.nodes.push(deviceInfo);
        if (updatePvIndex) {
            this.increaseProvisionIndex(deviceInfo.elementCnt);
        }
        this.saveOrUpdate();
    }

    public removeNode(node: NodeInfo) {
        if (this.nodes.length == 0) {
            return;
        }
        for (let scene of this.scenes) {
            scene.removeNode(node)
        }

        this.nodes = this.nodes.filter((n) => {
            return node.deviceUUID != n.deviceUUID
        })
        this.excludedNodes.push(node);
        this.saveOrUpdate();
    }

    public removeDeviceByUUID(deviceUUID: string): boolean {
        if (this.nodes == null || this.nodes.length == 0) {
            return false;
        }
        let len = this.nodes.length
        this.nodes = this.nodes.filter((n) => {
            return deviceUUID != n.deviceUUID
        })
        return len != this.nodes.length;
    }


    /**
     * get all online nodes
     */
    public getOnlineCountInAll(): number {
        if (this.nodes.length == 0) {
            return 0;
        }

        let result = 0;
        for (let device of this.nodes) {
            if (!device.isOffline()) {
                result++;
            }
        }

        return result;
    }

    /**
     * get all online nodes
     */
    public getOnlineNodes(): Array<NodeInfo> {
        let re: Array<NodeInfo> = new Array();
        if (this.nodes == null || this.nodes.length == 0) {
            return re;
        }
        for (let device of this.nodes) {
            if (!device.isOffline()) {
                re.push(device);
            }
        }
        return re;
    }


    /**
     * get all online nodes
     */
    public getOnlineAddresses(): Array<number> {
        let re: number[] = []
        if (this.nodes == null || this.nodes.length == 0) {
            return re;
        }
        for (let device of this.nodes) {
            if (!device.isOffline()) {
                re.push(device.meshAddress);
            }
        }
        return re;
    }

    /**
     * get online nodes count in group
     *
     * @return
     */
    public getOnlineCountInGroup(groupAddress: number): number {
        if (this.nodes.length == 0) {
            return 0;
        }
        let result = 0;
        for (let device of this.nodes) {
            if (!device.isOffline()) {
                for (let addr of device.subList) {
                    if (hexToIntB(addr) == groupAddress) {
                        result++;
                        break;
                    }
                }
            }
        }

        return result;
    }

    public getSceneById(id: number): Scene | undefined {
        for (let scene of this.scenes) {
            if (id == scene.sceneId) {
                return scene;
            }
        }
        return undefined;
    }

    /**
     * 1-0xFFFF
     *
     * @return -1 invalid id
     */
    public allocSceneId(): number {
        if (this.scenes.length == 0) {
            return 1;
        }
        let id = this.scenes[this.scenes.length - 1].sceneId;
        if (id == 0xFFFF) {
            return -1;
        }
        return id + 1
    }

    public addScene(scene: Scene) {
        this.scenes.push(scene)
        this.saveOrUpdate()
    }

    public removeScene(scene: Scene) {
        this.scenes = this.scenes.filter((s) => {
            return s.sceneId != scene.sceneId
        })
        this.saveOrUpdate();
    }

    // only update metadata in mesh info, not includes inner entities (ToOne and ToMany)
    public saveOrUpdate() {
        MeshInfoService.getInstance().updateMeshInfo(this);
    }


    public toString() {
        return "MeshInfo{" +
            "id=" + this.id +
            "nodes=" + this.nodes.length +
            ", netKey=" + this.getNetKeyStr() +
            ", appKey=" + this.getAppKeyStr() +
            ", ivIndex=" + num2Hex(this.ivIndex, 8) +
            ", sequenceNumber=" + num2Hex(this.sequenceNumber, 6) +
            ", localAddress=" + num2Hex(this.localAddress, 4) +
            ", provisionIndex=" + num2Hex(this.provisionIndex, 4) +
            ", scenes=" + this.scenes.length +
            ", groups=" + this.groups.length +
            ", provisioners=" + this.allProvisioners.length +
            ", provisionerNodes=" + this.provisionerNodes.length +
            '}';
    }

    public getNetKeyStr() {
        let strBuilder = "";
        for (let meshNetKey of this.meshNetKeyList) {
            strBuilder += ("\nindex = ${meshNetKey.index} , key = ${bytesToHexString(meshNetKey.key)}")
        }
        return strBuilder
    }

    public getAppKeyStr() {
        let strBuilder = ""
        for (let meshNetKey of this.appKeyList) {
            strBuilder += (`\nindex = ${meshNetKey.index} , key = ${meshNetKey.key}`)
        }
        return strBuilder.toString();
    }

    public getProvisionIndex() {
        return this.provisionIndex;
    }

    /**
     * @param addition
     */
    public increaseProvisionIndex(addition: number) {
        this.provisionIndex += addition;
        if (this.provisionIndex > this.addressTopLimit) {
            logd("alloc new address range");
            let low = this.addressTopLimit + 1;
            let high = low + 0x03FF;
            this.unicastRange.push({ lowAddress: num2Hex(low, 4), highAddress: num2Hex(high, 4) })
            this.addressTopLimit = high;
        }
        this.saveOrUpdate();
    }

    public resetProvisionIndex(index: number) {
        this.provisionIndex = index;
    }


    public convertToConfiguration(): MeshConfiguration {
        let meshConfiguration = new MeshConfiguration();
        meshConfiguration.deviceKeyMap = new ArrayList();
        if (this.nodes.length != 0) {
            for (let node of this.nodes) {
                meshConfiguration.addDeviceKey(node.meshAddress, hexToBytes(node.deviceKey))
            }
        }
        let netKey = this.getDefaultNetKey();
        meshConfiguration.netKeyIndex = netKey.index;
        meshConfiguration.networkKey = hexToBytes(netKey.key)

        meshConfiguration.appKeyMap = []
        for (let appKey of
        this.appKeyList) {
            meshConfiguration.appKeyMap.push({ keyIndex: appKey.index, key: hexToBytes(appKey.key) });
        }

        meshConfiguration.ivIndex = this.ivIndex;

        meshConfiguration.sequenceNumber = this.sequenceNumber;

        meshConfiguration.localAddress = this.localAddress;

        meshConfiguration.proxyFilterWhiteList = new Uint16Array([this.localAddress, ADDRESS_BROADCAST])
        return meshConfiguration;
    }


    public static createNewMesh(context: common.Context, meshName?: string): MeshInfo {
        // 0x7FFF

        let meshInfo = new MeshInfo();
        if (!meshName) {
            meshName = MeshInfo.MESH_NAME_DEFAULT;
        }
        meshInfo.meshName = meshName;
        meshInfo.meshUUID = util.generateRandomUUID()

        meshInfo.timestamp = formatDateToISOString(new Date())

        //        final int IV_INDEX = 0x20345678;

        let KEY_COUNT = 3;
        let NET_KEY_NAMES: string[] = ["Default Net Key", "Sub Net Key 1", "Sub Net Key 2"]
        let APP_KEY_NAMES = ["Default App Key", "Sub App Key 1", "Sub App Key 2"]
        let APP_KEY_VAL = bytesToHexString(generateRandom(16))
        for (let i = 0; i < KEY_COUNT; i++) {
            meshInfo.meshNetKeyList.push({
                name: NET_KEY_NAMES[i],
                index: i,
                key: bytesToHexString(generateRandom(16))
            })
            meshInfo.appKeyList.push({
                name: APP_KEY_NAMES[i],
                index: i,
                key: APP_KEY_VAL,
                boundNetKeyIndex: i
            })
        }

        meshInfo.createProvisionerInfo(context);
        meshInfo.ivIndex = 0x01;
        let groupNames = ['Living room',
            'Kitchen',
            'Master bedroom',
            'Secondary bedroom',
            'Balcony',
            'Bathroom',
            'Hallway',
            'others']
        let group: GroupInfo
        for (let i = 0; i < 8; i++) {
            group = new GroupInfo();
            group.address = i | 0xC000;
            group.name = groupNames[i];
            meshInfo.groups.push(group);
        }
        return meshInfo;
    }

    /**
     * check whether extend groups exist
     */
    public addExtendGroups() {
        let extGroups = [
            " subgroup level lightness",
            " subgroup level temperature",
            " subgroup level Hue",
            " subgroup level Saturation"
        ];

        let step = 0x10;

        let extGroupIdx = 0xD000;
        let extGroup: GroupInfo;
        if (this.extendGroups.length == 0) {
            for (let groupInfo of this.groups) {
                for (let i = 0; i < extGroups.length; i++) {
                    extGroup = new GroupInfo();
                    extGroup.name = groupInfo.name + extGroups[i];
                    extGroup.address = extGroupIdx + i;
                    this.extendGroups.push(extGroup);
                }
                extGroupIdx += step;
            }
        }
    }

    public async createProvisionerInfo(context: common.Context): Promise<boolean> {
        let maxRangeHigh = 0;
        let tmpHigh: number;
        for (let provisioner of this.allProvisioners) {
            for (let unRange of provisioner.allocatedUnicastRange) {
                tmpHigh = parseInt(unRange.highAddress, 16)
                if (maxRangeHigh == 0 || maxRangeHigh < tmpHigh) {
                    maxRangeHigh = tmpHigh;
                }
            }
        }

        let low = maxRangeHigh + 1;

        if (low + 0xFF > UNICAST_ADDRESS_MAX) {
            logd("no available unicast range");
            return false;
        }

        let high: number;
        if (low == 1) {
            high = 0x03FF;
        } else {
            high = low + 0x03FF;
        }

        this.unicastRange = []
        this.unicastRange.push({ lowAddress: num2Hex(low, 4), highAddress: num2Hex(high, 4) })
        this.localAddress = low;
        this.resetProvisionIndex(low + 1);
        this.addressTopLimit = high;
        this.sequenceNumber = 0;
        this.ivIndex = MeshInfo.UNINITIALIZED_IVI;

        let pvUUID = PreferencesHelper.getLocalUuid(context)
        let provisioner = new Provisioner();
        provisioner.provisionerName = MeshInfo.PROVISIONER_NAME_DEFAULT;
        provisioner.UUID = pvUUID;
        provisioner.allocatedSceneRange.push({ firstScene: 0x01, lastScene: 0x0F })
        provisioner.allocatedUnicastRange.push({ lowAddress: num2Hex(low, 4), highAddress: num2Hex(high, 4) })
        provisioner.allocatedGroupRange.push({ lowAddress: num2Hex(0xC000, 4), highAddress: num2Hex(0xC0FF, 4) });
        this.allProvisioners.push(provisioner);

        let nodeInfo = new NodeInfo();
        nodeInfo.meshAddress = this.localAddress;
        nodeInfo.name = `Provisioner Node: ${num2Hex(this.localAddress)}`
        nodeInfo.compositionData = CompositionData.from(MeshStorageService.VC_TOOL_CPS);
        nodeInfo.elementCnt = 1;
        nodeInfo.deviceUUID = uuidToRawHex(pvUUID);
        nodeInfo.bound = true;
        nodeInfo.deviceKey = NodeInfo.LOCAL_DEVICE_KEY
        this.provisionerNodes.push(nodeInfo);
        return true;
    }

    public getSolSeq() {
        let seq = this.solSeq++;
        this.saveOrUpdate();
        return seq;
    }

    public getGroupByAddress(groupAddress: number): GroupInfo | undefined {
        for (let info of this.groups) {
            if (info.address == groupAddress) {
                return info;
            }
        }
        return undefined;
    }
}

