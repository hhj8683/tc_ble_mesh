import { CompositionDataGetMessage, Event, MeshService, num2Hex } from 'telinksigmeshlib';
import { router } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams, SchedulerSettingParams } from '../PageParams';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon } from '../../components/Widgets';
import { Scheduler } from '../../model/Scheduler';
import { CardView } from '../../components/CardView';
import { SchedulerRegister } from '../../model/SchedulerRegister';

const Months = [
    'Jan', 'Feb', 'Mar',
    'Apr', 'May', 'June',
    'July', 'Aug', 'Sep',
    'Oct', 'Nov', 'Dec']

const Weeks = [
    'Monday', 'Tuesday',
    'Wednesday', 'Thursday',
    'Friday', 'Saturday',
    'Sunday']

@Entry
@Component
struct SchedulerListPage {
    @State node?: NodeInfo = undefined
    @State schedulers: Scheduler[] = []

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        this.schedulers = []
        this.schedulers.push(...this.node!.schedulers)
    }

    nodeCpsDataEvtCb = (event: Event) => {

    }

    aboutToDisappear(): void {
    }

    private addScheduler() {
        let params: SchedulerSettingParams = { deviceUuid: this.node!.deviceUUID, schedulerIndex: -1 }
        router.push({ url: "pages/node/SchedulerSettingPage", params })
    }

    @Builder
    getActionView() {
        getCommonIcon($r("app.media.ic_plus"), () => {
            this.addScheduler()
        })
    }

    getRegisterDetail(register: SchedulerRegister) {
        let info = ""
        let year = register.year
        info += `\nYear: ${year == Scheduler.YEAR_ANY ? "Any" : year}`

        let month = register.month
        info += `\nMonth: `

        let head = true;
        for (let i = 0; i < Months.length; i++) {

            if (((month >> i) & 1) == 1) {
                if (!head) {
                    info == '/'
                }
                head = false;
                info += Months[i]
            }
        }

        let day = register.day
        info += `\nDay: ${day == Scheduler.DAY_ANY ? "Any" : day}`


        let hour = register.hour
        info += "\nHour: "
        if (hour == Scheduler.HOUR_ANY) {
            info += "Any"
        } else if (hour == Scheduler.HOUR_RANDOM) {
            info += "Random"
        } else {
            info += hour
        }


        let minute = register.minute
        info += "\nMinute: "
        if (minute == Scheduler.MINUTE_ANY) {
            info += "Any"
        } else if (minute == Scheduler.MINUTE_RANDOM) {
            info += "Random"
        } else if (minute == Scheduler.MINUTE_CYCLE_15) {
            info += "Every 15 minutes"
        } else if (minute == Scheduler.MINUTE_CYCLE_20) {
            info += "Every 20 minutes"
        } else {
            info += minute
        }

        info += "\nSecond: "
        let second = register.second
        if (second == Scheduler.SECOND_ANY) {
            info += "Any"
        } else if (second == Scheduler.SECOND_RANDOM) {
            info += "Random"
        } else if (second == Scheduler.SECOND_CYCLE_15) {
            info += "Every 15 seconds"
        } else if (second == Scheduler.SECOND_CYCLE_20) {
            info += "Every 20 seconds"
        } else {
            info += second
        }


        info += "\nWeek: "
        let week = register.week

        let wHead = true;
        for (let i = 0; i < Weeks.length; i++) {

            if (((week >> i) & 1) == 1) {
                if (!wHead) {
                    info += "/"
                }
                wHead = false;
                info += Weeks[i]
            }
        }

        info += "\nAction: "
        let action = register.action
        if (action == Scheduler.ACTION_OFF) {
            info += "Off"
        } else if (action == Scheduler.ACTION_ON) {
            info += "On"
        } else if (action == Scheduler.ACTION_NO) {
            info += "NO"
        } else if (action == Scheduler.ACTION_SCENE) {
            info += `Scene -- ${register.sceneId}`
        }

        return info
    }

    @Builder
    getSchedulerItem(sched: Scheduler) {
        CardView({
            cdPadding: 16,
            cdMargin: 8,
        }) {
            Column({ space: 4 }) {
                Row() {
                    Text(`Index : 0x${num2Hex(sched.index, 2)}\nElement : ${sched.elementOffset}`)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                    getCommonIcon($r('app.media.ic_edit'), undefined, Color.Gray)
                }.width('100%')

                Text(this.getRegisterDetail(sched.register)).fontSize(12).fontStyle(FontStyle.Italic)
            }.width('100%').alignItems(HorizontalAlign.Start)
        }
    }

    @Builder
    getEmptyView() {
        Column() {
            getCommonIcon($r('app.media.ic_sad', undefined, $r('app.color.primary')))
            Text('List Empty')
            Button('ADD').buttonStyle(ButtonStyleMode.TEXTUAL).onClick(() => {
                this.addScheduler()
            })
        }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    }

    build() {
        Column() {
            TitleBar({
                title: "Scheduler List",
                showNavigation: true,
                showAction: true,
                actionView: () => {
                    this.getActionView()
                }
            })
            if (this.schedulers.length > 0) {
                Scroll() {
                    Column() {
                        ForEach(this.schedulers, (item: Scheduler, index: number) => {
                            this.getSchedulerItem(item)
                        })
                    }.height('auto').justifyContent(FlexAlign.Start)
                }.layoutWeight(1).align(Alignment.TopStart).padding(8)
            } else {
                this.getEmptyView()
            }

            // .backgroundColor(Color.Blue)
        }.width('100%').height("100%")
    }
}
