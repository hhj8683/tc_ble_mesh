/********************************************************************************************************
 * @file	mesh_master_dongle.h
 *
 * @brief	for TLSR chips
 *
 * @author	telink
 * @date	Sep. 30, 2010
 *
 * @par     Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
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
#if (__PROJECT_MASTER_KMA_DONGLE__)
extern u8 kma_online_st_handle;
extern u32 connect_tick;
extern u8 my_provision_in_uuid[2];
extern u8 my_provision_out_uuid[2];
extern u8 my_proxy_out_uuid[2];
extern u8 my_proxy_in_uuid[2];
extern const u8 my_OnlineStC2SUUID[16];
extern u8 prov_out_handle;
extern u8 prov_in_handle;
extern u8 prov_out_ccc_handle;
extern u8 proxy_out_handle;
extern u8 proxy_in_handle;
extern u8 proxy_out_ccc_handle;
extern u8 fw_version_handle;

extern my_fifo_t hci_tx_fifo;

int app_kma_hci_cmd_from_usb (void);
ble_sts_t blm_att_requestMtuSizeExchange (u16 handle, u16 mtu_size);
void set_ccc_by_master();
void push_adv_to_usb(event_adv_report_t *pa);
u8 tc_set_fifo(u8 cmd,u8 *pfifo,u8 cmd_len);
int get_ccc_handle(u16 start_handle, u16 end_handle);
int get_fw_version();
#endif
