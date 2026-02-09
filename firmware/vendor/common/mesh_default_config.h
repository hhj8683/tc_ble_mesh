/********************************************************************************************************
 * @file    mesh_default_config.h
 *
 * @brief   This is the header file for BLE SDK
 *
 * @author  BLE GROUP
 * @date    06,2020
 *
 * @par     Copyright (c) 2020, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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

#ifndef ACL_PERIPHR_MAX_NUM
#define ACL_PERIPHR_MAX_NUM	1
#endif

#ifndef RF_PKT_BUFF_LEN
#define RF_PKT_BUFF_LEN			256			// telink proprietary protocol
#endif

#if((0 == __TLSR_RISCV_EN__) && FLASH_1M_ENABLE)
#define FLASH_PLUS_ENABLE		FLASH_1M_ENABLE
#endif
#ifndef FLASH_PLUS_ENABLE
#define FLASH_PLUS_ENABLE	    0	// means 2M flash for B91, 1M flash for B85m
#endif
#if(__TLSR_RISCV_EN__)
#define FLASH_SIZE_MAX_SW		((FLASH_PLUS_ENABLE ? 2048 : 1024) * 1024)
#else
#define FLASH_SIZE_MAX_SW		((FLASH_PLUS_ENABLE ? 1024 : 512) * 1024)
#endif

#ifndef PINGPONG_OTA_DISABLE
#define PINGPONG_OTA_DISABLE    0
#endif

#ifndef	SWITCH_FW_ENABLE
#define SWITCH_FW_ENABLE		0
#endif

#ifndef FW_START_BY_LEGACY_BOOTLOADER_EN
#define FW_START_BY_LEGACY_BOOTLOADER_EN    0
#endif

#ifndef FW_START_BY_BOOTLOADER_EN
#define FW_START_BY_BOOTLOADER_EN    0
#endif

#ifndef DUAL_MODE_WITH_TLK_MESH_EN
#define DUAL_MODE_WITH_TLK_MESH_EN   0
#endif

#ifndef	GATT_LPN_EN
#define GATT_LPN_EN		        0
#endif

#ifndef	MESH_DLE_MODE
#define MESH_DLE_MODE		    0
#endif
#ifndef	EXTENDED_ADV_ENABLE
#define EXTENDED_ADV_ENABLE		0
#endif
#ifndef	DUAL_OTA_NEED_LOGIN_EN
#define DUAL_OTA_NEED_LOGIN_EN	0
#endif
#ifndef	ENCODE_OTA_BIN_EN
#define ENCODE_OTA_BIN_EN      	0
#endif
#ifndef	DISTRIBUTOR_UPDATE_CLIENT_EN
#define DISTRIBUTOR_UPDATE_CLIENT_EN		0
#endif
#ifndef	DISTRIBUTOR_UPDATE_SERVER_EN
#define DISTRIBUTOR_UPDATE_SERVER_EN      	0
#endif
#ifndef	APP_LOG_EN
#define APP_LOG_EN      		0
#endif
#ifndef	SPEECH_ENABLE
#define SPEECH_ENABLE      		0
#endif
#ifndef	AUDIO_MESH_EN
#define AUDIO_MESH_EN      		0
#endif

#ifndef PAIR_PROVISION_ENABLE
#define PAIR_PROVISION_ENABLE	0
#endif

#ifndef	USE_DP_TO_BURN_FW
#define USE_DP_TO_BURN_FW      	0
#endif

#if __PROJECT_MESH_PRO__
#define MESH_BLE_NOTIFY_FIFO_EN     0
#else
#define MESH_BLE_NOTIFY_FIFO_EN     (MESH_DLE_MODE != MESH_DLE_MODE_EXTEND_BEAR)
#endif

#ifndef LIGHT_CONTROL_MODEL_LOCATE_PRIMARY_ELEMENT
#define LIGHT_CONTROL_MODEL_LOCATE_PRIMARY_ELEMENT		0
#endif

#ifndef LIGHT_CONTROL_SERVER_LOCATE_EXCLUSIVE_ELEMENT_EN
#define LIGHT_CONTROL_SERVER_LOCATE_EXCLUSIVE_ELEMENT_EN	0
#endif

#ifndef MESH_TIMER_MS_100MS_EN
#define MESH_TIMER_MS_100MS_EN      1
#endif

#ifndef MESH_HEARTBEAT_EN
#define MESH_HEARTBEAT_EN           1
#endif

#ifndef ENERGY_HARVEST_RX_EN
#define ENERGY_HARVEST_RX_EN        0
#endif

#ifndef BLE_GATT_CHANNEL_SELECTION_ALGORITHM2_ENABLE
#define BLE_GATT_CHANNEL_SELECTION_ALGORITHM2_ENABLE    1
#endif

#ifndef DEPRECATED_MESH_OTA_COMPAT
// Mesh OTA was officially released in v4.1.0.0.
// Previous versions used a draft protocol with different opcodes.
// Support for the previous draft protocol usually unnecessary.
#define DEPRECATED_MESH_OTA_COMPAT           (0 && MD_MESH_OTA_EN)
#endif

