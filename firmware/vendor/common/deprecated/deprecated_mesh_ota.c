/********************************************************************************************************
 * @file	deprecated_mesh_ota.c
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
#include "proj_lib/ble/blt_config.h"
#include "vendor/common/user_config.h"
#include "proj_lib/sig_mesh/app_mesh.h"
#include "mesh_ota.h"
#include "deprecated_mesh_ota.h"

#if (DEPRECATED_MESH_OTA_COMPAT)
int g_draft_mesh_ota_en = 0;
int is_draft_mesh_ota_active()
{
    return g_draft_mesh_ota_en;
}

void enable_draft_mesh_ota(bool enable)
{
    LOG_MSG_LIB(TL_LOG_NODE_SDK, 0, 0,"enable_draft_mesh_ota:%d", enable);
    g_draft_mesh_ota_en = enable;
}

const mesh_ota_md_id_mapping_t mesh_ota_md_id_map[] = {
    {SIG_MD_BLOB_TRANSFER_S_DRAFT, SIG_MD_BLOB_TRANSFER_S},
    {SIG_MD_BLOB_TRANSFER_C_DRAFT, SIG_MD_BLOB_TRANSFER_C},
    {SIG_MD_FW_UPDATE_S_DRAFT,     SIG_MD_FW_UPDATE_S},
    {SIG_MD_FW_UPDATE_C_DRAFT,     SIG_MD_FW_UPDATE_C},
    {SIG_MD_FW_DISTRIBUT_S_DRAFT,  SIG_MD_FW_DISTRIBUT_S},
    {SIG_MD_FW_DISTRIBUT_C_DRAFT,  SIG_MD_FW_DISTRIBUT_C},
};

const mesh_ota_opcode_mapping_t mesh_ota_op_map[] = {
    {FW_UPDATE_INFO_GET_DRAFT,               FW_UPDATE_INFO_GET},
    {FW_UPDATE_INFO_STATUS_DRAFT,            FW_UPDATE_INFO_STATUS},
    {FW_UPDATE_METADATA_CHECK_DRAFT,         FW_UPDATE_METADATA_CHECK},
    {FW_UPDATE_METADATA_CHECK_STATUS_DRAFT,  FW_UPDATE_METADATA_CHECK_STATUS},
    {FW_UPDATE_GET_DRAFT,                    FW_UPDATE_GET},
    {FW_UPDATE_START_DRAFT,                  FW_UPDATE_START},
    {FW_UPDATE_CANCEL_DRAFT,                 FW_UPDATE_CANCEL},
    {FW_UPDATE_APPLY_DRAFT,                  FW_UPDATE_APPLY},
    {FW_UPDATE_STATUS_DRAFT,                 FW_UPDATE_STATUS},
    {FW_DISTRIBUT_GET_DRAFT,                 FW_DISTRIBUT_GET},
    {FW_DISTRIBUT_START_DRAFT,               FW_DISTRIBUT_START},
    {FW_DISTRIBUT_SUSPEND_DRAFT,             FW_DISTRIBUT_SUSPEND},
    {FW_DISTRIBUT_CANCEL_DRAFT,              FW_DISTRIBUT_CANCEL},
    {FW_DISTRIBUT_APPLY_DRAFT,               FW_DISTRIBUT_APPLY},
    {FW_DISTRIBUT_STATUS_DRAFT,              FW_DISTRIBUT_STATUS},
    {FW_DISTRIBUT_RECEIVERS_GET_DRAFT,       FW_DISTRIBUT_RECEIVERS_GET},
    {FW_DISTRIBUT_RECEIVERS_LIST_DRAFT,      FW_DISTRIBUT_RECEIVERS_LIST},
    {FW_DISTRIBUT_RECEIVERS_ADD_DRAFT,       FW_DISTRIBUT_RECEIVERS_ADD},
    {FW_DISTRIBUT_RECEIVERS_DELETE_ALL_DRAFT,FW_DISTRIBUT_RECEIVERS_DELETE_ALL},
    {FW_DISTRIBUT_RECEIVERS_STATUS_DRAFT,    FW_DISTRIBUT_RECEIVERS_STATUS},
    {FW_DISTRIBUT_CAPABILITIES_GET_DRAFT,    FW_DISTRIBUT_CAPABILITIES_GET},
    {FW_DISTRIBUT_CAPABILITIES_STATUS_DRAFT, FW_DISTRIBUT_CAPABILITIES_STATUS},
    {FW_DISTRIBUT_UPLOAD_GET_DRAFT,          FW_DISTRIBUT_UPLOAD_GET},
    {FW_DISTRIBUT_UPLOAD_START_DRAFT,        FW_DISTRIBUT_UPLOAD_START},
    {FW_DISTRIBUT_UPLOAD_OOB_START_DRAFT,    FW_DISTRIBUT_UPLOAD_OOB_START},
    {FW_DISTRIBUT_UPLOAD_CANCEL_DRAFT,       FW_DISTRIBUT_UPLOAD_CANCEL},
    {FW_DISTRIBUT_UPLOAD_STATUS_DRAFT,       FW_DISTRIBUT_UPLOAD_STATUS},
    {FW_DISTRIBUT_FW_GET_DRAFT,              FW_DISTRIBUT_FW_GET},
    {FW_DISTRIBUT_FW_STATUS_DRAFT,           FW_DISTRIBUT_FW_STATUS},
    {FW_DISTRIBUT_FW_GET_BY_INDEX_DRAFT,     FW_DISTRIBUT_FW_GET_BY_INDEX},
    {FW_DISTRIBUT_FW_DELETE_DRAFT,           FW_DISTRIBUT_FW_DELETE},
    {FW_DISTRIBUT_FW_DELETE_ALL_DRAFT,       FW_DISTRIBUT_FW_DELETE_ALL},
    {BLOB_TRANSFER_GET_DRAFT,                BLOB_TRANSFER_GET},
    {BLOB_TRANSFER_START_DRAFT,              BLOB_TRANSFER_START},
    {BLOB_TRANSFER_CANCEL_DRAFT,             BLOB_TRANSFER_CANCEL},
    {BLOB_TRANSFER_STATUS_DRAFT,             BLOB_TRANSFER_STATUS},
    {BLOB_BLOCK_GET_DRAFT,                   BLOB_BLOCK_GET},
    {BLOB_BLOCK_START_DRAFT,                 BLOB_BLOCK_START},
    {BLOB_BLOCK_STATUS_DRAFT,                BLOB_BLOCK_STATUS},
    {BLOB_PARTIAL_BLOCK_REPORT_DRAFT,        BLOB_PARTIAL_BLOCK_REPORT},
    {BLOB_CHUNK_TRANSFER_DRAFT,              BLOB_CHUNK_TRANSFER},
    {BLOB_INFO_GET_DRAFT,                    BLOB_INFO_GET},
    {BLOB_INFO_STATUS_DRAFT,                 BLOB_INFO_STATUS},
};

u16 mesh_ota_adapt_rx_md_id(u16 md_id)
{
    if(is_draft_mesh_ota_active()){
        foreach_arr(i, mesh_ota_md_id_map){
            if(md_id == mesh_ota_md_id_map[i].draft_md_id){
                return mesh_ota_md_id_map[i].release_md_id;
            }
        }
    }

    return md_id;
}

u16 mesh_ota_find_release_opcode(u16 op)
{
    foreach_arr(i, mesh_ota_op_map){
        if(op == mesh_ota_op_map[i].draft_op){
            return mesh_ota_op_map[i].release_op;
        }
    }

    return op;
}

u16 mesh_ota_find_draft_opcode(u16 op)
{
    foreach_arr(i, mesh_ota_op_map){
        if(op == mesh_ota_op_map[i].release_op){
            return mesh_ota_op_map[i].draft_op;
        }
    }

    return op;
}

void mesh_ota_select_mode_by_op(u16 op)
{
    if((op >= FW_UPDATE_INFO_GET_DRAFT) && (op <= FW_DISTRIBUT_FW_DELETE_ALL_DRAFT)){
       enable_draft_mesh_ota(1);
    }
    else if((op >= FW_UPDATE_INFO_GET) && (op <= FW_DISTRIBUT_FW_DELETE_ALL)){
        enable_draft_mesh_ota(0);
    }
}

u16 mesh_ota_adapt_rx_opcode(u16 op)
{
    mesh_ota_select_mode_by_op(op);

    if(is_draft_mesh_ota_active()){
        op = mesh_ota_find_release_opcode(op);
    }

    return op;
}

u16 mesh_ota_adapt_tx_opcode(u16 op)
{
    if(is_draft_mesh_ota_active()){
        op = mesh_ota_find_draft_opcode(op);
    }

    return op;
}

#endif

