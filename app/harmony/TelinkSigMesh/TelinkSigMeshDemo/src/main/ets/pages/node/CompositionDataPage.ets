/********************************************************************************************************
 * @file     CompositionDataPage.ets 
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
import {
    CompositionDataGetMessage,
    CompositionDataStatusMessage,
    Event,
    EventBus,
    getModelName,
    logd,
    MeshService,
    MeshSigModel,
    num2Hex,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { router, ToolBarOptions } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams } from '../PageParams';
import { NodeStatusChangedEvent } from '../../model/NodeStatusChangedEvent';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, toastMessage } from '../../components/Widgets';
import NodeControlSubPage from './NodeControlSubPage';
import NodeGroupingSubPage from './NodeGroupingSubPage';
import NodeSettingSubPage from './NodeSettingSubPage';

@Entry
@Component
struct CompositionDataPage {
    @State node?: NodeInfo = undefined
    @State cpsInfo: string = ''

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        logd("CompositionDataPage # device uuid = " + deviceUuid)
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        logd("CompositionDataPage # device name = " + this.node?.name)

        EventBus.getInstance().on(CompositionDataStatusMessage.STATUS_NAME, this.nodeCpsDataEvtCb)
        this.showCpsData()

    }

    private showCpsData() {

        let cps = this.node!.compositionData;
        if (!cps) {
            return
        }

        let str = "Composition-Data:\n"

        // basic
        str += `cid: 0x${num2Hex(cps.cid, 4)}\n`
        str += `pid: 0x${num2Hex(cps.pid, 4)}\n`
        str += `vid: 0x${num2Hex(cps.vid, 4)}\n`
        str += `crpl: 0x${num2Hex(cps.crpl, 4)}\n\n`

        // features
        str += `features: 0x${num2Hex(cps.features, 4)}\n`
        str += `\trelay support: ${cps.relaySupport()}\n`
        str += `\tproxy support: ${cps.proxySupport()}\n`
        str += `\tfriend support: ${cps.friendSupport()}\n`
        str += `\tlow power support: ${cps.lowPowerSupport()}\n\n`

        // elements
        str += `elements: (${cps.elements.length})\n`
        let basicEleAdr = this.node!.meshAddress;
        for (let ele of cps.elements) {
            str += `\telement adr: 0x${num2Hex(basicEleAdr)}\n`
            for (let sigModel of ele.sigModels) {
                str += `\t\tSIG model -- 0x${num2Hex(sigModel, 4)} -- ${getModelName(sigModel)}\n`
            }

            for (let vendorModel of ele.vendorModels) {
                str += `\t\tvendor model -- 0x${num2Hex(vendorModel, 6)}\n`
            }
            basicEleAdr++;
        }

        this.cpsInfo = str
    }

    nodeCpsDataEvtCb = (event: Event) => {
        let ntfEvent = event as StatusNotificationEvent
        this.showCpsData()
        if (ntfEvent.notificationMessage.src == this.node!.meshAddress) {
            toastMessage(this.getUIContext(), "refresh cps success")
        }
    }

    aboutToDisappear(): void {
        EventBus.getInstance().off(CompositionDataStatusMessage.STATUS_NAME, this.nodeCpsDataEvtCb)
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_refresh"), () => {
            MeshService.getInstance().sendMeshMessage(new CompositionDataGetMessage(this.node!.meshAddress))
        })
    }


    build() {
        Column() {
            TitleBar({
                title: "Composition Data",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })
            Scroll() {
                    Text(this.cpsInfo).fontStyle(FontStyle.Italic).fontSize(13).height('auto').align(Alignment.TopStart)
            }.layoutWeight(1).align(Alignment.TopStart).padding(8)
            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
