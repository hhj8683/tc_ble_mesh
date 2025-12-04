import { getCommonIcon, getWarnButton, toastMessage } from '../../components/Widgets';
import { router } from '@kit.ArkUI';
import {
    Event,
    EventBus,
    logd,
    MeshEvent,
    MeshService,
    NodeResetMessage,
    NodeResetStatusMessage,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { NodeInfo } from '../../model/NodeInfo';
import { UiStateEvent } from '../../model/UiStateEvent';
import { MeshInfoService } from '../../model/MeshInfoService';
import { showConfirmDialog, WaitingDialog } from '../../components/Dialogs';
import { CardView } from '../../components/CardView';

interface NodeSettingAction {
    icon: Resource
    title: string
    pagePath: string
}

const NODE_SETTING_ACTIONS: NodeSettingAction[] = [
    { icon: $r("app.media.ic_config"), title: "Device Config - todo", pagePath: "" },
    { icon: $r("app.media.ic_composition"), title: "Composition Data - todo", pagePath: "" },
    { icon: $r("app.media.ic_keys"), title: "Network Keys - todo", pagePath: "" },
    { icon: $r("app.media.ic_bridge"), title: "Subnet Bridge Setting - todo", pagePath: "" },
    { icon: $r("app.media.ic_alarm"), title: "Scheduler Setting - todo", pagePath: "" },
    { icon: $r("app.media.ic_model"), title: "Subscription Models - todo", pagePath: "" },
    { icon: $r("app.media.ic_update"), title: "Device OTA - todo", pagePath: "" },
    { icon: $r("app.media.ic_private_beacon"), title: "Private Beacon - todo", pagePath: "" },
]

@Component
export default struct NodeSettingSubPage {
    nameInputCtrl: TextInputController = new TextInputController();
    @Prop node?: NodeInfo = undefined
    @State nameInput: string = ""
    private nameInputDialogId = 0
    private isKickingDirect = false
    private kickOutTimerId = 0;

    async aboutToAppear() {

        logd("NodeControlSubPage # aboutToAppear")
        EventBus.getInstance().on(NodeResetStatusMessage.STATUS_NAME, this.onResetStatus)
        EventBus.getInstance().on(MeshEvent.EVENT_TYPE_DISCONNECTED, this.onDisconnectEvent)

    }

    aboutToDisappear(): void {
        logd("NodeControlSubPage # aboutToDisappear")
        clearTimeout(this.kickOutTimerId)
        EventBus.getInstance().off(NodeResetStatusMessage.STATUS_NAME, this.onResetStatus)
    }

    onDisconnectEvent = (event: Event) => {
        if (this.isKickingDirect) {
            this.onKickComplete()
        }
    }
    onResetStatus = (event: Event) => {
        let ne = event as StatusNotificationEvent
        let stMsg = ne.notificationMessage.statusMessage as NodeResetStatusMessage
        if (ne.notificationMessage.src == this.node?.meshAddress && !this.isKickingDirect) {
            this.onKickComplete()
        }
    }

    /****************************************************************
     * kick out
     ****************************************************************/
    private onKickComplete() {
        WaitingDialog.dismiss()
        MeshInfoService.getInstance().getCurrentMesh().removeNode(this.node!)
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
        router.back()
    }

    private kickOut() {
        if (!this.node) {
            return
        }
        this.isKickingDirect = MeshService.getInstance().getDirectConnectedNodeAddress() == this.node.meshAddress
        let resetMessage = new NodeResetMessage(this.node.meshAddress)
        this.kickOutTimerId = setTimeout(() => {
            this.onKickComplete()
        }, this.isKickingDirect ? 10 * 1000 : 3 * 1000);
        WaitingDialog.show("kicking out")
        MeshService.getInstance().sendMeshMessage(resetMessage)
    }

    @Builder
    nameInputDialogContent() {
        Column({ space: 8 }) {
            Text("Input New Name").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.nameInput })
            Button("CONFIRM").onClick(() => {
                this.node!.name = this.nameInput
                MeshInfoService.getInstance().updateNodeInfo(this.node!)
                this.getUIContext().getPromptAction().closeCustomDialog(this.nameInputDialogId)
                toastMessage(this.getUIContext(), "update name success")
            })
        }.width('80%').alignItems(HorizontalAlign.Center).padding(8)

    }

    private showNameInputDialog() {
        if (this.node) {
            this.nameInput = this.node?.name
        }
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.nameInputDialogContent()
            },
            autoCancel: true,
        }).then((id: number) => {
            this.nameInputDialogId = id
        })
    }

    @Builder
    getNameView() {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 }
        }) {
            Row() {
                getCommonIcon($r('app.media.ic_name'), undefined, $r('app.color.text_color_normal'))
                Text("Name : " + this.node!.name).layoutWeight(1).fontSize(14)
                getCommonIcon($r('app.media.ic_edit'), () => {
                    this.showNameInputDialog()
                }, $r('app.color.primary'))
            }.width('100%')
        }
    }

    @Builder
    getPubView() {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 }
        }) {
            Row() {
                getCommonIcon($r('app.media.ic_publish'), undefined, $r('app.color.text_color_normal'))
                Text("Publication : todo").layoutWeight(1).fontSize(14)
                Checkbox()
                    .select(true)
                    .enabled(false)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .selectedColor($r('app.color.primary'))
            }.width('100%')
        }
    }

    @Builder
    getNodeActionView(actionIndex: number) {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 },
            cdClick: () => {
                if (NODE_SETTING_ACTIONS[actionIndex].pagePath != '') {
                    router.push({ url: NODE_SETTING_ACTIONS[actionIndex].pagePath })
                }
            }
        }) {
            Row() {
                getCommonIcon(NODE_SETTING_ACTIONS[actionIndex].icon, undefined, $r('app.color.text_color_normal'))
                Text(NODE_SETTING_ACTIONS[actionIndex].title).layoutWeight(1).fontSize(14)
                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.text_color_normal'))
            }.width('100%')
        }
    }

    build() {
        Column() {
            Text("UUID : " + this.node!.deviceUUID).fontSize(13).fontStyle(FontStyle.Italic).margin(16)
            Scroll() {
                Column({ space: 16 }) {
                    this.getNameView()
                    ForEach(NODE_SETTING_ACTIONS, (item: NodeSettingAction, index: number) => {
                        this.getNodeActionView(index)
                    })
                    this.getPubView()
                }.height('auto').width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1)
            .align(Alignment.TopStart)
            .backgroundColor('#FCFCFC')

            Row() {
                getWarnButton("KICK OUT", () => {
                    showConfirmDialog(this.getUIContext(), "Warn", "Confirm to remove device?", () => {
                        this.kickOut();
                    })
                })
            }.width('100%').padding(16)
        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC').alignItems(HorizontalAlign.Start)
    }
}
