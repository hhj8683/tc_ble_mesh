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
import { MeshInfoParams } from '../PageParams';


@Entry
@Component
struct NetworkListPage {
    @State networkList: MeshInfo[] = []
    @State currentNetworkId: number = -1
    @State networkNameInput: string = ""
    private nameInputDialogId = 0
    private networkActionDialogId = 0

    async aboutToAppear() {
    }

    private refreshData() {
        this.networkList = MeshInfoService.getInstance().getAll()
        this.currentNetworkId = MeshInfoService.getInstance().getCurrentMesh().id
    }

    eventCb = (event: Event) => {
        let type = event.type
        switch (type) {

        }
    }

    onPageShow(): void {
        this.refreshData()
    }

    aboutToDisappear(): void {
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
        EventBus.getInstance().offEvents(this.eventCb)
    }

    @Builder
    networkInputDialogContent() {
        Column({ space: 8 }) {
            Text("Input Network Name").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.networkNameInput })
            Button("CONFIRM").onClick(() => {
                if (this.networkNameInput == '') {
                    toastMessage(this.getUIContext(), "name input err")
                    return
                }
                let mesh = MeshInfo.createNewMesh(TelinkSigMeshDemoAbility.getContext(), this.networkNameInput)
                MeshInfoService.getInstance().addMeshInfo(mesh)
                this.getUIContext().getPromptAction().closeCustomDialog(this.nameInputDialogId)
                toastMessage(this.getUIContext(), "create new mesh network success")
                this.refreshData()
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)

    }

    private showAddNetworkDialog() {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.networkInputDialogContent()
            },
            autoCancel: true,
            // alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.nameInputDialogId = id
        })
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            this.showAddNetworkDialog()
        })
    }

    // network action dialog - start

    /**
     * show action dialog content
     * @param meshInfo
     */
    @Builder
    networkActionDialogContent(meshInfo: MeshInfo) {
        Column({ space: 8 }) {
            Row() {
                Text("select action for : " + meshInfo.meshName)
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .layoutWeight(1)
                getCommonIcon($r('app.media.ic_close'), () => {
                    this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
                }, $r('app.color.primary'))
            }.padding({ left: 8, right: 8 })

            Divider().strokeWidth(0.2).color(Color.Gray).padding(4)

            Row() {
                getCommonIcon($r('app.media.ic_detail'), undefined, $r('app.color.primary'), 36, 36)
                Text("Show Detail").fontColor($r('app.color.primary')).layoutWeight(1).fontSize(12)
                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.primary'), 36, 36)
            }.onClick(() => {
                this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
                let params: MeshInfoParams = { id: meshInfo.id }
                router.push({ url: "pages/manage-network/NetworkInfoPage", params: params })
            })

            Row() {
                getCommonIcon($r('app.media.ic_share'), undefined, $r('app.color.primary'), 36, 36)
                Text("Share Export").fontColor($r('app.color.primary')).layoutWeight(1).fontSize(12)
                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.primary'), 36, 36)
            }.onClick(()=>{
                this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
                let params: MeshInfoParams = { id: meshInfo.id }
                router.push({ url: "pages/manage-network/ShareImportPage", params: params })
            })

            Row() {
                // Image($r('app.media.ic_share')).fillColor($r('app.color.primary')).width('40').height('40')
                getCommonIcon($r('app.media.ic_switch'), undefined, $r('app.color.primary'), 36, 36)
                Text("Switch To This Network").fontColor($r('app.color.primary')).layoutWeight(1).fontSize(12)
                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.primary'), 36, 36)
            }.onClick(() => {
                this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
                MeshInfoService.getInstance().resetCurrentMesh(meshInfo)
                this.refreshData()
                this.getUIContext()
                    .getPromptAction()
                    .showToast({ message: "switch success" })
            })

            Row() {
                getWarnButton("DELETE", () => {
                    this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
                    showConfirmDialog(this.getUIContext(), "Warn", "Delete Mesh Network?", () => {
                        if (meshInfo.id == this.currentNetworkId) {
                            this.getUIContext()
                                .getPromptAction()
                                .showToast({ message: "can not delete current mesh network" })
                            return
                        }
                        MeshInfoService.getInstance().removeMeshInfo(meshInfo)
                        this.refreshData()
                    })
                })
            }.width('100%').padding(16)

        }
        .width('80%').alignItems(HorizontalAlign.Start).padding(8)
    }

    private showNetworkActionDialog(meshInfo: MeshInfo) {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.networkActionDialogContent(meshInfo)
            },
            autoCancel: true,
            alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.networkActionDialogId = id
        })
    }

    // network action dialog - end

    @Builder
    geNavView() {
        getCommonIcon($r("app.media.ic_arrow_left"), () => {
            router.back()
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
    networkItemContent(item: MeshInfo, index: number) {
        Column({ space: 4 }) {
            this.getTitleText("Name")
            this.getContentText(item.meshName)
            this.getTitleText("UUID")
            this.getContentText(item.meshUUID)
            this.getTitleText("Timestamp")
            Row() {
                Text(item.timestamp)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)
                    .layoutWeight(1)
                getCommonIcon($r('app.media.ic_dots'), undefined, $r('app.color.primary'))
            }.alignItems(VerticalAlign.Top)
        }
        .border({
            width: this.currentNetworkId == item.id ? 2 : {
                bottom: 0.2,
                top: 0.6,
                left: 0.5,
                right: 0.5
            },
            color: this.currentNetworkId == item.id ? $r('app.color.primary') : Color.Grey,
            radius: 5
        })
        .shadow({
            radius: 5,
            offsetY: 2,
            offsetX: 2,
            fill: false,
            color: this.currentNetworkId == item.id ? $r('app.color.primary') : Color.Grey,
            type: ShadowType.COLOR
        })
        .alignItems(HorizontalAlign.Start)
        .margin(8)
        .padding(8)
        .onClick(() => {
            logd("network : " + item.meshName)
            this.showNetworkActionDialog(item)
        })
    }

    removeAll() {
        MeshInfoService.getInstance().removeAllMesh()
        let context = TelinkSigMeshDemoAbility.getContext()
        let meshInfo = MeshInfo.createNewMesh(context)
        MeshInfoService.getInstance().addMeshInfo(meshInfo)
        MeshInfoService.getInstance().resetCurrentMesh(meshInfo)
        PreferencesHelper.setSelectedMeshId(context, meshInfo.id)
        this.refreshData()

        // notify device sub page to refresh node list
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
    }

    switchMesh(meshInfo: MeshInfo) {
        let context = TelinkSigMeshDemoAbility.getContext()
        this.getUIContext().getPromptAction().closeCustomDialog(this.networkActionDialogId)
        MeshInfoService.getInstance().resetCurrentMesh(meshInfo)
        PreferencesHelper.setSelectedMeshId(context, meshInfo.id)

        this.refreshData()
        toastMessage(this.getUIContext(), "switch success")
        // notify device sub page to refresh node list
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
    }

    build() {
        Stack({ alignContent: Alignment.BottomEnd }) {
            Column() {
                TitleBar({
                    title: "Network List",
                    showNavigation: true,
                    showAction: true,
                    navigationView: () => {
                        this.geNavView()
                    },
                    actionView: () => {
                        this.getActionView()
                    }
                })

                List({ space: 4 }) {
                    ForEach(this.networkList, (item: MeshInfo, index: number) => {
                        ListItem() {
                            this.networkItemContent(item, index);
                        }
                    })
                }.width("100%").layoutWeight(1)

                Row() {
                    getWarnButton("REMOVE ALL", () => {
                        showConfirmDialog(this.getUIContext(), "Warn", "remove all and create a new mesh??", () => {
                            this.removeAll()
                        })
                    })
                }.width('100%').padding(16)
            }.height("100%").width("100%")

            Stack({ alignContent: Alignment.Center }) {
                Circle({ width: 56, height: 56 }).fill($r('app.color.accent'))
                Image($r('app.media.ic_import'))
                    .fillColor($r('app.color.white'))
                    .width(24)
                    .height(24)
            }.position({ x: '75%', y: '80%' }).shadow({
                radius: 5,
                fill: false,
                color: $r('app.color.accent'),
                type: ShadowType.BLUR
            }).onClick(() => {
                router.push({ url: "pages/manage-network/ShareImportPage" })
            })
        }.height("100%").width("100%")
    }
}
