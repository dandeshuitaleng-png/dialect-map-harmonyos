import AbilityStage from '@ohos.app.ability.AbilityStage';
import hilog from '@ohos.hilog';

const LOG_DOMAIN: number = 0x0000;
const LOG_TAG: string = 'DialectMap';

export default class DialectMapAbilityStage extends AbilityStage {
  onCreate(): void {
    hilog.info(LOG_DOMAIN, LOG_TAG, 'Ability stage created');
  }
}

