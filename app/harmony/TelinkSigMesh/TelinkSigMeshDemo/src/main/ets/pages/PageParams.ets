import { bytesToHex, generateRandom } from 'telinksigmeshlib'

export interface NodeParams {
    deviceUuid: string
}

export interface MeshInfoParams {
    id: number
}

export interface QrcodeUuidParams {
    uuid: string
}

export interface SchedulerSettingParams {
    deviceUuid: string
    schedulerIndex: number
}

export interface SceneSettingParams {
    sceneId: number
}