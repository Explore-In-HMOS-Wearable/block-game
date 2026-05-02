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
    PersistentStorage.persistProp('bestScore', 0);
    windowStage.loadContent('pages/Index', (err, data) => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
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
    Logger.info(TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    Logger.info(TAG, '%{public}s', 'Ability onBackground');
  }
}
