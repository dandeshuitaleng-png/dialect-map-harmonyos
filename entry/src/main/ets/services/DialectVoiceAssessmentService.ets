import { http } from '@kit.NetworkKit';
import { backendUrl } from './AlibabaCloudConfig';
import { DialectAssessment } from '../models/DialectModels';

const VOICE_ASSESS_URL: string = backendUrl('/v1/dialect-voice-assess');
const MAX_AUDIO_BYTES: number = 16000 * 2 * 15;

export enum VoiceAiErrorKind {
  CONFIGURATION = 'configuration',
  NETWORK = 'network',
  API = 'api',
  INVALID_RESULT = 'invalidResult'
}

export class VoiceAiError extends Error {
  kind: VoiceAiErrorKind;
  recovery: string;

  constructor(kind: VoiceAiErrorKind, message: string, recovery: string) {
    super(message);
    this.kind = kind;
    this.recovery = recovery;
  }
}

interface VoiceAssessmentResponse {
  transcript?: string;
  sttConfidence?: number;
  assessment?: DialectAssessment;
}

interface VoiceAiAssessmentPayload {
  primaryDialect: string;
  confidence: number;
  evidence: Array<string>;
  needsConfirmation: boolean;
}

export async function assessCapturedDialectVoice(
  chunks: Array<ArrayBuffer>, durationSeconds: number
): Promise<VoiceAssessmentResponse> {
  const byteLength = chunks.reduce((total: number, chunk: ArrayBuffer): number =>
    total + chunk.byteLength, 0);
  if (byteLength <= 0 || byteLength > MAX_AUDIO_BYTES || durationSeconds <= 0 || durationSeconds > 15) {
    throw new VoiceAiError(VoiceAiErrorKind.API, '录音长度不符合语音鉴定要求', '请录制 2–15 秒后重试');
  }
  if (VOICE_ASSESS_URL.length === 0) {
    throw new VoiceAiError(VoiceAiErrorKind.CONFIGURATION, '语音 AI 服务尚未配置', '请配置阿里云语音服务地址后重试');
  }
  const payload = JSON.stringify({
    audioBase64: encodeBase64(chunks),
    sampleRate: 16000,
    channels: 1,
    format: 'pcm_s16le',
    durationSeconds
  });
  const req = http.createHttp();
  try {
    const response = await req.request(VOICE_ASSESS_URL, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json'
      },
      extraData: payload,
      connectTimeout: 15000,
      readTimeout: 35000
    });
    if (response.responseCode < 200 || response.responseCode >= 300) {
      throw new VoiceAiError(VoiceAiErrorKind.API, '语音 AI 服务暂不可用', '请稍后重试，或改用文字鉴定');
    }
    const result = JSON.parse(response.result as string) as VoiceAssessmentResponse;
    if (result.transcript === undefined || result.transcript.trim().length === 0 ||
      result.assessment === undefined) {
      throw new VoiceAiError(VoiceAiErrorKind.INVALID_RESULT, '语音 AI 返回结果不完整', '请重新录制后重试');
    }
    return {
      transcript: result.transcript,
      sttConfidence: result.sttConfidence,
      assessment: mapVoiceAssessment(result.assessment)
    };
  } catch (error) {
    if (error instanceof VoiceAiError) throw error;
    throw new VoiceAiError(VoiceAiErrorKind.NETWORK, '无法连接语音 AI 服务', '请检查网络后重试，或改用文字鉴定');
  } finally {
    req.destroy();
  }
}

function mapVoiceAssessment(raw: DialectAssessment): DialectAssessment {
  const confidence = Math.max(0, Math.min(100, Math.round(raw.confidence)));
  const unknown = raw.isUnknown === true || raw.dialectName.trim().length === 0 || raw.dialectName === '暂未判定';
  return {
    classificationId: raw.classificationId || 'unclassified',
    dialectName: unknown ? '暂未判定' : raw.dialectName,
    ethnicity: raw.ethnicity,
    language: raw.language,
    dialect: raw.dialect,
    dialectFamily: raw.dialectFamily || '待确认',
    dialectGroup: raw.dialectGroup || '待确认',
    dialectBranch: raw.dialectBranch,
    regionName: raw.regionName || '待确认地区',
    regionCandidates: raw.regionCandidates,
    coverageScopes: raw.coverageScopes,
    confidence,
    retention: raw.retention,
    evidence: raw.evidence,
    similarDialects: raw.similarDialects,
    needsConfirmation: unknown || confidence < 70 || raw.needsConfirmation,
    isUnknown: unknown,
    sourceStatus: raw.sourceStatus,
    isSimulated: false
  };
}

const BASE64_TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function encodeBase64(chunks: Array<ArrayBuffer>): string {
  let binary = '';
  chunks.forEach((chunk: ArrayBuffer): void => {
    const bytes = new Uint8Array(chunk);
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
  });
  let output = '';
  for (let i = 0; i < binary.length; i += 3) {
    const a = binary.charCodeAt(i);
    const b = i + 1 < binary.length ? binary.charCodeAt(i + 1) : 0;
    const c = i + 2 < binary.length ? binary.charCodeAt(i + 2) : 0;
    output += BASE64_TABLE.charAt(a >> 2);
    output += BASE64_TABLE.charAt(((a & 3) << 4) | (b >> 4));
    output += i + 1 < binary.length ? BASE64_TABLE.charAt(((b & 15) << 2) | (c >> 6)) : '=';
    output += i + 2 < binary.length ? BASE64_TABLE.charAt(c & 63) : '=';
  }
  return output;
}
