import { router, ToolBarOptions } from '@kit.ArkUI';
import GroupSubPage from './GroupSubPage';
import DeviceSubPage from './DeviceSubPage';
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
    ADDRESS_BROADCAST,
    AutoConnectEvent,
    AutoConnectParameters,
    Event,
    EventBus,
    logd,
    MeshService,
    OnOffGetMessage
} from 'telinksigmeshlib';
import NetworkSubPage from './NetworkSubPage';
import SettingSubPage from './SettingSubPage';
import { MeshInfoService } from '../../model/MeshInfoService';
import { showConfirmDialog, WaitingDialog } from '../../components/Dialogs';

const TAB_TITLES: Array<string> = [
    "Device",
    "Group",
    "Network",
    "Setting"
]

const TAB_ICONS: Array<Resource> = [
    $r("app.media.ic_bulb"),
    $r("app.media.ic_group"),
    $r("app.media.ic_network"),
    $r("app.media.ic_setting"),
]

const APP_PERMISSIONS: Permissions[] =
    ['ohos.permission.ACCESS_BLUETOOTH',
        'ohos.permission.READ_MEDIA',
        'ohos.permission.WRITE_MEDIA'];

@Entry
@Component
struct MainPage {
    @State titleActions: ToolBarOptions = new ToolBarOptions()
    @State fontColor: Resource = $r('app.color.nav_btn_normal') //   '#182431'
    @State selectedFontColor: Resource = $r("app.color.primary")
    @State currentIndex: number = 0
    @State selectedIndex: number = 0
    private controller: TabsController = new TabsController()
    private isPermissionChecked = false

    aboutToAppear(): void {
        this.checkPermissions();
        EventBus.getInstance().on(AutoConnectEvent.EVENT_TYPE_AUTO_CONNECT_LOGIN, this.onLoginSuccess)

        WaitingDialog.init(this.getUIContext())
    }

    onLoginSuccess = (event: Event) => {
        let setMessage = OnOffGetMessage.getSimple(ADDRESS_BROADCAST,
            MeshInfoService.getInstance().getCurrentMesh().getDefaultAppKeyIndex(), 0)
        MeshService.getInstance().sendMeshMessage(setMessage)
    }

    onPageShow(): void {
        logd("main page # onPageShow")
        if (this.isPermissionChecked) {
            MeshService.getInstance().autoConnect(new AutoConnectParameters())
        }
    }

    onPageHide(): void {
        logd("main page # onPageHide")
    }

    onPermissionChecked() {
        this.isPermissionChecked = true
    }

    onPermissionDenied() {
        this.isPermissionChecked = false
        showConfirmDialog(this.getUIContext(), 'permission check err')
    }

    async checkPermissionGrant(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

        // 获取应用程序的accessTokenID
        let tokenId: number = 0;
        try {
            let bundleInfo: bundleManager.BundleInfo =
                await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
            let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
            tokenId = appInfo.accessTokenId;
        } catch (error) {
            const err: BusinessError = error as BusinessError;
            console.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
        }
        try {
            grantStatus = await atManager.checkAccessToken(tokenId, permission);
        } catch (error) {
            const err: BusinessError = error as BusinessError;
            console.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
        }
        return grantStatus;
    }

    async checkPermissions(): Promise<void> {
        let permissionChecked = true
        for (let per of APP_PERMISSIONS) {
            if (await this.checkPermissionGrant(per) != abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
                permissionChecked = false
                break
            }
        }

        console.log("permission status ", permissionChecked)
        if (!permissionChecked) {
            this.reqPermissionsFromUser(APP_PERMISSIONS);
            return
        }
        this.onPermissionChecked()
    }

    // 使用UIExtensionAbility：将common.UIAbilityContext 替换为common.UIExtensionContext
    reqPermissionsFromUser(permissions: Array<Permissions>): void {
        let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
        // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
        let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
        atManager.requestPermissionsFromUser(context, permissions).then((data) => {
            let grantStatus: number[] = data.authResults
            let length: number = grantStatus.length;
            for (let i = 0; i < length; i++) {
                if (grantStatus[i] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
                    logd("permission GRANTED : " + APP_PERMISSIONS[i])
                } else {
                    logd("permission DENIED : " + APP_PERMISSIONS[i])
                    // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
                }
            }
            this.onPermissionChecked()
            // 授权成功
        }).catch((err: BusinessError) => {
            console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
        })
    }

    @Builder
    tabBuilder(index: number) {
        Column() {
            Image(TAB_ICONS[index])
                .width(24)
                .height(24)
                .fillColor(this.selectedIndex == index ? this.selectedFontColor : this.fontColor)
                .margin({ top: 4 })

            Text(TAB_TITLES[index])
                .fontColor(this.selectedIndex === index ? this.selectedFontColor : this.fontColor)
                .fontSize(12)
                .fontWeight(this.selectedIndex === index ? 500 : 400)
                .lineHeight(16)
                .margin({ top: 2, bottom: 2 })
        }.width('100%')
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

    build() {
        Flex({ direction: FlexDirection.Column }) {
            Tabs({ barPosition: BarPosition.End, index: this.currentIndex, controller: this.controller }) {
                TabContent() {
                    // Column().width('100%').height('100%').backgroundColor(Color.Yellow)
                    DeviceSubPage()
                }.tabBar(this.tabBuilder(0))
                .border({
                    width: { bottom: 0.2 },
                    color: Color.Grey
                })

                TabContent() {
                    // Column().width('100%').height('100%').backgroundColor(Color.Yellow)
                    GroupSubPage()
                }.tabBar(this.tabBuilder(1))
                .border({
                    width: { bottom: 0.2 },
                    color: Color.Grey
                })

                TabContent() {
                    // Column().width('100%').height('100%').backgroundColor(Color.Yellow)
                    NetworkSubPage()
                }.tabBar(this.tabBuilder(2))
                .border({
                    width: { bottom: 0.2 },
                    color: Color.Grey
                })

                TabContent() {
                    // Column().width('100%').height('100%').backgroundColor(Color.Yellow)
                    SettingSubPage()
                }.tabBar(this.tabBuilder(3))
                .border({
                    width: { bottom: 0.2 },
                    color: Color.Grey
                })
            }
            .scrollable(false)
            .vertical(false)
            .barMode(BarMode.Fixed)
            .barWidth("100%")

            .barHeight(56)
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
