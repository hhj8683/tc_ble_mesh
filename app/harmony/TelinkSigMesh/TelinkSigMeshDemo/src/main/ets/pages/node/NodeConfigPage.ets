/********************************************************************************************************
 * @file     NodeConfigPage.ets 
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
    BeaconGetMessage,
    BeaconSetMessage,
    BeaconStatusMessage,
    DefaultTTLGetMessage,
    DefaultTTLSetMessage,
    DefaultTTLStatusMessage,
    Event,
    EventBus,
    FriendGetMessage,
    FriendSetMessage,
    FriendStatusMessage,
    GattProxyGetMessage,
    GattProxySetMessage,
    GattProxyStatusMessage,
    KeyRefreshPhaseGetMessage,
    KeyRefreshPhaseStatusMessage,
    logd,
    MeshMessage,
    MeshService,
    NetworkTransmitGetMessage,
    NetworkTransmitSetMessage,
    NetworkTransmitStatusMessage,
    NodeIdentityGetMessage,
    NodeIdentitySetMessage,
    NodeIdentityStatusMessage,
    num2Hex,
    OnDemandPrivateProxyGetMessage,
    OnDemandPrivateProxySetMessage,
    OnDemandPrivateProxyStatusMessage,
    RelayGetMessage,
    RelaySetMessage,
    RelayStatusMessage,
    ReliableMessageProcessEvent,
    StatusNotificationEvent
} from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { toastMessage } from '../../components/Widgets';
import { CardView } from '../../components/CardView';
import { WaitingDialog } from '../../components/Dialogs';

interface NodeConfigItem {
    title: string
    about: string,
    isGetSupported: boolean
    isSetSupported: boolean
}

interface NodeConfigExpansion {
    item: NodeConfigItem
    expanded: boolean
}

function getItem(title: string, about: string, isSetSupported: boolean = true): NodeConfigItem {
    return {
        title: title,
        about: about,
        isGetSupported: true,
        isSetSupported: isSetSupported
    }
}

/**
 * default: 10
 */
const DEFAULT_TTL =
    getItem("Default TTL", "The Default TTL state determines the TTL value used when sending messages.")

/**
 * default
 * relay: 0x01
 * relay retransmit: 0x15
 */
const RELAY = getItem("Relay & RelayRetransmit",
    "The Relay state indicates support for the Relay feature; The Relay Retransmit state is a composite state that controls parameters of retransmission of the Network PDU relayed by the node.")
/**
 * default:
 * 0x01
 */
const SECURE_NETWORK_BEACON = getItem("Secure Network Beacon",
    "The Secure Network Beacon state determines if a node is periodically broadcasting Secure Network beacon messages.")

/**
 * default:
 */
const PROXY = getItem("GATT Proxy",
    "The GATT Proxy state indicates if the Mesh Proxy Service is supported, and if supported, it indicates and controls the status of the Mesh Proxy Service. ")

/**
 *
 */
const NODE_IDENTITY = getItem("Node Identity",
    "The Node Identity state determines if a node that supports the Mesh Proxy Service is advertising on a subnet using Node Identity messages. ")

/**
 * default: 0x01
 */
const FRIEND = getItem("Friend",
    "The Friend state indicates support for the Friend feature. If Friend feature is supported, then this also indicates and controls whether Friend feature is enabled or disabled.")

/**
 * default: 00000000
 */
const KEY_REFRESH_PHASE = getItem("Key Refresh Phase",
    "The Key Refresh Phase state indicates and controls the Key Refresh procedure for each NetKey in the NetKey List. ",
    false)

/**
 * Network Transmit
 */
const NETWORK_TRANSMIT = getItem("Network Transmit",
    "The Network Transmit state is a composite state that controls the number and timing of the transmissions of Network PDU originating from a node.")

/**
 * On-Demand Private GATT Proxy
 */
const ON_DEMAND_PRIVATE_GATT_PROXY = getItem("On-Demand Private GATT Proxy",
    "The On-Demand Private GATT Proxy state indicates whether advertising with Private Network Identity type can be enabled on demand and can be triggered upon reception of a Solicitation PDU.")


@Entry
@Component
struct NodeConfigPage {
    @State node?: NodeInfo = undefined
    // default TTL
    @State defaultTTL: number = 0x0A;
    // is relay enabled
    @State relayEnable: boolean = true;
    // relay retransmit, include count and steps
    @State relayRetransmit: number = 0x15;
    // is secure network beacon opened
    @State beaconOpened: boolean = true;
    // is gatt proxy enabled
    @State gattProxyEnable: boolean = true;
    @State nodeIdentityStarted: boolean = false;
    @State phase: number = -1;
    // is friend enabled
    @State friendEnable: boolean = true;
    // network retransmit
    @State networkRetransmit: number = 0x15;
    // network retransmit
    @State onDemandPrivateGattProxy: number = 20;
    private netKeyIndex = 0
    private messageTimeoutId = 0
    // @State expandedState: boolean[] = []
    @State nodeConfigExpansions: NodeConfigExpansion[] = []
    /**
     * input values showing in dialog
     */
    private setDialogId = 0
    @State ttlInput: string = ''
    // relay retransmit count
    @State relayRetCntInput: string = ''
    // relay retransmit interval
    @State relayRetIntInput: string = ''
    relaySelection: SelectOption[] = [{ value: 'Enabled' }, { value: 'Disabled' }]
    @State selectedRelayIndex: number = 0
    beaconSelection: SelectOption[] = [{ value: 'Open the Broadcasting' }, { value: 'Close the Broadcasting' }]
    @State selectedBeaconIndex: number = 0
    proxySelection: SelectOption[] = [{ value: 'Enabled' }, { value: 'Disabled' }]
    @State selectedProxyIndex: number = 0
    nodeIdSelection: SelectOption[] = [{ value: 'Start' }, { value: 'Stop' }]
    @State selectedNodeIdIndex: number = 0
    friendSelection: SelectOption[] = [{ value: 'Enabled' }, { value: 'Disabled' }]
    @State selectedFriendIndex: number = 0
    @State nwkTransCntInput: string = ''
    // network retransmit interval
    @State nwkTransIntInput: string = ''
    @State onDemandProxyInput: string = ''

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        this.netKeyIndex = MeshInfoService.getInstance().getCurrentMesh().getDefaultNetKey().index
        this.initItems()
        this.initInputValues()

        EventBus.getInstance().on(NetworkTransmitStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(BeaconStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(DefaultTTLStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(FriendStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(GattProxyStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(KeyRefreshPhaseStatusMessage.STATUS_NAME, this.configEvtCb);

        EventBus.getInstance().on(ReliableMessageProcessEvent.EVENT_TYPE_MSG_PROCESS_COMPLETE, this.reliableMsgCb);

        EventBus.getInstance().on(RelayStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(NodeIdentityStatusMessage.STATUS_NAME, this.configEvtCb);
        EventBus.getInstance().on(OnDemandPrivateProxyStatusMessage.STATUS_NAME, this.configEvtCb);
    }

    private initItems() {
        let node = this.node!
        // default ttl
        this.defaultTTL = node.defaultTTL
        this.ttlInput = `${num2Hex(this.defaultTTL, 2)}`

        // relay
        this.relayEnable = node.relayEnable
        this.relayRetransmit = node.relayRetransmit
        this.selectedRelayIndex = this.relayEnable ? 0 : 1
        this.relayRetCntInput = `${num2Hex(this.relayRetransmit & 0b111, 2)}`
        this.relayRetIntInput = `${num2Hex((this.relayRetransmit >> 3) & 0x1F, 2)}`

        // beacon
        this.beaconOpened = node.beaconOpened
        this.selectedBeaconIndex = this.beaconOpened ? 0 : 1

        // proxy
        this.gattProxyEnable = node.gattProxyEnable
        this.selectedProxyIndex = this.gattProxyEnable ? 0 : 1

        this.selectedNodeIdIndex = 1

        //
        this.friendEnable = node.friendEnable
        this.selectedFriendIndex = this.friendEnable ? 0 : 1

        // network transmit
        this.networkRetransmit = node.networkRetransmit
        this.nwkTransCntInput = `${num2Hex(this.networkRetransmit & 0b111, 2)}`
        this.nwkTransIntInput = `${num2Hex((this.networkRetransmit >> 3) & 0x1F, 2)}`


        this.onDemandPrivateGattProxy = node.onDemandPrivateGattProxy
        this.onDemandProxyInput = `${num2Hex(this.onDemandPrivateGattProxy, 2)}`

        this.nodeConfigExpansions = []
        this.nodeConfigExpansions.push({ item: DEFAULT_TTL, expanded: false })
        this.nodeConfigExpansions.push({ item: RELAY, expanded: false })
        this.nodeConfigExpansions.push({ item: SECURE_NETWORK_BEACON, expanded: false })
        this.nodeConfigExpansions.push({ item: PROXY, expanded: false })
        this.nodeConfigExpansions.push({ item: NODE_IDENTITY, expanded: false })
        this.nodeConfigExpansions.push({ item: FRIEND, expanded: false })
        this.nodeConfigExpansions.push({ item: KEY_REFRESH_PHASE, expanded: false })
        this.nodeConfigExpansions.push({ item: NETWORK_TRANSMIT, expanded: false })
        this.nodeConfigExpansions.push({ item: ON_DEMAND_PRIVATE_GATT_PROXY, expanded: false })
    }

    private initInputValues() {

        // relay retransmit count
        /*
        \nretransmit count: ${num2Hex(,
                        2)}\nretransmit interval steps: `,
         */
    }

    reliableMsgCb = (event: Event) => {
        let msgEvt = event as ReliableMessageProcessEvent

    }
    configEvtCb = (event: Event) => {
        let stEvt = event as StatusNotificationEvent
        let message = stEvt.notificationMessage
        let src = message.src
        if (src != this.node!.meshAddress) {
            return
        }
        WaitingDialog.dismiss()
        clearTimeout(this.messageTimeoutId)
        switch (event.type) {

            case DefaultTTLStatusMessage.STATUS_NAME: {
                let statusMessage: DefaultTTLStatusMessage = message.statusMessage! as DefaultTTLStatusMessage
                let ttl = statusMessage.ttl
                this.defaultTTL = ttl
                this.ttlInput = `${num2Hex(this.defaultTTL, 2)}`
                this.node!.defaultTTL = ttl
                logd(`ttl update to : ${this.defaultTTL} , ${this.ttlInput}`)
                break
            }

            case RelayStatusMessage.STATUS_NAME: {
                let statusMessage: RelayStatusMessage = message.statusMessage! as RelayStatusMessage

                this.relayEnable = statusMessage.relay == 1
                this.relayRetransmit =
                    ((statusMessage.retransmitCount & 0b111) | (statusMessage.retransmitIntervalSteps << 3));
                this.selectedRelayIndex = this.relayEnable ? 0 : 1
                this.relayRetCntInput = `${num2Hex(this.relayRetransmit & 0b111, 2)}`
                this.relayRetIntInput = `${num2Hex((this.relayRetransmit >> 3) & 0x1F, 2)}`

                this.node!.relayEnable = this.relayEnable
                this.node!.relayRetransmit = this.relayRetransmit
                break
            }

            case BeaconStatusMessage.STATUS_NAME: {
                let statusMessage: BeaconStatusMessage = message.statusMessage! as BeaconStatusMessage
                this.beaconOpened = statusMessage.beacon == 1
                this.selectedBeaconIndex = this.beaconOpened ? 0 : 1
                this.node!.beaconOpened = this.beaconOpened
                break
            }

            case GattProxyStatusMessage.STATUS_NAME: {
                let statusMessage: GattProxyStatusMessage = message.statusMessage! as GattProxyStatusMessage
                this.gattProxyEnable = statusMessage.gattProxy == 1
                this.selectedProxyIndex = this.gattProxyEnable ? 0 : 1
                this.node!.gattProxyEnable = this.gattProxyEnable
                break
            }

            case NodeIdentityStatusMessage.STATUS_NAME: {
                let statusMessage: NodeIdentityStatusMessage = message.statusMessage! as NodeIdentityStatusMessage
                this.nodeIdentityStarted = statusMessage.identity == 1
                this.selectedNodeIdIndex = this.nodeIdentityStarted ? 0 : 1
                break
            }

            case FriendStatusMessage.STATUS_NAME: {
                let statusMessage: FriendStatusMessage = message.statusMessage! as FriendStatusMessage
                this.friendEnable = statusMessage.friend == 1
                this.selectedFriendIndex = this.friendEnable ? 0 : 1
                break
            }
                KEY_REFRESH_PHASE
            case KeyRefreshPhaseStatusMessage.STATUS_NAME: {
                let statusMessage: KeyRefreshPhaseStatusMessage = message.statusMessage! as KeyRefreshPhaseStatusMessage
                this.phase = statusMessage.phase
                break
            }

            case NetworkTransmitStatusMessage.STATUS_NAME: {
                let statusMessage: NetworkTransmitStatusMessage = message.statusMessage! as NetworkTransmitStatusMessage
                let networkRetransmit = ((statusMessage.count & 0b111) | (statusMessage.intervalSteps << 3));
                this.networkRetransmit = networkRetransmit
                this.node!.networkRetransmit = this.networkRetransmit
                break
            }
            case OnDemandPrivateProxyStatusMessage.STATUS_NAME: {
                let statusMessage: OnDemandPrivateProxyStatusMessage =
                    message.statusMessage! as OnDemandPrivateProxyStatusMessage
                this.onDemandPrivateGattProxy = statusMessage.privateProxy
                this.onDemandProxyInput = `${num2Hex(this.onDemandPrivateGattProxy, 2)}`
                this.node!.onDemandPrivateGattProxy = this.onDemandPrivateGattProxy
                break
            }
        }
        MeshInfoService.getInstance().updateNodeInfo(this.node!)
    }

    private async sendMessage(message: MeshMessage) {
        let re = await MeshService.getInstance().sendMeshMessage(message)
        if (!re) {
            toastMessage(this.getUIContext(), 'send message err')
            return
        }
        WaitingDialog.show("processing...")
        this.messageTimeoutId = setTimeout(() => {
            toastMessage(this.getUIContext(), 'processing timeout')
            WaitingDialog.dismiss()
        }, 3 * 1000)
    }

    aboutToDisappear(): void {
        EventBus.getInstance().offEvents(this.configEvtCb)
        EventBus.getInstance().offEvents(this.reliableMsgCb)
    }

    getValueDesc(configItem: NodeConfigExpansion): string {
        switch (configItem.item) {
            case DEFAULT_TTL:
                return num2Hex(this.defaultTTL, 2)
            case RELAY:
                return `${this.relayEnable ? "enabled" :
                    "disabled"} \nretransmit count: ${num2Hex(this.relayRetransmit & 0b111,
                    2)}\nretransmit interval steps: ${num2Hex((this.relayRetransmit >> 3) & 0x1F, 2)}`
            case SECURE_NETWORK_BEACON:
                return this.beaconOpened ? "opened" : "closed"
            case PROXY:
                return this.gattProxyEnable ? "enabled" : "disabled"
            case NODE_IDENTITY:
                return this.nodeIdentityStarted ? "started" : "stopped"
            case FRIEND:
                return this.friendEnable ? "enabled" : "disabled"

            case KEY_REFRESH_PHASE:
                return this.phase == -1 ? "phase: unknown" : ("phase: " + this.phase)
            case NETWORK_TRANSMIT:
                return `\ntransmit count: ${num2Hex(this.networkRetransmit & 0b111,
                    2)}\ntransmit interval steps: ${num2Hex((this.networkRetransmit >> 3) & 0x1F, 2)}`
                break
            case ON_DEMAND_PRIVATE_GATT_PROXY:
                return num2Hex(this.defaultTTL, 2)
                break
        }
        return ''
    }

    @Builder
    getNodeConfigItem(position: number, onGetClick?: Function,
        onSetClick?: Function) {
        CardView({
            cdPadding: 4,
            cdMargin: 8,
        }) {
            Column({ space: 4 }) {
                Row() {
                    Text(this.nodeConfigExpansions[position].item.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .layoutWeight(1)

                    Image(this.nodeConfigExpansions[position].expanded ? $r('app.media.ic_arrow_down') :
                    $r('app.media.ic_arrow_right'))
                        .width(42)
                        .height(42)
                        .fillColor($r('app.color.primary'))
                        .objectFit(ImageFit.Contain)// .margin({ left: 10 })
                        .padding(8)
                }.width('100%')
                .onClick(() => {
                    this.nodeConfigExpansions[position].expanded = !this.nodeConfigExpansions[position].expanded
                    this.nodeConfigExpansions = [...this.nodeConfigExpansions]
                })

                if (this.nodeConfigExpansions[position].expanded) {
                    Text(this.nodeConfigExpansions[position].item.about).fontSize(11).fontStyle(FontStyle.Italic)
                    Text('value: ' + this.getValueDesc(this.nodeConfigExpansions[position]))
                        .fontSize(12)
                        .fontColor($r('app.color.primary'))
                    Row() {
                        if (this.nodeConfigExpansions[position].item.isGetSupported && onGetClick) {
                            Button('GET').buttonStyle(ButtonStyleMode.TEXTUAL).onClick(() => {
                                onGetClick()
                            })
                        }
                        if (this.nodeConfigExpansions[position].item.isSetSupported && onSetClick) {
                            Button('SET').buttonStyle(ButtonStyleMode.TEXTUAL).onClick(() => {
                                onSetClick()
                            })
                        }
                    }.justifyContent(FlexAlign.End).width('100%')
                }


            }.width('100%').alignItems(HorizontalAlign.Start)
        }
    }

    @Builder
    ttlInputDialogContent() {
        Column({ space: 8 }) {
            Text("Input Default TTL(HEX)").fontSize(15).fontWeight(FontWeight.Bold)
            TextInput({ text: $$this.ttlInput }).type(InputType.Normal).textAlign(TextAlign.Center)
            Button("CONFIRM").onClick(() => {
                if (this.ttlInput == '' || this.ttlInput.length > 2 || !(/^[0-9A-Fa-f]+$/.test(this.ttlInput))) {
                    toastMessage(this.getUIContext(), "input err")
                    return
                }
                let ttl: number;
                try {
                    ttl = parseInt(this.ttlInput, 16)
                } catch (e) {
                    toastMessage(this.getUIContext(), "parse input error");
                    return;
                }
                this.closeDialog();
                let setMessage = DefaultTTLSetMessage.getSimple(this.node!.meshAddress, ttl);
                this.sendMessage(setMessage)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    relayInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Relay & Relay Retransmit").fontSize(15).fontWeight(FontWeight.Bold)
            Row() {
                Text('Relay').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                Select(this.relaySelection)
                    .value(this.relaySelection[this.selectedRelayIndex].value)
                    .selected(this.selectedRelayIndex)
                    .arrowPosition(ArrowPosition.END)
                    .onSelect((index: number, value: string | undefined) => {
                        this.selectedRelayIndex = index
                    })
            }.justifyContent(FlexAlign.Start).width('100%')

            Row() {
                Text('Retransmit Count(3 bits): 0x')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.Black)
                    .textAlign(TextAlign.Center)
                TextInput({ text: $$this.relayRetCntInput }).layoutWeight(1).textAlign(TextAlign.Center)
            }.justifyContent(FlexAlign.Start).width('100%')

            Row() {
                Text('Retransmit Interval Steps(5 bits): 0x')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.Black)
                TextInput({ text: $$this.relayRetIntInput }).layoutWeight(1).textAlign(TextAlign.Center)
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                if (this.relayRetCntInput == '' || this.relayRetCntInput.length > 2 ||
                    !(/^[0-9A-Fa-f]+$/.test(this.relayRetCntInput))
                    || this.relayRetIntInput == '' || this.relayRetIntInput.length > 2 ||
                    !(/^[0-9A-Fa-f]+$/.test(this.relayRetIntInput))) {
                    toastMessage(this.getUIContext(), "relay input err")
                    return
                }
                let relay = this.selectedRelayIndex == 0 ? 1 : 0
                let retransmitCnt: number;
                let retransmitInterval: number
                try {
                    retransmitCnt = parseInt(this.relayRetCntInput, 16)
                    retransmitInterval = parseInt(this.relayRetIntInput, 16)
                } catch (e) {
                    toastMessage(this.getUIContext(), "parse input error");
                    return;
                }
                this.closeDialog();
                let setMessage =
                    RelaySetMessage.getSimple(this.node!.meshAddress, relay, retransmitCnt, retransmitInterval)
                this.sendMessage(setMessage)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    beaconInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Secure Network Beacon").fontSize(15).fontWeight(FontWeight.Bold)
            Row() {
                Text('Select New Value').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                Select(this.beaconSelection)
                    .value(this.beaconSelection[this.selectedBeaconIndex].value)
                    .selected(this.selectedBeaconIndex)
                    .arrowPosition(ArrowPosition.END)
                    .onSelect((index: number, value: string | undefined) => {
                        this.selectedBeaconIndex = index
                    })
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                this.closeDialog();
                let value = this.selectedBeaconIndex == 0 ? 1 : 0
                this.sendMessage(BeaconSetMessage.getSimple(this.node!.meshAddress, value))
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    proxyInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Gatt Proxy").fontSize(15).fontWeight(FontWeight.Bold)
            Row() {
                Text('Select New Value').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                Select(this.proxySelection)
                    .value(this.proxySelection[this.selectedProxyIndex].value)
                    .selected(this.selectedProxyIndex)
                    .arrowPosition(ArrowPosition.END)
                    .onSelect((index: number, value: string | undefined) => {
                        this.selectedProxyIndex = index
                    })
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                this.closeDialog();
                let value = this.selectedProxyIndex == 0 ? 1 : 0
                this.sendMessage(GattProxySetMessage.getSimple(this.node!.meshAddress, value))
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    nodeIdInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Node Identity").fontSize(15).fontWeight(FontWeight.Bold)
            Row() {
                Text('Select New Value').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                Select(this.nodeIdSelection)
                    .value(this.nodeIdSelection[this.selectedNodeIdIndex].value)
                    .selected(this.selectedNodeIdIndex)
                    .arrowPosition(ArrowPosition.END)
                    .onSelect((index: number, value: string | undefined) => {
                        this.selectedNodeIdIndex = index
                    })
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                this.closeDialog();
                let value = this.selectedNodeIdIndex == 0 ? 1 : 0
                this.sendMessage(NodeIdentitySetMessage.getSimple(this.node!.meshAddress, this.netKeyIndex, value))
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    friendInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Friend").fontSize(15).fontWeight(FontWeight.Bold)
            Row() {
                Text('Select New Value').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                Select(this.friendSelection)
                    .value(this.friendSelection[this.selectedFriendIndex].value)
                    .selected(this.selectedFriendIndex)
                    .arrowPosition(ArrowPosition.END)
                    .onSelect((index: number, value: string | undefined) => {
                        this.selectedFriendIndex = index
                    })
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                this.closeDialog();
                let value = this.selectedFriendIndex == 0 ? 1 : 0
                this.sendMessage(FriendSetMessage.getSimple(this.node!.meshAddress, value))
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @Builder
    networkTransmitInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set Network Transmit").fontSize(15).fontWeight(FontWeight.Bold)

            Row() {
                Text('Transmit Count(3 bits): 0x').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                TextInput({ text: $$this.nwkTransCntInput }).layoutWeight(1).textAlign(TextAlign.Center)
            }.justifyContent(FlexAlign.Start).width('100%')

            Row() {
                Text('Transmit Interval Steps(5 bits): 0x')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.Black)
                TextInput({ text: $$this.nwkTransIntInput }).layoutWeight(1).textAlign(TextAlign.Center)
            }.justifyContent(FlexAlign.Start).width('100%')

            Button("CONFIRM").onClick(() => {
                if (this.nwkTransCntInput == '' || this.nwkTransCntInput.length > 2 ||
                    !(/^[0-9A-Fa-f]+$/.test(this.nwkTransCntInput))
                    || this.nwkTransIntInput == '' || this.nwkTransIntInput.length > 2 ||
                    !(/^[0-9A-Fa-f]+$/.test(this.nwkTransIntInput))) {
                    toastMessage(this.getUIContext(), "input err")
                    return
                }
                let transmitCnt: number;
                let transmitInterval: number
                try {
                    transmitCnt = parseInt(this.nwkTransCntInput, 16)
                    transmitInterval = parseInt(this.nwkTransIntInput, 16)
                } catch (e) {
                    toastMessage(this.getUIContext(), "parse input error");
                    return;
                }
                this.closeDialog();
                let setMessage =
                    NetworkTransmitSetMessage.getSimple(this.node!.meshAddress, transmitCnt, transmitInterval)
                this.sendMessage(setMessage)
            }
            )
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    @
    Builder
    onDemandInputDialogContent() {
        Column({ space: 8 }) {
            Text("Set On-Demand Private GATT Proxy").fontSize(15).fontWeight(FontWeight.Bold)

            Row() {
                Text('value: 0x').fontSize(12).fontWeight(FontWeight.Medium).fontColor(Color.Black)
                TextInput({ text: $$this.onDemandProxyInput }).layoutWeight(1).textAlign(TextAlign.Center)
            }.justifyContent(FlexAlign.Start).width('100%')


            Button("CONFIRM").onClick(() => {
                if (this.onDemandProxyInput == '' || this.onDemandProxyInput.length > 2 ||
                    !(/^[0-9A-Fa-f]+$/.test(this.onDemandProxyInput))) {
                    toastMessage(this.getUIContext(), "input err")
                    return
                }
                let onDmd: number;
                try {
                    onDmd = parseInt(this.onDemandProxyInput, 16)
                } catch (e) {
                    toastMessage(this.getUIContext(), "parse byte input error");
                    return;
                }
                this.closeDialog();
                let setMessage = OnDemandPrivateProxySetMessage.getSimple(this.node!.meshAddress, onDmd);
                this.sendMessage(setMessage)
            })
        }
        .width('80%').alignItems(HorizontalAlign.Center).padding(8)
    }

    private closeDialog() {
        this.getUIContext().getPromptAction().closeCustomDialog(this.setDialogId)
    }

    private showSettingDialog(configItem:
        NodeConfigItem
    ) {
        this.getUIContext().getPromptAction().openCustomDialog({
            builder: () => {
                switch (configItem) {
                    case DEFAULT_TTL:
                        this.ttlInputDialogContent()
                        break
                    case RELAY:
                        this.relayInputDialogContent()
                        break
                    case SECURE_NETWORK_BEACON:
                        this.beaconInputDialogContent()
                        break
                    case PROXY:
                        this.proxyInputDialogContent()
                        break

                    case NODE_IDENTITY:
                        this.nodeIdInputDialogContent()
                        break
                    case FRIEND:
                        this.friendInputDialogContent()
                        break

                    case NETWORK_TRANSMIT:
                        this.networkTransmitInputDialogContent()
                        break
                    case ON_DEMAND_PRIVATE_GATT_PROXY:
                        this.onDemandInputDialogContent()
                        break
                }
                // if (configItem == DEFAULT_TTL) {
                //     this.ttlInputDialogContent()
                // }
                // this.networkInputDialogContent()
            },
            autoCancel: true,
            // alignment: DialogAlignment.Bottom
        }).then((id: number) => {
            this.setDialogId = id
        })
    }

    build() {
        Column() {
            TitleBar({
                title: "Device Config",
                showNavigation: true,
                showAction: false,
            })
            Scroll() {
                Column() {
                    // ttl
                    this.getNodeConfigItem(0,
                        // get
                        () => {
                            this.sendMessage(new DefaultTTLGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(DEFAULT_TTL)
                        })
                    this.getNodeConfigItem(1,
                        // get
                        () => {
                            this.sendMessage(new RelayGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(RELAY)
                        }
                    )

                    this.getNodeConfigItem(2,
                        // get
                        () => {
                            this.sendMessage(new BeaconGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(SECURE_NETWORK_BEACON)
                        })
                    this.getNodeConfigItem(3,
                        // get
                        () => {
                            this.sendMessage(new GattProxyGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(PROXY)
                        })
                    this.getNodeConfigItem(4,
                        // get
                        () => {
                            this.sendMessage(NodeIdentityGetMessage.getSimple(this.node!.meshAddress,
                                this.netKeyIndex))
                        },
                        // set
                        () => {
                            this.showSettingDialog(NODE_IDENTITY)
                        })
                    this.getNodeConfigItem(5,
                        // get
                        () => {
                            this.sendMessage(new FriendGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(FRIEND)
                        })
                    this.getNodeConfigItem(6,

                        // get
                        () => {
                            this.sendMessage(new KeyRefreshPhaseGetMessage(this.node!.meshAddress))
                        })
                    this.getNodeConfigItem(7,

                        // get
                        () => {
                            this.sendMessage(new NetworkTransmitGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(NETWORK_TRANSMIT)
                        })
                    this.getNodeConfigItem(8,
                        // get
                        () => {
                            this.sendMessage(new OnDemandPrivateProxyGetMessage(this.node!.meshAddress))
                        },
                        // set
                        () => {
                            this.showSettingDialog(ON_DEMAND_PRIVATE_GATT_PROXY)
                        })
                }.height('auto').justifyContent(FlexAlign.Start)
            }.layoutWeight(1).align(Alignment.TopStart).padding(8)

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
