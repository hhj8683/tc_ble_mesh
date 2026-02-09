/********************************************************************************************************
 * @file     ShareQrcodePage.ets 
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
