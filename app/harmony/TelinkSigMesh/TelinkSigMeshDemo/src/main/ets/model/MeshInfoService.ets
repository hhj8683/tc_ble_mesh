/********************************************************************************************************
 * @file MeshInfoService.ets
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
import { MeshInfo } from "./MeshInfo";

import dataPreferences from '@ohos.data.preferences';
import TelinkSigMeshDemoAbility from "../abilities/TelinkSigMeshDemoAbility";
import { logd, loge } from "telinksigmeshlib";
import { ArrayList } from "@kit.ArkTS";
import { objectifyMeshInfo } from "./json/JsonParser";
import { NodeInfo } from "./NodeInfo";

/*
[{id: 1, filename: "xxx1"},
id: 1, filename: "xxx2"}]
 */
const IDX_FILE_NAME = "mesh.db.idx"

const KEY_IDX = "key_idx"
const MESH_DB_FILE_PREFIX = "mesh.db.file_"

const KEY_MESH_INFO = "key_mesh_info"

export class MeshInfoService {
    private static instance: MeshInfoService;
    private currentMesh?: MeshInfo
    private meshInfoList: MeshInfo[] = []

    private constructor() {
    }

    static getInstance(): MeshInfoService {
        if (!MeshInfoService.instance) {
            MeshInfoService.instance = new MeshInfoService();
        }
        return MeshInfoService.instance;
    }


    public loadAll() {
        const preferences =
            dataPreferences.getPreferencesSync(TelinkSigMeshDemoAbility.getContext(), { name: IDX_FILE_NAME });
        let idxStr = preferences.getSync(KEY_IDX, undefined) as string
        if (!idxStr) {
            loge("idx info found")
            return
        }
        logd("idx info : " + idxStr)
        let idx: number[] | undefined = JSON.parse(idxStr)
        this.meshInfoList = []
        if (!idx) {
            loge("parse id list err")
            return
        }
        logd(" idx : " + idx.length)
        for (let i = 0; i < idx.length; i++) {
            let file = dataPreferences.getPreferencesSync(TelinkSigMeshDemoAbility.getContext(),
                { name: this.getDbFile(idx[i]) });
            let meshStr = file.getSync(KEY_MESH_INFO, undefined) as string
            if (meshStr) {
                let mesh: MeshInfo | undefined = objectifyMeshInfo(meshStr)
                if (mesh) {
                    this.meshInfoList.push(mesh)
                } else {
                    loge("mesh info err")
                }
            } else {
                loge("mesh str not found")
            }
        }

        logd("load result : meshInfoList = " + this.meshInfoList.length)
    }

    public updateNodeInfo(node: NodeInfo) {
        let nodes = this.currentMesh?.nodes
        if (!nodes) {
            return
        }
        let found = false
        for (let i = 0; i < nodes.length; i++) {
            if (nodes[i].deviceUUID == node.deviceUUID) {
                nodes[i] = node
                found = true
                break
            }
        }
        if (found) {
            logd("update node : found")
            this.updateMeshInfo(this.currentMesh!)
        } else {
            logd("update node : not found")
        }
    }

    public updateNetworkInfo(sequenceNumber: number, ivIndex: number) {
        this.currentMesh!.sequenceNumber = sequenceNumber
        this.currentMesh!.ivIndex = ivIndex
        this.saveMeshInfo(this.currentMesh!)
    }

    public resetCurrentMesh(meshInfo: MeshInfo) {
        this.currentMesh = meshInfo
    }

    public getCurrentMesh() {
        return this.currentMesh!
    }

    private getDbFile(id: number) {
        return MESH_DB_FILE_PREFIX + id
    }

    private saveMeshInfo(meshInfo: MeshInfo) {
        let file = dataPreferences.getPreferencesSync(TelinkSigMeshDemoAbility.getContext(),
            { name: this.getDbFile(meshInfo.id) });
        file.put(KEY_MESH_INFO, JSON.stringify(meshInfo)).then(() => {
            file.flush()
        })
    }

    private removeMeshInfoFromDb(meshInfo: MeshInfo) {
        dataPreferences.deletePreferences(TelinkSigMeshDemoAbility.getContext(), { name: this.getDbFile(meshInfo.id) })
    }


    public getById(id: number): MeshInfo | undefined {
        for (let mesh of this.meshInfoList) {
            if (mesh.id == id) {
                return mesh
            }
        }
        return undefined
    }

    public getByUuid(meshUUID: string): MeshInfo | undefined {
        for (let mesh of this.meshInfoList) {
            if (mesh.meshUUID == meshUUID) {
                return mesh
            }
        }
        return undefined
    }

    /**
     * @return all mesh info in db
     */
    public getAll(): MeshInfo[] {
        return this.meshInfoList
    }


    public updateMeshInfo(meshInfo: MeshInfo) {
        for (let i = 0; i < this.meshInfoList.length; i++) {
            if (this.meshInfoList[i].id == meshInfo.id) {
                this.meshInfoList[i] = meshInfo
                this.saveMeshInfo(meshInfo)
                break
            }
        }
    }

    /**
     * start from 1
     * @returns
     */
    public getAvailableMeshId(): number {
        let id = 0
        for (let meshInfo of this.meshInfoList) {
            if (meshInfo.id > id) {
                id = meshInfo.id
            }
        }
        return id + 1
    }

    /**
     * add new mesh info
     * the id {@link MeshInfo#id} should be 0
     */
    public addMeshInfo(meshInfo: MeshInfo) {
        let newId = this.getAvailableMeshId()
        meshInfo.id = newId
        this.meshInfoList.push(meshInfo)
        this.saveMeshInfo(meshInfo)
        this.saveIdList()
    }

    private saveIdList() {
        let file = dataPreferences.getPreferencesSync(TelinkSigMeshDemoAbility.getContext(),
            { name: IDX_FILE_NAME });
        let idx: number[] = []
        for (let mesh of this.meshInfoList) {
            idx.push(mesh.id)
        }
        file.put(KEY_IDX, JSON.stringify(idx)).then(() => {
            file.flush()
        })
    }


    /**
     * remove mesh info
     */
    public removeMeshInfo(meshInfo: MeshInfo) {
        this.removeMeshInfoFromDb(meshInfo)
        this.meshInfoList = this.meshInfoList.filter((value: MeshInfo, index: number) => {
            return value.id != meshInfo.id
        })
    }

    public removeAllMesh() {
        for (let mesh of this.meshInfoList) {
            this.removeMeshInfoFromDb(mesh)
        }
        this.meshInfoList = []
    }
}
