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