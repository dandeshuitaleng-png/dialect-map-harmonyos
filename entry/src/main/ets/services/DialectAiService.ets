import { http } from '@kit.NetworkKit';
import { DialectAssessment, DialectCoverageScope, DialectRegionCandidate } from '../models/DialectModels';
import { clampScore } from './MockDialectService';
import { backendUrl } from './AlibabaCloudConfig';

const AI_FUNCTION_URL: string = backendUrl('/v1/dialect-ai');

export enum AiErrorKind {
  NO_KEY = 'noKey',
  NETWORK = 'network',
  API_ERROR = 'apiError',
  PARSE_ERROR = 'parseError',
}

export class AiError extends Error {
  kind: AiErrorKind;
  recovery: string;

  constructor(kind: AiErrorKind, message: string, recovery: string) {
    super(message);
    this.kind = kind;
    this.recovery = recovery;
  }
}

export function isAiConfigured(): boolean {
  return AI_FUNCTION_URL.length > 0;
}

class RequestConf {
  method: http.RequestMethod = http.RequestMethod.POST;
  header: Record<string, string>;
  extraData: string;
  connectTimeout: number = 15000;
  readTimeout: number = 20000;

  constructor(bodyStr: string) {
    this.header = {
      'Content-Type': 'application/json',
    };
    this.extraData = bodyStr;
  }
}

function errorForStatus(status: number): AiError {
  if (status === 429) {
    return new AiError(AiErrorKind.API_ERROR, 'AI 服务请求过于频繁', '请稍等一分钟后重试');
  }
  if (status === 400) {
    return new AiError(AiErrorKind.API_ERROR, '鉴定文本不符合要求', '请输入 1-2000 个字符的方言例句');
  }
  if (status === 503) {
    return new AiError(AiErrorKind.API_ERROR, 'AI 服务暂未配置', '请稍后重试或联系应用维护者');
  }
  if (status >= 500) {
    return new AiError(AiErrorKind.API_ERROR, 'AI 服务暂时不可用', '请稍后重试');
  }
  return new AiError(AiErrorKind.API_ERROR, 'AI 服务请求失败', '请稍后重试');
}

async function requestAssessment(text: string): Promise<Record<string, Object>> {
  if (!isAiConfigured()) {
    throw new AiError(AiErrorKind.NO_KEY, 'AI 鉴定服务尚未配置', '请配置阿里云 AI 服务地址后重试');
  }
  const req = http.createHttp();
  try {
    const response = await req.request(AI_FUNCTION_URL, new RequestConf(JSON.stringify({ text })));
    if (response.responseCode < 200 || response.responseCode >= 300) {
      throw errorForStatus(response.responseCode);
    }
    return JSON.parse(response.result as string) as Record<string, Object>;
  } catch (error) {
    if (error instanceof AiError) throw error;
    throw new AiError(AiErrorKind.NETWORK, '网络连接失败，无法访问 AI 服务', '请检查网络连接后重试');
  } finally {
    req.destroy();
  }
}

function stringValue(value: Object | undefined): string {
  return typeof value === 'string' ? value.trim() : '';
}

function numberValue(value: Object | undefined): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function booleanValue(value: Object | undefined, fallback: boolean): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

function mapRegionCandidates(value: Object | undefined): Array<DialectRegionCandidate> {
  if (!Array.isArray(value)) return [];
  const result: Array<DialectRegionCandidate> = [];
  for (let i = 0; i < value.length && result.length < 3; i++) {
    const item = value[i] as Record<string, Object>;
    const name = stringValue(item['name']);
    const region = stringValue(item['region']);
    if (name.length === 0) continue;
    result.push({
      name,
      region,
      confidence: Math.max(0, Math.min(1, numberValue(item['confidence'])))
    });
  }
  return result;
}

function mapCoverageScopes(value: Object | undefined): Array<DialectCoverageScope> {
  if (!Array.isArray(value)) return [];
  const result: Array<DialectCoverageScope> = [];
  for (let i = 0; i < value.length && result.length < 12; i++) {
    const item = value[i] as Record<string, Object>;
    const name = stringValue(item['name']);
    if (name.length === 0) continue;
    result.push({
      name,
      provinceName: stringValue(item['provinceName']),
      prefectureName: stringValue(item['prefectureName']),
      countyName: stringValue(item['countyName']),
      coverageLevel: stringValue(item['coverageLevel']) || 'region_scope_summary',
      coordinateStatus: stringValue(item['coordinateStatus']) || 'not_applicable'
    });
  }
  return result;
}

function mapEvidence(value: Object | undefined): Array<string> {
  if (!Array.isArray(value)) return [];
  return value.filter((item: Object): boolean => typeof item === 'string' && item.trim().length > 0)
    .map((item: Object): string => String(item).trim())
    .slice(0, 8);
}

export async function detectDialectByAI(text: string): Promise<DialectAssessment> {
  const normalizedText = text.trim();
  if (normalizedText.length === 0 || normalizedText.length > 2000) {
    throw new AiError(AiErrorKind.API_ERROR, '鉴定文本不符合要求', '请输入 1-2000 个字符的方言例句');
  }

  const parsed = await requestAssessment(normalizedText);
  const evidence = mapEvidence(parsed['evidence']);
  const confidence = Math.max(0, Math.min(1, numberValue(parsed['confidence'])));
  const primaryDialect = stringValue(parsed['primaryDialect']);
  const language = stringValue(parsed['language']);
  const unknown = booleanValue(parsed['isUnknown'], primaryDialect.length === 0 && language.length === 0);
  if (evidence.length < 2 || (!unknown && primaryDialect.length === 0 && language.length === 0)) {
    throw new AiError(AiErrorKind.PARSE_ERROR, 'AI 返回结果解析失败', '请尝试用更清晰的方言例句重新鉴定');
  }

  const displayName = unknown ? '暂未判定' : (primaryDialect.length > 0 ? primaryDialect : language);
  const regionName = stringValue(parsed['regionName']);
  const assessment: DialectAssessment = {
    classificationId: stringValue(parsed['classificationId']) || 'unclassified',
    dialectName: displayName,
    ethnicity: stringValue(parsed['ethnicity']) || undefined,
    language: language || undefined,
    dialect: stringValue(parsed['dialect']) || undefined,
    dialectFamily: stringValue(parsed['dialectFamily']) || '待确认',
    dialectGroup: stringValue(parsed['dialectGroup']) || '待确认',
    dialectBranch: '',
    regionName: regionName || '待确认地区',
    regionCandidates: mapRegionCandidates(parsed['regionCandidates']),
    coverageScopes: mapCoverageScopes(parsed['coverageScopes']),
    confidence: clampScore(Math.round(confidence * 100)),
    retention: clampScore(Math.round(confidence * 75)),
    evidence,
    similarDialects: [],
    needsConfirmation: unknown || booleanValue(parsed['needsConfirmation'], true) || confidence < 0.7,
    isUnknown: unknown,
    sourceStatus: stringValue(parsed['sourceStatus']) || 'legacy',
    isSimulated: false,
  };
  return assessment;
}
