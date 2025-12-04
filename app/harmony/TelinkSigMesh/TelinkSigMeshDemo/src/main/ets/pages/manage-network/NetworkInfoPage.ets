import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getWarnButton, toastMessage } from '../../components/Widgets';
import {
    BindingBearer,
    BindingDevice,
    BindingEvent,
    BindingParameters,
    bytesToHexString,
    Event,
    EventBus,
    hexToBytes,
    logd,
    logw,
    MeshConfiguration,
    MeshScanRecord,
    MeshService,
    num2Hex,
    OnOffSetMessage,
    ProvisioningDevice,
    ProvisioningEvent,
    ProvisioningParameters,
    ScanEvent,
    ScanParameters
} from 'telinksigmeshlib';
import { UiStateEvent } from '../../model/UiStateEvent';
import { router } from '@kit.ArkUI';
import { ble } from '@kit.ConnectivityKit';
import { MeshInfo } from '../../model/MeshInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { CardView } from '../../components/CardView';
import { ArrayList } from '@kit.ArkTS';
import TelinkSigMeshDemoAbility from '../../abilities/TelinkSigMeshDemoAbility';
import { showConfirmDialog } from '../../components/Dialogs';
import { PreferencesHelper } from '../../utils/PreferencesHelper';
import { MeshNetKey } from '../../model/MeshNetKey';
import { MeshAppKey } from '../../model/MeshAppKey';
import { MeshInfoParams } from '../PageParams';


@Entry
@Component
struct NetworkInfoPage {
    @State networkName: string = ""
    @State meshInfo: MeshInfo | undefined = undefined
    private nameInputDialogId = 0

    async aboutToAppear() {
        let meshId = (router.getParams() as MeshInfoParams).id
        if (meshId) {
            this.meshInfo = MeshInfoService.getInstance().getById(meshId)
        } else {
            this.meshInfo = MeshInfoService.getInstance().getCurrentMesh()
        }
        this.networkName = this.meshInfo?.meshName ?? ""
    }

    @Builder
    nameInputDialogContent() {
        Column({ space: 8 }) {
            Text("Update Mesh Name").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.networkName })
            Button("CONFIRM").onClick(() => {
                if (this.networkName == '') {
                    toastMessage(this.getUIContext(), "name input err")
                    return
                }
                this.meshInfo!.meshName = this.networkName
                MeshInfoService.getInstance().updateMeshInfo(this.meshInfo!)
                toastMessage(this.getUIContext(), "update mesh name success")
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    private showUpdateNameDialog() {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.nameInputDialogContent()
            },
            autoCancel: true,
            // alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.nameInputDialogId = id
        })
    }

    @Builder
    getTitleText(title: string) {
        Text(title)
            .fontSize(11)
            .fontColor(Color.Gray)
            .textAlign(TextAlign.Start)
    }

    @Builder
    getContentText(content: string) {
        Text(content)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Gray)
            .textAlign(TextAlign.Start)
    }

    @Builder
    getInfoItem(icon: Resource, title: string, content: string, titleFontSize: number = 13, leftPadding: number = 0) {
        Row() {
            getCommonIcon(icon, undefined, Color.Gray)
            Column() {
                Text(title)
                    .fontSize(titleFontSize)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)

                Text(content).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
            }.alignItems(HorizontalAlign.Start)
        }.padding({ left: leftPadding })
    }

    @Builder
    getNetKeysView() {
        Row() {
            getCommonIcon($r('app.media.ic_keys'), undefined, Color.Gray)
            Text("Net Keys")
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)
        }

        ForEach(this.meshInfo!.meshNetKeyList, (item: MeshNetKey, index: number) => {
            this.getInfoItem($r('app.media.ic_name'), 'Name', item.name, 12, 16)
            this.getInfoItem($r('app.media.ic_id'), 'Index', `0x${num2Hex(item.index, 2)}`, 12, 16)
            Row() {
                getCommonIcon($r('app.media.ic_key_value'), undefined, Color.Gray)
                Column() {
                    Text('Key')
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.Gray)
                        .textAlign(TextAlign.Start)

                    Text(item.key).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
                }.alignItems(HorizontalAlign.Start)
            }.padding({ left: 16 })
        });
    }

    @Builder
    getAppKeysView() {
        Row() {
            getCommonIcon($r('app.media.ic_keys'), undefined, Color.Gray)
            Text("App Keys")
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)
        }

        ForEach(this.meshInfo!.appKeyList, (item: MeshAppKey, index: number) => {
            this.getInfoItem($r('app.media.ic_name'), 'Name', item.name, 12, 16)
            this.getInfoItem($r('app.media.ic_id'), 'Index', `0x${num2Hex(item.index, 2)}`, 12, 16)
            Row() {
                getCommonIcon($r('app.media.ic_key_value'), undefined, Color.Gray)
                Column() {
                    Text('Key')
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.Gray)
                        .textAlign(TextAlign.Start)

                    Text(item.key).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
                }.alignItems(HorizontalAlign.Start)
            }.padding({ left: 16 })

            this.getInfoItem($r('app.media.ic_bound_key'), 'Bond Net Key', `0x${num2Hex(item.boundNetKeyIndex, 2)}`, 12,
                16)
        });
    }

    build() {
        Column() {
            TitleBar({
                title: "MeshInfo",
                subTitle: this.networkName,
                showAction: true,
                actionView: () => {
                    getCommonIcon($r("app.media.ic_edit"), () => {
                        this.showUpdateNameDialog()
                    })
                }
            })

            Scroll() {
                Column({ space: 4 }) {
                    this.getInfoItem($r('app.media.ic_name'), 'Mesh Name', this.networkName)
                    this.getInfoItem($r('app.media.ic_id'), 'Mesh UUID', this.meshInfo!.meshUUID)
                    this.getInfoItem($r('app.media.ic_iv_index'), 'IV Index', "0x" + num2Hex(this.meshInfo!.ivIndex, 8))
                    this.getInfoItem($r('app.media.ic_sequence_number'), 'Sequence Number',
                        "0x" + num2Hex(this.meshInfo!.sequenceNumber, 6))
                    this.getInfoItem($r('app.media.ic_local_address'), 'Local Address',
                        "0x" + num2Hex(this.meshInfo!.localAddress, 4))
                    this.getNetKeysView()
                }.height('auto').width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1)
            .align(Alignment.TopStart)
            .backgroundColor('#FCFCFC').margin({ top: 16, bottom: 16 })

        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC').alignItems(HorizontalAlign.Start)
    }
}
