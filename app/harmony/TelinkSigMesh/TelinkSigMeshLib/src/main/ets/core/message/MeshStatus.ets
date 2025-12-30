/********************************************************************************************************
 * @file MeshStatus.java
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
import { AppKeyStatusMessage } from './config/AppKeyStatusMessage';
import { CompositionDataStatusMessage } from './config/CompositionDataStatusMessage';
import { ModelAppStatusMessage } from './config/ModelAppStatusMessage';
import { ModelSubscriptionStatusMessage } from './config/ModelSubscriptionStatusMessage';
import { NodeIdentityStatusMessage } from './config/NodeIdentityStatusMessage';
import { NodeResetStatusMessage } from './config/NodeResetStatusMessage';
import { OnOffStatusMessage } from './generic/OnOffStatusMessage';
import { LightnessStatusMessage } from './Index';
import { Opcode } from './Opcode';
import { SceneRegisterStatusMessage } from './scene/SceneRegisterStatusMessage';
import { StatusMessage } from './StatusMessage';
import { TimeStatusMessage } from './time/TimeStatusMessage';


/**
 * MeshStatus is a class that represents the status of a mesh network message.
 * It contains the opcode and the class of the status message.
 * The opcode is the unique identifier of the message.
 * The status message class is the class that extends the StatusMessage class.
 * <p>
 * This class also includes a nested class called Container, which is responsible for registering the opcode and the corresponding status message class.
 * The register method is used to register the opcode and the status message class.
 * The getMessageClass method is used to retrieve the status message class based on the opcode.
 * <p>
 * Note: All registered status messages should have an empty constructor for creating an instance of the message.
 * {@link StatusMessage#createByAccessMessage(int, byte[])}
 * Created by kee on 2019/9/3.
 */
export class MeshStatus {
    private static parserRegistry: Map<number, () => StatusMessage> = new Map();

    public static register(opcode: number, statusCreator: () => StatusMessage) {
        MeshStatus.parserRegistry.set(opcode, statusCreator)
    }

    public static getStatusMessage(opcode: number, params?: Uint8Array): StatusMessage | undefined {
        let statusCreator = MeshStatus.parserRegistry.get(opcode)
        if (!statusCreator) {
            return undefined
        }
        let stMsg: StatusMessage = statusCreator()
        if (stMsg && params) {
            stMsg.parse(params)
        }
        return stMsg
    }

    static {
        MeshStatus.register(Opcode.COMPOSITION_DATA_STATUS, () => {
            return new CompositionDataStatusMessage()
        });
        MeshStatus.register(Opcode.MODE_APP_STATUS, () => {
            return new ModelAppStatusMessage()
        });
        MeshStatus.register(Opcode.APPKEY_STATUS, () => {
            return new AppKeyStatusMessage()
        });
        MeshStatus.register(Opcode.NODE_RESET_STATUS, () => {
            return new NodeResetStatusMessage()
        });
        MeshStatus.register(Opcode.CFG_MODEL_SUB_STATUS, () => {
            return new ModelSubscriptionStatusMessage()
        });

        MeshStatus.register(Opcode.TIME_STATUS, () => {
            return new TimeStatusMessage()
        });
        // MeshStatus.register(Opcode.CFG_MODEL_PUB_STATUS, ()=>{return new ModelPublicationStatusMessage()});
        MeshStatus.register(Opcode.NODE_ID_STATUS, () => {
            return new NodeIdentityStatusMessage()
        });
        // MeshStatus.register(Opcode.NETKEY_STATUS, ()=>{return new NetKeyStatusMessage()});
        //
        // MeshStatus.register(Opcode.SUBNET_BRIDGE_STATUS, ()=>{return new SubnetBridgeStatusMessage()});
        // MeshStatus.register(Opcode.BRIDGING_TABLE_STATUS, ()=>{return new BridgingTableStatusMessage()});
        //
        // /// configs
        // MeshStatus.register(Opcode.CFG_NW_TRANSMIT_STATUS, ()=>{return new NetworkTransmitStatusMessage()});
        // MeshStatus.register(Opcode.CFG_BEACON_STATUS, ()=>{return new BeaconStatusMessage()});
        // MeshStatus.register(Opcode.CFG_DEFAULT_TTL_STATUS, ()=>{return new DefaultTTLStatusMessage()});
        // MeshStatus.register(Opcode.CFG_RELAY_STATUS, ()=>{return new RelayStatusMessage()});
        //
        // MeshStatus.register(Opcode.CFG_FRIEND_STATUS, ()=>{return new FriendStatusMessage()});
        // MeshStatus.register(Opcode.CFG_GATT_PROXY_STATUS, ()=>{return new GattProxyStatusMessage()});
        // MeshStatus.register(Opcode.CFG_KEY_REFRESH_PHASE_STATUS, ()=>{return new KeyRefreshPhaseStatusMessage()});
        //
        // // private beacon
        // MeshStatus.register(Opcode.PRIVATE_BEACON_STATUS, ()=>{return new PrivateBeaconStatusMessage()});
        // MeshStatus.register(Opcode.PRIVATE_NODE_IDENTITY_STATUS, ()=>{return new PrivateNodeIdentityStatusMessage()});
        // MeshStatus.register(Opcode.PRIVATE_GATT_PROXY_STATUS, ()=>{return new PrivateGattProxyStatusMessage()});
        //
        // // generic
        MeshStatus.register(Opcode.G_ONOFF_STATUS, () => {
            return new OnOffStatusMessage()
        });
        // MeshStatus.register(Opcode.G_LEVEL_STATUS, ()=>{return new LevelStatusMessage()});
        //
        // // lighting
        MeshStatus.register(Opcode.LIGHTNESS_STATUS, ()=>{return new LightnessStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_CTL_TEMP_STATUS, ()=>{return new CtlTemperatureStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_CTL_STATUS, ()=>{return new CtlStatusMessage()});
        //
        // MeshStatus.register(Opcode.LIGHT_HSL_STATUS, ()=>{return new HslStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_HSL_TARGET_STATUS, ()=>{return new HslTargetStatusMessage()});
        //
        // MeshStatus.register(Opcode.LIGHT_LC_MODE_STATUS, ()=>{return new LcModeStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_LC_OM_STATUS, ()=>{return new LcOmStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_LC_ONOFF_STATUS, ()=>{return new LcLightOnOffStatusMessage()});
        // MeshStatus.register(Opcode.LIGHT_LC_PROPERTY_STATUS, ()=>{return new LcPropertyStatusMessage()});
        //
        //
        // // sensor
        // MeshStatus.register(Opcode.SENSOR_CANDECE_STATUS, ()=>{return new SensorCadenceStatusMessage()});
        // MeshStatus.register(Opcode.SENSOR_STATUS, ()=>{return new SensorStatusMessage()});
        // MeshStatus.register(Opcode.SENSOR_DESCRIP_STATUS, ()=>{return new SensorDescriptorStatusMessage()});
        //
        // // time
        // MeshStatus.register(Opcode.TIME_STATUS, ()=>{return new TimeStatusMessage()});
        //
        // // scene
        // MeshStatus.register(Opcode.SCENE_STATUS, ()=>{return new SceneStatusMessage()});
        MeshStatus.register(Opcode.SCENE_REG_STATUS, () => {
            return new SceneRegisterStatusMessage()
        });
        //
        // // scheduler status
        // MeshStatus.register(Opcode.SCHD_STATUS, ()=>{return new SchedulerStatusMessage()});
        // MeshStatus.register(Opcode.SCHD_ACTION_STATUS, ()=>{return new SchedulerActionStatusMessage()});
        //
        //
        // // mesh firmware update
        // MeshStatus.register(Opcode.FIRMWARE_UPDATE_INFORMATION_STATUS, ()=>{return new FirmwareUpdateInfoStatusMessage()});
        // MeshStatus.register(Opcode.FIRMWARE_UPDATE_FIRMWARE_METADATA_STATUS, ()=>{return new FirmwareMetadataStatusMessage()});
        // MeshStatus.register(Opcode.FIRMWARE_UPDATE_STATUS, ()=>{return new FirmwareUpdateStatusMessage()});
        //
        // // mesh firmware distribution
        // MeshStatus.register(Opcode.FD_STATUS, ()=>{return new FDStatusMessage()});
        // MeshStatus.register(Opcode.FD_CAPABILITIES_STATUS, ()=>{return new FDCapabilitiesStatusMessage()});
        // MeshStatus.register(Opcode.FD_RECEIVERS_STATUS, ()=>{return new FDReceiversStatusMessage()});
        // MeshStatus.register(Opcode.FD_RECEIVERS_LIST, ()=>{return new FDReceiversListMessage()});
        // MeshStatus.register(Opcode.FD_UPLOAD_STATUS, ()=>{return new FDUploadStatusMessage()});
        // MeshStatus.register(Opcode.FD_FIRMWARE_STATUS, ()=>{return new FDFirmwareStatusMessage()});
        //
        // /// blob transfer
        // MeshStatus.register(Opcode.BLOB_BLOCK_STATUS, ()=>{return new BlobBlockStatusMessage()});
        // MeshStatus.register(Opcode.BLOB_INFORMATION_STATUS, ()=>{return new BlobInfoStatusMessage()});
        // MeshStatus.register(Opcode.BLOB_TRANSFER_STATUS, ()=>{return new BlobTransferStatusMessage()});
        // MeshStatus.register(Opcode.BLOB_PARTIAL_BLOCK_REPORT, ()=>{return new BlobPartialBlockReportMessage()});
        //
        // // remote provision
        // MeshStatus.register(Opcode.REMOTE_PROV_SCAN_STS, ()=>{return new ScanStatusMessage()});
        // MeshStatus.register(Opcode.REMOTE_PROV_SCAN_REPORT, ()=>{return new ScanReportStatusMessage()});
        // MeshStatus.register(Opcode.REMOTE_PROV_LINK_STS, ()=>{return new LinkStatusMessage()});
        // MeshStatus.register(Opcode.REMOTE_PROV_PDU_REPORT, ()=>{return new ProvisioningPDUReportMessage()});
        // MeshStatus.register(Opcode.REMOTE_PROV_PDU_OUTBOUND_REPORT, ()=>{return new ProvisioningPDUOutboundReportMessage()});
        //
        // // fast provision [vendor]
        // MeshStatus.register(Opcode.VD_MESH_ADDR_GET_STS, ()=>{return new MeshAddressStatusMessage()});
        //
        // // opcode aggregator
        // MeshStatus.register(Opcode.CFG_OP_AGG_STATUS, ()=>{return new OpcodeAggregatorStatusMessage()});
        //
        // // direct forwarding table
        // MeshStatus.register(Opcode.FORWARDING_TABLE_STATUS, ()=>{return new ForwardingTableStatusMessage()});
        // MeshStatus.register(Opcode.DIRECTED_CONTROL_STATUS, ()=>{return new DirectedControlStatusMessage()});
        //
        // // enhanced features
        // MeshStatus.register(Opcode.CFG_SAR_TRANSMITTER_STATUS, ()=>{return new SarTransmitStatusMessage()});
        // MeshStatus.register(Opcode.CFG_SAR_RECEIVER_STATUS, ()=>{return new SarReceiverStatusMessage()});
        // MeshStatus.register(Opcode.CFG_ON_DEMAND_PROXY_STATUS, ()=>{return new OnDemandPrivateProxyStatusMessage()});
        // MeshStatus.register(Opcode.LARGE_CPS_STATUS, ()=>{return new LargeCompositionDataStatusMessage()});
        // MeshStatus.register(Opcode.SOLI_PDU_RPL_ITEM_STATUS, ()=>{return new SolicitationItemsStatusMessage()});
    }
}
