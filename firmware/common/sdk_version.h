/********************************************************************************************************
 * @file    sdk_version.h
 *
 * @brief   This is the header file for BLE SDK
 *
 * @author  BLE GROUP
 * @date    2022
 *
 * @par     Copyright (c) 2022, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
 *
 *******************************************************************************************************/
/*
 * It is only used by SDK, and the customer is not allowed to modify it
 */
/*
 * Release Tool need to change this macro to match the release version,
 * the replace rules is: "$$$B85m_driver_sdk_"#sdk_version_num"$$$", The "#sdk_version_num"
 * will replace with this macro value.
 */

#define SDK_VER_SPEC            4       // SDK version, don't change!!! //"3" means SIG MESH 1.0.x
#define SDK_VER_MAJOR           1       // SDK version, don't change!!! 
#define SDK_VER_MINOR           1       // SDK version, don't change!!! 
#define SDK_VER_2ND_MINOR       0       // SDK version, don't change!!!	// second minor
#define PATCH_NUM               0       // Patch version

#define CUSTOM_MAJOR_VERSION	0
#define CUSTOM_MINOR_VERSION	0

// these macro use in lib function blc_get_sdk_version() to get sdk version
#define	CERTIFICATION_MARK		SDK_VER_SPEC
#define	SOFT_STRUCTURE			SDK_VER_MAJOR
#define	MAJOR_VERSION			SDK_VER_MINOR
#define	MINOR_VERSION			SDK_VER_2ND_MINOR

/*
 * Release Tool need to change this macro to match the release version,
 * the replace rules is: "$$$B85m_driver_sdk_"#sdk_version_num"$$$", The "#sdk_version_num"
 * will replace with this macro value.
 */
#define TC_BLE_MESH_VERSION_NUM             SDK_VER_SPEC.SDK_VER_MAJOR.SDK_VER_MINOR.SDK_VER_2ND_MINOR
#define SDK_VERSION_NUM                     TC_BLE_MESH_VERSION_NUM

#define SDK_VERSION1(sdk_version_num)       "$$$tc_ble_mesh_V"#sdk_version_num"$$$"


#define SDK_VERSION(sdk_version_num)         SDK_VERSION1(sdk_version_num)

#define PATCH_VERSION1(patch_num)            "$$$patch_" #patch_num "$$$"
#define PATCH_VERSION(patch_num)             PATCH_VERSION1(patch_num)

#define CUSTOM_VERSION_NUM                   CUSTOM_MAJOR_VERSION.CUSTOM_MINOR_VERSION

#define CUSTOM_VERSION1(cunstom_version_num) "$$$custom_" #cunstom_version_num "$$$"
#define CUSTOM_VERSION(cunstom_version_num)  CUSTOM_VERSION1(cunstom_version_num)

