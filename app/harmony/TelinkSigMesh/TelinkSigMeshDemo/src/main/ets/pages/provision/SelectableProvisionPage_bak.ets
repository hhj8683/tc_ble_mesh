/********************************************************************************************************
 * @file     SelectableProvisionPage_bak.ets 
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
import { getCommonIcon } from '../../components/Widgets';
import {
    generateRandom,
    logd,
    MeshConfiguration,
    MeshController,
    ScanParameters,
    EventCallback,
    Event,
    ScanEvent,
    logw,
    ProvisioningParameters,
    ProvisioningDevice,
    generateKeyPair,
    bytesToHexString,
    hexToBytes,
    ccm,
    aesCmac,
    aesEcb,
    ProvisioningEvent,
    BindingDevice,
    BindingBearer,
    BindingParameters,
    OnOffSetMessage,
    loge,
    BindingEvent,
    MeshService,
    EventBus,
    NodeResetMessage,
} from 'telinksigmeshlib';
import { ArrayList, JSON } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { UiStateEvent } from '../../model/UiStateEvent';

@Entry
@Component
struct SelectableProvisionPage_bak {
    // private meshController: MeshController = new MeshController()
    @State isProcessing: boolean = false
    @State deviceId: string = ""
    @State log: string = ""

    async aboutToAppear() {
        EventBus.getInstance().on(ScanEvent.EVENT_TYPE_DEVICE_FOUND, this.eventCb)
        EventBus.getInstance().on(ScanEvent.EVENT_TYPE_SCAN_TIMEOUT, this.eventCb)
        EventBus.getInstance().on(ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS, this.eventCb)
        EventBus.getInstance().on(ProvisioningEvent.EVENT_TYPE_PROVISION_FAIL, this.eventCb)
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_SUCCESS, this.eventCb)
        EventBus.getInstance().on(BindingEvent.EVENT_TYPE_BIND_FAIL, this.eventCb)
    }

    eventTestCb = (event: Event) => {
        logw("eventTestCb # " + event.type)
    }
    eventCb = (event: Event) => {
        let type = event.type
        switch (type) {
            case ScanEvent.EVENT_TYPE_DEVICE_FOUND:
                let scanEvent = event as ScanEvent
                let dev = scanEvent.advertisingDevice!
                logd("device found ##: " + dev.deviceId)
                let rssi = dev.rssi
                if (rssi > -45) {
                    this.deviceId = dev.deviceId
                    this.appendLog("find device id : " + this.deviceId)
                }
                break

            case ScanEvent.EVENT_TYPE_SCAN_TIMEOUT:
                this.appendLog("scan timeout")
                break

            case ProvisioningEvent.EVENT_TYPE_PROVISION_SUCCESS:
                this.appendLog("provision success")
                let provisionEvent = event as ProvisioningEvent
                this.startKeyBind()
                break

            case BindingEvent.EVENT_TYPE_BIND_SUCCESS:
                this.appendLog("key bind success")
                break
        }
    }

    aboutToDisappear(): void {
        EventBus.getInstance().emit(new UiStateEvent(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED))
        EventBus.getInstance().offEvents(this.eventCb)
    }

    createNewConfig() {
        let config = new MeshConfiguration()
        config.netKeyIndex = 0
        let netKey = hexToBytes("4D5307EF5E2644D9378E59557268a5a5")
        let appKey = hexToBytes("4D5307EF5E2644D9378E595572687788")
        // let netKey = generateRandom(16)
        config.networkKey = netKey

        config.appKeyMap = new Array()

        for (let index = 0; index < 3; index++) {
            config.appKeyMap.push({ keyIndex: index, key: appKey })
            // config.appKeyMap.push({ keyIndex: index, key: generateRandom(16) })
        }

        // config.deviceKeyMap.add({key: hexToBytes("56db5a5f3beb5e0b6e4f04cbd427cf6a"), address: 2})

        config.ivIndex = 0
        config.sequenceNumber = 0;
        config.localAddress = 1
        return config
    }

    @Builder
    getActionView() {
        if (this.isProcessing) {
            Text("hh")
        } else {
            getCommonIcon($r("app.media.ic_refresh"), () => {
                logd("refresh : " + this.isProcessing)
                this.isProcessing = true
                setTimeout(() => {
                    this.isProcessing = false
                })
            })
        }
    }

    @Builder
    geNavView() {
        if (!this.isProcessing) {
            getCommonIcon($r("app.media.ic_refresh"), () => {
                logd("refresh : " + this.isProcessing)
                this.isProcessing = true
                setTimeout(() => {
                    this.isProcessing = false
                }, 3 * 1000)
            })
        }
    }

    private appendLog(log: string) {
        logd(" log : " + log)
        this.log += log + "\n"
    }

    private startScan() {
        this.appendLog("start scan ")
        MeshService.getInstance().startScan(ScanParameters.getDefault(false, false));
    }

    private startProvision() {
        this.appendLog('start provision')
        if (this.deviceId == "") {
            this.appendLog("err : device not found")
            return
        }
        let testUuid = new Uint8Array(16)
        let provisionDevice = new ProvisioningDevice(this.deviceId, testUuid)
        provisionDevice.unicastAddress = 0x02

        MeshService.getInstance().startProvisioning(new ProvisioningParameters(provisionDevice))
    }

    private startKeyBind() {
        this.appendLog("start key bind")
        let bindingDevice = new BindingDevice();
        bindingDevice.meshAddress = 0x02;
        bindingDevice.deviceUUID = new Uint8Array(16)
        bindingDevice.appKeyIndex = 0
        bindingDevice.defaultBound = false
        // bindingDevice.bearer = BindingBearer.GattOnly
        bindingDevice.bearer = BindingBearer.Any
        MeshService.getInstance().startKeyBind(new BindingParameters(bindingDevice));
    }

    private sendOnOff(state: number) {
        let setMessage = OnOffSetMessage.getSimple(0x02, 0, state, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    build() {
        Flex({ direction: FlexDirection.Column }) {
            TitleBar({
                title: "Provision",
                showNavigation: true,
                showAction: true,
                navigationView: () => {
                    this.geNavView()
                },
                actionView: () => {
                    this.getActionView()
                }
            })
            Button("scan").onClick(() => {
                this.startScan();
            })
            Row() {
                Button("provision").onClick(() => {
                    this.startProvision()
                })
                Button("key bind").onClick(() => {
                    this.startKeyBind()
                })
            }

            Row() {
                Button("SET ON").onClick(() => {
                    this.sendOnOff(1)
                })
                Button("SET OFF").onClick(() => {
                    this.sendOnOff(0)
                })
            }

            Row() {
                Button("on event").onClick(() => {
                    EventBus.getInstance().on("test_event", this.eventTestCb)
                    EventBus.getInstance().on("test_event_1", this.eventTestCb)
                    EventBus.getInstance().on("test_event_2", this.eventTestCb)
                })

                Button("off event").onClick(() => {
                    EventBus.getInstance().off("test_event", this.eventTestCb)
                })


                Button("off all").onClick(() => {
                    EventBus.getInstance().offEvents(this.eventTestCb)
                })

                Button("emit event").onClick(() => {
                    EventBus.getInstance().emit({ type: 'test_event' })
                })

            }

            Button("reset").onClick(() => {
                MeshService.getInstance().sendMeshMessage(new NodeResetMessage(0x02))
            })

            Text(this.log)

            // List() {
            //   ForEach(this.bleDeviceList, (item: ble.ScanResult) => {
            //     ListItem() {
            //       Row({ space: 4 }) {
            //         Image($r("app.media.ic_bluetooth"))
            //           .fillColor($r("app.color.primary"))
            //           .height(24)
            //           .margin({ left: 8 })
            //         Column({ space: 8 }) {
            //           Text(item.deviceName || "N/A").fontSize(16).fontWeight(FontWeight.Bold)
            //           Text(item.deviceId).fontSize(14).fontStyle(FontStyle.Italic)
            //           Text("Rssi: " + item.rssi + "dBm").fontSize(12).fontStyle(FontStyle.Italic)
            //         }
            //         .layoutWeight(1)
            //         .padding(16)
            //         .alignItems(HorizontalAlign.Start)
            //
            //         Image($r("app.media.ic_arrow_right"))
            //           .fillColor($r("app.color.primary"))
            //           .height(24)
            //           .margin({ right: 8 })
            //       }
            //       .width('100%')
            //       .onClick(() => {
            //         if (this.isScanning) {
            //           this.stopScan()
            //         }
            //         let params: OtaPageParams = { deviceId: item.deviceId, deviceName: item.deviceName }
            //         router.pushUrl({ url: 'pages/SigMesh', params: params })
            //       })
            //     }
            //     .border({
            //       width: { bottom: 0.2 },
            //       color: Color.Grey
            //     })
            //   })
            // }
        }.height("100%").width("100%")
    }
}
