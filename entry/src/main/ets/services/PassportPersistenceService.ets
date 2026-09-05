import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { fileIo as fs } from '@kit.CoreFileKit';
import { DialectAssessment } from '../models/DialectModels';

const STORE_NAME: string = 'dialect_map_state';
export const PASSPORT_SHARE_IMAGE_NAME: string = '/voice-passport.png';
let passportMutationTail: Promise<void> = Promise.resolve();

export interface SavedPassportState {
  readonly regionName: string;
  readonly dialectName: string;
  readonly dialectBranch: string;
}

export interface PassportLoadResult {
  readonly state?: SavedPassportState;
  readonly failed: boolean;
}

export async function savePassportState(
  context: common.UIAbilityContext,
  assessment: DialectAssessment
): Promise<boolean> {
  return await enqueuePassportMutation(async (): Promise<boolean> => {
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
  });
}

export async function loadPassportState(
  context: common.UIAbilityContext
): Promise<SavedPassportState | undefined> {
  return (await loadPassportStateWithStatus(context)).state;
}

export async function loadPassportStateWithStatus(
  context: common.UIAbilityContext
): Promise<PassportLoadResult> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    const hasPassport = store.getSync('hasPassport', false);
    if (hasPassport !== true) {
      return { failed: false };
    }

    return {
      state: {
        regionName: store.getSync('regionName', '四川') as string,
        dialectName: store.getSync('dialectName', '四川话') as string,
        dialectBranch: store.getSync('dialectBranch', '成渝小片') as string
      },
      failed: false
    };
  } catch (storageError) {
    return { failed: true };
  }
}

export async function clearPassportState(
  context: common.UIAbilityContext
): Promise<boolean> {
  return await enqueuePassportMutation(async (): Promise<boolean> => {
    try {
      const store = await preferences.getPreferences(context, { name: STORE_NAME });
      store.deleteSync('hasPassport');
      store.deleteSync('regionName');
      store.deleteSync('dialectName');
      store.deleteSync('dialectBranch');
      await store.flush();
      return true;
    } catch (storageError) {
      return false;
    }
  });
}

export function clearGeneratedPassportShareImage(
  context: common.UIAbilityContext
): boolean {
  const imagePath = context.cacheDir + PASSPORT_SHARE_IMAGE_NAME;
  try {
    if (fs.accessSync(imagePath)) {
      fs.unlinkSync(imagePath);
    }
    return true;
  } catch (_error) {
    return false;
  }
}

async function enqueuePassportMutation(
  mutation: () => Promise<boolean>
): Promise<boolean> {
  let mutationResult: boolean = false;
  const queuedMutation = passportMutationTail.then(async (): Promise<void> => {
    mutationResult = await mutation();
  });
  passportMutationTail = queuedMutation.catch((): void => {});
  try {
    await queuedMutation;
    return mutationResult;
  } catch (_error) {
    return false;
  }
}

export async function hasSeenFirstRunGuide(
  context: common.UIAbilityContext
): Promise<boolean> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    return store.getSync('hasSeenFirstRunGuide', false) === true;
  } catch (_error) {
    return false;
  }
}

export async function markFirstRunGuideSeen(
  context: common.UIAbilityContext
): Promise<boolean> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    store.putSync('hasSeenFirstRunGuide', true);
    await store.flush();
    return true;
  } catch (_error) {
    return false;
  }
}
