import { BusinessError } from '@ohos.base';
import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';

const LOG_DOMAIN: number = 0x0000;
const LOG_TAG: string = 'DialectMap';

export default class EntryAbility extends UIAbility {
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (error: BusinessError): void => {
      if (error.code) {
        hilog.error(LOG_DOMAIN, LOG_TAG, 'Failed to load Index. Code: %{public}d', error.code);
        return;
      }
    });
  }
}
