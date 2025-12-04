import { getCommonIcon } from '../../components/Widgets';
import {
    CtlTemperatureSetMessage,
    currentTimeMillis,
    DeltaSetMessage,
    HslSetMessage,
    LightnessSetMessage,
    logd,
    MeshService,
    MeshSigModel,
    num2Hex,
    OnOffSetMessage
} from 'telinksigmeshlib';
import { NodeInfo } from '../../model/NodeInfo';
import { MeshInfoService } from '../../model/MeshInfoService';
import { OnlineState } from '../../model/OnlineState';
import { UnitConvert } from '../../utils/UnitConvert';
import { Colors } from '../../utils/Colors';

const SAMPLE_TIME = 320 // ms
const COLOR_PANEL_WIDTH = 200

@Component
export default struct NodeControlSubPage {
    @Prop node?: NodeInfo = undefined
    @State elements: number[] = []
    @State lum: number = 100
    @State temp: number = 100
    private lumEleAdr = -1
    private ctEleAdr = -1
    private hslEleAdr = -1
    private appKeyIndex: number = 0
    private delta: number = 0
    private preTime = 0
    @State selectedColor: string = '#FF0000'
    @State pageScrollable: boolean = true;
    // HSV
    @State hsvH: number = 360 // 0 - 360
    @State hsvS: number = 1 // 0 - 1
    @State hsvV: number = 100 // 0 - 100
    // RGB
    @State rgb: number = 100
    // HSL
    @State hslH: number = 360
    @State hslS: number = 1
    @State hslL: number = 100

    async aboutToAppear() {
        logd("NodeControlSubPage # aboutToAppear")
        if (this.node) {
            let elements = this.node.getEleListByModel(MeshSigModel.SIG_MD_G_ONOFF_S)
            logd("on off elements : " + elements?.length)
            if (elements) {
                this.elements = elements
            } else {
                this.elements = []
            }
            this.lumEleAdr = this.node.getTargetEleAdr(MeshSigModel.SIG_MD_LIGHTNESS_S)
            this.ctEleAdr = this.node.getTargetEleAdr(MeshSigModel.SIG_MD_LIGHT_CTL_S)
            this.hslEleAdr = this.node.getTargetEleAdr(MeshSigModel.SIG_MD_LIGHT_HSL_S)
        }
        this.appKeyIndex = MeshInfoService.getInstance().getCurrentMesh().getDefaultAppKeyIndex()
        this.delta = Math.ceil(0xFFFF / 10);
        // EventBus.getInstance().on(UiStateEvent.EVENT_TYPE_NODE_LIST_CHANGED, this.refreshNodeList)
        // EventBus.getInstance().on(NodeStatusChangedEvent.EVENT_TYPE_NODE_STATUS_CHANGED, this.refreshNodeList)
        // EventBus.getInstance().on(AutoConnectEvent.EVENT_TYPE_AUTO_CONNECT_LOGIN, this.onLoginEvent)
        // EventBus.getInstance().on(MeshEvent.EVENT_TYPE_DISCONNECTED, this.onDisconnectEvent)
        // this.refreshNodeList()
    }

    aboutToDisappear(): void {
        logd("NodeControlSubPage # aboutToDisappear")
        // EventBus.getInstance().offEvents(this.refreshNodeList)
        // EventBus.getInstance().offEvents(this.onLoginEvent)
    }

    private onOffToggle(isOn: boolean, eleAdr: number) {
        let state = isOn ? OnlineState.ON : OnlineState.OFF
        let setMessage = OnOffSetMessage.getSimple(eleAdr, this.appKeyIndex, state, true, 1)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    private sendDeltaSetMessage(adr: number, delta: number) {
        MeshService.getInstance().sendMeshMessage(DeltaSetMessage.getSimple(adr, this.appKeyIndex, delta, true, 1))
    }

    private sendLumSetMessage(lum: number, immediate: boolean = false) {
        logd("sendLumSetMessage : " + lum + " -- immediate : " + immediate)
        let curTime = currentTimeMillis()
        let delta = curTime - this.preTime
        if (delta > SAMPLE_TIME || immediate) {
            this.preTime = curTime
            MeshService.getInstance().sendMeshMessage(LightnessSetMessage.getSimple(this.lumEleAdr,
                this.appKeyIndex,
                UnitConvert.lum2lightness(lum),
                false, 0))
        }
    }

    private sendTempSetMessage(temp: number, immediate: boolean = false) {
        logd("sendTempSetMessage : " + temp + " -- immediate : " + immediate)
        let curTime = currentTimeMillis()
        let delta = curTime - this.preTime
        if (delta > SAMPLE_TIME || immediate) {
            this.preTime = curTime
            MeshService.getInstance().sendMeshMessage(CtlTemperatureSetMessage.getSimple(this.ctEleAdr,
                this.appKeyIndex,
                UnitConvert.temp100ToTemp(temp),
                0,
                false, 0))
        }
    }

    private sendHslSetMessage(immediate: boolean) {
        let hue = Math.round(this.hslH * 65535 / 360)
        let sat = Math.round(this.hslS * 65535 / 100)
        let lightness = Math.round(this.hslL * 65535 / 100)
        logd(`sendHslSetMessage : hue=${hue} , sat=${sat} , lightness=${lightness} `)
        let curTime = currentTimeMillis()
        let delta = curTime - this.preTime
        if (delta > SAMPLE_TIME || immediate) {
            this.preTime = curTime
            MeshService.getInstance().sendMeshMessage(HslSetMessage.getSimple(this.hslEleAdr,
                this.appKeyIndex,
                lightness,
                hue,
                sat,
                false, 0))
        }
    }

    private handleTouchEvent(event: TouchEvent, width: number) {
        let touch0 = event.touches[0]
        let touchX = touch0.x;
        let touchY = touch0.y;
        let circleWidth = width / 2
        let circlePoiontX = width / 2
        let circlePoiontY = width / 2

        let relativeX = touchX - circlePoiontX;
        let relativeY = touchY - circlePoiontY;

        let distance = Math.sqrt(relativeX * relativeX + relativeY * relativeY);
        let angle = Math.atan2(relativeY, relativeX);

        if (angle < 0) {
            angle += 2 * Math.PI;
        }

        if (distance > circleWidth) {
            distance = circleWidth
        }

        let saturation = distance / circleWidth

        logd("hue angle = " + angle)
        let hue = angle * 180 / Math.PI;

        // sync to android picture  - start
        hue += 180
        if (hue > 360) {
            hue -= 360;
        }
        this.hsvH = hue
        this.hsvS = saturation
        // sync to android picture - end

        this.onHsvUpdate(event.type != TouchType.Move)
    }

    /**
     * from color panel or visibility slider
     */
    onHsvUpdate(immediate: boolean) {
        this.rgb = Colors.hsvToRgb(this.hsvH, this.hsvS, this.hsvV / 100)

        let hsl = Colors.rgbToHsl(this.rgb)
        this.hslH = Math.round(hsl[0])
        this.hslS = Math.round(hsl[1] * 100)
        this.hslL = Math.round(hsl[2] * 100)
        this.sendHslSetMessage(immediate)
    }

    /**
     * from r/g/b slider changed event
     */
    onRgbUpdate(immediate: boolean) {
        // this.selectedColor = `#FF${num2Hex((rgb >> 16) & 0xFF, 2)}${num2Hex((rgb >> 8) & 0xFF, 2)}${num2Hex(rgb & 0xFF, 2)}`
        let hsv = Colors.rgbToHsv(this.rgb)
        this.hsvH = hsv[0]
        this.hsvS = hsv[1]
        this.hsvV = Math.round(hsv[2] * 100)

        let hsl = Colors.rgbToHsl(this.rgb)
        this.hslH = Math.round(hsl[0])
        this.hslS = Math.round(hsl[1] * 100)
        this.hslL = Math.round(hsl[2] * 100)
        this.sendHslSetMessage(immediate)
    }

    onHslUpdate(immediate: boolean) {
        this.rgb = Colors.hslToRgb(this.hslH, this.hslS / 100, this.hslL / 100)

        let hsv = Colors.rgbToHsv(this.rgb)
        this.hsvH = hsv[0]
        this.hsvS = hsv[1]
        this.hsvV = Math.round(hsv[2] * 100)

        this.sendHslSetMessage(immediate)
    }

    @Builder
    private getColorPanel() {
        Row() {
            Text()
                .width(36)
                .height(36)
                .backgroundColor(`#FF${num2Hex((this.rgb >> 16) & 0xFF, 2)}${num2Hex((this.rgb >> 8) & 0xFF,
                    2)}${num2Hex(this.rgb & 0xFF, 2)}`)
        }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 8, bottom: 8 })

        Divider().strokeWidth(0.2).color(Color.Gray).padding(8)
        Text("HSV").fontWeight(FontWeight.Bold).fontSize(15).margin({ left: 8 })
        Row() {
            Image($r('app.media.image_color_wheel')).width('100%').onTouch((event: TouchEvent) => {
                if (event.type == TouchType.Down) {
                    this.pageScrollable = false;
                }
                if (event.type == TouchType.Up) {
                    this.pageScrollable = true;
                }
                if (event.type != TouchType.Down && event.type != TouchType.Move) {
                    return
                }
                this.handleTouchEvent(event, COLOR_PANEL_WIDTH)
            })
                .width(COLOR_PANEL_WIDTH)
                .height(COLOR_PANEL_WIDTH)
        }
        .width('100%')
        .padding({
            top: 16,
            bottom: 16,
            left: 32,
            right: 32
        })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Row() {
            Text(`V: ${this.hsvV}`).fontSize(12).width(48)
            Slider({
                value: this.hsvV,
                min: 0,
                max: 100,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.hsvV = value
                this.onHsvUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1)
        }.width('100%').padding({ left: 16, right: 16 })

        Divider().strokeWidth(0.2).color(Color.Gray).padding(8)

        // RGB
        Text("RGB").fontWeight(FontWeight.Bold).fontSize(15).margin({ left: 8 })
        Row() {
            Text(`R: ${(this.rgb >> 16) & 0xFF}`).fontSize(12).width(48)
            Slider({
                value: (this.rgb >> 16) & 0xFF,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.rgb = (this.rgb & 0xFF00FFFF) | (value << 16)
                this.onRgbUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor(Color.Red)
        }.width('100%').padding({ left: 16, right: 16 })

        Row() {
            Text(`G: ${(this.rgb >> 8) & 0xFF}`).fontSize(12).width(48)
            Slider({
                value: (this.rgb >> 8) & 0xFF,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.rgb = (this.rgb & 0xFFFF00FF) | (value << 8)
                this.onRgbUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor('#00FF00')
        }.width('100%').padding({ left: 16, right: 16 })

        Row() {
            Text(`B: ${(this.rgb) & 0xFF}`).fontSize(12).width(48)
            Slider({
                value: (this.rgb) & 0xFF,
                min: 0,
                max: 255,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.rgb = (this.rgb & 0xFFFFFF00) | (value << 0)
                logd("updateRgb # b")
                this.onRgbUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor(Color.Blue)
        }.width('100%').padding({ left: 16, right: 16 })

        Divider().strokeWidth(0.2).color(Color.Gray).padding(8)

        // HSL
        Text("HSL").fontWeight(FontWeight.Bold).fontSize(15).margin({ left: 8 })
        Row() {
            Text(`H: ${this.hslH}`).fontSize(12).width(48)
            Slider({
                value: this.hslH,
                min: 0,
                max: 360,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.hslH = value
                this.onHslUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor(Color.Grey)
        }.width('100%').padding({ left: 16, right: 16 })

        Row() {
            Text(`S: ${this.hslS}`).fontSize(12).width(48)
            Slider({
                value: this.hslS,
                min: 0,
                max: 100,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.hslS = value
                this.onHslUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor(Color.Brown)
        }.width('100%').padding({ left: 16, right: 16 })

        Row() {
            Text(`S: ${this.hslL}`).fontSize(12).width(48)
            Slider({
                value: this.hslL,
                min: 0,
                max: 100,
                style: SliderStyle.OutSet
            }).onChange((value: number, mode: SliderChangeMode) => {
                this.hslL = value
                this.onHslUpdate(mode != SliderChangeMode.Moving)
            }).layoutWeight(1).selectedColor(Color.Orange)
        }.width('100%').padding({ left: 16, right: 16 })
    }

    build() {
        Scroll() {
            Column() {
                if (this.hslEleAdr != -1) {
                    this.getColorPanel()
                }
                Grid() {
                    ForEach(this.elements, (item: number) => {
                        GridItem() {
                            Column() {
                                Toggle({ type: ToggleType.Switch, isOn: true })
                                    .selectedColor($r('app.color.primary'))
                                    .switchPointColor('#FFFFFF')
                                    .onChange((isOn: boolean) => {
                                        this.onOffToggle(isOn, item)
                                        // console.info('Component status:' + isOn);
                                    })

                                Text(`ele adr : 0x${num2Hex(item + this.node!.meshAddress, 4)}`).fontSize(12)
                            }
                            .padding(8)
                            .backgroundColor(Color.White)
                            .borderRadius(4)
                            .borderWidth(0.5)
                            .margin(4)
                            .borderColor(Color.Gray)
                        }
                    })
                }.width('100%')

                if (this.lumEleAdr != -1) {
                    Row() {
                        Text(`Lum Level\n(at ele adr ${num2Hex(this.lumEleAdr, 4)})`).fontSize(12)
                        Row() {
                            getCommonIcon($r('app.media.ic_minus'), () => {
                                this.sendDeltaSetMessage(this.lumEleAdr, -this.delta)
                            }, Color.Gray)
                        }.layoutWeight(1).justifyContent(FlexAlign.Center)

                        Row() {
                            getCommonIcon($r('app.media.ic_plus'), () => {
                                this.sendDeltaSetMessage(this.lumEleAdr, this.delta)
                            }, Color.Gray)
                        }.layoutWeight(1).justifyContent(FlexAlign.Center)

                    }.width('100%')

                    Text(`Lum(${this.lum})(at ele adr ${num2Hex(this.lumEleAdr, 4)}):`).fontSize(12)
                    Slider({
                        value: this.lum,
                        min: 1,
                        max: 100,
                        style: SliderStyle.OutSet
                    })
                        .onChange((value: number, mode: SliderChangeMode) => {
                            this.lum = value
                            this.sendLumSetMessage(this.lum, mode != SliderChangeMode.Moving)
                            console.info('value:' + value + 'mode:' + mode.toString());
                        })
                }
                if (this.ctEleAdr != -1) {
                    Row() {
                        Text(`Temp Level\n(at ele adr ${num2Hex(this.ctEleAdr, 4)})`).fontSize(12)
                        Row() {
                            getCommonIcon($r('app.media.ic_minus'), () => {
                                this.sendDeltaSetMessage(this.ctEleAdr, -this.delta)
                            }, Color.Gray)
                        }.layoutWeight(1).justifyContent(FlexAlign.Center)

                        Row() {
                            getCommonIcon($r('app.media.ic_plus'), () => {
                                this.sendDeltaSetMessage(this.ctEleAdr, this.delta)
                            }, Color.Gray)
                        }.layoutWeight(1).justifyContent(FlexAlign.Center)

                    }.width('100%')

                    Text(`Temp(${this.temp})(at ele adr ${num2Hex(this.ctEleAdr, 4)}):`).fontSize(12)
                    Slider({
                        value: this.temp,
                        min: 0,
                        max: 100,
                        style: SliderStyle.OutSet
                    })
                        .onChange((value: number, mode: SliderChangeMode) => {
                            this.temp = value
                            this.sendTempSetMessage(this.temp, mode != SliderChangeMode.Moving)
                            console.info('value:' + value + 'mode:' + mode.toString());
                        })
                }
            }.height('auto').width("100%").alignItems(HorizontalAlign.Start)

        }
        .height('100%')
        .enableScrollInteraction(this.pageScrollable)
        .align(Alignment.TopStart)
        .backgroundColor('#FCFCFC')

    }
}
