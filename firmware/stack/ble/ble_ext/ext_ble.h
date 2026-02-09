/********************************************************************************************************
 * @file	ext_ble.h
 *
 * @brief	for TLSR chips
 *
 * @author	BLE GROUP
 * @date	2020.06
 *
 * @par     Copyright (c) 2020, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *          All rights reserved.
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
#pragma once
#include "tl_common.h"

// use in lib, don't change
#define MAX_OCTETS_DATA_LEN_EXTENSION       251

#define get_32k_tick()          pm_get_32k_tick()

#define GATT_ADV_HANDLE         ADV_HANDLE0

#ifndef EXTHD_BIT_ADVA
//Extended Header BIT
#define 		EXTHD_BIT_ADVA         							BIT(0)
#define 		EXTHD_BIT_TARGETA      							BIT(1)
#define			EXTHD_BIT_CTE_INFO         						BIT(2)
#define 		EXTHD_BIT_ADI		    						BIT(3)
#define 		EXTHD_BIT_AUX_PTR      							BIT(4)
#define 		EXTHD_BIT_SYNC_INFO	    						BIT(5)
#define 		EXTHD_BIT_TX_POWER	     						BIT(6)

//Extended Header Length
#define			EXTHD_LEN_6_ADVA								6
#define			EXTHD_LEN_6_TARGETA								6
#define			EXTHD_LEN_1_CTE									1
#define			EXTHD_LEN_2_ADI									2
#define			EXTHD_LEN_3_AUX_PTR								3
#define			EXTHD_LEN_18_SYNC_INFO							18
#define			EXTHD_LEN_1_TX_POWER							1

#define 		LL_EXTADV_MODE_NON_CONN_NON_SCAN    			(0x00)
#define 		LL_EXTADV_MODE_CONN        						(0x01)		//connectable, none_scannable
#define 		LL_EXTADV_MODE_SCAN        						(0x02)      //scannable,   none_connectable

#define			EXT_ADV_PDU_AUXPTR_OFFSET_UNITS_30_US			0
#define			EXT_ADV_PDU_AUXPTR_OFFSET_UNITS_300_US			1

#define			EXT_ADV_PDU_AUXPTR_CA_51_500_PPM				0
#define			EXT_ADV_PDU_AUXPTR_CA_0_50_PPM					1
#endif

// Advertise channel PDU Type
typedef enum advChannelPDUType_e {
	LL_TYPE_ADV_IND 		 = 0x00,
	LL_TYPE_ADV_DIRECT_IND 	 = 0x01,
	LL_TYPE_ADV_NONCONN_IND  = 0x02,
	LL_TYPE_SCAN_REQ 		 = 0x03,		LL_TYPE_AUX_SCAN_REQ 	 = 0x03,
	LL_TYPE_SCAN_RSP 		 = 0x04,
	LL_TYPE_CONNECT_REQ 	 = 0x05,		LL_TYPE_AUX_CONNECT_REQ = 0x05,
	LL_TYPE_ADV_SCAN_IND 	 = 0x06,

	LL_TYPE_ADV_EXT_IND		 = 0x07,		LL_TYPE_AUX_ADV_IND 	 = 0x07,	LL_TYPE_AUX_SCAN_RSP = 0x07,	LL_TYPE_AUX_SYNC_IND = 0x07,	LL_TYPE_AUX_CHAIN_IND = 0x07,
	LL_TYPE_AUX_CONNECT_RSP = 0x08,
} advChannelPDUType_t;

typedef enum{
// previous enum hci_type_t,

   //-------- mesh
	HCI_RSP_USER_START 			= 0x10,
	HCI_RSP_USER 				= HCI_RSP_USER_START,	// line feeds
	HCI_RSP_USER_END 			= 0x2F,
	TSCRIPT_MESH_TX				= 0x30,
	TSCRIPT_PROVISION_SERVICE	= 0x31,
	TSCRIPT_PROXY_SERVICE		= 0x32,
	TSCRIPT_END 				= 0x36,
	HCI_LOG 					= 0x3A,	// ":"
	DONGLE_REPORT_SPP_DATA 		= 0x55,
	DONGLE_REPORT_PROVISION_UUID= 0x56,
	DONGLE_REPORT_PROXY_UUID	= 0x57,
	DONGLE_REPORT_ATT_MTU		= 0x58,
    DONGLE_REPORT_ONLINE_ST_UUID= 0x59,
    DONGLE_REPORT_ONLINE_ST_DATA= 0x5a,
    DONGLE_REPORT_READ_RSP		= 0x5b,
    DONGLE_REPORT_FW_VERSION	= 0x5c,
    MESH_CMD_RSP 				= 0x70,
    MESH_ADV_PAYLOAD 			= 0x71,
    MESH_PROV 					= 0x72,	// provision parameters
	MESH_ADV_BEAR_GATT 			= 0x73,
	MESH_ADV_BLE_ST 			= 0x74,
	MESH_MONITOR_DATA 			= 0x75,
	MESH_ADV_ONE_PKT_COMPLETED 	= 0x76,
	MESH_CONNECTION_STS_REPORT 	= 0x77,
	MESH_TX_CMD_RUN_STATUS		= 0x78,
	MESH_GATT_OTA_STATUS 	    = 0x79,
	// can't use 0x7f,  because of HCI_TYPE_TLK_MODULE

	//-------- mesh cmd receive
	TSCRIPT_MESH_RX 			= 0x80,
	TSCRIPT_MESH_RX_NW 			= 0x90,
	
	TSCRIPT_GATEWAY_DIR_RSP 	= 0x91,
	HCI_GATEWAY_CMD_SAR_MSG		= 0x92, 
	TSCRIPT_CMD_VC_DEBUG 		= 0xfa,
	// can't use 0xff,	because of HCI_TYPE_TLK_MODULE
} hci_private_type_t;

extern my_fifo_t			blt_rxfifo;
extern u8					blt_rxfifo_b[];

extern my_fifo_t			blt_txfifo;
extern u8					blt_txfifo_b[];

/***************************ota callback*****************************/
#define     OTA_STEP_FEEDBACK       BIT(2)  //feedback OTA result to peer device

extern u8 ota_reboot_flag;

typedef int (*ota_write_auth_cb_t)(void *p);
extern ota_write_auth_cb_t p_ota_write_auth_cb;

typedef int (*ota_write_data_cb_t)(u32 flash_addr, int len, u8 * data);
extern ota_write_data_cb_t p_ota_write_data_cb;

typedef void (*ota_set_result_cb_t)(int result);
extern ota_set_result_cb_t p_ota_set_result_cb;

void blc_ota_register_ota_auth_cb(ota_write_auth_cb_t cb);
void blc_ota_register_ota_data_cb(ota_write_data_cb_t cb);
void blc_ota_register_ota_result_cb(ota_set_result_cb_t cb);

void blc_ota_write_cb_init(void);
void set_ota_reboot_flag(u8 flag);
int ota_set_flag(void);
int ota_save_data(u32 flash_addr, int len, u8 * data);
bool blt_ota_isOtaBusy(void);
void blt_ota_setResult(int next_step, int result);
void blt_ota_reset(void);
void blc_ota_set_busy(void);
void blc_ota_clear_busy(void);
/**
 * @brief       This function serves to record start tick of gatt ota
 * @return      none
 * @note        
 */
void blc_ota_set_start_tick(void);

/**
 * @brief       This function serves to refresh packet tick when receive ota packet
 * @return      none
 * @note        
 */
void blc_ota_refresh_packet_tick(void);

u8 get_fw_ota_value(void);
/***************************ota callback end*****************************/

u8 is_scan_enable(void);
u8 bls_ll_isConnectState (void);
u8 get_ble_state(void);
u8 get_blt_busy(void);
void set_blt_busy(u8 busy);
void set_sdk_mainLoop_run_flag(u8 flag);
u16 blc_ll_getAdvInterval(void);
void blt_adv_expect_time_refresh(u8 en);
int is_valid_startup_flag(u32 flag_addr, int check_all_flag);
/**
 * @brief       This function serves to check if there's sufficient time before the next connection event
 * @param[in]   us	- expected time
 * @return      1: time is enough   0: time is not enough
 * @note        
 */
int rf_link_time_allow (u32 us);
void set_adv_addr(u8 adv_handle, u8 *addr, u8 addr_type);
u8 blc_ll_getTxFifoMaxNumber(void);
u8 blc_ll_getRxFifoMaxNumber(void);
bool is_in_brx_window(void);

u8 adv_filter_proc(u8 *raw_pkt ,u8 blt_sts);

/**
 * @brief      This function servers to wake up the cpu from sleep mode.
 * @param[in]  sleep_mode - sleep mode type select.
 * @param[in]  wakeup_src - wake up source select.
 * @param[in]  wakeup_tick - the 32k tick which you want to sleep.(32*1000 -> 1s)
 * @return     indicate whether the cpu is wake up successful.
 */
int cpu_long_sleep_wakeup_32k_rc(SleepMode_TypeDef sleep_mode,  SleepWakeupSrc_TypeDef wakeup_src, unsigned int  wakeup_tick);

/**
 * @brief       This function server to rebbot mcu by set REG_ADDR8(0x6f) to 0x20
 * @return      
 * @note        
 */
void start_reboot_by_reg(void);

int get_cpu_wakeup_source(void);

/***********master dongle interface*************/
u32 blm_get_connection_interval(void);
bool blm_push_fifo (int connHandle, u8 *dat);
/***********master dongle interface end*************/

