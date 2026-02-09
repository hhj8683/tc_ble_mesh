/********************************************************************************************************
 * @file     NetworkSubPage.ets 
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
import { CardView } from '../../components/CardView';
import { TitleBar } from '../../components/TitleBar';
import { router } from '@kit.ArkUI';
import { getCommonIcon } from '../../components/Widgets';

interface NetworkAction {
    icon: Resource
    title: string
    subTitle: string | undefined
    pagePath: string
}

const NETWORK_ACTIONS: NetworkAction[] = [
    {
        icon: $r("app.media.ic_network"),
        title: "Mesh Info",
        subTitle: "Default Mesh",
        pagePath: "pages/manage-network/NetworkInfoPage"
    },
    {
        icon: $r("app.media.ic_multi_node"),
        title: "Node Batch Setting - todo",
        subTitle: undefined,
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_scene"),
        title: "Scenes",
        subTitle: undefined,
        pagePath: "pages/scene/SceneListPage",
    },
    {
        icon: $r("app.media.ic_motion_sensor_on"),
        title: "NLC - todo",
        subTitle: undefined,
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_df"),
        title: "Direct Forwarding - todo",
        subTitle: undefined,
        pagePath: ""
    },
    {
        icon: $r("app.media.ic_mesh_ota"),
        title: "Mesh OTA - todo",
        subTitle: undefined,
        pagePath: ""
    },
]

@Component
export default struct NetworkSubPage {
    async aboutToAppear() {
    }

    @Builder
    getNetworkActionView(actionIndex: number) {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 },
            cdClick: () => {
                if (NETWORK_ACTIONS[actionIndex].pagePath != '') {
                    router.push({ url: NETWORK_ACTIONS[actionIndex].pagePath })
                }
            }
        }) {
            Row() {
                getCommonIcon(NETWORK_ACTIONS[actionIndex].icon, undefined, $r('app.color.text_color_normal'))
                Column({ space: 4 }) {
                    Text(NETWORK_ACTIONS[actionIndex].title).fontSize(14).fontWeight(FontWeight.Medium)
                    if (NETWORK_ACTIONS[actionIndex].subTitle) {
                        Text(NETWORK_ACTIONS[actionIndex].subTitle).fontSize(11).fontStyle(FontStyle.Italic)
                    }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)

                getCommonIcon($r('app.media.ic_arrow_right'), undefined, $r('app.color.text_color_normal'))
            }.width('100%')
        }
    }

    @Builder
    getSolView() {
        CardView({
            cdPadding: 6,
            cdMargin: { left: 16, right: 16 }
        }) {
            Row() {
                getCommonIcon($r('app.media.ic_sol'), undefined, $r('app.color.text_color_normal'))
                Text("Proxy Solicitation - todo").layoutWeight(1).fontSize(14)
                Checkbox()
                    .select(true)
                    .enabled(false)
                    .shape(CheckBoxShape.ROUNDED_SQUARE)
                    .selectedColor($r('app.color.primary'))
            }.width('100%')
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Network",
                showNavigation: false,
                showAction: false
            })
            Scroll() {
                Column({ space: 16 }) {
                    ForEach(NETWORK_ACTIONS, (item: NetworkAction, index: number) => {
                        this.getNetworkActionView(index)
                    })
                    this.getSolView()
                }.height('auto').width('100%').alignItems(HorizontalAlign.Start)
            }.layoutWeight(1)
            .align(Alignment.TopStart)
            .backgroundColor('#FCFCFC').margin({ top: 16, bottom: 16 })

        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC').alignItems(HorizontalAlign.Start)
    }
}
