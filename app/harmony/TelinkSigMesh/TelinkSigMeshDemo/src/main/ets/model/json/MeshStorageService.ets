/********************************************************************************************************
 * @file MeshStorageService.java
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
    DEFAULT_SUB_LIST,
    hexToIntB,
    hexToUuid,
    LEVEL_ASSOCIATED_LIST,
    logd,
    loge,
    MeshSigModel,
    num2Hex,
    TransitionTime
} from 'telinksigmeshlib';
import { MeshInfo } from '../MeshInfo';
import {
    ApplicationKey,
    convertToMeshInfo,
    Element,
    Features,
    Group,
    MeshStorage,
    Model,
    NetworkKey,
    Node,
    NodeKey,
    Publish,
    PublishPeriod,
    Scene,
    Transmit
} from './MeshStorage';
import { MeshNetKey } from '../MeshNetKey';
import { formatDateToISOString } from '../../utils/ContextUtils';
import { GroupInfo } from '../GroupInfo';
import { PreferencesHelper } from '../../utils/PreferencesHelper';
import { NodeInfo } from '../NodeInfo';
import TelinkSigMeshDemoAbility from '../../abilities/TelinkSigMeshDemoAbility';
import { MeshSecurity } from './MeshSecurity';
import { MeshInfoService } from '../MeshInfoService';

export class MeshStorageService {

    public static readonly JSON_FILE = "mesh.json";
    public static readonly VC_TOOL_CPS = new Uint8Array([

        0x00, 0x00, 0x01, 0x01, 0x33, 0x31, 0xE8, 0x03,
        0x04, 0x00, 0x00, 0x00, 0x17, 0x01, 0x00, 0x00,
        0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x05, 0x00,
        0x00, 0xFE, 0x01, 0xFE, 0x02, 0xFE, 0x03, 0xFE,
        0x00, 0xFF, 0x01, 0xFF, 0x02, 0x12, 0x01, 0x10,
        0x03, 0x10, 0x05, 0x10, 0x08, 0x10, 0x05, 0x12,
        0x08, 0x12, 0x02, 0x13, 0x05, 0x13, 0x09, 0x13,
        0x11, 0x13, 0x15, 0x10, 0x11, 0x02, 0x01, 0x00
    ])

    /**
     * target mesh - mesh info parsed from jsonStr
     * current mesh means current used mesh info
     * <br/>
     * three possibilities:
     * <p>
     * 1. target mesh is current mesh: replace the nodes in current mesh by nodes in target mesh , then refresh UI
     * <br/>
     * 2. target mesh is not current mesh, but in the Mesh-List {@link MeshInfoService#getAll()}: replace the nodes in current mesh by nodes in target mesh
     * <br/>
     * 3. target mesh is not current mesh, and not in the Mesh-List {@link MeshInfoService#getAll()}: create new mesh and save in Mesh List
     * <p>
     * import external data
     *
     * @return new mesh info
     */
    // , BaseActivity activity
    public static async importExternal(jsonStr: string): Promise<MeshInfo | undefined> {
        let newMesh: MeshInfo | undefined;
        try {
            newMesh = await MeshStorageService.importFromJson(jsonStr);
        } catch (e) {
            loge(`import failed : ${e.code} -> ${e.message}`)
            return undefined;
        }
        if (newMesh == null) {
            loge("import failed [NULL]");
            return undefined;
        }
        return newMesh;
    }


    /**
     * @param jsonStr json
     * @return
     * @throws Exception
     */
    private static async importFromJson(jsonStr: string): Promise<MeshInfo | undefined> {

        let tempStorage: MeshStorage = JSON.parse(jsonStr) as MeshStorage

        if (!MeshStorageService.validStorageData(tempStorage)) {
            return undefined;
        }

        let targetMesh = convertToMeshInfo(tempStorage);
        let targetMeshUUID = targetMesh.meshUUID;

        // mesh in db
        let localMesh = MeshInfoService.getInstance().getByUuid(targetMeshUUID);

        if (localMesh) {
            logd("update local mesh");
            localMesh.nodes = targetMesh.nodes;

            localMesh.groups = targetMesh.groups;

            localMesh.allProvisioners = targetMesh.allProvisioners;

            localMesh.provisionerNodes = targetMesh.provisionerNodes;

            localMesh.excludedNodes = targetMesh.excludedNodes;

            localMesh.extendGroups = targetMesh.extendGroups;

            localMesh.scenes = targetMesh.scenes;
            localMesh.saveOrUpdate();
            return localMesh;
        }

        logd("create new provisioner");

        // mesh not found in db
        // create new provisioner and provisioner node
        if (!await targetMesh.createProvisionerInfo(TelinkSigMeshDemoAbility.getContext())) {
            loge("create new provisioner error");
            return undefined;
        }

        targetMesh.ivIndex = 0;
        targetMesh.sequenceNumber = 0;
        MeshInfoService.getInstance().addMeshInfo(targetMesh);
        return targetMesh;
    }


    private static validStorageData(meshStorage: MeshStorage): boolean {
        return meshStorage && meshStorage.provisioners && meshStorage.provisioners.length != 0;
    }


    /**
     * save mesh to json file
     *
     * @return file
     */
    // public File exportMeshToJson(File dir, String filename, MeshInfo mesh, List<MeshNetKey> selectedNetKeys) {
    //     MeshStorage meshStorage = convertMeshToJson(mesh, selectedNetKeys);
    //     String jsonData = mGson.toJson(meshStorage);
    //     return FileSystem.writeString(dir, filename, jsonData);
    // }

    /**
     * @return json string
     */
    public static meshToJsonString(meshInfo: MeshInfo, selectedNetKeys: Array<MeshNetKey>): string {
        let meshStorage = MeshStorageService.convertMeshToJson(meshInfo, selectedNetKeys);
        return JSON.stringify(meshStorage)
    }

    /**
     * convert mesh to MeshStorage
     *
     * @param mesh            target meshInfo
     * @param selectedNetKeys selected network key
     */
    private static convertMeshToJson(mesh: MeshInfo, selectedNetKeys: Array<MeshNetKey>): MeshStorage {
        let meshStorage = new MeshStorage();
        meshStorage.meshUUID = mesh.meshUUID;
        meshStorage.meshName = mesh.meshName;
        // get current time
        // SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssXXX", Locale.getDefault());
        // String formattedDate = sdf.format(new Date());
        // MeshLogger.d("time : " + formattedDate);
        meshStorage.timestamp = formatDateToISOString(new Date());

        // add all netKey
        let appKey: ApplicationKey;
        for (let meshNetKey of selectedNetKeys) {
            let netKey = new NetworkKey();
            netKey.name = meshNetKey.name;
            netKey.index = meshNetKey.index;
            netKey.phase = 0;
            // secure | insecure
            netKey.minSecurity = "secure";
            netKey.timestamp = meshStorage.timestamp;
            netKey.key = meshNetKey.key
            meshStorage.netKeys.push(netKey);

            // find bound app keys
            for (let ak of mesh.appKeyList) {
                if (ak.boundNetKeyIndex == meshNetKey.index) {
                    appKey = new ApplicationKey();
                    appKey.name = ak.name;
                    appKey.index = ak.index;
                    appKey.key = ak.key
                    appKey.boundNetKey = ak.boundNetKeyIndex;
                    meshStorage.appKeys.push(appKey);
                    break;
                }
            }
        }

        let groups: Array<GroupInfo> = mesh.groups;
        for (let i = 0; i < groups.length; i++) {
            let group = new Group();
            group.address = num2Hex(groups[i].address, 4)
            group.name = groups[i].name;
            meshStorage.groups.push(group);
        }


        if (PreferencesHelper.isLevelServiceEnable(TelinkSigMeshDemoAbility.getContext())) {
            // add extend groups
            groups = mesh.extendGroups;
            for (let i = 0; i < groups.length; i++) {
                let group = new Group();
                group.address = num2Hex(groups[i].address, 4)
                group.name = groups[i].name;
                meshStorage.groups.push(group);
            }
        }

        for (let provisioner of mesh.allProvisioners) {
            meshStorage.provisioners.push(provisioner);
        }

        for (let node of mesh.nodes) {
            meshStorage.nodes.push(MeshStorageService.convertDeviceInfoToNode(node, mesh.getDefaultAppKeyIndex()));
        }

        for (let node of mesh.excludedNodes) {
            let nd = MeshStorageService.convertDeviceInfoToNode(node, mesh.getDefaultAppKeyIndex());
            nd.excluded = true;
            meshStorage.nodes.push(nd);
        }

        for (let node of mesh.provisionerNodes) {
            meshStorage.nodes.push(MeshStorageService.convertDeviceInfoToNode(node, mesh.getDefaultAppKeyIndex()));
        }

        /*
         * convert [mesh.scenes] to [meshStorage.scenes]
         */
        let scene: Scene;
        for (let meshScene of mesh.scenes) {
            scene = new Scene();
            scene.number = num2Hex(meshScene.sceneId, 4)
            scene.name = meshScene.name;
            if (meshScene.addressList) {
                for (let adr of meshScene.addressList) {
                    scene.addresses.push(adr)
                }
            }
            meshStorage.scenes.push(scene);
        }

        return meshStorage;
    }


    // convert nodeInfo(mesh.java) to node(json)
    public static convertDeviceInfoToNode(deviceInfo: NodeInfo, appKeyIndex: number): Node {
        let node = new Node();
        let levelServiceEnable = PreferencesHelper.isLevelServiceEnable(TelinkSigMeshDemoAbility.getContext());
        node.UUID = hexToUuid(deviceInfo.deviceUUID);
        node.unicastAddress = num2Hex(deviceInfo.meshAddress, 4)

        if (deviceInfo.deviceKey) {
            node.deviceKey = deviceInfo.deviceKey
        }
        node.elements = [] // new ArrayList<>(deviceInfo.elementCnt);

        if (deviceInfo.compositionData != null) {
            node.deviceKey = deviceInfo.deviceKey.toUpperCase();
            node.cid = num2Hex(deviceInfo.compositionData.cid, 4);
            node.pid = num2Hex(deviceInfo.compositionData.pid, 4);
            node.vid = num2Hex(deviceInfo.compositionData.vid, 4);
            node.crpl = num2Hex(deviceInfo.compositionData.crpl, 4);
            let features = deviceInfo.compositionData.features;
            // value in supported node is 1, value in unsupported node is 0 (as 2 in json)
            // closed
            node.features = new Features(
                (features & 0b0001) == 0 ? 2 : 1,
                (features & 0b0010) == 0 ? 2 : 1,
                (features & 0b0100) == 0 ? 2 : 1,
                (features & 0b1000) == 0 ? 2 : 1);
            /*node.features = new Features(features & 0b0001,
                    features & 0b0010,
                    features & 0b0100,
                    features & 0b1000);*/


            let publishModel = deviceInfo.getPublishModel()
            if (deviceInfo.compositionData.elements) {
                let elements = deviceInfo.compositionData.elements;
                let element: Element;
                for (let i = 0; i < elements.length; i++) {
                    let ele = elements[i];
                    element = new Element();
                    element.index = i;
                    element.location = num2Hex(ele.location, 4);

                    element.models = []
                    let model: Model;

                    // find the offset ? (C000 + 1000 + ?)
                    let levelAssociatedModels: MeshSigModel[] = LEVEL_ASSOCIATED_LIST
                    let levelModelIndex = -1;
                    if (levelServiceEnable) {
                        for (let j = 0; j < levelAssociatedModels.length; j++) {
                            if (ele.containModel(MeshSigModel.SIG_MD_G_LEVEL_S) &&
                            ele.containModel(levelAssociatedModels[j])) {
                                levelModelIndex = j;
                                break;
                            }
                        }
                    }
                    if (ele.sigNum != 0 && ele.sigModels != null) {
                        for (let modelId of ele.sigModels) {
                            model = new Model();
                            model.modelId = num2Hex(modelId, 4);
                            model.bind = []
                            model.bind.push(appKeyIndex);

                            model.subscribe = [];

                            // for default sub models
                            if (MeshStorageService.inDefaultSubModel(modelId)) {
                                for (let subAdr of deviceInfo.subList) {
                                    model.subscribe.push(subAdr)
                                }
                            }

                            // for level models:  use the offset
                            if (modelId == MeshSigModel.SIG_MD_G_LEVEL_S && levelModelIndex != -1) {
                                for (let subAdr of deviceInfo.subList) { //
                                    model.subscribe.push(num2Hex(GroupInfo.getExtendAddressWithParams(hexToIntB(subAdr),
                                        levelModelIndex), 4))
                                }
                            }


                            if (publishModel != null && publishModel.modelId == modelId) {
                                let publish = new Publish();
                                publish.address = num2Hex(publishModel.address, 4);
                                publish.index = 0;

                                publish.ttl = publishModel.ttl;
                                let transitionTime = TransitionTime.fromTime(publishModel.period);
                                let period = new PublishPeriod();
                                period.numberOfSteps = transitionTime.getNumber() & 0xFF;
                                period.resolution = transitionTime.getResolution();
                                //                                publish.period = publishModel.period;
                                publish.period = period;
                                publish.credentials = publishModel.credential;
                                publish.retransmit = new Transmit(publishModel.getTransmitCount()
                                    , (publishModel.getTransmitInterval() + 1) * 50);

                                model.publish = publish;
                            }

                            element.models.push(model);
                        }
                    }

                    if (ele.vendorNum != 0 && ele.vendorModels != null) {

                        for (let modelId of ele.vendorModels) {
                            model = new Model();
                            model.modelId = num2Hex(modelId, 8);
                            model.bind = []
                            model.bind.push(appKeyIndex);
                            element.models.push(model);
                        }
                    }
                    node.elements.push(element);
                }
            }
        } else {

            // create elements
            for (let i = 0; i < deviceInfo.elementCnt; i++) {
                node.elements.push(new Element());
            }
        }
        node.netKeys = []
        node.netKeys.push(new NodeKey(0, false));
        node.configComplete = true;
        //        node.name = "Common Node";
        node.name = deviceInfo.name;

        // check if appKey list exists to confirm device bound state
        if (deviceInfo.bound) {
            node.appKeys = []
            node.appKeys.push(new NodeKey(appKeyIndex, false));
        }

        node.security = MeshSecurity.SECURE

        if (deviceInfo.schedulers != null) {
            node.schedulers = []
            for (let deviceScheduler of deviceInfo.schedulers) {
                node.schedulers.push((deviceScheduler));
            }
        }

        return node;
    }


    //
    private static inDefaultSubModel(modelId: number): boolean {
        let models = DEFAULT_SUB_LIST
        for (let model of models) {
            if (model == modelId) {
                return true;
            }
        }
        return false;
    }


    /**
     * convert node in json to composition data
     */


    // check if node is provisioner
    private static isProvisionerNode(meshStorage: MeshStorage, node: Node): boolean {
        for (let provisioner of meshStorage.provisioners) {
            if (provisioner.UUID.toUpperCase() == node.UUID.toUpperCase()) {
                return true;
            }
        }
        return false;
    }
}
