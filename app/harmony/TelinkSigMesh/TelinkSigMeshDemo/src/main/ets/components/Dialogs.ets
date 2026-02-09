/********************************************************************************************************
 * @file     Dialogs.ets 
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
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { UIContext } from '@ohos.arkui.UIContext';

const DEFAULT_WAITING_MESSAGE = "waiting..."


@Builder
function waitingDialogBuilder(message: string) {
    Column() {
        LoadingProgress()
            .enableLoading(true)
            .color(Color.Blue)
            .height(30)
            .width(30)
        Blank().width(50)
        Text(message)
    }.padding(20).width('80%').borderRadius(4).backgroundColor(Color.White)
}

export class WaitingDialog {
    static context: UIContext;
    static content: ComponentContent<Object>;
    static options: promptAction.BaseDialogOptions =
        { alignment: DialogAlignment.Center, autoCancel: false };

    static init(context: UIContext) {
        WaitingDialog.context = context;
        WaitingDialog.content =
            new ComponentContent(context, wrapBuilder(waitingDialogBuilder), DEFAULT_WAITING_MESSAGE);
    }

    static updateOptions(options: promptAction.BaseDialogOptions) {
        WaitingDialog.options = options;
    }

    static show(message: string = DEFAULT_WAITING_MESSAGE) {
        if (WaitingDialog.content) {
            WaitingDialog.content.update(message)
            WaitingDialog.context.getPromptAction()
                .openCustomDialog(WaitingDialog.content, WaitingDialog.options)
        }
    }

    static dismiss() {
        if (WaitingDialog.content) {
            WaitingDialog.context.getPromptAction().closeCustomDialog(WaitingDialog.content)
        }
    }

    static updateDialog(options: promptAction.BaseDialogOptions) {
        if (WaitingDialog.content) {
            WaitingDialog.context.getPromptAction().updateCustomDialog(WaitingDialog.content, options)
        }
    }
}


/**
 * confirm dialog
 */
export function showConfirmDialog(context: UIContext, title: string, message?: string, onConfirm?: Function,
    onCancel?: Function) {
    context.getPromptAction().showDialog({
        title: title,
        message: message,
        buttons: [
            {
                text: 'cancel',
                color: '#000000',
            },
            {
                text: 'OK',
                color: $r('app.color.primary')
            }
        ]
    }, (err, data) => {
        if (err) {
            console.error('showDialog err: ' + err);
            return;
        }
        if (data.index == 0 && onCancel) {
            onCancel()
        } else if (data.index == 1 && onConfirm) {
            onConfirm()
        }
    })
}