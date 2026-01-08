import { ADDRESS_BROADCAST, Event, MeshService, num2Hex, SceneRecallMessage } from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { SceneSettingParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, toastMessage } from '../../components/Widgets';
import { CardView } from '../../components/CardView';
import { Scene } from '../../model/Scene';
import { MeshInfo } from '../../model/MeshInfo';

@Entry
@Component
struct SceneListPage {
    @State scenes: Scene[] = []
    @State sceneNameInput: string = ''
    private meshInfo?: MeshInfo
    private nameInputDialogId = 0

    async aboutToAppear() {
        this.meshInfo = MeshInfoService.getInstance().getCurrentMesh()
    }

    onPageShow(): void {
        this.resetData()
    }

    private resetData() {
        this.scenes = this.meshInfo!.scenes
    }

    nodeCpsDataEvtCb = (event: Event) => {
    }

    aboutToDisappear(): void {
    }

    @Builder
    sceneInputDialogContent() {
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
                this.getUIContext().getPromptAction().closeCustomDialog(this.nameInputDialogId)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)

    }

    private showAddSceneDialog() {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.sceneInputDialogContent()
            },
            autoCancel: true,
            // alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.nameInputDialogId = id
        })
    }

    private addScene() {
        this.showAddSceneDialog()
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            this.addScene()
        })
    }

    private sceneRecall(sceneId: number, adr: number) {
        let appKeyIndex = this.meshInfo!.getDefaultAppKeyIndex()
        let recallMessage = SceneRecallMessage.getSimple(adr,
            appKeyIndex, sceneId, false, 0);
        MeshService.getInstance().sendMeshMessage(recallMessage);
    }

    @Builder
    getSceneItem(scene: Scene) {
        CardView({
            cdPadding: 16,
            cdMargin: 8,
        }) {
            Column() {
                Row({ space: 8 }) {
                    getCommonIcon($r('app.media.ic_scene'), undefined, Color.Grey)
                    Text(`Name : ${scene.name}\nID : ${scene.sceneId}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium).layoutWeight(1)

                    getCommonIcon($r('app.media.ic_open'), () => {
                        // scene recall
                        this.sceneRecall(scene.sceneId, ADDRESS_BROADCAST)
                    }, Color.Grey)

                    getCommonIcon($r('app.media.ic_edit'), () => {
                        let params: SceneSettingParams = { sceneId: scene.sceneId }
                        router.push({ url: 'pages/scene/SceneSettingPage', params: params })
                    }, Color.Grey)
                }.alignItems(VerticalAlign.Center)

                // elements
                ForEach(scene.addressList, (ele: number, index) => {
                    Row() {
                        getCommonIcon($r('app.media.ic_element'), undefined, $r('app.color.primary'))

                        Text(`${this.meshInfo!.getDeviceByElementAddress(ele)?.name ??
                            '[unknown]'} \nelement address : 0x${num2Hex(ele, 4)}`).fontSize(12).layoutWeight(1)

                        getCommonIcon($r('app.media.ic_open'), () => {
                            this.sceneRecall(scene.sceneId, ele)
                        }, $r('app.color.primary'), 36, 36)

                    }.alignItems(VerticalAlign.Center)
                })
            }

        }
    }

    @Builder
    getEmptyView() {
        Column() {
            getCommonIcon($r('app.media.ic_sad'), undefined, $r('app.color.primary'))
            Text('List Empty')
            Button('ADD').buttonStyle(ButtonStyleMode.TEXTUAL).onClick(() => {
                this.addScene()
            })
        }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    }

    build() {
        Column() {
            TitleBar({
                title: "Scene List",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })
            if (this.scenes.length > 0) {
                Scroll() {
                    Column() {
                        ForEach(this.scenes, (item: Scene, index: number) => {
                            this.getSceneItem(item)
                        })
                    }.height('auto').justifyContent(FlexAlign.Start)
                }.layoutWeight(1).align(Alignment.TopStart).padding(8)
            } else {
                this.getEmptyView()
            }

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
