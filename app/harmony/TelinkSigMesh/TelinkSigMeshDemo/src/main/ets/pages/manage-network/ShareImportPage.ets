import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getNormalButton, toastMessage } from '../../components/Widgets';
import { Event, EventBus, logd, loge, readTextFile } from 'telinksigmeshlib';
import { UiStateEvent } from '../../model/UiStateEvent';
import { router } from '@kit.ArkUI';
import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MeshStorageService } from '../../model/json/MeshStorageService';

const IMPORT_SRC_QRCODE = 0
const IMPORT_SRC_JSON = 1

@Entry
@Component
struct ShareImportPage {
    @State srcType: number = IMPORT_SRC_QRCODE

    async aboutToAppear() {
    }

    eventCb = (event: Event) => {
        let type = event.type
        switch (type) {

        }
    }

    aboutToDisappear(): void {
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
        EventBus.getInstance().offEvents(this.eventCb)
    }

    @Builder
    geNavView() {
        getCommonIcon($r("app.media.ic_arrow_left"), () => {
            router.back()
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

    private selectJsonFile() {
        try {
            let documentPicker = new picker.DocumentViewPicker(getContext(this));
            documentPicker.select({ maxSelectNumber: 1 },
                async (err: BusinessError, documentSelectResult: Array<string>) => {
                    if (err) {
                        loge('select file failed : ' + JSON.stringify(err));
                        return;
                    }
                    let path = documentSelectResult[0];
                    logd('select file success, uri: ' + path);

                    readTextFile(path).then(async (data) => {
                        if (!data) {
                            toastMessage(this.getUIContext(), "parse data err")
                            return
                        }
                        logd('readTextFile success : ' + data)
                        let mesh = await MeshStorageService.importExternal(data)
                        if (mesh) {
                            toastMessage(this.getUIContext(), "import success")
                        } else {
                            toastMessage(this.getUIContext(), "import fail")
                        }
                    })
                });
        } catch (error) {
            let err: BusinessError = error as BusinessError;
            loge('DocumentViewPicker failed with err: ' + JSON.stringify(err));
        }
    }

    build() {
        Column({ space: 8 }) {
            TitleBar({
                title: "Share Import",
                showNavigation: true,
            })
            Text('Import mesh storage from json')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Start)

            Text('1.Select source \n2.If the selected source is JSON file, select the target file \n3.Click IMPORT')
                .fontSize(11)
                .fontWeight(FontWeight.Normal)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)

            Text('Select source')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.Gray)
                .textAlign(TextAlign.Start)

            Row() {
                Radio({
                    value: 'src_qr', group: 'src',
                    indicatorType: RadioIndicatorType.TICK
                }).checked(this.srcType == IMPORT_SRC_QRCODE)
                    .height(24)
                    .width(24)
                    .onChange((isChecked: boolean) => {
                        this.srcType = isChecked ? IMPORT_SRC_QRCODE : IMPORT_SRC_JSON
                    })

                Text('QRCode').fontSize(13)
            }

            Row() {
                Radio({
                    value: 'src_qr', group: 'src',
                    indicatorType: RadioIndicatorType.TICK
                }).checked(this.srcType == IMPORT_SRC_JSON)
                    .height(24)
                    .width(32)

                Text('JSON File').fontSize(13)
            }

            Row().layoutWeight(1)
            Row() {
                getNormalButton("IMPORT", () => {
                    if (this.srcType == IMPORT_SRC_JSON) {
                        this.selectJsonFile()
                    } else {
                        toastMessage(this.getUIContext(), 'qrcode todo')
                    }
                })
            }.width('100%')

        }.height("100%").width("100%").alignItems(HorizontalAlign.Start)
    }
}
