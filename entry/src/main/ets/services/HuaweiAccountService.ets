import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';

const AUTH_STORE: string = 'xiangyin_huawei_account';
const SESSION_KEY: string = 'current_session';
const HUAWEI_LOGIN_URL: string = 'https://hnp666.me/functions/v1/huawei-login';

class HuaweiLoginRequestOptions {
  method: http.RequestMethod = http.RequestMethod.POST;
  header: Record<string, string> = {
    'Content-Type': 'application/json'
  };
  extraData: string = '';
  connectTimeout: number = 15000;
  readTimeout: number = 20000;
}

/** A local app session created only after Account Kit returns a Huawei ID. */
export class HuaweiAccountSession {
  userId: string = '';
  displayName: string = '鸿蒙用户';
  accessToken: string = '';
  expiresAt: number = 0;
}

function parseServerSession(raw: string): HuaweiAccountSession {
  const value = JSON.parse(raw) as Record<string, Object>;
  const userId = typeof value['userId'] === 'string' ? value['userId'].trim() : '';
  const accessToken = typeof value['accessToken'] === 'string' ? value['accessToken'].trim() : '';
  const expiresAt = typeof value['expiresAt'] === 'number' ? value['expiresAt'] : 0;
  if (userId.length === 0 || accessToken.length === 0 || expiresAt <= Date.now()) {
    throw new Error('invalid_huawei_server_session');
  }
  const session = new HuaweiAccountSession();
  session.userId = userId;
  session.accessToken = accessToken;
  session.expiresAt = expiresAt;
  session.displayName = typeof value['displayName'] === 'string' && value['displayName'].trim().length > 0
    ? value['displayName'].trim() : '鸿蒙用户';
  return session;
}

export async function signInWithHuaweiAccount(
  context: common.UIAbilityContext,
  authorizationCode: string
): Promise<HuaweiAccountSession> {
  if (authorizationCode.trim().length === 0) {
    throw new Error('华为帐号未返回授权码');
  }
  const request = http.createHttp();
  let session: HuaweiAccountSession;
  try {
    const options = new HuaweiLoginRequestOptions();
    options.extraData = JSON.stringify({ authorizationCode: authorizationCode.trim() });
    const response = await request.request(HUAWEI_LOGIN_URL, options);
    if (response.responseCode < 200 || response.responseCode >= 300) {
      throw new Error(`华为帐号服务器登录失败（HTTP ${response.responseCode}）`);
    }
    session = parseServerSession(response.result as string);
  } finally {
    request.destroy();
  }
  const store = await preferences.getPreferences(context, { name: AUTH_STORE });
  await store.put(SESSION_KEY, JSON.stringify(session));
  await store.flush();
  return session;
}

export async function restoreHuaweiAccountSession(
  context: common.UIAbilityContext
): Promise<HuaweiAccountSession | undefined> {
  try {
    const store = await preferences.getPreferences(context, { name: AUTH_STORE });
    const raw = await store.get(SESSION_KEY, '') as string;
    if (raw.length === 0) return undefined;
    return parseServerSession(raw);
  } catch (_error) {
    return undefined;
  }
}
