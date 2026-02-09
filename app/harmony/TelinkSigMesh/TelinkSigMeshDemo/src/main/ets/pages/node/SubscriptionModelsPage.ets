/********************************************************************************************************
 * @file     SubscriptionModelsPage.ets 
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
import { DEFAULT_SUB_LIST, getModelName, num2Hex } from 'telinksigmeshlib';
import { TitleBar } from '../../components/TitleBar';
import { CardView } from '../../components/CardView';

interface SubModel {
    id: number
    name: string
}

@Entry
@Component
struct SubscriptionModelsPage {
    @State models: SubModel[] = []

    async aboutToAppear() {
        for (let md of DEFAULT_SUB_LIST) {
            this.models.push({ id: md, name: getModelName(md) })
        }
    }

    aboutToDisappear(): void {
    }

    @Builder
    getModelItem(model: SubModel) {
        CardView({
            cdPadding: 16,
            cdMargin: 8,
        }) {
            Column({ space: 4 }) {
                Text(`ID : 0x${num2Hex(model.id, 4)}`).fontSize(14).fontWeight(FontWeight.Medium)
                Text(`Name : ${model.name}`).fontSize(12).fontStyle(FontStyle.Italic)
            }.width('100%').alignItems(HorizontalAlign.Start)
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Subscription Models",
                showNavigation: true,
            })
            Scroll() {
                Column() {
                    ForEach(this.models, (item: SubModel, index: number) => {
                        this.getModelItem(item)
                    })
                }.height('auto').justifyContent(FlexAlign.Start)
            }.layoutWeight(1).align(Alignment.TopStart).padding(8)

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
