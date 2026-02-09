/********************************************************************************************************
 * @file     NodeNetKeysPage.ets 
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
    BindingBearer,
    BindingDevice,
    BindingEvent,
    BindingParameters,
    CompositionDataGetMessage,
    ConfigStatus,
    Event,
    EventBus,
    hexToBytes,
    hexToIntB,
    loge,
    MeshService,
    NetKeyAddMessage,
    NetKeyStatusMessage,
    num2Hex,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams, SchedulerSettingParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, toastMessage } from '../../components/Widgets';
import { Scheduler } from '../../model/Scheduler';
import { CardView } from '../../components/CardView';
import { SchedulerRegister } from '../../model/SchedulerRegister';
import { MeshNetKey } from '../../model/MeshNetKey';
import { WaitingDialog } from '../../components/Dialogs';
import { MeshAppKey } from '../../model/MeshAppKey';

@Entry
@Component
struct SchedulerListPage {
    @State node?: NodeInfo = undefined
    @State innerKeys: MeshNetKey[] = []
    @State outerKeys: MeshNetKey[] = []
    private selectNetKeyDialogId = 0
    private processingKey?: MeshNetKey = undefined

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        this.initData(deviceUuid)

        EventBus.getInstance().on(NetKeyStatusMessage.STATUS_NAME, this.evtCb);
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_FAIL, this.evtCb);
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_SUCCESS, this.evtCb);
    }

    private initData(deviceUuid: string) {
        let meshInfo = MeshInfoService.getInstance().getCurrentMesh()
        this.node = meshInfo.getDeviceByUUID(deviceUuid)
        let allKeys = meshInfo.meshNetKeyList
        let keyIndexes = this.node!.netKeyIndexes
        for (let key of allKeys) {
            if (keyIndexes.includes(num2Hex(key.index))) {
                this.innerKeys.push(key)
            } else {
                this.outerKeys.push(key)
            }
        }
    }

    evtCb = (event: Event) => {
        if (!this.processingKey) {
            return
        }
        switch (event.type) {
            case NetKeyStatusMessage.STATUS_NAME: {
                let stEvent = event as StatusNotificationEvent
                let ntfMsg = stEvent.notificationMessage
                if (ntfMsg.src != this.node!.meshAddress) {
                    return
                }
                let stMsg: NetKeyStatusMessage = ntfMsg.statusMessage as NetKeyStatusMessage
                if (stMsg.status != ConfigStatus.SUCCESS) {
                    this.onAddKeyComplete(false, 'status err : ' + stMsg.status)
                    return
                }
                this.bindAppKey(this.processingKey)
                break
            }

            case BindingEvent.EVENT_TYPE_BIND_FAIL:
                this.onAddKeyComplete(false, 'app key bind fail')
                break
            case BindingEvent.EVENT_TYPE_BIND_SUCCESS:
                this.onAddKeyComplete(true, "add key success")
                break
        }
    }

    private bindAppKey(netKey: MeshNetKey) {
        //        find binding app key
        let appKeys = MeshInfoService.getInstance().getCurrentMesh().appKeyList
        let meshAppKey: MeshAppKey | undefined
        for (let appKey of appKeys) {
            if (appKey.boundNetKeyIndex == netKey.index) {
                meshAppKey = appKey;
                break;
            }
        }
        if (!meshAppKey) {
            this.onAddKeyComplete(false, "meshAppKey not found");
            return;
        }


        let bindingDevice = new BindingDevice()
        bindingDevice.meshAddress = this.node!.meshAddress
        bindingDevice.deviceUUID = hexToBytes(this.node!.deviceUUID)
        bindingDevice.appKeyIndex = meshAppKey.index
        bindingDevice.netKeyIndex = meshAppKey.boundNetKeyIndex
        bindingDevice.compositionData = this.node!.compositionData;
        bindingDevice.bearer = BindingBearer.Any
        MeshService.getInstance().startKeyBind(new BindingParameters(bindingDevice));
    }

    private onAddKeyComplete(success: boolean, message: string) {
        if (success) {
            if (this.processingKey) {
                this.node!.netKeyIndexes.push(num2Hex(this.processingKey.index))
                MeshInfoService.getInstance().updateNodeInfo(this.node!)
                // add inner keys
                this.innerKeys.push(this.processingKey!)
                // remove outer keys
                this.outerKeys = this.outerKeys.filter((item) => {
                    return item.index != this.processingKey!.index
                })
            }
            toastMessage(this.getUIContext(), message)
        } else {
            toastMessage(this.getUIContext(), message)
        }
        WaitingDialog.dismiss()
    }

    aboutToDisappear(): void {
        EventBus.getInstance().off(NetKeyStatusMessage.STATUS_NAME, this.evtCb);
        EventBus.getInstance().off(BindingEvent.EVENT_TYPE_BIND_FAIL, this.evtCb);
        EventBus.getInstance().off(BindingEvent.EVENT_TYPE_BIND_SUCCESS, this.evtCb);
    }

    @Builder
    outerNetKeyListView() {
        if (this.outerKeys.length > 0) {
            Scroll() {
                Column() {
                    ForEach(this.outerKeys, (item: MeshNetKey, index: number) => {
                        this.getNetKeyItem(item, true)
                    })
                }.height('auto').justifyContent(FlexAlign.Start)
            }.width('100%').align(Alignment.TopStart).padding(8)
        } else {
            Column() {
                getCommonIcon($r('app.media.ic_sad'), undefined, $r('app.color.primary'))
                Text('List Empty')
            }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
        }
    }

    private showSelectKeyDialog() {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                this.outerNetKeyListView()
            },
            autoCancel: true,
            // alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.selectNetKeyDialogId = id
        })
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            this.showSelectKeyDialog()
        })
    }

    @Builder
    getInfoItem(icon: Resource, title: string, content: string) {
        Row() {
            getCommonIcon(icon, undefined, Color.Gray)
            Column() {
                Text(title)
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)

                Text(content).fontSize(11).fontColor(Color.Gray).textAlign(TextAlign.Start)
            }.alignItems(HorizontalAlign.Start)
        }.width('100%')
    }

    private async addKey(key: MeshNetKey) {
        this.processingKey = key
        let meshMessage = NetKeyAddMessage.getSimple(this.node!.meshAddress, key.index, hexToBytes(key.key))
        WaitingDialog.show('adding key...')
        let re = await MeshService.getInstance().sendMeshMessage(meshMessage)
        if (!re) {
            this.onAddKeyComplete(false, 'send message fail')
        }
    }

    @Builder
    getNetKeyItem(key: MeshNetKey, isOuter = false) {

        CardView({
            cdPadding: 6,
            cdMargin: 8,
            cdClick: () => {
                if (isOuter) {
                    this.addKey(key)
                }
            }
        }) {
            this.getInfoItem($r('app.media.ic_name'), 'Name', key.name)
            this.getInfoItem($r('app.media.ic_id'), 'Index', num2Hex(key.index))
            this.getInfoItem($r('app.media.ic_key_value'), 'Key', key.key)
        }
    }

    build() {
        Column() {
            TitleBar({
                title: "Network Keys",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })

            Scroll() {
                Column() {
                    ForEach(this.innerKeys, (item: MeshNetKey, index: number) => {
                        this.getNetKeyItem(item)
                    })
                }.height('auto').justifyContent(FlexAlign.Start).width('100%')
            }.layoutWeight(1).align(Alignment.TopStart).padding(8).width('100%')

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
