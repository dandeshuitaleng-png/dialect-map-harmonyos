import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { DialectAssessment } from '../models/DialectModels';

const STORE_NAME: string = 'dialect_map_state';

export interface SavedPassportState {
  readonly regionName: string;
  readonly dialectName: string;
  readonly dialectBranch: string;
}

export async function savePassportState(
  context: common.UIAbilityContext,
  assessment: DialectAssessment
): Promise<boolean> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    store.putSync('hasPassport', true);
    store.putSync('regionName', assessment.regionName);
    store.putSync('dialectName', assessment.dialectName);
    store.putSync('dialectBranch', assessment.dialectBranch);
    await store.flush();
    return true;
  } catch (storageError) {
    return false;
  }
}

export async function loadPassportState(
  context: common.UIAbilityContext
): Promise<SavedPassportState | undefined> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    const hasPassport = store.getSync('hasPassport', false);
    if (hasPassport !== true) {
      return undefined;
    }

    return {
      regionName: store.getSync('regionName', '四川') as string,
      dialectName: store.getSync('dialectName', '四川话') as string,
      dialectBranch: store.getSync('dialectBranch', '成渝片') as string
    };
  } catch (storageError) {
    return undefined;
  }
}
