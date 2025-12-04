import { Event, EventBus, logd } from 'telinksigmeshlib';
import { router, ToolBarOptions } from '@kit.ArkUI';
import { MeshInfoService } from '../../model/MeshInfoService';
import { NodeInfo } from '../../model/NodeInfo';
import { NodeParams } from '../PageParams';
import { NodeStatusChangedEvent } from '../../model/NodeStatusChangedEvent';
import { TitleBar } from '../../components/TitleBar';
import { getCommonIcon } from '../../components/Widgets';
import NodeControlSubPage from './NodeControlSubPage';
import NodeGroupingSubPage from './NodeGroupingSubPage';
import NodeSettingSubPage from './NodeSettingSubPage';

// contains control, group, setting

const TAB_TITLES: Array<string> = [
    "CONTROL",
    "GROUP",
    "SETTINGS"
]

@Entry
@Component
struct NodeMainPage {
    @State node?: NodeInfo = undefined
    @State titleActions: ToolBarOptions = new ToolBarOptions()
    @State fontColor: Resource = $r('app.color.nav_btn_normal') //   '#182431'
    @State selectedFontColor: Resource = $r("app.color.primary")
    @State currentIndex: number = 0
    @State selectedIndex: number = 0
    private controller: TabsController = new TabsController()

    async aboutToAppear() {
        let deviceUuid = (router.getParams() as NodeParams).deviceUuid
        // logd("NodeMainPage # device uuid = " + deviceUuid)
        this.node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByUUID(deviceUuid)
        // logd("NodeMainPage # device name = " + this.node?.name)

        EventBus.getInstance().on(NodeStatusChangedEvent.EVENT_TYPE_NODE_STATUS_CHANGED, this.nodeStateChangeEvtCb)

    }

    nodeStateChangeEvtCb = (event: Event) => {

    }

    onPageShow(): void {
        logd("NodeMainPage # onPageShow")
    }

    onPageHide(): void {
        logd("NodeMainPage # onPageHide")
    }

    @Builder
    tabBuilder(index: number) {
        Column() {
            Text(TAB_TITLES[index])
                .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
                .fontSize(16)
                .fontWeight(this.selectedIndex === index ? 500 : 400)
                .align(Alignment.Center)
        }
        .height(48)
        .justifyContent(FlexAlign.Center)
        .border({ width: { bottom: this.selectedIndex === index ? 2 : 0 }, color: this.selectedFontColor })
        .width('100%')
    }

    @Builder
    indexNavigationBuilder() {
        Image($r("app.media.ic_arrow_left"))
            .width(30)
            .height(50)
            .fillColor(Color.White)
            .objectFit(ImageFit.Contain)
            .margin({ left: 10 })
            .onClick(() => {
                router.back()
            })
    }

    @Builder
    geNavView() {
        getCommonIcon($r("app.media.ic_arrow_left"), () => {
            router.back()
        })
    }

    build() {
        Flex({ direction: FlexDirection.Column }) {
            TitleBar({
                title: "Device Setting",
                showNavigation: true,
                showAction: false,
                navigationView: () => {
                    this.geNavView()
                },
            })
            Tabs({ barPosition: BarPosition.Start, index: this.currentIndex, controller: this.controller }) {
                TabContent() {
                    NodeControlSubPage({ node: this.node })
                }
                .tabBar(this.tabBuilder(0))

                TabContent() {
                    NodeGroupingSubPage({ node: this.node })
                }.tabBar(this.tabBuilder(1))

                TabContent() {
                    NodeSettingSubPage({ node: this.node })
                }.tabBar(this.tabBuilder(2))
            }
            .scrollable(false)
            .vertical(false)
            .barMode(BarMode.Fixed)
            .barWidth("100%")
            .barHeight(48)
            .animationDuration(0)
            .onChange((index: number) => {
                this.currentIndex = index
                this.selectedIndex = index
            })
            .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
                if (index === targetIndex) {
                    return
                }

                this.selectedIndex = targetIndex
            })
            .width('100%')
            .layoutWeight(1)
        }.width('100%').height("100%")
    }
}
