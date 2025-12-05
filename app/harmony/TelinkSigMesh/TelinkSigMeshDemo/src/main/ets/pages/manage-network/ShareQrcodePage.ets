import { TitleBar } from '../../components/TitleBar';
import environment from '@ohos.file.environment';
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
import { MeshInfoParams, QrcodeUuidParams } from '../PageParams';
import { MeshInfo } from '../../model/MeshInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { MeshNetKey } from '../../model/MeshNetKey';
import TelinkSigMeshDemoAbility from '../../abilities/TelinkSigMeshDemoAbility';
import { http } from '@kit.NetworkKit';
import { HttpClient } from '../../utils/HttpClient';
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
