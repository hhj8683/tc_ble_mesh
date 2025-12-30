import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon } from '../../components/Widgets';
import {
    BindingBearer,
    BindingDevice,
    BindingEvent,
    BindingParameters,
    bytesEquals,
    bytesToHexString,
    Event,
    EventBus,
    hexToBytes,
    logd,
    logw,
    MeshConfiguration,
    MeshScanRecord,
    MeshService,
    num2Hex,
    OnOffSetMessage,
    ProvisioningDevice,
    ProvisioningEvent,
    ProvisioningParameters,
    ScanEvent,
    ScanParameters
} from 'telinksigmeshlib';
import { UiStateEvent } from '../../model/UiStateEvent';
import { router } from '@kit.ArkUI';
import { ble } from '@kit.ConnectivityKit';
import { MeshInfo } from '../../model/MeshInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { CardView } from '../../components/CardView';


enum NetworkingState {
    STATE_IDLE = 'IDLE',
    STATE_PROVISIONING = 'PROVISIONING',
    STATE_PROVISION_SUCCESS = 'PROVISION_SUCCESS',
    STATE_PROVISION_FAIL = 'PROVISION_FAIL',
    STATE_KEY_BINDING = "KEY_BINDING",
    STATE_KEY_BIND_SUCCESS = "KEY_BIND_SUCCESS",
    STATE_KEY_BIND_FAIL = "KEY_BIND_FAIL",
}

interface NetworkingDevice {
    scanResult: ble.ScanResult
    address: number
    deviceUuid: Uint8Array
    state: NetworkingState
}

@Entry
@Component
struct SelectableProvisionPage {
    @State isProcessing: boolean = false
    // @State deviceId: string = ""
    @State log: string = ""
    @State devices: NetworkingDevice[] = []
    private meshInfo: MeshInfo = MeshInfoService.getInstance().getCurrentMesh()
    private provisionIndex = -1

    async aboutToAppear() {
        EventBus.getInstance().on(ScanEvent.EVENT_TYPE_DEVICE_FOUND, this.eventCb)
        EventBus.getInstance().on(ScanEvent.EVENT_TYPE_SCAN_TIMEOUT, this.eventCb)
        EventBus.getInstance().on(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS, this.eventCb)
        EventBus.getInstance().on(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL, this.eventCb)
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_SUCCESS, this.eventCb)
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_FAIL, this.eventCb)
        this.startScan()
    }

    eventCb = (event: Event) => {
        let type = event.type
        switch (type) {
            case ScanEvent.EVENT_TYPE_DEVICE_FOUND:
                let scanEvent = event as ScanEvent
                let dev = scanEvent.advertisingDevice!
                logd("device found ##: " + dev.deviceId)
                let rssi = dev.rssi
                this.onDeviceFound(dev)
                // if (rssi > -55) {
                // }
                break

            case ScanEvent.EVENT_TYPE_SCAN_TIMEOUT:
                this.appendLog("scan timeout")
                this.isProcessing = false
                break

            case ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS:
                this.appendLog("provision success")
                let provisionEvent = event as ProvisioningEvent
                this.onProvisionSuccess(provisionEvent)
                break

            case ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL:
                this.appendLog("provision fail success")
                this.onDeviceComplete()
                break

            case BindingEvent.EVENT_TYPE_BIND_SUCCESS:
                this.appendLog("key bind success")
                this.onKeyBindSuccess(event as BindingEvent)
                break

            case BindingEvent.EVENT_TYPE_BIND_FAIL:
                this.appendLog("key bind success")
                this.onDeviceComplete()
                break
        }
    }

    onDeviceComplete() {
        this.isProcessing = false
    }

    onDeviceFound(scanResult: ble.ScanResult) {
        let deviceId = scanResult.deviceId
        this.appendLog("[scan]device id : " + deviceId)
        let sr = MeshScanRecord.parseFromBytes(scanResult.data);
        if (!sr) {
            return;
        }
        let data = sr.getProvServiceData()
        if (!data) {
            return
        }
        let deviceUuid = data.slice(0, 16)
        if (this.deviceExists(deviceUuid)) {
            logd("device exists");
            return;
        }
        this.devices.push({
            deviceUuid: deviceUuid,
            address: 0,
            scanResult: scanResult,
            state: NetworkingState.STATE_IDLE
        })
    }

    /**
     * only find in unprovisioned list
     *
     * @param deviceUuid deviceUUID in unprovisioned scan record
     */
    private deviceExists(deviceUuid: Uint8Array): boolean {
        for (let device of this.devices) {
            if (device.state == NetworkingState.STATE_IDLE && bytesEquals(deviceUuid, device.deviceUuid)) {
                return true;
            }
        }
        return false;
    }

    onProvisionSuccess(event: ProvisioningEvent) {
        let remote = event.provisioningDevice
        let nodeInfo = new NodeInfo()
        nodeInfo.meshAddress = remote.unicastAddress
        nodeInfo.deviceUUID = bytesToHexString(remote.deviceUUID)
        nodeInfo.elementCnt = remote.deviceCapability!.eleNum
        nodeInfo.deviceKey = bytesToHexString(remote.deviceKey!)
        nodeInfo.netKeyIndexes.push(num2Hex(this.meshInfo.getDefaultNetKey().index))
        this.meshInfo.insertDevice(nodeInfo, true)
        this.updateNetworkingState(NetworkingState.STATE_KEY_BINDING)
        this.startKeyBind(remote)
    }

    onProvisionFail(event: ProvisioningEvent) {
        let remote = event.provisioningDevice
        this.updateNetworkingState(NetworkingState.STATE_PROVISION_FAIL)
    }

    onKeyBindSuccess(event: BindingEvent) {
        this.onDeviceComplete()
        let uuid = bytesToHexString(event.bindingDevice.deviceUUID)
        let nodeInfo = this.meshInfo.getDeviceByUUID(uuid)
        if (nodeInfo) {
            nodeInfo.bound = true
            nodeInfo.compositionData = event.bindingDevice.compositionData
            this.meshInfo.saveOrUpdate()
        }
        this.updateNetworkingState(NetworkingState.STATE_KEY_BIND_SUCCESS)
    }

    updateNetworkingState(state: NetworkingState) {
        let dev = this.devices[this.provisionIndex]
        this.devices[this.provisionIndex] = {
            scanResult: dev.scanResult,
            address: dev.address,
            deviceUuid: dev.deviceUuid,
            state: state
        }
        logd(`updateNetworkingState index=${this.provisionIndex} state=${state} ${JSON.stringify(this.devices)}`)
    }

    aboutToDisappear(): void {
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
        EventBus.getInstance().offEvents(this.eventCb)
    }

    @Builder
    getActionView() {
        if (!this.isProcessing) {
            getCommonIcon($r("app.media.ic_refresh"), () => {
                this.startScan()
            })
        }
    }

    @Builder
    geNavView() {
        if (!this.isProcessing) {
            getCommonIcon($r("app.media.ic_arrow_left"), () => {
                router.back()
            })
        }
    }

    private appendLog(log: string) {
        logd(" log : " + log)
        this.log += log + "\n"
    }

    private startScan() {
        this.isProcessing = true
        this.appendLog("provision start scan ")
        MeshService.getInstance().startScan(ScanParameters.getDefault(false, false));
    }

    private startProvision(device: NetworkingDevice, index: number) {
        this.isProcessing = true
        this.provisionIndex = index
        this.appendLog('start provision')
        let deviceId = device.scanResult.deviceId
        let uuid = device.deviceUuid
        let address = this.meshInfo.getProvisionIndex()
        logd(`new address : ${num2Hex(address, 4)}`)
        let provisionDevice = new ProvisioningDevice(deviceId, uuid)
        provisionDevice.unicastAddress = address
        this.devices[this.provisionIndex].address = address
        this.updateNetworkingState(NetworkingState.STATE_PROVISIONING)
        MeshService.getInstance().startProvisioning(new ProvisioningParameters(provisionDevice))
    }

    private startKeyBind(device: ProvisioningDevice) {
        this.appendLog("start key bind")
        let bindingDevice = new BindingDevice();
        bindingDevice.meshAddress = device.unicastAddress
        bindingDevice.deviceUUID = device.deviceUUID
        bindingDevice.appKeyIndex = this.meshInfo.getDefaultAppKeyIndex()
        bindingDevice.defaultBound = false
        // bindingDevice.bearer = BindingBearer.GattOnly
        bindingDevice.bearer = BindingBearer.Any
        MeshService.getInstance().startKeyBind(new BindingParameters(bindingDevice));
    }

    private sendOnOff(state: number) {
        let setMessage = OnOffSetMessage.getSimple(0xFFFF, 0, state, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    // 自定义列表项内容
    @Builder
    ListItemContent(item: NetworkingDevice, index: number) {
        Column() {
            Row() {
                Image($r("app.media.ic_bulb_on"))
                    .width(32)
                    .height(32)
                    .margin({ right: 12 })
                Text(`address: ${item.address == 0 ? "[Unallocated]" : "0x" + num2Hex(item.address,
                    4)} \nUUID : ${bytesToHexString(item.deviceUuid)} \nrssi : ${item.scanResult.rssi}dBm`)
                    .fontSize(12)
                    .fontColor(Color.Gray)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                    .layoutWeight(1)
            }

            Row() {
                Text(item.state)
                    .fontSize(12)
                    // .fontColor($r('app.color.primary'))
                    .fontColor(Color.Grey)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                    .layoutWeight(1)
                Row() {
                    if (this.isProcessing && this.provisionIndex == index) {
                        LoadingProgress()
                            .enableLoading(true)
                            .color(Color.Blue)
                            .height('100%')
                            .width(30)
                    }
                    if (!this.isProcessing && item.state == NetworkingState.STATE_IDLE) {
                        // 右侧按钮
                        Button("ADD", { buttonStyle: ButtonStyleMode.TEXTUAL })
                            .borderRadius(4)
                            .fontSize(13)
                            .fontWeight(FontWeight.Bold)
                            .fontColor($r("app.color.primary"))
                            .height('100%')
                            .onClick(() => {
                                this.startProvision(item, index)
                            })
                    }
                }.height(36)

            }
        }
        .border({
            width: {
                bottom: 0.2,
                top: 0.6,
                left: 0.5,
                right: 0.5
            },
            color: Color.Grey,
            radius: 5
        })
        .shadow({
            radius: 5,
            offsetY: 2,
            offsetX: 2,
            fill: false,
            color: Color.Grey,
            type: ShadowType.COLOR
        })
        .alignItems(HorizontalAlign.Start)
        .margin(4)
        .padding(4)
    }

    build() {
        Column({}) {
            TitleBar({
                title: "Device Scan",
                subTitle: "Selectable",
                showNavigation: true,
                showAction: true,
                navigationView: () => {
                    this.geNavView()
                },
                actionView: () => {
                    this.getActionView()
                }
            })

            List({ space: 4 }) {
                ForEach(this.devices, (item: NetworkingDevice, index: number) => {
                    ListItem() {
                        this.ListItemContent(item, index);
                    }
                })
            }.width("100%").layoutWeight(1)

        }.height("100%").width("100%")
    }
}
