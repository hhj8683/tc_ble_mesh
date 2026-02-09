/********************************************************************************************************
 * @file     EditText.ets 
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
export struct EditText {

  @BuilderParam rightRowElement: () => void

  build() {
    Column(){
      TextInput({ text: "8004" })
        .fontSize(14)
        .fontColor($r("app.color.primary"))
        .backgroundColor(Color.Transparent)
        .borderRadius(0).width("100%")
        .textAlign(TextAlign.Center)
      // only for border
      Text().borderColor($r("app.color.primary"))
        .borderWidth({ bottom: 1 })
        .width("100%")
        .margin({top: -10})
    }
  }
}

@Builder
export function getEditText(preText: string | null, text: string){
  Row() {
    if (preText){
      Text(preText)  .fontWeight(FontWeight.Normal).fontSize(14).width("40%").textAlign(TextAlign.Start)
    }
    Column(){
      TextInput({ text: text })
        .fontSize(14)
        .fontColor($r("app.color.primary"))
        .backgroundColor(Color.Transparent)
        .borderRadius(0).width("100%")
        .textAlign(TextAlign.Center)
      // only for border
      Text().borderColor($r("app.color.primary"))
        .borderWidth({ bottom: 1 })
        .width("100%")
        .margin({top: -10})
    }.layoutWeight(1)
  }.alignItems(VerticalAlign.Bottom)
  .margin(4)
}

