import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getNormalButton, toastMessage } from '../../components/Widgets';
import {
    bufferToHex,
    bytesToHexString,
    bytesToString,
    Event,
    EventBus,
    logd,
    loge,
    num2Hex,
    readTextFile
} from 'telinksigmeshlib';
import { UiStateEvent } from '../../model/UiStateEvent';
import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { picker, ReadTextOptions } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

import { fileIo as fs } from '@kit.CoreFileKit'
import { MeshStorageService } from '../../model/json/MeshStorageService';
import { MeshInfoParams } from '../PageParams';
import { MeshInfo } from '../../model/MeshInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { MeshNetKey } from '../../model/MeshNetKey';

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
    }

    @Builder
    getKeyListView() {
        ForEach(this.keyExtArr, (item: MeshNetKeyExt, index: number) => {
            Row() {
                Column() {
                    Row() {
                        getCommonIcon($r('app.media.ic_name'), undefined, Color.Gray)
                        Text(item.key.name)
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start)
                    }.padding(4)

                    Row() {
                        getCommonIcon($r('app.media.ic_id'), undefined, Color.Gray)
                        Text('0x' + num2Hex(item.key.index, 2))
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start)
                    }.padding(4)

                    Row() {
                        getCommonIcon($r('app.media.ic_key_value'), undefined, Color.Gray)
                        Text(item.key.key)
                            .fontSize(11)
                            .fontColor(Color.Gray)
                            .textAlign(TextAlign.Start)
                    }.padding(4)
                }

                Divider().vertical(true).strokeWidth(0.2).color(Color.Gray).padding(4)
                Checkbox().select(item.selected).onChange((value) => {
                    logd("key select changed : " + item.key.name + " => " + value)
                })
            }
        })
    }

    async readBinaryFile(path: string): Promise<Uint8Array | undefined> {
        try {
            console.log("readBinaryFile : " + path)
            const file = fs.openSync(path, fs.OpenMode.READ_ONLY & fs.OpenMode.WRITE_ONLY)
            const stat = fs.statSync(file.fd);
            const buffer = new ArrayBuffer(stat.size);
            fs.readSync(file.fd, buffer, {
                offset: 0,
                length: stat.size
            });
            console.log("read file complete : " + buffer.byteLength)
            await fs.close(file.fd);
            return new Uint8Array(buffer);
        } catch (err) {
            console.error('read bin error :', JSON.stringify(err));
            return undefined
        }
    }

    private exportMeshInfo() {
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
        // fs.openSync()
        // fs.()
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
                    if (this.srcType == EXPORT_DST_JSON) {
                        this.exportMeshInfo()
                    } else {
                        toastMessage(this.getUIContext(), 'qrcode todo')
                    }
                    logd("selected : " + this.srcType)
                })
            }.width('100%')

        }.height("100%").width("100%").alignItems(HorizontalAlign.Start)
    }
}
