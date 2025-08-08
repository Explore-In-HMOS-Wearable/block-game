import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

const TAG: string = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    Logger.info(TAG, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Splash', (err, data) => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      PersistentStorage.persistProp('bestScore',0);
      if (err.code) {
        Logger.error(TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      Logger.info(TAG, 'testTag', 'Succeeded in loading the content.');
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.setWindowSystemBarEnable([])
      let isLayoutFullScreen = true;
      windowClass.setWindowLayoutFullScreen(isLayoutFullScreen)
        .then(() => {
          Logger.info(TAG, 'testTag', 'Succeeded in setting the window layout to full-screen mode. Data: %{public}s',
            JSON.stringify(data) ?? '');
        })
        .catch((err: BusinessError) => {
          Logger.error(TAG, 'testTag', 'Failed to set the window layout to full-screen mode. Cause: %{public}s',
            JSON.stringify(err) ?? '');
        })
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.error(TAG, 'testTag', '%{public}s', 'Ability onBackground');
  }
}