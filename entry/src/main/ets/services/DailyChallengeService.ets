import { http } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { DailyChallengeProgress, DailyDialectChallenge, LicensedDialectAudio } from '../models/DialectModels';
import { backendUrl } from './AlibabaCloudConfig';

const CHALLENGE_URL: string = backendUrl('/v1/daily-dialect-challenge');
const STORE_NAME: string = 'dialect_map_state';
const PROGRESS_KEY: string = 'daily_challenge_progress';

class ChallengeRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET;
  header: Record<string, string> = {
    'Content-Type': 'application/json'
  };
  connectTimeout: number = 15000;
  readTimeout: number = 20000;
}

function text(value: Object | undefined): string {
  return typeof value === 'string' ? value.trim() : '';
}

function validHttps(value: string): boolean {
  return value.indexOf('https://') === 0;
}

function progressDay(): string {
  const date = new Date();
  const year = date.getFullYear().toString();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  return year + '-' + month + '-' + day;
}

function parseChallenge(raw: string): DailyDialectChallenge {
  const value = JSON.parse(raw) as Record<string, Object>;
  const audioRaw = value['audio'] as Record<string, Object>;
  const answersRaw = value['answers'];
  const answers = Array.isArray(answersRaw) ? answersRaw
    .filter((item: Object): boolean => typeof item === 'string' && item.trim().length > 0)
    .map((item: Object): string => String(item).trim()).slice(0, 8) : [];
  const audio: LicensedDialectAudio = {
    recordingId: text(audioRaw?.['recording_id']),
    dialectName: text(audioRaw?.['dialect_name']),
    attributionText: text(audioRaw?.['attribution_text']),
    speakerConsentVersion: text(audioRaw?.['speaker_consent_version']),
    licenseName: text(audioRaw?.['license_name']),
    licenseUrl: text(audioRaw?.['license_url']),
    sourceUrl: text(audioRaw?.['source_url']),
    audioUrl: text(audioRaw?.['audio_url']),
    expiresAt: text(audioRaw?.['expires_at'])
  };
  const result: DailyDialectChallenge = {
    id: text(value['id']), kindLabel: text(value['kind_label']), icon: text(value['icon']),
    title: text(value['title']), instruction: text(value['instruction']), answers,
    correctAnswer: text(value['correct_answer']), audio
  };
  if (result.id.length === 0 || result.title.length === 0 || result.answers.indexOf(result.correctAnswer) < 0 ||
    audio.recordingId.length === 0 || audio.attributionText.length === 0 || audio.speakerConsentVersion.length === 0 ||
    !validHttps(audio.audioUrl) || !validHttps(audio.sourceUrl) || !validHttps(audio.licenseUrl) ||
    Number.isNaN(Date.parse(audio.expiresAt)) || Date.parse(audio.expiresAt) <= Date.now()) {
    throw new Error('今日语料未通过来源、授权或有效期校验');
  }
  return result;
}

export async function fetchDailyDialectChallenge(): Promise<DailyDialectChallenge> {
  if (CHALLENGE_URL.length === 0) {
    throw new Error('阿里云今日挑战服务尚未配置');
  }
  const request = http.createHttp();
  try {
    const response = await request.request(CHALLENGE_URL, new ChallengeRequestOptions());
    if (response.responseCode === 404) throw new Error('今日暂无已审核、授权且有效的真人语料');
    if (response.responseCode < 200 || response.responseCode >= 300) throw new Error('今日挑战暂时不可用');
    return parseChallenge(response.result as string);
  } finally {
    request.destroy();
  }
}

export async function loadDailyChallengeProgress(context: common.UIAbilityContext): Promise<DailyChallengeProgress> {
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    const raw = store.getSync(PROGRESS_KEY, '') as string;
    if (raw.length === 0) return { lastCompletedDay: '', energy: 0, streak: 0, totalCompletions: 0 };
    const value = JSON.parse(raw) as Record<string, Object>;
    return { lastCompletedDay: text(value['lastCompletedDay']), energy: Number(value['energy']) || 0,
      streak: Number(value['streak']) || 0, totalCompletions: Number(value['totalCompletions']) || 0 };
  } catch (_error) {
    return { lastCompletedDay: '', energy: 0, streak: 0, totalCompletions: 0 };
  }
}

export async function completeDailyChallenge(context: common.UIAbilityContext): Promise<DailyChallengeProgress> {
  const existing = await loadDailyChallengeProgress(context);
  const today = progressDay();
  if (existing.lastCompletedDay === today) return existing;
  const date = new Date(); date.setDate(date.getDate() - 1);
  const yesterday = date.getFullYear().toString() + '-' + (date.getMonth() + 1).toString().padStart(2, '0') + '-' + date.getDate().toString().padStart(2, '0');
  const updated: DailyChallengeProgress = { lastCompletedDay: today, energy: existing.energy + 1,
    streak: existing.lastCompletedDay === yesterday ? existing.streak + 1 : 1,
    totalCompletions: existing.totalCompletions + 1 };
  try {
    const store = await preferences.getPreferences(context, { name: STORE_NAME });
    store.putSync(PROGRESS_KEY, JSON.stringify(updated));
    await store.flush();
  } catch (_error) {
  }
  return updated;
}
