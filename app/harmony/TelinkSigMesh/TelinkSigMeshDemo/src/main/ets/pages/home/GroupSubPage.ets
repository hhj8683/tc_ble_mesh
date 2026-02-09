/********************************************************************************************************
 * @file     GroupSubPage.ets 
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
import { MeshService, OnOffSetMessage } from 'telinksigmeshlib';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon } from '../../components/Widgets';
import { GroupInfo } from '../../model/GroupInfo';
import { MeshInfoService } from '../../model/MeshInfoService';

@Component
export default struct GroupSubPage {
    @State groupList: GroupInfo[] = []

    async aboutToAppear() {
        this.groupList = MeshInfoService.getInstance().getCurrentMesh().groups
    }

    sendGroupMessage(group: GroupInfo, isOn: boolean) {
        let onOff = isOn ? OnOffSetMessage.ON : OnOffSetMessage.OFF
        let setMessage = OnOffSetMessage.getSimple(group.address, 0, onOff, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    build() {
        Column() {
            TitleBar({
                title: "Group",
                showNavigation: false,
                showAction: false,
            })

            List() {
                ForEach(this.groupList, (item: GroupInfo) => {
                    ListItem() {
                        Row() {
                            getCommonIcon($r('app.media.ic_group'), undefined, $r('app.color.primary'))
                            Text(item.name).layoutWeight(1).fontSize(16).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_color_normal'))
                            Toggle({ type: ToggleType.Switch, isOn: true })
                                .selectedColor($r('app.color.primary'))
                                .switchPointColor('#FFFFFF')
                                .onChange((isOn: boolean) => {
                                    this.sendGroupMessage(item, isOn)
                                    // console.info('Component status:' + isOn);
                                })
                        }
                        .alignItems(VerticalAlign.Center)
                        .justifyContent(FlexAlign.Start)
                        .padding(8)
                        .border({
                            width: { bottom: 0.2 },
                            color: $r('app.color.primary')
                        })
                    }
                })
            }
        }.height("100%").width("100%")
    }
}
