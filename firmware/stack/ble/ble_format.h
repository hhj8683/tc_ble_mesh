/********************************************************************************************************
 * @file    ble_format.h
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
#ifndef BLE_FORMAT_H
#define BLE_FORMAT_H


#include "tl_common.h" // BLE_SRC_TELINK_MESH_EN
#include "stack/ble/ble_common.h"

/******************************************** Link Layer **************************************************************/


/**
 *  @brief Definition for a connection completion event
 */
typedef struct {
	u8	subcode;
	u8	status;
	u16	handle;
	u8	role;
	u8	peer_adr_type;
	u8	mac[6];
	u16	interval;
	u16	latency;
	u16	timeout;
	u8	accuracy;
} event_connection_complete_t;


typedef struct { // BLE_SRC_TELINK_MESH_EN
    u8 type   :4;
    u8 rfu1   :1;
    u8 chan_sel:1;
    u8 txAddr :1;
    u8 rxAddr :1;
}rf_adv_head_t;

/**
 *  @brief Definition for the packet used for advertizing
 */
typedef struct{
	u32 dma_len;

    union{
        rf_adv_head_t header; // BLE_SRC_TELINK_MESH_EN
        struct{
        	u8 type   :4;
        	u8 rfu1   :1;
        	u8 chan_sel:1;
        	u8 txAddr :1;
        	u8 rxAddr :1;
        };
    };

	u8  rf_len;				//LEN(6)_RFU(2)

	u8	advA[6];			//address
    #if (MESH_DLE_MODE == MESH_DLE_MODE_EXTEND_BEAR || EXTENDED_ADV_ENABLE) // BLE_SRC_TELINK_MESH_EN
    u8  data[249];          // 255 -6(mac)
    #else
	u8	data[31];
    #endif
}rf_packet_adv_t;


/**
 *  @brief Definition for RF data head
 */
typedef struct {
    u8 llid   :2;
    u8 nesn   :1;
    u8 sn     :1;
    u8 md     :1;
    u8 rfu1   :3;
}rf_data_head_t;

// BLE_SRC_TELINK_MESH_EN start
typedef struct {
    s8  rssi;       // have been -110
    s16 dc;
    u32 timeStamp;
} adv_report_extend_t;

//sizeof(rf_pkt_ext_adv_t) = 261
typedef struct{
	u32 dma_len;

	u8 type   :4;
	u8 rfu1   :1;
	u8 chan_sel:1;
	u8 txAddr :1;
	u8 rxAddr :1;

	u8  rf_len;
	u8	ext_hdr_len		:6;
	u8	adv_mode		:2;
	u8	ext_hdr_flg;

	u8	data[253];   //Extended Header + AdvData
}rf_pkt_ext_adv_t;

typedef struct{
	u32 dma_len;

	u8 type   :4;
	u8 rfu1   :1;
	u8 chan_sel:1;
	u8 txAddr :1;
	u8 rxAddr :1;

	u8  rf_len;

	u8	ext_hdr_len		:6;
	u8	adv_mode		:2;

	u8	ext_hdr_flg;

	u8	advA[6];

	//ADI
	u16	did	:12;
	u16	sid : 4;

	u8	dat[1];   // AuxPtr/AdvData
}rf_pkt_aux_adv_ind_1;

typedef struct{
	u32 dma_len;

	u8 type   :4;
	u8 rfu1   :1;
	u8 chan_sel:1;
	u8 txAddr :1;
	u8 rxAddr :1;

	u8  rf_len;

	u8	ext_hdr_len		:6;
	u8	adv_mode		:2;

	u8	ext_hdr_flg;

	u8	advA[6];
	u8	targetA[6];

	//ADI
	u16	did	:12;
	u16	sid : 4;

	u8	dat[1]; // AuxPtr/AdvData
}rf_pkt_aux_adv_ind_2;

typedef struct{
	u32 dma_len;

	u8 type   :4;
	u8 rfu1   :1;
	u8 chan_sel:1;
	u8 txAddr :1;
	u8 rxAddr :1;

	u8  rf_len;

	u8	ext_hdr_len		:6;
	u8	adv_mode		:2;

	u8	ext_hdr_flg;

	u8	advA[6];

	//ADI
	u16	did	:12;
	u16	sid : 4;

	//AuxPrt
	u8  chn_index    :6;
	u8  ca 		 	:1;
	u8  offset_unit	:1;
	u16 aux_offset  :13;
	u16	aux_phy		:3;

	u8	dat[1];   // AdvData
}rf_pkt_aux_adv_ind_3;

typedef struct{
	u32 dma_len;

	u8 type   :4;
	u8 rfu1   :1;
	u8 chan_sel:1;
	u8 txAddr :1;
	u8 rxAddr :1;

	u8  rf_len;

	u8	ext_hdr_len		:6;
	u8	adv_mode		:2;

	u8	ext_hdr_flg;

	u8	advA[6];
	u8	targetA[6];

	//ADI
	u16	did	:12;
	u16	sid : 4;

	//AuxPrt
	u8  chn_index    :6;
	u8  ca 		 	:1;
	u8  offset_unit	:1;
	u16 aux_offset  :13;
	u16	aux_phy		:3;

	u8	dat[1]; // AdvData
}rf_pkt_aux_adv_ind_4;
// BLE_SRC_TELINK_MESH_EN end

/******************************************** L2CAP **************************************************************/


/**
 *  @brief Definition for RF packet used to transfer data for the L2CAP protocol
 */
typedef struct{
	rf_data_head_t	header;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8 data[1];
}rf_packet_l2cap_t;



/**
 *  @brief Definition for RF packet used to transfer data for the attribute protocol
 */
typedef struct{
	rf_data_head_t	header;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8  handle0;
	u8  handle1;
	u8	dat[20];
}rf_packet_att_t;



/**
 *  @brief Definition for RF packet used to transfer request data of l2cap protocol
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8 data[1];
}rf_packet_l2cap_req_t;



/**
 *  @brief Definition for RF packet used to the connection parameters for transmitting the L2CAP protocol update request data.
 */
typedef struct{
	u8	llid;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8	id;
	u16 data_len;
	u16 min_interval;
	u16 max_interval;
	u16 latency;
	u16 timeout;
}rf_packet_l2cap_connParaUpReq_t;


/**
 *  @brief Definition for RF packet used to transfer ATT data
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2cap;
	u16	chanid;

	u8	att;
	u16 handle;

	u8	dat[20];

}rf_packet_att_data_t;


/**
 *  @brief Definition for RF packet used to transmit ATT error responses
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8 	errOpcode;
	u16 errHandle;
	u8  errReason;
}rf_packet_att_errRsp_t;


/**
 *  @brief Definition for RF packet used to transmit ATT data of read by type response
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8  datalen;
	u8  data[1];			// character_handle / property / value_handle / value
}rf_pkt_att_readByTypeRsp_t;



/**
 *  @brief Definition for RF packet used for transmitting write request data in ATT
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u16 handle;
	u8 value;
}rf_packet_att_write_t;


/**
 *  @brief Definition for RF packet used  for MTU exchange in ATT
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8 mtu[2];
}rf_packet_att_mtu_exchange_t;


/**
 *  @brief Definition for an ATT response packet
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8  datalen;
	u8  data[1];			// character_handle / property / value_handle / value
}att_readByTypeRsp_t;


/**
 *  @brief Definition for  an ATT response packet for the "Find Information" operation
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8  format;
	u8  data[1];			// character_handle / property / value_handle / value
}att_findInfoRsp_t;


/**
 *  @brief Definition for an ATT response packet for the "Read Request" operation
 */
typedef struct{
	u8	type;
	u8  rf_len;
	u16	l2capLen;
	u16	chanId;
	u8  opcode;
	u8 	value[22];
}att_readRsp_t;


#endif	/* BLE_FORMAT_H */
