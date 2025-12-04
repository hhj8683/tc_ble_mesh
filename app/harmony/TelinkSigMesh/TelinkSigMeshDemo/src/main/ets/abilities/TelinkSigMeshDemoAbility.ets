import { AbilityConstant, common, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ThemeControl, window } from '@kit.ArkUI';
import {
    bytesToHexString,
    Event,
    EventBus,
    logd,
    MeshService,
    OnOffStatusMessage,
    StatusNotificationEvent,
    NetworkInfoUpdateEvent,
    MeshEvent,
    logw
} from 'telinksigmeshlib';
import { MeshInfoService } from '../model/MeshInfoService';
import { MeshInfo } from '../model/MeshInfo';
import { PreferencesHelper } from '../utils/PreferencesHelper';
import { NodeStatusChangedEvent } from '../model/NodeStatusChangedEvent';
import { OnlineState } from '../model/OnlineState';

export default class TelinkSigMeshDemoAbility extends UIAbility {
    static globalContext: common.Context

    async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
        this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
        logd('Ability onCreate')
        TelinkSigMeshDemoAbility.globalContext = this.context.getApplicationContext()
    }

    private async loadMeshInfo() {
        MeshInfoService.getInstance().loadAll()
        let allMeshList = MeshInfoService.getInstance().getAll()
        logd(`all mesh : count = ${allMeshList.length}`)
        let id = await PreferencesHelper.getSelectedMeshId(this.context);
        logd(`current mesh id = ${id}`)
        let meshInfo = MeshInfoService.getInstance().getById(id)
        if (!meshInfo) {
            logd('mesh not exists => create new mesh')
            meshInfo = MeshInfo.createNewMesh(this.context)
            MeshInfoService.getInstance().addMeshInfo(meshInfo)
            PreferencesHelper.setSelectedMeshId(this.context, meshInfo.id);
        } else {
            logd('load local mesh success')
        }
        for (let node of meshInfo.nodes) {
            node.onlineState = OnlineState.OFFLINE
        }
        MeshInfoService.getInstance().resetCurrentMesh(meshInfo)
        logd(`mesh = ${JSON.stringify(meshInfo)}`)
        MeshService.getInstance().init((event: Event) => {
            this.handleEvent(event);
            EventBus.getInstance().emit(event)
        })
        MeshService.getInstance().setupMeshNetwork(meshInfo.convertToConfiguration())
    }

    public static getContext() {
        return TelinkSigMeshDemoAbility.globalContext
    }

    private handleEvent(event: Event) {
        let eventType = event.type
        if (eventType == NetworkInfoUpdateEvent.EVENT_TYPE_NETWORK_INFO_UPDATE) {
            let updEvent = event as NetworkInfoUpdateEvent
            MeshInfoService.getInstance().updateNetworkInfo(updEvent.sequenceNumber, updEvent.ivIndex)
        } else if (eventType == OnOffStatusMessage.STATUS_NAME) {
            let stEvent = event as StatusNotificationEvent

            let status = stEvent.notificationMessage.statusMessage! as OnOffStatusMessage
            let onOff = status.isComplete ? status.targetOnOff : status.presentOnOff
            let src = stEvent.notificationMessage.src
            let node = MeshInfoService.getInstance().getCurrentMesh().getDeviceByMeshAddress(src)
            if (node) {
                if (node.onlineState != onOff) {
                    node.onlineState = onOff
                    EventBus.getInstance().emit(new NodeStatusChangedEvent(node))
                }
            }
        } else if (eventType == MeshEvent.EVENT_TYPE_DISCONNECTED) {
            for (let node of MeshInfoService.getInstance().getCurrentMesh().nodes) {
                node.setOnlineState(OnlineState.OFFLINE)
            }
        }
    }

    onDestroy(): void {
        logd('Ability onDestroy');
    }

    async onWindowStageCreate(windowStage: window.WindowStage) {
        // Main window is created, set main page for this ability
        logd('Ability onWindowStageCreate');

        await this.loadMeshInfo()
        windowStage.loadContent('pages/home/MainPage', (err) => {
            if (err.code) {
                hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s',
                    JSON.stringify(err) ?? '');
                return;
            }
            logd('Succeeded in loading the content.');
        });


        let mainWindow = windowStage.getMainWindowSync();
        // mainWindow.setWindowSystemBarEnable(["status"]);
        // let res = $r('app.color.primary')
        // let primaryColor = this.context.resourceManager.getStringSync(res.id)

        let res = $r('app.color.primary')
        let primaryColor = this.context.resourceManager.getColorSync(res.id)
        logw("primaryColor : " + primaryColor.toString(16))
        mainWindow.setWindowSystemBarProperties({
            statusBarColor: `#${primaryColor.toString(16)}`,
            statusBarContentColor: '#ffffffff',
        })
        // ThemeControl.setDefaultTheme()
    }

    onWindowStageDestroy(): void {
        // Main window is destroyed, release UI related resources
        logd('Ability onWindowStageDestroy');
    }

    onForeground(): void {
        // Ability has brought to foreground
        logd('Ability onForeground');
    }

    onBackground(): void {
        // Ability has back to background
        logd('Ability onBackground');
    }
}