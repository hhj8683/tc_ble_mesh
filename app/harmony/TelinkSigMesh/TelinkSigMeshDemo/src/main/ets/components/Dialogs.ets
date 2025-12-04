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
export function showConfirmDialog(context: UIContext, title: string, message?: string, onConfirm?: Function) {
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
        if (data.index == 1) {
            if (onConfirm) {
                onConfirm()
            }
        }
    })
}