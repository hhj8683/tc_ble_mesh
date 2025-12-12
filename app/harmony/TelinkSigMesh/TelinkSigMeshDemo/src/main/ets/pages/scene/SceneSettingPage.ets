import {
    ConfigStatus,
    Element,
    Event,
    EventBus,
    logd,
    MeshMessage,
    MeshService,
    num2Hex,
    SceneDeleteMessage,
    SceneRecallMessage,
    SceneRegisterStatusMessage,
    SceneStoreMessage,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams, SceneSettingParams, SchedulerSettingParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, toastMessage } from '../../components/Widgets';
import { CardView } from '../../components/CardView';
import { Scene } from '../../model/Scene';
import { MeshInfo } from '../../model/MeshInfo';
import { IconGenerator } from '../../utils/IconGenerator';
import { WaitingDialog } from '../../components/Dialogs';


interface SettingModel {
    elementOffset: number
    add: boolean
    nodeInfo: NodeInfo
}

@Entry
@Component
struct SceneSettingPage {
    private sceneId = 0
    private scene?: Scene
    private setSceneTimeoutId = 0
    @State sceneNameInput: string = ''
    @State nodes: NodeInfo[] = []
    private meshInfo?: MeshInfo
    private nameInputDialogId: number = 0
    private settingModel?: SettingModel

    async aboutToAppear() {
        let params = router.getParams() as SceneSettingParams
        this.sceneId = params.sceneId
        this.meshInfo = MeshInfoService.getInstance().getCurrentMesh()
        this.scene = this.meshInfo.getSceneById(this.sceneId)
        this.nodes = [...this.meshInfo.nodes]
        this.resetData()
        EventBus.getInstance().on(SceneRegisterStatusMessage.STATUS_NAME, this.evtCb)
    }

    private resetData() {
    }

    evtCb = (event: Event) => {
        if (event.type == SceneRegisterStatusMessage.STATUS_NAME) {
            let statusNotificationEvent = event as StatusNotificationEvent;
            let notificationMessage = statusNotificationEvent.notificationMessage
            let sceneRegisterStatusMessage =  notificationMessage.statusMessage as SceneRegisterStatusMessage
            let model = this.settingModel;
            if (!model) {
                logd("scene setting null");
                return;
            }
            if (sceneRegisterStatusMessage.statusCode == ConfigStatus.SUCCESS
                && notificationMessage.src == model.nodeInfo.meshAddress + model.elementOffset) {
                this.onSettingComplete(model);
            }
        }
    }

    aboutToDisappear(): void {
        clearTimeout(this.setSceneTimeoutId)
    }

    @Builder
    nameInputDialogContent() {
        Column({ space: 8 }) {
            Text("Create Scene").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.sceneNameInput })
            Button("CONFIRM").onClick(() => {
                if (this.sceneNameInput == '') {
                    toastMessage(this.getUIContext(), "name input err")
                    return
                }

                let sceneId = this.meshInfo!.allocSceneId();
                if (sceneId == -1) {
                    toastMessage(this.getUIContext(), "no available scene id")
                    return;
                }
                let scene = new Scene();
                scene.sceneId = sceneId;
                scene.name = this.sceneNameInput;
                toastMessage(this.getUIContext(), 'create scene success')
                this.meshInfo!.addScene(scene);
                this.resetData();
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)

    }

    private showEditNameDialog() {
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

    private setScene(node: NodeInfo, eleOffset: number, selected: boolean) {
        let meshMessage: MeshMessage;
        let appKeyIndex = this.meshInfo!.getDefaultAppKeyIndex();
        let adr = node.meshAddress + eleOffset
        this.settingModel = { elementOffset: eleOffset, add: selected, nodeInfo: node }
        if (selected) {
            meshMessage = SceneStoreMessage.getSimple(adr, appKeyIndex, this.sceneId, true, 1);
        } else {
            meshMessage = SceneDeleteMessage.getSimple(adr, appKeyIndex, this.sceneId, true, 1);
        }
        WaitingDialog.show('scene setting...')
        this.setSceneTimeoutId = setTimeout(() => {
            WaitingDialog.dismiss()
        }, 5 * 1000)
        MeshService.getInstance().sendMeshMessage(meshMessage);
    }

    private onSettingComplete(settingModel: SettingModel) {
        clearTimeout(this.setSceneTimeoutId)
        let adr = settingModel.nodeInfo.meshAddress + settingModel.elementOffset
        if (settingModel.add) {
            this.scene!.save(adr);
        } else {
            this.scene!.remove(adr);
        }
        settingModel.nodeInfo.compositionData!.elements[settingModel.elementOffset].selected = settingModel.add;
        WaitingDialog.dismiss()
        this.resetData
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_edit"), () => {
            this.showEditNameDialog()
        })
    }

    @Builder
    getNodeItem(node: NodeInfo) {
        CardView({
            cdPadding: 16,
            cdMargin: 8,
        }) {
            Column() {
                Row({ space: 8 }) {
                    Image(IconGenerator.getIcon(node)).width(36).height(36)
                    Text(`name : ${node.name}\naddress : 0x${num2Hex(node.meshAddress, 4)}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium).layoutWeight(1)

                }.alignItems(VerticalAlign.Center)

                ForEach(node.compositionData?.elements, (ele: Element, index) => {

                    Row() {

                        Row() {
                            getCommonIcon($r('app.media.ic_element'), undefined, $r('app.color.primary'))
                            Text(`element : 0x${num2Hex(node.meshAddress + index, 4)}`).fontSize(12)
                            Checkbox().select(ele.selected).shape(CheckBoxShape.ROUNDED_SQUARE)
                        }.alignItems(VerticalAlign.Center)
                        .hitTestBehavior(HitTestMode.Block)
                        .onClick(() => {
                            this.setScene(node, index, !ele.selected)
                        })

                        if (ele.selected) {
                            getCommonIcon($r('app.media.ic_refresh'), () => {
                                this.setScene(node, index, true)
                            }, $r('app.color.primary'), 42, 42)
                        } else {
                            Text().width(42).height(42)

                        }

                    }.alignItems(VerticalAlign.Center)
                })
            }.alignItems(HorizontalAlign.Start)
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Scheduler List",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })
            List() {
                ForEach(this.nodes, (node: NodeInfo, index: number) => {
                    ListItem() {
                        this.getNodeItem(node)
                    }
                })
            }.layoutWeight(1).width('100%')

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
