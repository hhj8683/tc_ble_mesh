/********************************************************************************************************
 * @file	deprecated_mesh_ota.h
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

#include "tl_common.h"
#include "proj_lib/sig_mesh/app_mesh.h"

typedef enum {
    MESH_OTA_PROTOCOL_DRAFT,      // draft protocol (pre-v4.1.0.0)
    MESH_OTA_PROTOCOL_STANDARD,   // release protocol (v4.1.0.0+)
    MESH_OTA_PROTOCOL_AUTO
} mesh_ota_protocol_t;

// draft opcode below is deprecated!
#define SIG_MD_FW_UPDATE_S_DRAFT                   0xFE00
#define SIG_MD_FW_UPDATE_C_DRAFT                   0xFE01
#define SIG_MD_FW_DISTRIBUT_S_DRAFT                0xFE02
#define SIG_MD_FW_DISTRIBUT_C_DRAFT                0xFE03
#define SIG_MD_BLOB_TRANSFER_S_DRAFT               0xFF00
#define SIG_MD_BLOB_TRANSFER_C_DRAFT               0xFF01

//----------------------------------- op code
// op cmd 0xxxxxxx (SIG)

// op cmd 10xxxxxx xxxxxxxx (SIG)
#define FW_UPDATE_INFO_GET_DRAFT                   0x01B6
#define FW_UPDATE_INFO_STATUS_DRAFT                0x02B6
#define FW_UPDATE_METADATA_CHECK_DRAFT             0x03B6
#define FW_UPDATE_METADATA_CHECK_STATUS_DRAFT      0x04B6
#define FW_UPDATE_GET_DRAFT                        0x05B6
#define FW_UPDATE_START_DRAFT                      0x06B6
#define FW_UPDATE_CANCEL_DRAFT                     0x07B6
#define FW_UPDATE_APPLY_DRAFT                      0x08B6
#define FW_UPDATE_STATUS_DRAFT                     0x09B6
#define FW_DISTRIBUT_GET_DRAFT                     0x0AB6
#define FW_DISTRIBUT_START_DRAFT                   0x0BB6
#define FW_DISTRIBUT_SUSPEND_DRAFT                 0x3AB7
#define FW_DISTRIBUT_CANCEL_DRAFT                  0x0CB6
#define FW_DISTRIBUT_APPLY_DRAFT                   0x0DB6
#define FW_DISTRIBUT_STATUS_DRAFT                  0x0EB6
#define FW_DISTRIBUT_RECEIVERS_GET_DRAFT           0x0FB6
#define FW_DISTRIBUT_RECEIVERS_LIST_DRAFT          0x10B6
#define FW_DISTRIBUT_RECEIVERS_ADD_DRAFT           0x11B6
#define FW_DISTRIBUT_RECEIVERS_DELETE_ALL_DRAFT    0x12B6
#define FW_DISTRIBUT_RECEIVERS_STATUS_DRAFT        0x13B6
#define FW_DISTRIBUT_CAPABILITIES_GET_DRAFT        0x14B6
#define FW_DISTRIBUT_CAPABILITIES_STATUS_DRAFT     0x15B6
#define FW_DISTRIBUT_UPLOAD_GET_DRAFT              0x16B6
#define FW_DISTRIBUT_UPLOAD_START_DRAFT            0x17B6
#define FW_DISTRIBUT_UPLOAD_OOB_START_DRAFT        0x18B6
#define FW_DISTRIBUT_UPLOAD_CANCEL_DRAFT           0x19B6
#define FW_DISTRIBUT_UPLOAD_STATUS_DRAFT           0x1AB6
#define FW_DISTRIBUT_FW_GET_DRAFT                  0x1BB6
#define FW_DISTRIBUT_FW_STATUS_DRAFT               0x1CB6
#define FW_DISTRIBUT_FW_GET_BY_INDEX_DRAFT         0x1DB6
#define FW_DISTRIBUT_FW_DELETE_DRAFT               0x1EB6
#define FW_DISTRIBUT_FW_DELETE_ALL_DRAFT           0x1FB6


#define BLOB_TRANSFER_GET_DRAFT                    0x01B7
#define BLOB_TRANSFER_START_DRAFT                  0x02B7
#define BLOB_TRANSFER_CANCEL_DRAFT                 0x03B7
#define BLOB_TRANSFER_STATUS_DRAFT                 0x04B7
#define BLOB_BLOCK_GET_DRAFT                       0x07B7
#define BLOB_BLOCK_START_DRAFT                     0x05B7
#define BLOB_BLOCK_STATUS_DRAFT                    0x7E
#define BLOB_PARTIAL_BLOCK_REPORT_DRAFT            0x7C     // used for pull mode(LPN)
#define BLOB_CHUNK_TRANSFER_DRAFT                  0x7D
#define BLOB_INFO_GET_DRAFT                        0x0AB7
#define BLOB_INFO_STATUS_DRAFT                     0x0BB7

typedef struct{
    u16 draft_md_id;
    u16 release_md_id;
}mesh_ota_md_id_mapping_t;

typedef struct{
    u16 draft_op;
    u16 release_op;
}mesh_ota_opcode_mapping_t;

int is_draft_mesh_ota_active(void);
void enable_draft_mesh_ota(bool enable);
u16 mesh_ota_adapt_rx_opcode(u16 op);
u16 mesh_ota_adapt_tx_opcode(u16 op);
u16 mesh_ota_adapt_rx_md_id(u16 md_id);
u16 mesh_ota_find_release_opcode(u16 op);

