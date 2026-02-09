/********************************************************************************************************
 * @file     ActionParameters.ets 
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
 * @file Parameters.ets
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
import { HashMap } from "@kit.ArkTS";
import { ble } from "@kit.ConnectivityKit";

/**
 * Mesh action params
 * This is an abstract class representing an event.
 * It implements the Parcelable interface to allow for easy serialization and deserialization.
 * The event class is generic, allowing for different types of events to be created.
 * The sender and type properties represent the sender object and the type of the event, respectively.
 * The threadMode property represents the thread mode in which the event should be handled.
 * The default thread mode is set to Default.
 */
export class ActionParameters {
    /**
     * default params
     */
    private static readonly DEFAULT_SCAN_SPACING_ABOVE_N = 6 * 1000;
    private static readonly DEFAULT_SCAN_TIMEOUT = 10 * 1000;
    private static readonly DEFAULT_CONNECT_TIMEOUT = 10 * 1000;
    private static readonly DEFAULT_CONNECT_RETRY = 2;
    // min scan space milliseconds
    public static readonly COMMON_SCAN_MIN_SPACING = "com.telink.ble.mesh.light.COMMON_SCAN_MIN_SPACING";
    // scan timeout default 10s
    public static readonly COMMON_SCAN_TIMEOUT = "com.telink.ble.mesh.light.COMMON_SCAN_TIMEOUT";
    public static readonly COMMON_CONNECT_TIMEOUT = "com.telink.ble.mesh.light.COMMON_CONNECT_TIMEOUT";
    // fail retry default 3
    public static readonly COMMON_CONNECT_RETRY = "com.telink.ble.mesh.light.COMMON_CONNECT_RETRY";
    public static readonly COMMON_PROXY_FILTER_INIT_NEEDED =
        "com.telink.ble.mesh.light.COMMON_PROXY_FILTER_INIT_NEEDED";
    // scan filter
    public static readonly SCAN_FILTERS = "com.telink.ble.mesh.light.SCAN_FILTERS";
    // scan filter
    public static readonly SCAN_SINGLE_MODE = "com.telink.ble.mesh.light.SCAN_SINGLE_MODE";
    public static readonly ACTION_PROVISIONING_TARGET = "com.telink.ble.mesh.light.ACTION_PROVISIONING_TARGET";
    public static readonly ACTION_BINDING_TARGET = "com.telink.ble.mesh.light.ACTION_BINDING_TARGET";
    // fast provision
    public static readonly ACTION_FAST_PROVISION_CONFIG = "com.telink.ble.mesh.light.ACTION_FAST_PROVISION_CONFIG";
    // min scan period: default 3s for RSSI filter
    public static readonly ACTION_AUTO_CONNECT_SCAN_MIN_PERIOD =
        "com.telink.ble.mesh.light.ACTION_AUTO_CONNECT_SCAN_MIN_PERIOD";
    // scan rest: default 3s
    public static readonly ACTION_AUTO_CONNECT_SCAN_REST = "com.telink.ble.mesh.light.ACTION_AUTO_CONNECT_SCAN_REST";
    // target mac list, deprecated
    public static readonly ACTION_AUTO_CONNECT_TARGET_LIST =
        "com.telink.ble.mesh.light.ACTION_AUTO_CONNECT_TARGET_LIST";
    // sparseArray<byte[]>: unicast and node identity key map
    public static readonly ACTION_AUTO_CONNECT_NODE_ADDRESS_LIST =
        "com.telink.ble.mesh.light.ACTION_AUTO_CONNECT_NODE_ADDRESS_LIST";
    public static readonly ACTION_AUTO_CONNECT_NETWORK_KEY =
        "com.telink.ble.mesh.light.ACTION_AUTO_CONNECT_NETWORK_KEY";
    /**
     * OTA firmware
     */
    public static readonly ACTION_OTA_FIRMWARE = "com.telink.ble.mesh.light.ACTION_OTA_FIRMWARE";
    /**
     * target filter for direct mesh connection
     */
    public static readonly ACTION_CONNECTION_FILTER = "com.telink.ble.mesh.light.ACTION_CONNECTION_FILTER";
    /**
     * target mac address for direct mesh connection
     */
    public static readonly ACTION_CONNECTION_MAC_ADDRESS = "com.telink.ble.mesh.light.ACTION_CONNECTION_MAC_ADDRESS";
    /**
     * target name for direct mesh connection: device name should be unique
     */
    public static readonly ACTION_CONNECTION_DEVICE_NAME = "com.telink.ble.mesh.light.ACTION_CONNECTION_DEVICE_NAME";
    /**
     * mesh ota targets: int[] addresses
     */
    public static readonly ACTION_MESH_OTA_CONFIG = "com.telink.ble.mesh.light.ACTION_MESH_OTA_CONFIG";
    /**
     * mesh ota firmware: byte[]
     */
    public static readonly ACTION_MESH_OTA_FIRMWARE = "com.telink.ble.mesh.light.ACTION_MESH_OTA_FIRMWARE";
    protected mParams: HashMap<string, Object> = new HashMap()

    protected Parameters() {
        this.setScanMinSpacing(0);
        this.setScanTimeout(ActionParameters.DEFAULT_SCAN_TIMEOUT);
        this.setConnectTimeout(ActionParameters.DEFAULT_CONNECT_TIMEOUT);
        this.setConnectRetry(ActionParameters.DEFAULT_CONNECT_RETRY);
        this.set(ActionParameters.COMMON_PROXY_FILTER_INIT_NEEDED, true);
    }

    /**
     * Sets a value for the specified key.
     *
     * @param key   the key for the parameter
     * @param value the value for the parameter
     */
    protected set(key: string, value: Object) {
        this.mParams.set(key, value);
    }

    /**
     * Retrieves the value for the specified key.
     *
     * @param key the key for the parameter
     * @return the value for the parameter, or null if the key does not exist
     */
    public get(key: string): Object {
        return this.mParams.get(key);
    }

    /**
     * Retrieves the boolean value for the specified key.
     *
     * @param key          the key for the parameter
     * @param defaultValue the default value to return if the key does not exist
     * @return the boolean value for the parameter, or the default value if the key does not exist
     */
    public getBool(key: string, defaultValue: boolean): boolean {
        if (this.mParams.hasKey(key)) {
            return this.mParams.get(key) as boolean
        }
        return defaultValue;
    }

    /**
     * Retrieves the integer value for the specified key.
     *
     * @param key          the key for the parameter
     * @param defaultValue the default value to return if the key does not exist
     * @return the integer value for the parameter, or the default value if the key does not exist
     */
    public getNumber(key: string, defaultValue: number): number {
        if (this.mParams.hasKey(key)) {
            return this.mParams.get(key) as number
        }
        return defaultValue
    }

    /**
     * Retrieves the string value for the specified key.
     *
     * @param key the key for the parameter
     * @return the string value for the parameter, or null if the key does not exist
     */
    public getString(key: string): string | undefined {
        if (this.mParams.hasKey(key)) {
            return this.mParams.get(key) as string
        }
        return undefined
    }

    /**
     * Sets the minimum scan spacing.
     *
     * @param spacing the minimum scan spacing in milliseconds
     */
    public setScanMinSpacing(spacing: number) {
        this.set(ActionParameters.COMMON_SCAN_MIN_SPACING, spacing);
    }

    /**
     * Sets the scan timeout.
     *
     * @param timeout the scan timeout in milliseconds
     */
    public setScanTimeout(timeout: number) {
        this.set(ActionParameters.COMMON_SCAN_TIMEOUT, timeout);
    }

    /**
     * Sets the connect timeout.
     *
     * @param timeout the connect timeout in milliseconds
     */
    public setConnectTimeout(timeout: number) {
        this.set(ActionParameters.COMMON_CONNECT_TIMEOUT, timeout);
    }

    /**
     * Sets the connect retry count.
     *
     * @param retry the connect retry count
     */
    public setConnectRetry(retry: number) {
        this.set(ActionParameters.COMMON_CONNECT_RETRY, retry);
    }

    /**
     * Sets the scan filter.
     *
     * @param scanFilter the scan filter to set
     */
    public setScanFilter(scanFilter: ble.ScanFilter[]) {
        this.set(ActionParameters.SCAN_FILTERS, scanFilter);
    }

    /**
     * Creates a scan filter with the specified UUIDs.
     *
     * @param uuid the UUIDs to include in the scan filter
     * @return the created scan filter
     */
    public createScanFilter(uuid: string): ble.ScanFilter {
        return { serviceUuid: uuid }
    }
}