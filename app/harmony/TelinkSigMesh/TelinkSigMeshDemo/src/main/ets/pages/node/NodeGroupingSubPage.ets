/********************************************************************************************************
 * @file     NodeGroupingSubPage.ets 
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
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getNormalButton } from '../../components/Widgets';
import { promptAction, router } from '@kit.ArkUI';
import {
    ADDRESS_BROADCAST,
    AutoConnectEvent,
    bytesToHexString,
    ConfigStatus,
    Event,
    EventBus,
    logd,
    loge,
    MeshEvent,
    MeshService,
    MeshSigModel,
    ModelSubscriptionSetMessage,
    ModelSubscriptionStatusMessage,
    num2Hex,
    OnOffGetMessage,
    OnOffSetMessage,
    OnOffStatusMessage,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { NodeInfo } from '../../model/NodeInfo';
import { UiStateEvent } from '../../model/UiStateEvent';
import { MeshInfoService } from '../../model/MeshInfoService';
import { IconGenerator } from '../../utils/IconGenerator';
import { OnlineState } from '../../model/OnlineState';
import { NodeStatusChangedEvent } from '../../model/NodeStatusChangedEvent';
import { NodeParams } from '../PageParams';
import { GroupInfo } from '../../model/GroupInfo';
import { WaitingDialog } from '../../components/Dialogs';

const GROUPING_TIMEOUT = 3 * 1000

@Component
export default struct NodeGroupingSubPage {
    @Prop node?: NodeInfo = undefined
    @State groups: GroupInfo[] = []
    private opGroupAdr = 0;
    private opMode = ModelSubscriptionSetMessage.MODE_ADD;
    private groupingTimerId = 0;

    async aboutToAppear() {
        logd("NodeGroupingSubPage # aboutToAppear")
        this.updateGroups()
        EventBus.getInstance().on(ModelSubscriptionStatusMessage.STATUS_NAME, this.onModelSubStatus)
    }

    private onModelSubStatus = (event: Event) => {
        let evt = event as StatusNotificationEvent
        let stMsg: ModelSubscriptionStatusMessage =
            evt.notificationMessage.statusMessage as ModelSubscriptionStatusMessage
        if (stMsg.status == ConfigStatus.SUCCESS) {
            if (this.opGroupAdr != stMsg.address) {
                loge("notification group address err")
                return
            }
            this.onModelComplete(true)
        }
    }

    private onModelComplete(success: boolean) {
        clearTimeout(this.groupingTimerId)
        logd("onModelComplete : " + success)
        if (success) {
            let groupAdr = num2Hex(this.opGroupAdr, 4)
            if (this.opMode == ModelSubscriptionSetMessage.MODE_ADD) {
                this.node?.subList.push(groupAdr)
            } else {
                this.node!.subList = this.node!.subList.filter((adr) => {
                    adr != groupAdr
                })
            }
            MeshInfoService.getInstance().updateNodeInfo(this.node!)
            this.updateGroups()
        }
        WaitingDialog.dismiss()
    }

    private updateGroups() {
        this.groups = []
        let localGroups = MeshInfoService.getInstance().getCurrentMesh().groups
        for (let gp of localGroups) {
            let group = new GroupInfo()
            group.selected = this.node!.subList.includes(num2Hex(gp.address, 4))
            group.name = gp.name
            group.address = gp.address
            logd("group " + group.name + " -- " + group.selected)
            this.groups.push(group)
        }
    }

    aboutToDisappear(): void {
        logd("NodeGrouping # aboutToDisappear")
        EventBus.getInstance().off(ModelSubscriptionStatusMessage.STATUS_NAME, this.onModelSubStatus)
    }

    private setGroup(group: GroupInfo) {
        clearTimeout(this.groupingTimerId)
        this.groupingTimerId = setTimeout(() => {
            this.onModelComplete(false)
        }, GROUPING_TIMEOUT)
        WaitingDialog.show("node grouping...")

        let modelId = MeshSigModel.SIG_MD_G_ONOFF_S
        let mode = group.selected ? ModelSubscriptionSetMessage.MODE_DELETE : ModelSubscriptionSetMessage.MODE_ADD

        logd("set group : " + group.name + " mode = " + mode)
        this.opGroupAdr = group.address
        this.opMode = mode
        let message = new ModelSubscriptionSetMessage(this.node!.meshAddress)
        message.mode = mode
        message.address = group.address
        message.modelIdentifier = modelId
        message.elementAddress = this.node!.getElementByModel(modelId)
        message.isSig = true
        MeshService.getInstance().sendMeshMessage(message)
    }

    build() {
        Column() {
            List() {
                ForEach(this.groups, (item: GroupInfo) => {
                    ListItem() {
                        Row() {
                            getCommonIcon($r('app.media.ic_group'), undefined, $r('app.color.primary'))
                            Text(item.name).layoutWeight(1)
                            Checkbox()
                                .select(item.selected)
                                .enabled(false)
                                .shape(CheckBoxShape.ROUNDED_SQUARE)
                                .selectedColor($r('app.color.primary'))
                                // .switchPointColor('#FFFFFF')

                            // Toggle({ type: ToggleType.Checkbox, isOn: item.selected })
                            //     .enabled(false)
                            //     .selectedColor($r('app.color.primary'))
                            //     .switchPointColor('#FFFFFF')

                        }
                        .alignItems(VerticalAlign.Center)
                        .justifyContent(FlexAlign.Start)
                        .padding(8)
                        .border({
                            width: { bottom: 0.2 },
                            color: $r('app.color.primary')
                        })
                        .onClick(() => {
                            this.setGroup(item)
                        })
                    }
                })
            }
        }.height("100%").width("100%")
        .backgroundColor('#FCFCFC')
    }
}
