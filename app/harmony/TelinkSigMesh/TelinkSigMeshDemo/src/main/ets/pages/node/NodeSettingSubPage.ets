import { getCommonIcon, getWarnButton, toastMessage } from '../../components/Widgets';
import { router } from '@kit.ArkUI';
import {
    Event,
    EventBus,
    logd,
    MeshEvent,
    MeshService,
    MeshSigModel,
    ModelPublication,
    NodeResetMessage,
    NodeResetStatusMessage,
    ModelPublicationSetMessage,
    num2Hex,
    StatusNotificationEvent,
    ModelPublicationStatusMessage,
    ConfigStatus
} from 'telinksigmeshlib';
import { NodeInfo } from '../../model/NodeInfo';
import { UiStateEvent } from '../../model/UiStateEvent';
import { MeshInfoService } from '../../model/MeshInfoService';
import { showConfirmDialog, WaitingDialog } from '../../components/Dialogs';
import { CardView } from '../../components/CardView';
import { NodeParams } from '../PageParams';
import TelinkSigMeshDemoAbility from '../../abilities/TelinkSigMeshDemoAbility';
import { PublishModel } from '../../model/PublishModel';

interface NodeSettingAction {
    icon: Resource
    title: string
    pagePath: string
}

const NODE_SETTING_ACTIONS: NodeSettingAction[] = [
    { icon: $r("app.media.ic_config"), title: "Device Config", pagePath: "pages/node/NodeConfigPage" },
    { icon: $r("app.media.ic_composition"), title: "Composition Data", pagePath: "pages/node/CompositionDataPage" },
    { icon: $r("app.media.ic_keys"), title: "Network Keys - todo", pagePath: "" },
    { icon: $r("app.media.ic_bridge"), title: "Subnet Bridge Setting - todo", pagePath: "" },
    { icon: $r("app.media.ic_alarm"), title: "Scheduler Setting", pagePath: "pages/node/SchedulerListPage" },
    { icon: $r("app.media.ic_model"), title: "Subscription Models", pagePath: "pages/node/SubscriptionModelsPage" },
    { icon: $r("app.media.ic_update"), title: "Device OTA", pagePath: "pages/node/NodeOtaPage" },
    { icon: $r("app.media.ic_private_beacon"), title: "Private Beacon - todo", pagePath: "" },
]

const PUB_INTERVAL = 20 * 1000;

const PUB_ADDRESS = 0xFFFF;

@Component
export default struct NodeSettingSubPage {
    nameInputCtrl: TextInputController = new TextInputController();
    @Prop node?: NodeInfo = undefined
    @State nameInput: string = ""
    private nameInputDialogId = 0
    private isKickingDirect = false
    private kickOutTimeoutId = 0;
    @State isPubConfigured: boolean = false
    private pubSetTimeoutId = 0
    private pubModel?: PublishModel
    @State pubModelInfo: string = ''

    async aboutToAppear() {
        logd("NodeControlSubPage # aboutToAppear")
        EventBus.getInstance().on(NodeResetStatusMessage.STATUS_NAME, this.onResetStatus)
        EventBus.getInstance().on(ModelPublicationStatusMessage.STATUS_NAME, this.onPubStatus)
        EventBus.getInstance().on(MeshEvent.EVENT_TYPE_DISCONNECTED, this.onDisconnectEvent)
        this.initPubModel()
    }

    aboutToDisappear(): void {
        logd("NodeControlSubPage # aboutToDisappear")
        clearTimeout(this.kickOutTimeoutId)
        clearTimeout(this.pubSetTimeoutId)
        EventBus.getInstance().off(NodeResetStatusMessage.STATUS_NAME, this.onResetStatus)
        EventBus.getInstance().off(ModelPublicationStatusMessage.STATUS_NAME, this.onPubStatus)
        EventBus.getInstance().off(MeshEvent.EVENT_TYPE_DISCONNECTED, this.onDisconnectEvent)
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
    onPubStatus = (event: Event) => {
        let ne = event as StatusNotificationEvent
        let stMsg = ne.notificationMessage.statusMessage as ModelPublicationStatusMessage
        if (ne.notificationMessage.src == this.node?.meshAddress) {
            let pubAdr = stMsg.publication!.publishAddress
            if (stMsg.status == ConfigStatus.SUCCESS) {
                let configured = pubAdr != 0
                this.isPubConfigured = configured
                this.node!.setPublishModel(configured ? this.pubModel : undefined)
                MeshInfoService.getInstance().updateNodeInfo(this.node!)
            } else {
                toastMessage(this.getUIContext(), 'set pub status err : ' + stMsg.status)
            }
            clearTimeout(this.pubSetTimeoutId)
            WaitingDialog.dismiss()
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
        this.kickOutTimeoutId = setTimeout(() => {
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
                if (this.nameInput.includes('&')) {
                    toastMessage(this.getUIContext(), 'can not contains \'&\'')
                    return
                }
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

    /**
     * check available publish model
     * check device has ctl model, if not -> check hsl, if not -> check onoff
     */
    public initPubModel() {
        this.isPubConfigured = this.node!.getPublishModel() != undefined

        let pubInterval = PUB_INTERVAL;
        let address = PUB_ADDRESS;
        let models = [
            MeshSigModel.SIG_MD_LIGHT_CTL_S, MeshSigModel.SIG_MD_LIGHT_HSL_S,
            MeshSigModel.SIG_MD_LIGHTNESS_S, MeshSigModel.SIG_MD_G_ONOFF_S
        ]
        let modelNames = [
            'CTL', 'HSL',
            'LIGHTNESS', 'ONOFF'
        ]
        for (let i = 0; i < models.length; i++) {
            let modelId = models[i];
            let pubEleAdr = this.node!.getElementByModel(modelId)
            if (pubEleAdr != -1) {
                this.pubModel = PublishModel.getSimple(pubEleAdr, modelId, address, pubInterval)
                this.pubModelInfo = `Publication (ele : ${num2Hex(pubEleAdr)} model: ${modelNames[i]})`
                return;
            }
        }
        this.pubModel = undefined
        this.pubModelInfo = 'Publication (no available model)'
    }

    private async setPublish() {
        if (!this.pubModel) {
            toastMessage(this.getUIContext(), 'no available model')
            return
        }
        let add: boolean = !this.isPubConfigured
        let pubAdr = 0;
        if (add) {
            pubAdr = this.pubModel.address;
            logd("cancel publication");
        } else {
            logd("set publication");

        }
        let appKeyIndex = MeshInfoService.getInstance().getCurrentMesh().getDefaultAppKeyIndex()
        let modelId = this.pubModel.modelId;
        let eleAdr = this.node!.getElementByModel(modelId)
        let modelPublication =
            ModelPublication.createDefault(eleAdr, pubAdr, appKeyIndex, this.pubModel.period, this.pubModel.modelId,
                true);
        let publicationSetMessage = new ModelPublicationSetMessage(this.node!.meshAddress, modelPublication);
        let result = await MeshService.getInstance().sendMeshMessage(publicationSetMessage);
        if (result) {
            WaitingDialog.show("processing...")
            this.pubSetTimeoutId = setTimeout(() => {
                toastMessage(this.getUIContext(), "pub set timeout")
                WaitingDialog.dismiss()
            }, 5 * 1000)
        }
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
                Text(this.pubModelInfo).layoutWeight(1).fontSize(14)
                Checkbox()
                    .select(this.isPubConfigured)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .selectedColor($r('app.color.primary'))
            }.width('100%')
            .onClick(() => {
                this.setPublish()
            }).hitTestBehavior(HitTestMode.Block)
        }
    }

    @Builder
    getNodeActionView(actionIndex: number) {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 },
            cdClick: () => {
                if (NODE_SETTING_ACTIONS[actionIndex].pagePath != '') {
                    router.push({
                        url: NODE_SETTING_ACTIONS[actionIndex].pagePath,
                        params: { deviceUuid: this.node!.deviceUUID }
                    })
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
            .padding({ bottom: 8 })

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
