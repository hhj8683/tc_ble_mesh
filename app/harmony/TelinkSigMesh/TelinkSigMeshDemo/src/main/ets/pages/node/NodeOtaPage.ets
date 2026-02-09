/********************************************************************************************************
 * @file     NodeOtaPage.ets 
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
    ByteOrder,
    bytesToHex,
    ConnectionFilter,
    Event,
    EventBus,
    GattOtaEvent,
    GattOtaParameters,
    logd,
    loge,
    MeshService,
    num2bytes,
    num2Hex,
    readBinaryFile
} from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { MeshInfo } from '../../model/MeshInfo';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getCommonIcon, getNormalButton, toastMessage } from '../../components/Widgets';

@Entry
@Component
struct NodeOtaPage {
    @State node?: NodeInfo = undefined
    @State nodeDesc: string = ''
    private meshInfo?: MeshInfo
    private fileData?: Uint8Array = undefined
    @State selectedFile?: string = undefined
    @State otaProgress: number = 0
    @State otaLog: string = ""
    @State isProcessing: boolean = false
    @State isForceUpdate: boolean = true

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        logd("gatt ota # device uuid = " + deviceUuid)
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        let pb = num2bytes(this.node!.compositionData!.pid, 2, ByteOrder.LITTLE_ENDIAN)
        let vb = num2bytes(this.node!.compositionData!.vid, 2, ByteOrder.BIG_ENDIAN)
        this.nodeDesc =
            `Node Info\naddress: ${num2Hex(this.node!.meshAddress)}\nUUID: ${this.node!.deviceUUID}\nversion: pid=${
            bytesToHex(pb)
            } vid=${bytesToHex(vb)}`
        EventBus.getInstance().on(GattOtaEvent.EVENT_TYPE_OTA_SUCCESS, this.evtCb)
        EventBus.getInstance().on(GattOtaEvent.EVENT_TYPE_OTA_FAIL, this.evtCb)
        EventBus.getInstance().on(GattOtaEvent.EVENT_TYPE_OTA_PROGRESS, this.evtCb)
        this.appendLog('init OK')
    }

    evtCb = (event: Event) => {
        let otaEvent = event as GattOtaEvent
        switch (event.type) {
            case GattOtaEvent.EVENT_TYPE_OTA_SUCCESS:
                this.appendLog('OTA success')
                this.isProcessing = false
                break
            case GattOtaEvent.EVENT_TYPE_OTA_FAIL:
                this.appendLog('OTA fail : ' + otaEvent.desc)
                this.isProcessing = false
                break
            case GattOtaEvent.EVENT_TYPE_OTA_PROGRESS:
                this.otaProgress = otaEvent.progress
                break
        }
    }

    aboutToDisappear(): void {
        EventBus.getInstance().off(GattOtaEvent.EVENT_TYPE_OTA_SUCCESS, this.evtCb)
        EventBus.getInstance().off(GattOtaEvent.EVENT_TYPE_OTA_FAIL, this.evtCb)
        EventBus.getInstance().off(GattOtaEvent.EVENT_TYPE_OTA_PROGRESS, this.evtCb)
    }

    private appendLog(log: string) {
        this.otaLog += log + '\n'
    }

    private selectBin() {
        try {
            let documentPicker = new picker.DocumentViewPicker(getContext(this))
            documentPicker.select({ maxSelectNumber: 1 },
                async (err: BusinessError, documentSelectResult: Array<string>) => {
                    if (err) {
                        loge('select file failed : ' + JSON.stringify(err))
                        return
                    }
                    let path = documentSelectResult[0]
                    logd('select file success, uri: ' + path)
                    this.selectedFile = path
                    readBinaryFile(path).then(async (data) => {
                        if (!data) {
                            toastMessage(this.getUIContext(), "parse data err")
                            this.selectedFile = undefined
                            return
                        }
                        this.fileData = data
                    })
                })
        } catch (error) {
            let err: BusinessError = error as BusinessError
            loge('DocumentViewPicker failed with err: ' + JSON.stringify(err))
        }
    }

    private startOta() {
        if (!this.fileData) {
            toastMessage(this.getUIContext(), "file data error")
            this.appendLog('file data error')
            return
        }
        let filter = new ConnectionFilter(this.node!.meshAddress)
        this.appendLog('start OTA')
        MeshService.getInstance().startGattOta(new GattOtaParameters(filter, this.fileData))
    }

    build() {
        Column() {
            TitleBar({
                title: "OTA",
                subTitle: "GATT",
                showNavigation: true,
            })

            Text(this.nodeDesc).fontSize(15).fontWeight(FontWeight.Bold).textAlign(TextAlign.Start).width('100%')

            Column() {
                Text(this.otaLog).fontSize(12).textAlign(TextAlign.Start).width('100%')
            }.layoutWeight(1)

            Row() {
                Checkbox()
                    .select(this.isForceUpdate!!)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .selectedColor($r('app.color.primary'))
                Text("Force upgrade different pid versions").layoutWeight(1).fontSize(12)
            }.width('100%')

            Text("bin version : null").fontColor(Color.Red).textAlign(TextAlign.Start).width('100%').fontSize(12)
            Row() {
                Text(this.selectedFile ?? 'select file').layoutWeight(1)
                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.primary'), 36, 36)
            }.onClick(() => {
                this.selectBin()
            })

            Text(`${this.otaProgress}%`)
            Progress({ total: 100, value: this.otaProgress }).margin({ bottom: 8 })
            Row() {
                getNormalButton('START', () => {
                    this.startOta()
                })
            }

        }.width('100%').height("100%").alignItems(HorizontalAlign.Start)
    }
}
