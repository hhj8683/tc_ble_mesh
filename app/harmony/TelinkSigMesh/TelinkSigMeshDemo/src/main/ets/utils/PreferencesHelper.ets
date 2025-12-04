import { bundleManager, common } from "@kit.AbilityKit";

import dataPreferences from '@ohos.data.preferences';
import { logd, loge, OtaSetting } from "telinksigmeshlib";
import { util } from "@kit.ArkTS";

export const PREFERENCES_NAME = 'telink_ble_ota_preferences';

export const KEY_OTA_SETTING = 'ota_setting'

export const KEY_FILTER_NAME = 'filter_name'

export const KEY_FILTER_RSSI = 'filter_rssi'

export const KEY_LOCAL_UUID = "KEY_PROVISIONER_UUID";

export const KEY_LEVEL_SERVICE = "KEY_LEVEL_SERVICE"

export const KEY_SELECTED_MESH_ID = "KEY_SELECTED_MESH_ID"

export class PreferencesHelper {
    public static async saveOtaSetting(context: common.Context, otaSetting: OtaSetting) {
        try {
            const preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
            preferences.putSync(KEY_OTA_SETTING, JSON.stringify(otaSetting))
            preferences.flushSync();
            console.log('save setting success');
        } catch (err) {
            console.error(`save setting fail: ${err.code}, ${err.message}`);
        }
    }

    public static async getOtaSetting(context: common.Context): Promise<OtaSetting | undefined> {
        try {
            const preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
            if (!preferences.hasSync(KEY_OTA_SETTING)) {
                return
            }
            let settingInfo = await preferences.get(KEY_OTA_SETTING, "")
            if (typeof settingInfo == 'string') {
                let otaSetting: OtaSetting = JSON.parse(settingInfo) as OtaSetting
                return otaSetting
            }
            return
        } catch (err) {
            console.error(`get ota setting error: ${err.code}, ${err.message}`);
            return
        }
    }


    public static async saveFilter(context: common.Context, filterName: string, filterRssi: number) {
        try {
            const preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
            preferences.putSync(KEY_FILTER_NAME, filterName)
            preferences.putSync(KEY_FILTER_RSSI, filterRssi)
            preferences.flushSync();
            console.log('save filter success');
        } catch (err) {
            console.error(`save setting fail: ${err.code}, ${err.message}`);
        }
    }

    public static async getFilterName(context: common.Context): Promise<string | undefined> {
        try {
            const preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
            let name = await preferences.get(KEY_FILTER_NAME, "")
            if (typeof name == 'string') {
                return name
            }
            return
        } catch (err) {
            console.error(`get filter name error: ${err.code}, ${err.message}`)
            return
        }
    }

    public static async getFilterRssi(context: common.Context): Promise<number | undefined> {
        try {
            const preferences = await dataPreferences.getPreferences(context, PREFERENCES_NAME);
            let rssi = await preferences.get(KEY_FILTER_RSSI, "")
            if (typeof rssi == 'number') {
                return rssi
            }
            return
        } catch (err) {
            console.error(`get filter rssi error: ${err.code}, ${err.message}`)
            return
        }
    }


    public static getLocalUuid(context: common.Context): string {
        try {
            const preferences = dataPreferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
            let localUuid = preferences.getSync(KEY_LOCAL_UUID, "") as string
            if (!localUuid) {
                localUuid = util.generateRandomUUID()
                preferences.putSync(KEY_LOCAL_UUID, localUuid)
            }
            return localUuid
        } catch (err) {
            console.error(`get local uuid error: ${err.code}, ${err.message}`)
            return util.generateRandomUUID()
        }
    }


    public static isLevelServiceEnable(context: common.Context): boolean {
        try {
            const preferences = dataPreferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
            let levelServiceEn = preferences.getSync(KEY_LEVEL_SERVICE, false) as boolean
            return levelServiceEn
        } catch (err) {
            console.error(`get isLevelServiceEnable error: ${err.code}, ${err.message}`)
            return false
        }
    }

    public static setLevelServiceEnable(context: common.Context, enable: boolean) {
        try {
            const preferences = dataPreferences.getPreferencesSync(context, { name: PREFERENCES_NAME });
            preferences.put(KEY_LEVEL_SERVICE, enable).then(() => {
                preferences.flush()
            })
            return
        } catch (err) {
            console.error(`setLevelServiceEnable error: ${err.code}, ${err.message}`)
            return false
        }
    }

    public static async getSelectedMeshId(context: common.Context) {
        let preferences = await dataPreferences.getPreferences(context, { name: PREFERENCES_NAME });
        let all = preferences.getAllSync();
        return preferences.getSync(KEY_SELECTED_MESH_ID, -1) as number
    }

    /**
     * @param meshId {@link com.telink.ble.mesh.model.MeshInfo#id}
     */
    public static async setSelectedMeshId(context: common.Context, meshId: number) {
        try {
            logd("setSelectedMeshId # " + meshId)
            let preferences = await dataPreferences.getPreferences(context, { name: PREFERENCES_NAME });
            preferences.put(KEY_SELECTED_MESH_ID, meshId).then(()=>{
                preferences.flush()
            })
        } catch (e) {
            loge(`setSelectedMeshId error : ${e.code} => ${e.message}`)
        }

    }
}

