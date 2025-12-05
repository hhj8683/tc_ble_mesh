import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getNormalButton, toastMessage } from '../../components/Widgets';
import { logd, loge, num2Hex } from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MeshStorageService } from '../../model/json/MeshStorageService';
import { MeshInfoParams, QrcodeUuidParams } from '../PageParams';
import { MeshInfo } from '../../model/MeshInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { MeshNetKey } from '../../model/MeshNetKey';
import { HttpClient } from '../../utils/HttpClient';

const EXPORT_DST_QRCODE = 0
const EXPORT_DST_JSON = 1


interface MeshNetKeyExt {
    key: MeshNetKey
    selected: boolean
}

@Entry
@Component
struct ShareExportPage {
    @State srcType: number = EXPORT_DST_QRCODE
    private meshInfo: MeshInfo | undefined = undefined
    @State keyExtArr: MeshNetKeyExt[] = []

    async aboutToAppear() {
        let meshId = (router.getParams() as MeshInfoParams).id
        this.meshInfo = MeshInfoService.getInstance().getById(meshId)
        this.keyExtArr = []
        for (let i = 0; i < this.meshInfo!.meshNetKeyList.length; i++) {
            this.keyExtArr.push({ key: this.meshInfo!.meshNetKeyList[i], selected: i == 0 }) // select key0 by default
        }
    }

    @Builder
    getKeyListView() {

        ForEach(this.keyExtArr, (item: MeshNetKeyExt, index: number) => {
            Row() {
                Column() {
                    Row({ space: 8 }) {
                        getCommonIcon($r('app.media.ic_name'), undefined, Color.Gray, 24, 24, 0)
                        Text(item.key.name)
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start).layoutWeight(1)
                    }.padding(4)

                    // .backgroundColor(Color.Yellow)

                    Row({ space: 8 }) {
                        getCommonIcon($r('app.media.ic_id'), undefined, Color.Gray, 24, 24, 0)
                        Text('0x' + num2Hex(item.key.index, 2))
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start)
                    }.padding(4)

                    Row({ space: 8 }) {
                        getCommonIcon($r('app.media.ic_key_value'), undefined, Color.Gray, 24, 24, 0)
                        Text(item.key.key)
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start)
                    }.padding(4)
                }.alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                // .backgroundColor(Color.Blue)

                Divider().vertical(true).strokeWidth(0.2).color(Color.Gray).padding(4)
                Checkbox()
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .select(item.selected)
                    .onChange((value) => {
                        item.selected = value
                        // logd("key select changed : " + item.key.name + " => " + value)
                    }).margin(16)
            }.width('100%')
            .height(100)

            // .backgroundColor(Color.Red)
        })
    }

    private convertToJson() {
        let selectedKeys: MeshNetKey[] = []
        for (let key of this.keyExtArr) {
            if (key.selected) {
                selectedKeys.push(key.key)
            }
        }
        if (selectedKeys.length == 0) {
            toastMessage(this.getUIContext(), 'select at least one net key')
            return
        }
        let json = MeshStorageService.meshToJsonString(this.meshInfo!, selectedKeys)
        logd("mesh json : " + json)
        return json
    }

    private exportMeshToJson(json: string) {
        let options = new picker.DocumentSaveOptions()
        options.newFileNames = ['mesh.json']; // file name
        options.fileSuffixChoices = ['.json']; // file type
        const documentViewPicker = new picker.DocumentViewPicker()
        let uris: Array<string> = [];
        documentViewPicker.save(options).then((documentSaveResult: Array<string>) => {
            uris = documentSaveResult;
            console.info('documentViewPicker.save to file succeed and uris are:' + uris);
            let uri = uris[0];
            let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
            fs.writeSync(file.fd, json)
            fs.closeSync(file);
            toastMessage(this.getUIContext(), "save json success")
        }).catch((err: BusinessError) => {
            loge(`select save file failed, code : ${err.code}, message : ${err.message}`);
            toastMessage(this.getUIContext(), "save json success")
        })
    }

    private async exportMeshToCloud(json: string) {
        let re = await HttpClient.upload(json)
        if (re) {
            // toastMessage(this.getUIContext(), 'upload success')
            let params: QrcodeUuidParams = { uuid: re }
            router.push({ url: "pages/manage-network/ShareQrcodePage", params: params })
        } else {
            toastMessage(this.getUIContext(), 'upload fail')
        }
    }

    build() {
        Column({ space: 8 }) {
            TitleBar({
                title: "Share Export",
                subTitle: this.meshInfo!.meshName,
                showNavigation: true,
            })
            Text('Export mesh storage to json')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Start)

            Text('1.Select at least one network key \n2.Select destination\n3.Click EXPORT')
                .fontSize(11)
                .fontWeight(FontWeight.Normal)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)

            Text('Select Net Keys')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)

            this.getKeyListView()

            Text('Select destination')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)

            Row() {
                Radio({
                    value: 'src_qr', group: 'src',
                    indicatorType: RadioIndicatorType.TICK
                }).checked(this.srcType == EXPORT_DST_QRCODE)
                    .height(24)
                    .width(24)
                    .onChange((isChecked: boolean) => {
                        this.srcType = isChecked ? EXPORT_DST_QRCODE : EXPORT_DST_JSON
                    })

                Text('QRCode').fontSize(13)
            }

            Row() {
                Radio({
                    value: 'src_qr', group: 'src',
                    indicatorType: RadioIndicatorType.TICK
                }).checked(this.srcType == EXPORT_DST_JSON)
                    .height(24)
                    .width(32)

                Text('JSON File').fontSize(13)
            }

            Row().layoutWeight(1)
            Row() {
                getNormalButton("EXPORT", () => {
                    let json = this.convertToJson()
                    if (!json) {
                        return
                    }
                    if (this.srcType == EXPORT_DST_JSON) {
                        this.exportMeshToJson(json)
                    } else {
                        this.exportMeshToCloud(json);
                    }
                })
            }.width('100%')

        }.height("100%").width("100%").alignItems(HorizontalAlign.Start)
    }
}
