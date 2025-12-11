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
import { NodeParams, SchedulerSettingParams } from '../PageParams';
import { NodeStatusChangedEvent } from '../../model/NodeStatusChangedEvent';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon, toastMessage } from '../../components/Widgets';
import NodeControlSubPage from './NodeControlSubPage';
import NodeGroupingSubPage from './NodeGroupingSubPage';
import NodeSettingSubPage from './NodeSettingSubPage';
import { Scheduler } from '../../model/Scheduler';
import { CardView } from '../../components/CardView';
import { SchedulerRegister } from '../../model/SchedulerRegister';
import { showConfirmDialog } from '../../components/Dialogs';

interface ItemSelection {
    itemName: string
    selected: boolean
}

const YEAR_TYPE_ANY = 0
const YEAR_TYPE_CUSTOM = 1

const DAY_TYPE_ANY = 0
const DAY_TYPE_CUSTOM = 1

const HOUR_TYPE_ANY = 0
const HOUR_TYPE_RANDOM = 1
const HOUR_TYPE_CUSTOM = 2

const MINUTE_TYPE_ANY = 0
const MINUTE_TYPE_CYCLE_15 = 1
const MINUTE_TYPE_CYCLE_20 = 2
const MINUTE_TYPE_RANDOM = 3
const MINUTE_TYPE_CUSTOM = 4

const SECOND_TYPE_ANY = 0
const SECOND_TYPE_CYCLE_15 = 1
const SECOND_TYPE_CYCLE_20 = 2
const SECOND_TYPE_RANDOM = 3
const SECOND_TYPE_CUSTOM = 4


const MONTHS: string[] = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
const MONTH_ALL = 0xFFF

const WEEKS: string[] = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
const WEEK_ALL = 0x7F

const ACTION_TYPE_OFF = 0
const ACTION_TYPE_ON = 1
const ACTION_TYPE_NO_ACTION = 2
const ACTION_TYPE_SCENE_RECALL = 3

@Entry
@Component
struct SchedulerSettingPage {
    @State node?: NodeInfo = undefined
    @State index: number = 0
    @State selectedElementIndex: number = 0
    schedElements: SelectOption[] = []
    // is editing selected scheduler
    private isEditMode: boolean = false
    // year
    @State yearType: number = 0
    @State yearInput: string = ""
    // month
    @State monthSelection: number = 0
    // day
    @State dayType: number = 0
    @State dayInput: string = ""
    // hour
    @State hourType: number = 0
    @State hourInput: string = ""
    // minute
    @State minuteType: number = 0
    @State minuteInput: string = ""
    // second
    @State secondType: number = 0
    @State secondInput: string = ""
    // week
    @State weekSelection: number = 0
    // action
    @State actionType: number = 0
    @State actionSceneIdInput: string = ""

    async aboutToAppear() {
        let params = router.getParams() as SchedulerSettingParams
        let deviceUuid = params.deviceUuid
        let schedulerIndex = params.schedulerIndex
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        if (schedulerIndex == -1) {
            // add new scheduler
            this.isEditMode = true
            this.index = this.node!.allocSchedulerIndex()
            if (this.index == -1) {
                showConfirmDialog(this.getUIContext(), 'Warning', 'No Available Scheduler Index', () => {
                    router.back()
                })
                return
            }
        } else {
            // update selected scheduler
            this.index = schedulerIndex
        }
        let eles = this.node!.getElementsByModel(MeshSigModel.SIG_MD_SCHED_S)
        let adr = this.node!.meshAddress
        eles = [adr + 1, adr + 2] //  for test
        if (!eles || eles.length == 0) {
            showConfirmDialog(this.getUIContext(), 'Warning', 'Not Support Scheduler', () => {
                router.back()
            })
            return
        }

        this.schedElements = []
        eles.forEach((val) => {
            this.schedElements.push({ value: `element ${val - adr}(address=0x${num2Hex(val, 4)})` })
        })
    }

    evtCb = (event: Event) => {

    }

    aboutToDisappear(): void {
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            MeshService.getInstance().sendMeshMessage(new CompositionDataGetMessage(this.node!.meshAddress))
        })
    }

    @Builder
    getTitleText(title: string) {
        Text(title).fontSize(15).fontWeight(FontWeight.Bold).fontColor(Color.Black)
    }

    @Builder
    indexItem() {
        this.getTitleText("Index : " + this.index)
    }

    @Builder
    elementItem() {
        Row() {
            this.getTitleText("Element : " + this.index)
            Select(this.schedElements)
                .value(this.schedElements[this.selectedElementIndex].value)
                .selected(this.selectedElementIndex)
                .arrowPosition(ArrowPosition.END)
                .onSelect((index: number, value: string | undefined) => {
                    this.selectedElementIndex = index
                })
        }
    }

    @Builder
    yearItem() {
        this.getTitleText("Year : ")
        Row() {
            Radio({
                value: 'year_any', group: 'year',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.yearType == YEAR_TYPE_ANY)
                .height(24)
                .width(24)

            Text('Any').fontSize(13)
        }.onClick(() => {
            this.yearType = YEAR_TYPE_ANY
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'year_custom', group: 'year',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.yearType == YEAR_TYPE_CUSTOM)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.yearType = YEAR_TYPE_CUSTOM
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.yearInput, placeholder: "year(2000-2099)" })
            .enabled(this.yearType == YEAR_TYPE_CUSTOM)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    monthItem() {
        this.getTitleText("Month : ")
        Row() {
            Checkbox().select(this.monthSelection == MONTH_ALL).shape(CheckBoxShape.ROUNDED_SQUARE)
            Text('Select ALL')
        }.justifyContent(FlexAlign.Start)
        .hitTestBehavior(HitTestMode.Block)
        .onClick(() => {
            if (this.monthSelection == MONTH_ALL) {
                this.monthSelection = 0
            } else {
                this.monthSelection = MONTH_ALL
            }
        })

        Grid() {
            ForEach(MONTHS, (month: string, index) => {
                GridItem() {
                    Row() {
                        Checkbox().select((this.monthSelection & (1 << index)) != 0)
                            .shape(CheckBoxShape.ROUNDED_SQUARE)
                        Text(month)
                    }.hitTestBehavior(HitTestMode.Block).onClick(() => {
                        this.monthSelection ^= (1 << index)
                    })
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                }
            })
        }.columnsTemplate('1fr 1fr 1fr 1fr')
    }

    @Builder
    dayItem() {
        this.getTitleText("Day : ")
        Row() {
            Radio({
                value: 'day_any', group: 'day',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.dayType == DAY_TYPE_ANY)
                .height(24)
                .width(24)
            Text('Any').fontSize(13)
        }.onClick(() => {
            this.dayType = DAY_TYPE_ANY
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'day_custom', group: 'day',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.dayType == DAY_TYPE_CUSTOM)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.dayType = DAY_TYPE_CUSTOM
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.dayInput, placeholder: "day(1-31)" })
            .enabled(this.dayType == DAY_TYPE_CUSTOM)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    hourItem() {
        this.getTitleText("Hour : ")
        Row() {
            Radio({
                value: 'hour_any', group: 'hour',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.hourType == HOUR_TYPE_ANY)
                .height(24)
                .width(24)
            Text('Any').fontSize(13)
        }.onClick(() => {
            this.hourType = HOUR_TYPE_ANY
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'hour_random', group: 'hour',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.hourType == HOUR_TYPE_RANDOM)
                .height(24)
                .width(24)
            Text('Once a day(at a random hour)').fontSize(13)
        }.onClick(() => {
            this.hourType = HOUR_TYPE_RANDOM
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'hour_custom', group: 'hour',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.hourType == HOUR_TYPE_CUSTOM)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.hourType = HOUR_TYPE_CUSTOM
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.hourInput, placeholder: "hour(0-23)" })
            .enabled(this.hourType == HOUR_TYPE_CUSTOM)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    minuteItem() {
        this.getTitleText("Minute : ")
        Row() {
            Radio({
                value: 'minute_any', group: 'minute',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.minuteType == MINUTE_TYPE_ANY)
                .height(24)
                .width(24)
            Text('Any').fontSize(13)
        }.onClick(() => {
            this.minuteType = MINUTE_TYPE_ANY
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'minute_circle_15', group: 'minute',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.minuteType == MINUTE_TYPE_CYCLE_15)
                .height(24)
                .width(24)
            Text('Every 15 minutes(0, 15, 30, 45)').fontSize(13)
        }.onClick(() => {
            this.minuteType = MINUTE_TYPE_CYCLE_15
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'minute_circle_20', group: 'minute',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.minuteType == MINUTE_TYPE_CYCLE_20)
                .height(24)
                .width(24)
            Text('Every 20 minutes(0, 20, 40)').fontSize(13)
        }.onClick(() => {
            this.minuteType = MINUTE_TYPE_CYCLE_20
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'minute_random', group: 'minute',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.minuteType == MINUTE_TYPE_RANDOM)
                .height(24)
                .width(24)
            Text('Once a day(at a random minute)').fontSize(13)
        }.onClick(() => {
            this.minuteType = MINUTE_TYPE_RANDOM
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'minute_custom', group: 'minute',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.minuteType == MINUTE_TYPE_CUSTOM)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.minuteType = MINUTE_TYPE_CUSTOM
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.minuteInput, placeholder: "minute(0-59)" })
            .enabled(this.minuteType == MINUTE_TYPE_CUSTOM)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    secondItem() {
        this.getTitleText("Second : ")
        Row() {
            Radio({
                value: 'second_any', group: 'second',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.secondType == SECOND_TYPE_ANY)
                .height(24)
                .width(24)
            Text('Any').fontSize(13)
        }.onClick(() => {
            this.secondType = SECOND_TYPE_ANY
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'second_circle_15', group: 'second',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.secondType == SECOND_TYPE_CYCLE_15)
                .height(24)
                .width(24)
            Text('Every 15 seconds(0, 15, 30, 45)').fontSize(13)
        }.onClick(() => {
            this.secondType = SECOND_TYPE_CYCLE_15
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'second_circle_20', group: 'second',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.secondType == SECOND_TYPE_CYCLE_20)
                .height(24)
                .width(24)
            Text('Every 20 seconds(0, 20, 40)').fontSize(13)
        }.onClick(() => {
            this.secondType = SECOND_TYPE_CYCLE_20
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'second_random', group: 'second',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.secondType == SECOND_TYPE_RANDOM)
                .height(24)
                .width(24)
            Text('Once a day(at a random second)').fontSize(13)
        }.onClick(() => {
            this.secondType = SECOND_TYPE_RANDOM
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'second_custom', group: 'second',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.secondType == SECOND_TYPE_CUSTOM)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.secondType = SECOND_TYPE_CUSTOM
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.secondInput, placeholder: "second(0-59)" })
            .enabled(this.secondType == SECOND_TYPE_CUSTOM)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    actionItem() {
        this.getTitleText("Action : ")
        Row() {
            Radio({
                value: 'action_off', group: 'action',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.actionType == ACTION_TYPE_OFF)
                .height(24)
                .width(24)
            Text('Off').fontSize(13)
        }.onClick(() => {
            this.actionType = ACTION_TYPE_OFF
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'action_on', group: 'action',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.actionType == ACTION_TYPE_ON)
                .height(24)
                .width(24)
            Text('On').fontSize(13)
        }.onClick(() => {
            this.actionType = ACTION_TYPE_ON
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'action_no_action', group: 'action',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.actionType == ACTION_TYPE_NO_ACTION)
                .height(24)
                .width(24)
            Text('No action').fontSize(13)
        }.onClick(() => {
            this.actionType = ACTION_TYPE_NO_ACTION
        }).hitTestBehavior(HitTestMode.Block)

        Row() {
            Radio({
                value: 'action_scene_recall', group: 'action',
                indicatorType: RadioIndicatorType.TICK
            }).checked(this.actionType == ACTION_TYPE_SCENE_RECALL)
                .height(24)
                .width(24)
            Text('Custom').fontSize(13)
        }.onClick(() => {
            this.actionType = ACTION_TYPE_SCENE_RECALL
        }).hitTestBehavior(HitTestMode.Block)

        TextInput({ text: $$this.actionSceneIdInput, placeholder: "scene id" })
            .enabled(this.actionType == ACTION_TYPE_SCENE_RECALL)
            .margin({ left: 16 })
            .type(InputType.Number)
    }

    @Builder
    weekItem() {
        this.getTitleText("Week : ")
        Row() {
            Checkbox().select(this.weekSelection == WEEK_ALL)
                .shape(CheckBoxShape.ROUNDED_SQUARE)
            Text('Select ALL')
        }.justifyContent(FlexAlign.Start)
        .onClick(() => {
            if (this.weekSelection == WEEK_ALL) {
                this.weekSelection = 0
            } else {
                this.weekSelection = WEEK_ALL
            }
        }).hitTestBehavior(HitTestMode.Block)

        Grid() {
            ForEach(WEEKS, (week: string, index) => {
                GridItem() {
                    Row() {
                        Checkbox().select((this.weekSelection & (1 << index)) != 0)
                            .shape(CheckBoxShape.ROUNDED_SQUARE)
                        Text(week)
                    }.onClick(() => {
                        this.weekSelection ^= (1 << index)
                    }).hitTestBehavior(HitTestMode.Block)
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                }
            })
        }.columnsTemplate('1fr 1fr 1fr')
    }

    build() {
        Column() {
            TitleBar({
                title: "Scheduler Setting",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })
            if (this.schedElements.length != 0) {
                Scroll() {
                    Column() {
                        this.indexItem()
                        this.elementItem()
                        this.yearItem()
                        this.monthItem()
                        this.dayItem()
                        this.hourItem()
                        this.minuteItem()
                        this.secondItem()
                        this.weekItem()
                        this.actionItem()
                    }.height('auto').justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start)
                }.layoutWeight(1).align(Alignment.TopStart).padding(8)
            } else {
                Text('not support scheduler')
            }
        }.width('100%').height("100%")
    }
}
