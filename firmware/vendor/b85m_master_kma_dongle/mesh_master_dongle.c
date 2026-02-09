/********************************************************************************************************
 * @file	mesh_master_dongle.c
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
#include "tl_common.h"
#include "drivers.h"
#include "stack/ble/ble.h"
#include "mesh_master_dongle.h"

#if (__PROJECT_MASTER_KMA_DONGLE__)
///////////////////////////////////////////
int app_kma_hci_cmd_from_usb (void)
{
	u8 buff[72];
	extern int usb_bulk_out_get_data (u8 *p);
	int n = usb_bulk_out_get_data (buff);

	if(n == 4 && buff[0] == 0x05 && buff[1] == 0x00 && buff[2] == 0x00 && buff[3] == 0x00){
		extern int master_ota_cmd;
		master_ota_cmd = 1;
		return 0;
	}

	if (n)
	{
		blc_hci_handler (buff, n);
	}
	return 0;
}

#if SIG_MESH_TEST_ENABLE
#define SIG_MESH_PTS_PROVISION_OUT_HANDLE	0x73
#define SIG_MESH_PTS_PROXY_OUT_HANDLE		0x95
#endif

ble_sts_t blm_att_requestMtuSizeExchange (u16 handle, u16 mtu_size)
{
	u8 mtu_exchange[16];  // 9 + 4(mic)
	rf_packet_att_mtu_exchange_t *pReq = (rf_packet_att_mtu_exchange_t *)mtu_exchange;

	pReq->type = 2;  //llid
	pReq->rf_len = 7;
	pReq->l2capLen = 0x0003;
	pReq->chanId = 0x0004;
	pReq->opcode = ATT_OP_EXCHANGE_MTU_REQ;
	pReq->mtu[0] = U16_LO(mtu_size);
	pReq->mtu[1] = U16_HI(mtu_size);
	blm_push_fifo (BLM_CONN_HANDLE, mtu_exchange);

	return BLE_SUCCESS;
}

u16 mtu_rx_size = 64-10;// usb endpoint max 64 bytes, rf header 10 bytes
void set_ccc_by_master()
{
	u8 dat_ccc0[11] ={0x02,0x09,0x05,0x00,0x04,0x00,0x12,0x13,0x00,0x01,0x00};
	u8 dat_ccc1[11] ={0x02,0x09,0x05,0x00,0x04,0x00,0x12,0x13,0x00,0x01,0x00};
	u8 tmp_uuid[4];
	#if SIG_MESH_TEST_ENABLE
	dat_ccc0[7]=SIG_MESH_PTS_PROVISION_OUT_HANDLE;
	dat_ccc1[7]=SIG_MESH_PTS_PROXY_OUT_HANDLE;
	#else


	#endif
	if( connect_tick &&
	    clock_time_exceed(connect_tick, 200*1000)&&
	    !central_sdp_pending){
	    if(prov_out_handle){
			dat_ccc0[7] = prov_out_ccc_handle;
			blm_push_fifo(BLM_CONN_HANDLE,dat_ccc0);
			sleep_us(blm_get_connection_interval()*1250<<2); // wait 4 interval for rsp
			memcpy(tmp_uuid,my_provision_out_uuid,sizeof(my_provision_out_uuid));
			tmp_uuid[2]= prov_out_handle;
			tmp_uuid[3]= prov_in_handle;
			tc_set_fifo(DONGLE_REPORT_PROVISION_UUID, tmp_uuid, sizeof(tmp_uuid));
	    }

		if(proxy_out_handle){
			dat_ccc1[7] = proxy_out_ccc_handle;

			blm_push_fifo(BLM_CONN_HANDLE,dat_ccc1);
			sleep_us(blm_get_connection_interval()*1250<<2);

			memcpy(tmp_uuid,my_proxy_out_uuid,sizeof(my_proxy_out_uuid));
			tmp_uuid[2]= proxy_out_handle;
			tmp_uuid[3]= proxy_in_handle;
			tc_set_fifo(DONGLE_REPORT_PROXY_UUID, tmp_uuid, sizeof(tmp_uuid));
			u8 tmp_ble_sts =1;
			tc_set_fifo(MESH_CONNECTION_STS_REPORT, &tmp_ble_sts, 1);
		}

		get_fw_version();
		connect_tick =0;
		sleep_us(blm_get_connection_interval()*1250<<2);
		blm_att_requestMtuSizeExchange(BLM_CONN_HANDLE, mtu_rx_size);
	}
	return ;
}

u32 connect_tick;

void push_adv_to_usb(event_adv_report_t *pa)
{
	u8 dat[0x40]={0x04,0x3e};
	dat[2] = pa->len+10+OFFSETOF(event_adv_report_t, mac);
	memcpy(dat+3,pa, 4);
	memcpy(dat+7,pa->mac,pa->len+10);
	my_fifo_push(&hci_tx_fifo, dat, pa->len+10+7,0,0); // 7:dat[0]~da[2] + OFFSETOF(event_adv_report_t, mac)
	return ;
}

u8 my_provision_out_uuid[2]	= {SIG_MESH_PROVSIION_DATA_OUT};
u8 my_provision_in_uuid[2] = {SIG_MESH_PROVISION_DATA_IN};

u8 my_proxy_out_uuid[2] = {SIG_MESH_PROXY_DATA_OUT};
u8 my_proxy_in_uuid[2] = {SIG_MESH_PROXY_DATA_IN};
const u8 my_OnlineStC2SUUID[16] = WRAPPING_BRACES(TELINK_ONLINE_ST_DATA_UUID);
u8 prov_out_handle =0;
u8 prov_in_handle =0;
u8 prov_out_ccc_handle = 0;

u8 proxy_out_handle =0;
u8 proxy_in_handle =0;
u8 proxy_out_ccc_handle =0;
u8 kma_online_st_handle =0;
u8 fw_version_handle = 0;

#if SIG_MESH_GATT_ENABLE
u8 tc_fifo[72];

u8 tc_set_fifo(u8 cmd,u8 *pfifo,u8 cmd_len)
{
	if(cmd_len>70){
		return 0;
	}
	tc_fifo[0] = cmd;
	tc_fifo[1] = cmd_len;
	memcpy(tc_fifo+2,pfifo,cmd_len);
	my_fifo_push(&hci_tx_fifo, tc_fifo, tc_fifo[1]+2,0,0);  // test
	return 1;
}
#endif

int get_ccc_handle(u16 start_handle, u16 end_handle)
{
	u16 handle = -1;
	u8  dat[32];

    dat[6] = ATT_OP_FIND_INFO_REQ;
	if (app_find_char_info(dat, cur_conn_device.conn_handle, start_handle, end_handle))
	{
		return  ATT_ERR_INVALID_PARAMETER;			//timeout
	}

	att_findInfoRsp_t *p_rsp = (att_findInfoRsp_t *) dat;
	if (p_rsp->opcode == ATT_OP_FIND_INFO_RSP && p_rsp->format == 1)
	{
		int n = p_rsp->l2capLen - 2;
		u8 *pd = p_rsp->data;
		while (n > 0)
		{
			if ((pd[2]==U16_LO(GATT_UUID_CLIENT_CHAR_CFG) && pd[3]==U16_HI(GATT_UUID_CLIENT_CHAR_CFG)))
			{
				handle = pd[0] + (pd[1]<<8);
				break;
			}

			n -= 4;
			pd += 4;
		}
	}

	return handle;
}

int get_fw_version()
{
	if(fw_version_handle == 0){
		return HCI_ERR_CMD_DISALLOWED;
	}

	u8  dat[32];
	u8 tmp = central_sdp_pending;
	central_sdp_pending = 1;
    dat[6] = ATT_OP_READ_REQ;
	if (app_read_char_value(dat, cur_conn_device.conn_handle, fw_version_handle))
	{
		central_sdp_pending = tmp;
		return	ATT_ERR_INVALID_PARAMETER;			//timeout
	}
	central_sdp_pending = tmp;

	att_readRsp_t *pr = (att_readRsp_t *) dat;
	if (pr->opcode == ATT_OP_READ_RSP)
	{
		tc_set_fifo(DONGLE_REPORT_FW_VERSION, pr->value, pr->l2capLen-1);
	}
	return BLE_SUCCESS;
}
#endif
