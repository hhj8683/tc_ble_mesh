/********************************************************************************************************
 * @file MeshSigModel.ets
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


/**
 * This enum represents the different mesh SIG models available in a mesh network.
 * Each model has a unique model ID, a model name, and a group description.
 * Some models use device key for encryption, while others use application key.
 */
export enum MeshSigModel {

    SIG_MD_CFG_SERVER = 0x0000, // config server",  // ", true),
    SIG_MD_CFG_CLIENT = 0x0001, // config client",  // ", true),


    SIG_MD_HEALTH_SERVER = 0x0002, // health server",  // health server", false),
    SIG_MD_HEALTH_CLIENT = 0x0003, // health client",  // health client", false),


    SIG_MD_REMOTE_PROV_SERVER = 0x0004, // remote provision server",  // ", true),
    SIG_MD_REMOTE_PROV_CLIENT = 0x0005, // remote provision client",  // ", true),

    SIG_MD_DF_CFG_S = 0x0006, // Directed Forwarding Configuration server",  // ", true),
    SIG_MD_DF_CFG_C = 0x0007, // Directed Forwarding Configuration client",  // ", true),

    SIG_MD_BRIDGE_CFG_SERVER = 0x0008, // Bridge Configuration Server",  // ", true),
    SIG_MD_BRIDGE_CFG_CLIENT = 0x0009, // Bridge Configuration Client",  // ", true),

    SIG_MD_PRIVATE_BEACON_SERVER = 0x000A, // Mesh Private Beacon Server",  // ", true),
    SIG_MD_PRIVATE_BEACON_CLIENT = 0x000B, // Mesh Private Beacon Client",  // ", true),

    SIG_MD_ON_DEMAND_PROXY_S = 0x000C, // On-Demand Private Proxy Server",  // ", true),
    SIG_MD_ON_DEMAND_PROXY_C = 0x000D, // On-Demand Private Proxy Client",  // ", true),

    SIG_MD_SAR_CFG_S = 0x000E, // SAR Configuration Server",  // ", true),
    SIG_MD_SAR_CFG_C = 0x000F, // SAR Configuration Client",  // ", true),

    // opcode aggregator
    SIG_MD_CFG_OP_AGG_S = 0x0010, // Opcodes Aggregator Server",  // aggregator", true),
    SIG_MD_CFG_OP_AGG_C = 0x0011, // Opcodes Aggregator Client",  // aggregator", true),

    // large composition data
    SIG_MD_LARGE_CPS_S = 0x0012, // Large Composition Data Server",  // ", true),
    SIG_MD_LARGE_CPS_C = 0x0013, // Large Composition Data Client",  // ", true),

    // Solicitation PDU RPL Configuration
    SIG_MD_SOL_PDU_RPL_CFG_S = 0x0014, // Solicitation PDU RPL Configuration Server",  // ", true),
    SIG_MD_SOL_PDU_RPL_CFG_C = 0x0015, // Solicitation PDU RPL Configuration Client",  // ", true),


    SIG_MD_G_ONOFF_S = 0x1000, // Generic OnOff Server",  // Generic"),
    SIG_MD_G_ONOFF_C = 0x1001, // Generic OnOff Client",  // Generic"),
    SIG_MD_G_LEVEL_S = 0x1002, // Generic Level Server",  // Generic"),
    SIG_MD_G_LEVEL_C = 0x1003, // Generic Level Client",  // Generic"),
    SIG_MD_G_DEF_TRANSIT_TIME_S = 0x1004, // Generic Default Transition Time Server ",  // Generic"),
    SIG_MD_G_DEF_TRANSIT_TIME_C = 0x1005, // Generic Default Transition Time Client ",  // Generic"),
    SIG_MD_G_POWER_ONOFF_S = 0x1006, // Generic Power OnOff Server",  // Generic"),
    SIG_MD_G_POWER_ONOFF_SETUP_S = 0x1007, // Generic Power OnOff Setup Server",  // Generic"),
    SIG_MD_G_POWER_ONOFF_C = 0x1008, // Generic Power OnOff Client",  // Generic"),
    SIG_MD_G_POWER_LEVEL_S = 0x1009, // Generic Power Level Server",  // Generic"),
    SIG_MD_G_POWER_LEVEL_SETUP_S = 0x100A, // Generic Power Level Setup Server",  // Generic"),
    SIG_MD_G_POWER_LEVEL_C = 0x100B, // Generic Power Level Client",  // Generic"),
    SIG_MD_G_BAT_S = 0x100C, // Generic Battery Server",  // Generic"),
    SIG_MD_G_BAT_C = 0x100D, // Generic Battery Client",  // Generic"),
    SIG_MD_G_LOCATION_S = 0x100E, // Generic Location Server",  // Generic"),
    SIG_MD_G_LOCATION_SETUP_S = 0x100F, // Generic Location Setup Server",  // Generic"),
    SIG_MD_G_LOCATION_C = 0x1010, // Generic Location Client",  // Generic"),
    SIG_MD_G_ADMIN_PROP_S = 0x1011, // Generic Admin Property Server",  // Generic"),
    SIG_MD_G_MFR_PROP_S = 0x1012, // Generic Manufacturer Property Server",  // Generic"),
    SIG_MD_G_USER_PROP_S = 0x1013, // Generic User Property Server",  // Generic"),
    SIG_MD_G_CLIENT_PROP_S = 0x1014, // Generic Client Property Server",  // Generic"),
    SIG_MD_G_PROP_C = 0x1015, // Generic Property Client",  // Generic"), // original: SIG_MD_G_PROP_S (may be err)

    SIG_MD_SENSOR_S = 0x1100, // Sensor Server",  // Sensors"),
    SIG_MD_SENSOR_SETUP_S = 0x1101, // Sensor Setup Server",  // Sensors"),
    SIG_MD_SENSOR_C = 0x1102, // Sensor Client",  // Sensors"),

    SIG_MD_TIME_S = 0x1200, // Time Server",  // Time and Scenes"),
    SIG_MD_TIME_SETUP_S = 0x1201, // Time Setup Server",  // Time and Scenes"),
    SIG_MD_TIME_C = 0x1202, // Time Client",  // Time and Scenes"),
    SIG_MD_SCENE_S = 0x1203, // Scene Server",  // Time and Scenes"),
    SIG_MD_SCENE_SETUP_S = 0x1204, // Scene Setup Server",  // Time and Scenes"),
    SIG_MD_SCENE_C = 0x1205, // Scene Client",  // Time and Scenes"),
    SIG_MD_SCHED_S = 0x1206, // MeshScheduler Server",  // Time and Scenes"),
    SIG_MD_SCHED_SETUP_S = 0x1207, // MeshScheduler Setup Server",  // Time and Scenes"),
    SIG_MD_SCHED_C = 0x1208, // MeshScheduler Client",  // Time and Scenes"),

    SIG_MD_LIGHTNESS_S = 0x1300, // Light Lightness Server",  // Lighting"),
    SIG_MD_LIGHTNESS_SETUP_S = 0x1301, // Light Lightness Setup Server",  // Lighting"),
    SIG_MD_LIGHTNESS_C = 0x1302, // Light Lightness Client",  // Lighting"),
    SIG_MD_LIGHT_CTL_S = 0x1303, // Light CTL Server",  // Lighting"),
    SIG_MD_LIGHT_CTL_SETUP_S = 0x1304, // Light CTL Setup Server",  // Lighting"),
    SIG_MD_LIGHT_CTL_C = 0x1305, // Light CTL Client",  // Lighting"),
    SIG_MD_LIGHT_CTL_TEMP_S = 0x1306, // Light CTL Temperature Server",  // Lighting"),
    SIG_MD_LIGHT_HSL_S = 0x1307, // Light HSL Server",  // Lighting"),
    SIG_MD_LIGHT_HSL_SETUP_S = 0x1308, // Light HSL Setup Server",  // Lighting"),
    SIG_MD_LIGHT_HSL_C = 0x1309, // Light HSL Client",  // Lighting"),
    SIG_MD_LIGHT_HSL_HUE_S = 0x130A, // Light HSL Hue Server",  // Lighting"),
    SIG_MD_LIGHT_HSL_SAT_S = 0x130B, // Light HSL Saturation Server",  // Lighting"),
    SIG_MD_LIGHT_XYL_S = 0x130C, // Light xyL Server",  // Lighting"),
    SIG_MD_LIGHT_XYL_SETUP_S = 0x130D, // Light xyL Setup Server",  // Lighting"),
    SIG_MD_LIGHT_XYL_C = 0x130E, // Light xyL Client",  // Lighting"),
    SIG_MD_LIGHT_LC_S = 0x130F, // Light LC Server",  // Lighting"),
    SIG_MD_LIGHT_LC_SETUP_S = 0x1310, // Light LC Setup Server",  // Lighting"),
    SIG_MD_LIGHT_LC_C = 0x1311, // Light LC Client",  // Lighting"),

    //    SIG_MD_DF_CFG_S
    //    SIG_MD_CFG_DF_S = 0xBF30,  // direct forwarding server",  // ", true),
    //    SIG_MD_CFG_DF_C = 0xBF31,  // direct forwarding client",  // ", true),

    //    SIG_MD_CFG_BRIDGE_S = 0xBF32,  // subnet bridge server",  // ", true),
    //    SIG_MD_CFG_BRIDGE_C = 0xBF33,  // subnet bridge client",  // ", true),


    SIG_MD_OBJ_TRANSFER_S = 0x1400, // BLOB Transfer Server",  // OTA"),
    SIG_MD_OBJ_TRANSFER_C = 0x1401, // BLOB Transfer Client",  // OTA"),

    /**
     * firmware update model
     */
    SIG_MD_FW_UPDATE_S = 0x1402, // Firmware Update Server",  // OTA"),
    SIG_MD_FW_UPDATE_C = 0x1403, // Firmware Update Client",  // OTA"),
    SIG_MD_FW_DISTRIBUT_S = 0x1404, // Firmware Distribute Server",  // OTA"),
    SIG_MD_FW_DISTRIBUT_C = 0x1405, // Firmware Distribute Client",  // OTA"),
    //    SIG_MD_OBJ_TRANSFER_S = 0xFF00,  // Object Transfer Server",  // OTA"),
    //    SIG_MD_OBJ_TRANSFER_C = 0xFF01,  // Object Transfer Client",  // OTA"),

}


// default sub list
export const DEFAULT_SUB_LIST: MeshSigModel[] =
    [MeshSigModel.SIG_MD_G_ONOFF_S, MeshSigModel.SIG_MD_LIGHTNESS_S, MeshSigModel.SIG_MD_LIGHT_CTL_S,
        MeshSigModel.SIG_MD_LIGHT_CTL_TEMP_S, MeshSigModel.SIG_MD_LIGHT_HSL_S,
        MeshSigModel.SIG_MD_LIGHT_LC_S]

export const LEVEL_ASSOCIATED_LIST: MeshSigModel[] =
    [MeshSigModel.SIG_MD_LIGHTNESS_S, MeshSigModel.SIG_MD_LIGHT_CTL_TEMP_S, MeshSigModel.SIG_MD_LIGHT_HSL_HUE_S,
        MeshSigModel.SIG_MD_LIGHT_HSL_SAT_S]


export const DEVICE_KEY_ENC_LIST: MeshSigModel[] = [
    MeshSigModel.SIG_MD_CFG_SERVER,
    MeshSigModel.SIG_MD_CFG_CLIENT,

    MeshSigModel.SIG_MD_REMOTE_PROV_SERVER,
    MeshSigModel.SIG_MD_REMOTE_PROV_CLIENT,

    MeshSigModel.SIG_MD_DF_CFG_S,
    MeshSigModel.SIG_MD_DF_CFG_C,
    MeshSigModel.SIG_MD_BRIDGE_CFG_SERVER,
    MeshSigModel.SIG_MD_BRIDGE_CFG_CLIENT,

    MeshSigModel.SIG_MD_PRIVATE_BEACON_SERVER,
    MeshSigModel.SIG_MD_PRIVATE_BEACON_CLIENT,

    MeshSigModel.SIG_MD_ON_DEMAND_PROXY_S,
    MeshSigModel.SIG_MD_ON_DEMAND_PROXY_C,

    MeshSigModel.SIG_MD_SAR_CFG_S,
    MeshSigModel.SIG_MD_SAR_CFG_C,

    // opcode aggregator
    MeshSigModel.SIG_MD_CFG_OP_AGG_S,
    MeshSigModel.SIG_MD_CFG_OP_AGG_C,

    // large composition data
    MeshSigModel.SIG_MD_LARGE_CPS_S,
    MeshSigModel.SIG_MD_LARGE_CPS_C,

    // Solicitation PDU RPL Configuration
    MeshSigModel.SIG_MD_SOL_PDU_RPL_CFG_S,
    MeshSigModel.SIG_MD_SOL_PDU_RPL_CFG_C

]

export function useDeviceKeyForEncByHexString(modelIdHex: string): boolean {
    let modelId = parseInt(modelIdHex, 16)
    return DEVICE_KEY_ENC_LIST.includes(modelId)
}

export function useDeviceKeyForEnc(modelId: number): boolean {
    return DEVICE_KEY_ENC_LIST.includes(modelId)
}


export function getModelName(modelId: number): string {
    switch (modelId) {
        case MeshSigModel.SIG_MD_CFG_SERVER:
            return "config server"
        case MeshSigModel.SIG_MD_CFG_CLIENT:
            return "config client"


        case MeshSigModel.SIG_MD_HEALTH_SERVER:
            return "health server"
        case MeshSigModel.SIG_MD_HEALTH_CLIENT:
            return "health client"


        case MeshSigModel.SIG_MD_REMOTE_PROV_SERVER:
            return " remote provision server"
        case MeshSigModel.SIG_MD_REMOTE_PROV_CLIENT:
            return " remote provision client"

        case MeshSigModel.SIG_MD_DF_CFG_S:
            return "Directed Forwarding Configuration server"
        case MeshSigModel.SIG_MD_DF_CFG_C:
            return "Directed Forwarding Configuration client"

        case MeshSigModel.SIG_MD_BRIDGE_CFG_SERVER:
            return "Bridge Configuration Server"
        case MeshSigModel.SIG_MD_BRIDGE_CFG_CLIENT:
            return "Bridge Configuration Client"

        case MeshSigModel.SIG_MD_PRIVATE_BEACON_SERVER:
            return "Mesh Private Beacon Server"
        case MeshSigModel.SIG_MD_PRIVATE_BEACON_CLIENT:
            return "Mesh Private Beacon Client"

        case MeshSigModel.SIG_MD_ON_DEMAND_PROXY_S:
            return "On-Demand Private Proxy Server"
        case MeshSigModel.SIG_MD_ON_DEMAND_PROXY_C:
            return "On-Demand Private Proxy Client"

        case MeshSigModel.SIG_MD_SAR_CFG_S:
            return "SAR Configuration Server"
        case MeshSigModel.SIG_MD_SAR_CFG_C:
            return "SAR Configuration Client"

    // opcode aggregator
        case MeshSigModel.SIG_MD_CFG_OP_AGG_S:
            return "Opcodes Aggregator Server"
        case MeshSigModel.SIG_MD_CFG_OP_AGG_C:
            return "Opcodes Aggregator Client"

    // large composition data
        case MeshSigModel.SIG_MD_LARGE_CPS_S:
            return "Large Composition Data Server"
        case MeshSigModel.SIG_MD_LARGE_CPS_C:
            return "Large Composition Data Client"

    // Solicitation PDU RPL Configuration
        case MeshSigModel.SIG_MD_SOL_PDU_RPL_CFG_S:
            return "Solicitation PDU RPL Configuration Server"
        case MeshSigModel.SIG_MD_SOL_PDU_RPL_CFG_C:
            return "Solicitation PDU RPL Configuration Client"


        case MeshSigModel.SIG_MD_G_ONOFF_S:
            return "Generic OnOff Server"
        case MeshSigModel.SIG_MD_G_ONOFF_C:
            return "Generic OnOff Client"
        case MeshSigModel.SIG_MD_G_LEVEL_S:
            return "Generic Level Server"
        case MeshSigModel.SIG_MD_G_LEVEL_C:
            return "Generic Level Client"
        case MeshSigModel.SIG_MD_G_DEF_TRANSIT_TIME_S:
            return "Generic Default Transition Time Server "
        case MeshSigModel.SIG_MD_G_DEF_TRANSIT_TIME_C:
            return "Generic Default Transition Time Client "
        case MeshSigModel.SIG_MD_G_POWER_ONOFF_S:
            return "Generic Power OnOff Server"
        case MeshSigModel.SIG_MD_G_POWER_ONOFF_SETUP_S:
            return "Generic Power OnOff Setup Server"
        case MeshSigModel.SIG_MD_G_POWER_ONOFF_C:
            return "Generic Power OnOff Client"
        case MeshSigModel.SIG_MD_G_POWER_LEVEL_S:
            return "Generic Power Level Server"
        case MeshSigModel.SIG_MD_G_POWER_LEVEL_SETUP_S:
            return "Generic Power Level Setup Server"
        case MeshSigModel.SIG_MD_G_POWER_LEVEL_C:
            return "Generic Power Level Client"
        case MeshSigModel.SIG_MD_G_BAT_S:
            return "Generic Battery Server"
        case MeshSigModel.SIG_MD_G_BAT_C:
            return "Generic Battery Client"
        case MeshSigModel.SIG_MD_G_LOCATION_S:
            return "Generic Location Server"
        case MeshSigModel.SIG_MD_G_LOCATION_SETUP_S:
            return "Generic Location Setup Server"
        case MeshSigModel.SIG_MD_G_LOCATION_C:
            return "Generic Location Client"
        case MeshSigModel.SIG_MD_G_ADMIN_PROP_S:
            return "Generic Admin Property Server"
        case MeshSigModel.SIG_MD_G_MFR_PROP_S:
            return "Generic Manufacturer Property Server"
        case MeshSigModel.SIG_MD_G_USER_PROP_S:
            return "Generic User Property Server"
        case MeshSigModel.SIG_MD_G_CLIENT_PROP_S:
            return "Generic Client Property Server"
        case MeshSigModel.SIG_MD_G_PROP_C:
            return "Generic Property Client"

        case MeshSigModel.SIG_MD_SENSOR_S:
            return "Sensor Server"
        case MeshSigModel.SIG_MD_SENSOR_SETUP_S:
            return "Sensor Setup Server"
        case MeshSigModel.SIG_MD_SENSOR_C:
            return "Sensor Client"

        case MeshSigModel.SIG_MD_TIME_S:
            return "Time Server"
        case MeshSigModel.SIG_MD_TIME_SETUP_S:
            return "Time Setup Server"
        case MeshSigModel.SIG_MD_TIME_C:
            return "Time Client"
        case MeshSigModel.SIG_MD_SCENE_S:
            return "Scene Server"
        case MeshSigModel.SIG_MD_SCENE_SETUP_S:
            return "Scene Setup Server"
        case MeshSigModel.SIG_MD_SCENE_C:
            return "Scene Client"
        case MeshSigModel.SIG_MD_SCHED_S:
            return "MeshScheduler Server"
        case MeshSigModel.SIG_MD_SCHED_SETUP_S:
            return "MeshScheduler Setup Server"
        case MeshSigModel.SIG_MD_SCHED_C:
            return "MeshScheduler Client"

        case MeshSigModel.SIG_MD_LIGHTNESS_S:
            return "Light Lightness Server"
        case MeshSigModel.SIG_MD_LIGHTNESS_SETUP_S:
            return "Light Lightness Setup Server"
        case MeshSigModel.SIG_MD_LIGHTNESS_C:
            return "Light Lightness Client"
        case MeshSigModel.SIG_MD_LIGHT_CTL_S:
            return "Light CTL Server"
        case MeshSigModel.SIG_MD_LIGHT_CTL_SETUP_S:
            return "Light CTL Setup Server"
        case MeshSigModel.SIG_MD_LIGHT_CTL_C:
            return "Light CTL Client"
        case MeshSigModel.SIG_MD_LIGHT_CTL_TEMP_S:
            return "Light CTL Temperature Server"
        case MeshSigModel.SIG_MD_LIGHT_HSL_S:
            return "Light HSL Server"
        case MeshSigModel.SIG_MD_LIGHT_HSL_SETUP_S:
            return "Light HSL Setup Server"
        case MeshSigModel.SIG_MD_LIGHT_HSL_C:
            return "Light HSL Client"
        case MeshSigModel.SIG_MD_LIGHT_HSL_HUE_S:
            return "Light HSL Hue Server"
        case MeshSigModel.SIG_MD_LIGHT_HSL_SAT_S:
            return "Light HSL Saturation Server"
        case MeshSigModel.SIG_MD_LIGHT_XYL_S:
            return "Light xyL Server"
        case MeshSigModel.SIG_MD_LIGHT_XYL_SETUP_S:
            return "Light xyL Setup Server"
        case MeshSigModel.SIG_MD_LIGHT_XYL_C:
            return "Light xyL Client"
        case MeshSigModel.SIG_MD_LIGHT_LC_S:
            return "Light LC Server"
        case MeshSigModel.SIG_MD_LIGHT_LC_SETUP_S:
            return "Light LC Setup Server"
        case MeshSigModel.SIG_MD_LIGHT_LC_C:
            return "Light LC Client"

    //    case MeshSigModel.SIG_MD_DF_CFG_S
    //    case MeshSigModel.SIG_MD_CFG_DF_S : return "direct forwarding server": return "", true),
    //    case MeshSigModel.SIG_MD_CFG_DF_C : return "direct forwarding client": return "", true),

    //    case MeshSigModel.SIG_MD_CFG_BRIDGE_S : return "subnet bridge server": return "", true),
    //    case MeshSigModel.SIG_MD_CFG_BRIDGE_C : return "subnet bridge client": return "", true),


        case MeshSigModel.SIG_MD_OBJ_TRANSFER_S:
            return "BLOB Transfer Server"
        case MeshSigModel.SIG_MD_OBJ_TRANSFER_C:
            return "BLOB Transfer Client"

    /**
     * firmware update model
     */
        case MeshSigModel.SIG_MD_FW_UPDATE_S:
            return "Firmware Update Server"
        case MeshSigModel.SIG_MD_FW_UPDATE_C:
            return "Firmware Update Client"
        case MeshSigModel.SIG_MD_FW_DISTRIBUT_S:
            return "Firmware Distribute Server"
        case MeshSigModel.SIG_MD_FW_DISTRIBUT_C:
            return "Firmware Distribute Client"
    }
    return "unknown model"
}

