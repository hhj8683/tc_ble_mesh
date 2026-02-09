/********************************************************************************************************
 * @file     Widgets.ets 
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
import { CustomContentDialog } from '@kit.ArkUI';

@Builder
export function getCommonIcon(iconRes: Resource, iconClick?: Function,
    color: Color | Resource = Color.White, width: Length = 42, height: Length = 42, padding: Padding | Length = 8
) {
    Image(iconRes)
        .width(width)
        .height(height)
        .fillColor(color)
        .objectFit(ImageFit.Contain)// .margin({ left: 10 })
        .onClick(() => {
            if (iconClick) {
                iconClick()
            }
        })
        .padding(padding)
    // .backgroundColor(Color.Green)
}

export function showItemSelectDialog(itemList: string[], itemClick?: (position: number) => void) {
    let dialogController: CustomDialogController = new CustomDialogController({
        builder: CustomContentDialog({
            primaryTitle: 'Select Service',
            // secondaryTitle: '辅助文本',
            contentBuilder: () => {
                getDialogContent(itemList, dialogController)
            },
        }),
    });
    console.log("dialog crate : ", dialogController)
    dialogController.open()
    console.log("dialog open : ", dialogController)
}

@Builder
function getDialogContent(itemList: string[], dialogController: CustomDialogController) {
    ForEach(itemList, (item: string, index: number) => {
        Text(item).width("100%").padding(4).onClick(() => {
            console.log(" widgets select : " + index)
            dialogController.close()
        })
    });
}

@Builder
export function getNormalButton(text: string, onClick?: Function) {
    Button(text, { type: ButtonType.Normal })
        .borderRadius(4)
        .layoutWeight(1)
        // .margin({left: 8, right: 8})
        .backgroundColor($r('app.color.primary')).onClick(() => {
        if (onClick) {
            onClick()
        }
    })
}


@Builder
export function getWarnButton(text: string, onClick?: Function) {
    Button(text, { type: ButtonType.Normal })
        .borderRadius(4)
        .layoutWeight(1)
        .backgroundColor($r('app.color.red')).onClick(() => {
        if (onClick) {
            onClick()
        }
    })
}

export function toastMessage(context: UIContext, message: string) {
    context.getPromptAction().showToast({ message: message })
}