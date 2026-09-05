export interface AudioCaptureSummary {
  readonly byteLength: number;
  readonly sampleCount: number;
  readonly durationSeconds: number;
  readonly peakAmplitude: number;
  readonly rmsAmplitude: number;
  readonly activeSampleRatio: number;
  readonly clippedSampleRatio: number;
}

export enum AudioCaptureQualityStatus {
  USABLE = 'usable',
  TOO_SHORT = 'tooShort',
  SILENT = 'silent',
  TOO_QUIET = 'tooQuiet',
  CLIPPED = 'clipped'
}

export interface AudioCaptureQualityResult {
  readonly status: AudioCaptureQualityStatus;
  readonly canContinue: boolean;
  readonly message: string;
}

const MIN_DURATION_SECONDS: number = 2;
const SILENT_PEAK_AMPLITUDE: number = 0.008;
const SILENT_RMS_AMPLITUDE: number = 0.002;
const QUIET_PEAK_AMPLITUDE: number = 0.03;
const QUIET_RMS_AMPLITUDE: number = 0.006;
const MIN_ACTIVE_SAMPLE_RATIO: number = 0.02;
const MAX_CLIPPED_SAMPLE_RATIO: number = 0.08;

export function evaluateAudioCapture(
  summary: AudioCaptureSummary
): AudioCaptureQualityResult {
  if (summary.byteLength <= 0 || summary.sampleCount <= 0 ||
    summary.durationSeconds < MIN_DURATION_SECONDS) {
    return {
      status: AudioCaptureQualityStatus.TOO_SHORT,
      canContinue: false,
      message: '录音不足 2 秒，请再说完整一点'
    };
  }
  if (summary.peakAmplitude < SILENT_PEAK_AMPLITUDE &&
    summary.rmsAmplitude < SILENT_RMS_AMPLITUDE) {
    return {
      status: AudioCaptureQualityStatus.SILENT,
      canContinue: false,
      message: '没有检测到清晰的声音，请确认麦克风没有被遮挡'
    };
  }
  if (summary.peakAmplitude < QUIET_PEAK_AMPLITUDE ||
    summary.rmsAmplitude < QUIET_RMS_AMPLITUDE ||
    summary.activeSampleRatio < MIN_ACTIVE_SAMPLE_RATIO) {
    return {
      status: AudioCaptureQualityStatus.TOO_QUIET,
      canContinue: false,
      message: '声音偏小，请靠近麦克风并重新录制'
    };
  }
  if (summary.clippedSampleRatio > MAX_CLIPPED_SAMPLE_RATIO) {
    return {
      status: AudioCaptureQualityStatus.CLIPPED,
      canContinue: false,
      message: '声音过大出现失真，请稍微离远一点重新录制'
    };
  }
  return {
    status: AudioCaptureQualityStatus.USABLE,
    canContinue: true,
    message: '录音长度和音量达到本次采集要求'
  };
}
