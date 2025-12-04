import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, getNormalButton, toastMessage } from '../../components/Widgets';
import { ComponentContent, promptAction, router } from '@kit.ArkUI';
import {
    ADDRESS_BROADCAST,
    AutoConnectEvent,
    bytesToHexString,
    Event,
    EventBus,
    logd,
    loge,
    MeshEvent,
    MeshService,
    OnOffGetMessage,
    OnOffSetMessage,
    OnOffStatusMessage
} from 'telinksigmeshlib';
import { NodeInfo } from '../../model/NodeInfo';
import { UiStateEvent } from '../../model/UiStateEvent';
import { MeshInfoService } from '../../model/MeshInfoService';
import { IconGenerator } from '../../utils/IconGenerator';
import { OnlineState } from '../../model/OnlineState';
import { NodeStatusChangedEvent } from '../../model/NodeStatusChangedEvent';
import { NodeParams } from '../PageParams';
import { WaitingDialog } from '../../components/Dialogs';
import TelinkSigMeshDemoAbility from '../../abilities/TelinkSigMeshDemoAbility';


@Component
export default struct DeviceSubPage {
    @State nodeList: NodeInfo[] = []
    @State directAddress: number = 0
    @State meshName: string = ""

    async aboutToAppear() {
        logd("dev sub # aboutToAppear")
        EventBus.getInstance().on(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED, this.refreshNodeList)
        EventBus.getInstance().on(NodeStatusChangedEvent.EVENT_TYPE_NODE_STATUS_CHANGED, this.refreshNodeList)
        EventBus.getInstance().on(AutoConnectEvent.EVENT_TYPE_AUTO_CONNECT_LOGIN, this.onLoginEvent)
        EventBus.getInstance().on(MeshEvent.EVENT_TYPE_DISCONNECTED, this.onDisconnectEvent)
        this.refreshNodeList()
    }

    refreshNodeList = () => {
        let nodes = MeshInfoService.getInstance().getCurrentMesh().nodes
        this.nodeList = nodes
        this.meshName = MeshInfoService.getInstance().getCurrentMesh().meshName
        logd("DeviceSubPage # refreshNodeList , len=" + this.nodeList.length)
    }
    onLoginEvent = (event: Event) => {
        let loginEvent = event as AutoConnectEvent
        this.directAddress = loginEvent.connectedAddress
        logd("DeviceSubPage # onLoginEvent , adr=" + this.directAddress)
    }
    onDisconnectEvent = (event: Event) => {
        logd("DeviceSubPage # onDisconnectEvent")
        this.directAddress = 0
        this.refreshNodeList()
    }

    aboutToDisappear(): void {
        logd("dev sub # aboutToDisappear")
        EventBus.getInstance().offEvents(this.refreshNodeList)
        EventBus.getInstance().offEvents(this.onLoginEvent)
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            router.push({ url: "pages/provision/SelectableProvisionPage" })
        })
    }

    @Builder
    geRefreshView() {
        getCommonIcon($r("app.media.ic_refresh"), () => {
            logd("refresh click")
            EventBus.getInstance().emit({ type: OnOffStatusMessage.STATUS_NAME })
            let setMessage = OnOffGetMessage.getSimple(ADDRESS_BROADCAST,
                MeshInfoService.getInstance().getCurrentMesh().getDefaultAppKeyIndex(), 0)
            MeshService.getInstance().sendMeshMessage(setMessage)
        })
    }

    private onOffToggle(node: NodeInfo) {
        let state = node.getOnlineState() == OnlineState.ON ? OnlineState.OFF : OnlineState.ON
        let setMessage = OnOffSetMessage.getSimple(node.meshAddress, 0, state, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    private gotoDetail(node: NodeInfo) {
        let params: NodeParams = { deviceUuid: node.deviceUUID }
        router.push({ url: "pages/node/NodeMainPage", params: params })
    }

    private setAllOnOff(onOff: number) {
        let setMessage = OnOffSetMessage.getSimple(0xFFFF, 0, onOff, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    @Builder
    waitingDialogBuilder(message: string) {
        Row() {
            LoadingProgress()
                .enableLoading(true)
                .color(Color.Blue)
                .height(48)
                .width(48)
            // Blank().width(50)
            Text(message).layoutWeight(1)
        }.padding(20)
    }

    build() {
        Column() {
            TitleBar({
                title: "Device",
                showNavigation: true,
                showAction: true,
                subTitle: this.meshName,
                actionView: () => {
                    this.getActionView()
                },
                navigationView: () => {
                    this.geRefreshView()
                },
            })
            Row({ space: 8 }) {
                getNormalButton('ALL ON', () => {
                    toastMessage(this.getUIContext(), "ALL ON TEST")
                    this.setAllOnOff(OnOffSetMessage.ON)
                })
                getNormalButton('ALL OFF', () => {
                    this.setAllOnOff(OnOffSetMessage.OFF)
                })
                getNormalButton('CMD', () => {
                    WaitingDialog.show("cmd todo...")
                    setTimeout(() => {
                        WaitingDialog.dismiss()
                    }, 2 * 1000)
                    // promptAction.showToast({
                    //     message: 'TODO'
                    // })
                })
            }.padding(4)


            Grid() {
                ForEach(this.nodeList, (item: NodeInfo, index: number) => {
                    GridItem() {
                        Column({ space: 8 }) {
                            // 显示开关状态图片
                            Image(IconGenerator.getIcon(item))
                                .width(36)
                                .height(36)
                                .draggable(false)
                                .gesture(
                                    LongPressGesture({ repeat: false, duration: 500 })
                                        .onAction((event: GestureEvent) => {
                                            logd("Image # LongPressGesture onAction")
                                            this.gotoDetail(item)
                                        })
                                )
                            // .objectFit(ImageFit.Contain)

                            // 显示设备名称
                            Text(item.name)
                                .fontSize(13)
                                .fontColor(this.directAddress == item.meshAddress ? $r('app.color.primary') :
                                Color.Black
                                )
                                .textAlign(TextAlign.Center)
                        }

                        .width('100%')
                        .justifyContent(FlexAlign.Center)


                        // .padding(10)
                    }

                    .onClick(() => {
                        // 点击切换开关状态
                        this.onOffToggle(item)
                    })

                }/*, (item: NodeInfo, index: number) => {
                    return item.deviceUUID
                }*/)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr') // 4等分列
            // .rowsTemplate('1fr 1fr') // 2行，根据数据量自动调整
            // .columnsGap(12)
            // .rowsGap(12)
            .width('100%')
            .height('100%')
            .padding(8)

            // .layoutWeight(1)

        }.height("100%").width("100%")
        .backgroundColor('#f0f0f0')
    }
}
