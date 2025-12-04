import { CardView } from '../../components/CardView';
import { TitleBar } from '../../components/TitleBar';
import { router } from '@kit.ArkUI';
import { getCommonIcon } from '../../components/Widgets';


interface SettingAction {
    icon: Resource
    title: string
    subTitle: string | undefined
    pagePath: string
}

const SETTING_ACTIONS: SettingAction[] = [
    {
        icon: $r("app.media.ic_list"),
        title: "Manage Network - todo",
        subTitle: "Switch, Create/Delete, Import/Export...",
        pagePath: "pages/manage-network/NetworkListPage"
    },
    {
        icon: $r("app.media.ic_oob"),
        title: "OOB Database - todo",
        subTitle: "used in static-oob provisioning",
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_cert"),
        title: "Root Cert - todo",
        subTitle: "used in certificate-based provisioning",
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_format_list"),
        title: "Private Device - todo",
        subTitle: "used in private mode and fast provision mode",
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_log"),
        title: "Log - todo",
        subTitle: 'app logcat',
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_setting"),
        title: "Settings - todo",
        subTitle: 'other settings...',
        pagePath: ""
    },
]

@Component
export default struct SettingSubPage {
    async aboutToAppear() {
    }

    @Builder
    getSettingActionView(actionIndex: number) {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 },
            cdClick: () => {
                if (SETTING_ACTIONS[actionIndex].pagePath != '') {
                    router.push({ url: SETTING_ACTIONS[actionIndex].pagePath })
                }
            }
        }) {
            Row() {
                getCommonIcon(SETTING_ACTIONS[actionIndex].icon, undefined, $r('app.color.text_color_normal'))
                Column({ space: 4 }) {
                    Text(SETTING_ACTIONS[actionIndex].title).fontSize(14).fontWeight(FontWeight.Medium)
                    if (SETTING_ACTIONS[actionIndex].subTitle) {
                        Text(SETTING_ACTIONS[actionIndex].subTitle).fontSize(11).fontStyle(FontStyle.Italic)
                    }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)

                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.text_color_normal'))
            }.width('100%')
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Setting"
            })
            Scroll() {
                Column({ space: 16 }) {
                    ForEach(SETTING_ACTIONS, (item: SettingAction, index: number) => {
                        this.getSettingActionView(index)
                    })
                }.height('auto').width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1)
            .align(Alignment.TopStart)
            .backgroundColor('#FCFCFC').margin({ top: 16, bottom: 16 })

        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC').alignItems(HorizontalAlign.Start)
    }
}