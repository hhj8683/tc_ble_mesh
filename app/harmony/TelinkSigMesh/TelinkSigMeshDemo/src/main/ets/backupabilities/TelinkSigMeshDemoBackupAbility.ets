import { hilog } from '@kit.PerformanceAnalysisKit';
import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { logd } from 'telinksigmeshlib';

export default class TelinkSigMeshDemoBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    logd('onBackup ok');
  }

  async onRestore(bundleVersion: BundleVersion) {
    logd('onRestore ok %{public}s', JSON.stringify(bundleVersion));
  }
}