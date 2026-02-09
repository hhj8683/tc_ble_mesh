/********************************************************************************************************
 * @file     SceneSettingPage.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
import {
    ConfigStatus,
    Element,
    Event,
    EventBus,
    logd,
    logw,
    MeshMessage,
    MeshService,
    MeshSigModel,
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
    @State scene?: Scene = undefined
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
        this.initData()
        this.resetData()
        EventBus.getInstance().on(SceneRegisterStatusMessage.STATUS_NAME, this.evtCb)
    }

    private initData() {
        // init element selection state
        for (let node of this.meshInfo!.nodes) {
            if (!node.compositionData) {
                continue;
            }
            for (let i = 0; i < node.compositionData.elements.length; i++) {
                node.compositionData.elements[i].selected = this.scene!.contains(node.meshAddress + i);
            }
        }
    }

    private resetData() {
        this.nodes = [...this.meshInfo!.nodes]
    }

    private evtCb = (event: Event) => {
        logw('scene register st')
        if (event.type == SceneRegisterStatusMessage.STATUS_NAME) {
            let statusNotificationEvent = event as StatusNotificationEvent;
            let notificationMessage = statusNotificationEvent.notificationMessage
            let sceneRegisterStatusMessage = notificationMessage.statusMessage as SceneRegisterStatusMessage
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
            Text("Update Scene Name").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.sceneNameInput })
            Button("CONFIRM").onClick(() => {
                if (this.sceneNameInput == '') {
                    toastMessage(this.getUIContext(), "name input err")
                    return
                }

                this.scene!.name = this.sceneNameInput;
                toastMessage(this.getUIContext(), 'update name success')
                this.meshInfo!.saveOrUpdate();
                this.getUIContext().getPromptAction().closeCustomDialog(this.nameInputDialogId)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)

    }

    private showEditNameDialog() {
        this.sceneNameInput = this.scene!.name
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

        MeshInfoService.getInstance().updateMeshInfo(this.meshInfo!)
        settingModel.nodeInfo.compositionData!.elements[settingModel.elementOffset].selected = settingModel.add;
        WaitingDialog.dismiss()
        this.resetData()
        toastMessage(this.getUIContext(), 'set scene success')
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_edit"), () => {
            this.showEditNameDialog()
        })
    }

    isElementSupportScene(element: Element) {
        let tarModelId = MeshSigModel.SIG_MD_SCENE_S
        if (element.sigModels != null) {
            for (let modelId of element.sigModels) {
                if (modelId == tarModelId) {
                    return true;
                }
            }
        }

        if (element.vendorModels != null) {
            for (let modelId of element.vendorModels) {
                if (modelId == tarModelId) {
                    return true;
                }
            }
        }
        return false
    }

    @Builder
    getNodeItem(node: NodeInfo) {
        CardView({
            cdPadding: 16,
            cdMargin: 8,
        }) {
            Column() {
                // node icon
                Row({ space: 8 }) {
                    Image(IconGenerator.getIcon(node)).width(36).height(36)
                    Text(`name : ${node.name}\naddress : 0x${num2Hex(node.meshAddress, 4)}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium).layoutWeight(1)

                }.alignItems(VerticalAlign.Center)

                // elements
                ForEach(node.compositionData?.elements, (ele: Element, index) => {
                    Row() {
                        Row() {
                            getCommonIcon($r('app.media.ic_element'), undefined, $r('app.color.primary'))
                            Text(`element : 0x${num2Hex(node.meshAddress + index, 4)}`).fontSize(12).layoutWeight(1)
                            if (this.isElementSupportScene(ele)) {
                                Checkbox().select(ele.selected).shape(CheckBoxShape.ROUNDED_SQUARE)
                            } else {
                                Text(`scene not support`).fontSize(12)
                            }
                        }.alignItems(VerticalAlign.Center)
                        .hitTestBehavior(HitTestMode.Block)
                        .onClick(() => {
                            if (this.isElementSupportScene(ele)) {
                                this.setScene(node, index, !ele.selected)
                            } else {
                                toastMessage(this.getUIContext(), 'scene not support')
                            }
                        }).layoutWeight(1)

                        if (this.isElementSupportScene(ele)) {
                            if (ele.selected) {
                                getCommonIcon($r('app.media.ic_refresh'), () => {
                                    this.setScene(node, index, true)
                                }, $r('app.color.primary'), 42, 42)
                            } else {
                                Text().width(42).height(42)
                            }
                        }

                    }.alignItems(VerticalAlign.Center).width('100%')
                })
            }.alignItems(HorizontalAlign.Start).width('100%')
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Scene Setting",
                subTitle: this.scene!.name,
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
                    }.width('100%')
                })
            }.layoutWeight(1).width('100%')
        }.width('100%').height("100%")
    }
}
