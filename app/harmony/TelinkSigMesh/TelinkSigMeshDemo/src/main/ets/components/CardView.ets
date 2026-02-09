/********************************************************************************************************
 * @file     CardView.ets 
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
@Component
export struct CardView {
    @Prop cdPadding: Padding | Length | LocalizedPadding = 8
    @Prop cdMargin: Margin | Length | LocalizedPadding = 8
    cdClick?: () => void = undefined
    @BuilderParam cardContent: () => void

    build() {
        Column() {
            this.cardContent()
        }
        .border({
            width: {
                bottom: 0.2,
                top: 0.6,
                left: 0.5,
                right: 0.5
            },
            color: Color.Grey,
            radius: 5
        })
        .shadow({
            radius: 5,
            offsetY: 2,
            offsetX: 2,
            fill: false,
            color: Color.Grey,
            type: ShadowType.COLOR
        })
        .alignItems(HorizontalAlign.Start)
        .margin(this.cdMargin)
        .padding(this.cdPadding)
        .onClick(() => {
            if (this.cdClick) {
                this.cdClick()
            }
        })
    }
}
