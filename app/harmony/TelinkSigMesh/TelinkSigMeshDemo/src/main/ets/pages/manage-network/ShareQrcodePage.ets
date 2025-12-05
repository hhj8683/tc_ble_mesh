import { TitleBar } from '../../components/TitleBar';
import { router } from '@kit.ArkUI';

import { QrcodeUuidParams } from '../PageParams';
import { showConfirmDialog } from '../../components/Dialogs';


@Entry
@Component
struct ShareQrcodePage {
    @State uuid: string = ""
    @State restTimeSec: number = 300
    private intervalId: number = 0

    async aboutToAppear() {
        this.uuid = (router.getParams() as QrcodeUuidParams).uuid
        clearInterval(this.intervalId)
        this.intervalId = setInterval(() => {
            this.restTimeSec -= 1
            if (this.restTimeSec <= 0) {
                clearInterval(this.intervalId)
                showConfirmDialog(this.getUIContext(), "Warning", "QRCode timeout", () => {
                    router.back()
                }, () => {
                    router.back()
                })
            }
        }, 1000)
    }

    aboutToDisappear(): void {
        clearInterval(this.intervalId)
    }

    build() {
        Column({ space: 8 }) {
            TitleBar({
                title: "Share-QRCode",
                showNavigation: true,
            })
            Column({ space: 16 }) {
                QRCode(this.uuid).width('90%')
                Text(`QR-Code available in ${this.restTimeSec} seconds`)
                    .fontColor($r('app.color.primary'))
                    .fontSize(13)
            }.alignItems(HorizontalAlign.Center).width('100%').margin({ top: 128 })

        }.height("100%").width("100%")
    }
}
