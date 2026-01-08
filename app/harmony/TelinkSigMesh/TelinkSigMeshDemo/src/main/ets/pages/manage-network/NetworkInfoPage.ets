import { TitleBar } from '../../components/TitleBar'
import { getCommonIcon, toastMessage } from '../../components/Widgets'
import { num2Hex } from 'telinksigmeshlib'
import { router } from '@kit.ArkUI'
import { MeshInfo } from '../../model/MeshInfo'
import { MeshInfoService } from '../../model/MeshInfoService'
import { MeshNetKey } from '../../model/MeshNetKey'
import { MeshAppKey } from '../../model/MeshAppKey'
import { MeshInfoParams } from '../PageParams'
import { pasteboard } from '@kit.BasicServicesKit'


@Entry
@Component
struct NetworkInfoPage {
    @State meshNameInput: string = ""
    @State meshInfo: MeshInfo | undefined = undefined
    private nameInputDialogId = 0

    async aboutToAppear() {
        // let params = router.getParams()
        let params = router.getParams() as MeshInfoParams
        if (params && params.id){
            this.meshInfo = MeshInfoService.getInstance().getById(params.id)
        }else {
            this.meshInfo = MeshInfoService.getInstance().getCurrentMesh()
        }
    }

    @Builder
    nameInputDialogContent() {
        Column({ space: 8 }) {
            Text("Update Mesh Name").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.meshNameInput })
            Button("CONFIRM").onClick(() => {
                if (this.meshNameInput == '') {
                    toastMessage(this.getUIContext(), "name input err")
                    return
                }
                if (this.meshNameInput.includes('&')) {
                    toastMessage(this.getUIContext(), 'can not contains \'&\'')
                    return
                }
                this.meshInfo!.meshName = this.meshNameInput
                MeshInfoService.getInstance().updateMeshInfo(this.meshInfo!)
                toastMessage(this.getUIContext(), "update mesh name success")
                this.getUIContext().getPromptAction().closeCustomDialog(this.nameInputDialogId)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    private showUpdateNameDialog() {
        this.meshNameInput = this.meshInfo!.meshName
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
    getInfoItem(icon: Resource, title: string, content: string) {
        Row() {
            getCommonIcon(icon, undefined, Color.Gray)
            Column() {
                Text(title)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)

                Text(content).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
            }.alignItems(HorizontalAlign.Start)
        }
    }

    @Builder
    getKeyItem(icon: Resource, title: string, content: string, isKey: boolean = false) {
        Row() {
            getCommonIcon(icon, undefined, Color.Gray, 36, 36)
            Column() {
                Text(title)
                    .fontSize(12)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)

                Text(content).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
            }.alignItems(HorizontalAlign.Start).layoutWeight(1)

            if (isKey) {
                getCommonIcon($r('app.media.ic_copy'), () => {
                    let pasteData: pasteboard.PasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, content)
                    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard()
                    systemPasteboard.setData(pasteData, (err) => {
                        if (err) {
                            toastMessage(this.getUIContext(), "copy key fail")
                            return
                        }
                        toastMessage(this.getUIContext(), "key copied")
                    })
                }, Color.Gray, 36, 36)
            }
        }.padding({ left: 16, right: 16 })
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
            this.getKeyItem($r('app.media.ic_name'), 'Name', item.name,)
            this.getKeyItem($r('app.media.ic_id'), 'Index', `0x${num2Hex(item.index, 2)}`)
            this.getKeyItem($r('app.media.ic_key_value'), 'Key', item.key, true)
        })
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
            this.getKeyItem($r('app.media.ic_name'), 'Name', item.name)
            this.getKeyItem($r('app.media.ic_id'), 'Index', `0x${num2Hex(item.index, 2)}`)
            this.getKeyItem($r('app.media.ic_key_value'), 'Key', item.key, true)
            this.getKeyItem($r('app.media.ic_bound_key'), 'Bond Net Key', `0x${num2Hex(item.boundNetKeyIndex, 2)}`)
        })
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_edit"), () => {
            this.showUpdateNameDialog()
        })
    }

    build() {
        Column() {
            TitleBar({
                title: "MeshInfo",
                subTitle: this.meshInfo!.meshName,
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })

            Scroll() {
                Column({ space: 4 }) {
                    // this.getInfoItem($r('app.media.ic_name'), 'Mesh Name', this.meshInfo!.meshName)

                    Row() {
                        getCommonIcon($r('app.media.ic_name'), undefined, Color.Gray)
                        Column() {
                            Text('Mesh Name')
                                .fontSize(13)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(Color.Gray)
                                .textAlign(TextAlign.Start)

                            Text(this.meshInfo!.meshName).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
                        }.alignItems(HorizontalAlign.Start)
                    }.padding({ left: 0 })

                    this.getInfoItem($r('app.media.ic_id'), 'Mesh UUID', this.meshInfo!.meshUUID)
                    this.getInfoItem($r('app.media.ic_iv_index'), 'IV Index', "0x" + num2Hex(this.meshInfo!.ivIndex, 8))
                    this.getInfoItem($r('app.media.ic_sequence_number'), 'Sequence Number',
                        "0x" + num2Hex(this.meshInfo!.sequenceNumber, 6))
                    this.getInfoItem($r('app.media.ic_local_address'), 'Local Address',
                        "0x" + num2Hex(this.meshInfo!.localAddress, 4))
                    this.getNetKeysView()
                    this.getAppKeysView()
                }.height('auto').width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1)
            .align(Alignment.TopStart)
            .backgroundColor('#FCFCFC').margin({ top: 16, bottom: 16 })

        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC').alignItems(HorizontalAlign.Start)
    }
}
