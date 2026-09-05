import {
  DialectAssessment,
  DialectClassification,
  DialectCoverageScope,
  DialectRegionCandidate,
  RecordingState
} from '../models/DialectModels';
import {
  createAiAssessment
} from '../services/MockDialectService';
import { AiError, AiErrorKind } from '../services/DialectAiService';
import {
  getDialectClassification
} from '../services/DialectClassificationCatalogService';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { TransientAudioCaptureService } from '../services/TransientAudioCaptureService';
import {
  AudioCaptureQualityResult,
  evaluateAudioCapture
} from '../services/AudioCaptureQualityService';
import {
  assessCapturedDialectVoice,
  VoiceAiError
} from '../services/DialectVoiceAssessmentService';

const PAPER: ResourceColor = $r('app.color.background_page');
const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT_FILL: ResourceColor = $r('app.color.accent');
const ACCENT_TEXT: ResourceColor = $r('app.color.accent_text');
const CONFIRM_FILL: ResourceColor = $r('app.color.confirm');
const CONFIRM_TEXT: ResourceColor = $r('app.color.confirm_text');

@Component
export struct VoiceAssessmentPage {
  @Link correctionOpen: boolean;
  @Link completionInFlight: boolean;
  onBack: () => void = (): void => {};
  onComplete: (assessment: DialectAssessment) => Promise<void> =
    async (_assessment: DialectAssessment): Promise<void> => {};
  @State recordingState: RecordingState = RecordingState.READY;
  @State assessment: DialectAssessment | undefined = undefined;
  @State resultConfirmed: boolean = false;
  @State aiError: AiError | undefined = undefined;
  @State elapsedSeconds: number = 0;
  @State recordingStatusMessage: string =
    '录音只用于本次采集验证，不保存、不上传。';
  @State actionInFlight: boolean = false;
  @State microphoneSettingsAvailable: boolean = false;
  @State amplitude: number = 0;
  @State waveform: number[] = [0, 0, 0, 0, 0, 0, 0, 0];
  @State playbackInFlight: boolean = false;
  @State aiText: string = '';
  @State aiLoading: boolean = false;
  @State voiceAiLoading: boolean = false;
  private captureService: TransientAudioCaptureService =
    new TransientAudioCaptureService();
  private recordingTimerId: number = -1;
  private lastAmplitudeUpdateAtMs: number = 0;

  aboutToAppear(): void {
    this.captureService.setAmplitudeListener((amplitude: number): void => {
      const now = Date.now();
      if (amplitude > 0 && now - this.lastAmplitudeUpdateAtMs < 80) {
        return;
      }
      this.lastAmplitudeUpdateAtMs = now;
      this.amplitude = amplitude;
      this.waveform = this.waveform.slice(1).concat([amplitude]);
    });
    this.captureService.setInterruptionListener((): void => {
      this.handleRecordingInterruption();
    });
  }

  aboutToDisappear(): void {
    this.clearRecordingTimer();
    this.captureService.setAmplitudeListener((_amplitude: number): void => {});
    this.captureService.setInterruptionListener((): void => {});
    this.captureService.release();
  }

  errorIcon(): string {
    if (this.aiError === undefined) return '';
    switch (this.aiError.kind) {
      case AiErrorKind.NO_KEY: return '⚙️';
      case AiErrorKind.NETWORK: return '📡';
      case AiErrorKind.API_ERROR: return '⚠️';
      case AiErrorKind.PARSE_ERROR: return '🔍';
      default: return '❌';
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row() {
          Button({ type: ButtonType.Circle }) {
            Text('‹').fontSize(28).fontColor(INK)
          }
          .width(48)
          .height(48)
          .backgroundColor($r('app.color.surface_primary'))
          .enabled(!this.completionInFlight)
          .onClick(this.onBack)
          .accessibilityText('返回乡音地图')

          Blank()

          Text('AI 方言鉴定')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(ACCENT_TEXT)
            .backgroundColor($r('app.color.surface_accent_soft'))
            .borderRadius(7)
            .padding({ left: 8, right: 8, top: 5, bottom: 5 })
        }
        .width('100%')

        Text('录音鉴定')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
          .accessibilityText('录音鉴定')
      }
      .width('100%')
      .height(56)
      .padding({ left: 18, right: 18 })
      .border({ width: { bottom: 1 }, color: $r('app.color.divider') })

      if (this.recordingState === RecordingState.RESULT && this.assessment !== undefined) {
        this.resultContent()
      } else {
        this.recordingContent()
      }

      Text('麦克风音频不会保存；启用阿里云鉴定服务后才会按你的操作发送用于本次识别，请结合依据确认地区。')
        .fontSize(12)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 26 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAPER)
  }

  @Builder
  recordingContent() {
    Scroll() {
      Column() {
        Column({ space: 10 }) {
          Text(this.stepEyebrow())
            .fontSize(12)
            .fontColor(ACCENT_TEXT)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(1)
          Text(this.stepTitle())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(this.stepDescription())
            .fontSize(13)
            .fontColor(MUTED)
            .textAlign(TextAlign.Center)
            .lineHeight(20)
        }
        .padding({ left: 28, right: 28, top: 28 })

        Stack() {
          Circle()
            .width(this.recordingState === RecordingState.RECORDING ? 154 : 130)
            .height(this.recordingState === RecordingState.RECORDING ? 154 : 130)
            .fill(this.recordingState === RecordingState.RECORDING ?
              $r('app.color.surface_recording') : $r('app.color.surface_disabled'))
          Circle()
            .width(104)
            .height(104)
            .fill(this.recordingState === RecordingState.RECORDING ?
              ACCENT_FILL : CONFIRM_FILL)
          Text(this.recordingState === RecordingState.RECORDING ?
            this.formatDuration(this.elapsedSeconds) : '声')
            .fontSize(this.recordingState === RecordingState.RECORDING ? 20 : 26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
        }
        .width(180)
        .height(180)
        .margin({ top: 42 })

      if (this.recordingState === RecordingState.RECORDING) {
        Column({ space: 8 }) {
          this.waveformBars()
          Text(this.liveSoundFeedback())
            .fontSize(12)
            .fontColor(MUTED)
            .textAlign(TextAlign.Center)
            .accessibilityText(this.liveSoundFeedback())
        }
        .width('100%')
        .margin({ top: 10 })
      }

      if (this.recordingState === RecordingState.RECORDED ||
        this.recordingState === RecordingState.ASSESSING) {
        Column({ space: 12 }) {
          Row() {
            Text('录音片段')
              .fontSize(12)
              .fontColor(MUTED)
            Blank()
            Text(this.formatDuration(this.elapsedSeconds))
              .fontSize(12)
              .fontColor(MUTED)
          }
          .width('100%')
          Progress({
            value: this.recordingState === RecordingState.ASSESSING ? 78 : 100,
            total: 100,
            type: ProgressType.Linear
          })
            .height(5)
            .color(this.recordingState === RecordingState.ASSESSING ?
              CONFIRM_TEXT : ACCENT_TEXT)
            .backgroundColor($r('app.color.divider'))

          this.waveformBars()

          if (this.recordingState === RecordingState.RECORDED) {
            Row({ space: 10 }) {
              Button(this.playbackInFlight ? '正在播放' : '播放本次录音')
                .layoutWeight(1)
                .height(44)
                .enabled(!this.actionInFlight)
                .fontColor(ACCENT_TEXT)
                .backgroundColor($r('app.color.brand_soft'))
                .onClick(async (): Promise<void> => {
                  await this.playCapturedAudio();
                })
              Button('重新录制')
                .layoutWeight(1)
                .height(44)
                .enabled(!this.actionInFlight)
                .fontColor(INK)
                .backgroundColor($r('app.color.surface_muted'))
                .onClick(async (): Promise<void> => {
                  await this.restartRecording();
                })
            }
            .width('100%')
            Button(this.voiceAiLoading ? '语音 AI 鉴定中…' : '用本次录音进行 AI 鉴定')
              .width('100%')
              .height(48)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .backgroundColor(ACCENT_FILL)
              .borderRadius(14)
              .enabled(!this.actionInFlight && !this.voiceAiLoading)
              .onClick(async (): Promise<void> => { await this.assessRecordedVoice(); })
              .accessibilityText('将本次临时录音发送到语音 AI 进行方言鉴定，录音不会保存')
          }
        }
        .padding(18)
        .width('100%')
        .backgroundColor($r('app.color.surface_primary'))
        .borderRadius(16)
        .margin({ top: 22 })
      }

      if (this.recordingStatusMessage.length > 0) {
        Text(this.recordingStatusMessage)
          .fontSize(12)
          .fontColor(MUTED)
          .lineHeight(18)
          .width('100%')
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)
          .margin({ top: 12 })
          .accessibilityText(this.recordingStatusMessage)
      }

      if (this.recordingState === RecordingState.RECORDING) {
        Button('取消本次录音')
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor(MUTED)
          .backgroundColor(Color.Transparent)
          .enabled(!this.actionInFlight)
          .onClick(async (): Promise<void> => {
            await this.cancelRecording();
          })
      }

      if (this.recordingState === RecordingState.READY) {
        // AI 文本鉴定入口
        Row({ space: 8 }) {
          TextInput({ placeholder: '输入你说的方言原句…', text: this.aiText })
            .layoutWeight(1)
            .height(48)
            .fontSize(14)
            .fontColor(INK)
            .placeholderColor(MUTED)
            .backgroundColor($r('app.color.surface_pure'))
            .borderRadius(14)
            .border({ width: 1, color: $r('app.color.divider') })
            .onChange((value: string): void => { this.aiText = value; this.aiError = undefined; })
            .enabled(!this.aiLoading)
          Button(this.aiLoading ? '鉴定中…' : 'AI 鉴定')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
            .height(48)
            .padding({ left: 16, right: 16 })
            .backgroundColor(this.aiText.trim().length > 0 && !this.aiLoading ?
              CONFIRM_FILL : $r('app.color.surface_muted'))
            .borderRadius(14)
            .enabled(this.aiText.trim().length > 0 && !this.aiLoading)
            .onClick(async (): Promise<void> => {
              this.aiLoading = true;
              this.aiError = undefined;
              try {
                this.assessment = await createAiAssessment(this.aiText.trim());
                this.recordingState = RecordingState.RESULT;
              } catch (e) {
                this.aiError = e as AiError;
              } finally {
                this.aiLoading = false;
              }
            })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      // AI 错误提示
      if (this.aiError !== undefined && this.recordingState === RecordingState.READY) {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(this.errorIcon())
              .fontSize(16)
            Text(this.aiError.message)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(ACCENT_TEXT)
              .layoutWeight(1)
          }
          .width('100%')

          Text(this.aiError.recovery)
            .fontSize(11)
            .fontColor(MUTED)
            .width('100%')

          if (this.aiError.kind === AiErrorKind.NO_KEY) {
            Button('了解如何配置')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .height(40)
              .padding({ left: 16, right: 16 })
              .backgroundColor(ACCENT_FILL)
              .borderRadius(12)
              .onClick((): void => { this.aiError = undefined; })
          } else {
            Button('重试')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .height(40)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.surface_pure'))
              .borderRadius(12)
              .border({ width: 1, color: $r('app.color.divider') })
              .onClick((): void => { this.aiError = undefined; })
          }
        }
        .width('100%')
        .padding(14)
        .backgroundColor($r('app.color.surface_accent_soft'))
        .borderRadius(14)
        .border({ width: 1, color: $r('app.color.border') })

        .margin({ bottom: 12 })
      }

      if (this.microphoneSettingsAvailable &&
        this.recordingState === RecordingState.READY) {
        Button('去系统设置开启麦克风')
          .width('100%')
          .height(48)
          .fontSize(14)
          .fontColor(ACCENT_TEXT)
          .backgroundColor($r('app.color.brand_soft'))
          .borderRadius(14)
          .enabled(!this.actionInFlight)
          .onClick(async (): Promise<void> => {
            await this.recoverMicrophonePermission();
          })
          .accessibilityText('前往系统设置开启麦克风权限')
      }

      Button(this.primaryLabel())
        .width('100%')
        .height(50)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_emphasis'))
        .backgroundColor(this.recordingState === RecordingState.ASSESSING ?
          CONFIRM_FILL : ACCENT_FILL)
        .borderRadius(14)
        .margin({ top: 20 })
        .enabled(!this.actionInFlight)
        .onClick(async (): Promise<void> => { await this.advance(); })
        .accessibilityText(this.primaryLabel())
      }
      .padding({ left: 20, right: 20, bottom: 18 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  resultContent() {
    Scroll() {
      Column({ space: 14 }) {
        Column({ space: 9 }) {
          Text('AI 鉴定完成')
            .fontSize(12)
            .fontColor(CONFIRM_TEXT)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(1)
          Text(this.assessment!.isUnknown === true ? '暂未判定' : this.assessment!.dialectName)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          if (this.assessment!.language !== undefined && this.assessment!.language!.length > 0) {
            Text('语言候选：' + this.assessment!.language)
              .fontSize(13)
              .fontColor(MUTED)
          }
          if (this.assessment!.isUnknown === true) {
            Text('当前目录没有足够证据对应此输入；结果保留为未知，请不要直接点亮地区。')
              .fontSize(13)
              .fontColor(ACCENT_TEXT)
              .lineHeight(19)
          }
          Text(this.assessment!.dialectFamily + ' · ' +
            this.assessment!.dialectGroup + ' · ' + this.assessment!.dialectBranch)
            .fontSize(12)
            .fontColor(MUTED)
        }
        .padding({ top: 24, bottom: 12 })

        Column({ space: 18 }) {
          AssessmentMetric({
            label: '鉴定置信度',
            value: this.assessment!.confidence,
            color: ACCENT_TEXT
          })
          Divider().color($r('app.color.divider'))
          AssessmentMetric({
            label: '乡音保留度',
            value: this.assessment!.retention,
            color: CONFIRM_TEXT
          })
        }
        .padding(20)
        .backgroundColor($r('app.color.surface_primary'))
        .borderRadius(18)
        .border({ width: 1, color: $r('app.color.border') })

        Column({ space: 12 }) {
          Text('候选地域')
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
          ForEach(this.assessment!.regionCandidates, (candidate: DialectRegionCandidate): void => {
            Row() {
              Text(candidate.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(INK)
              Blank()
              Text(candidate.confidence.toString() + '%')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(candidate.name === this.assessment!.regionCandidates[0].name ?
                  ACCENT_TEXT : MUTED)
            }
            .width('100%')
          }, (candidate: DialectRegionCandidate): string => candidate.name)
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_primary'))
        .borderRadius(16)
        .border({ width: 1, color: $r('app.color.border') })

        if (this.assessment!.coverageScopes !== undefined && this.assessment!.coverageScopes!.length > 0) {
          Column({ space: 8 }) {
            Text('已报道的区域范围')
              .fontSize(12)
              .fontColor(MUTED)
              .width('100%')
            ForEach(this.assessment!.coverageScopes!, (scope: DialectCoverageScope): void => {
              Row({ space: 8 }) {
                Text(scope.name)
                  .fontSize(13)
                  .fontColor(INK)
                  .lineHeight(19)
                  .layoutWeight(1)
                Text(scope.coordinateStatus === 'not_applicable' ? '范围摘要' : scope.coordinateStatus)
                  .fontSize(11)
                  .fontColor(MUTED)
              }
              .width('100%')
            }, (scope: DialectCoverageScope): string => scope.name)
            Text('以上是来源目录中的区域范围摘要，不是精确调查点或籍贯结论；坐标需完成来源核验后才会进入地图。')
              .fontSize(11)
              .fontColor(MUTED)
              .lineHeight(17)
              .width('100%')
          }
          .padding(18)
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(16)
          .border({ width: 1, color: $r('app.color.border') })
        }

        Column({ space: 10 }) {
          Text('识别依据')
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
          ForEach(this.assessment!.evidence, (item: string): void => {
            Row({ space: 8 }) {
              Text('·').fontSize(18).fontColor(ACCENT_TEXT)
              Text(item)
                .fontSize(13)
                .fontColor(INK)
                .lineHeight(19)
                .layoutWeight(1)
            }
            .width('100%')
          }, (item: string): string => item)
          Text('相似乡音：' + this.assessment!.similarDialects.join('、'))
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_muted'))
        .borderRadius(16)

        this.classificationSourceCard()

        Column({ space: 10 }) {
          Text('即将点亮')
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
          Row() {
            Column({ space: 3 }) {
              Text(this.assessment!.dialectGroup + ' · ' + this.assessment!.dialectBranch)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(INK)
              Text('在' + this.assessment!.regionName + '留下乡音足迹')
                .fontSize(12)
                .fontColor(MUTED)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('代表点范围')
              .fontSize(12)
              .fontColor(CONFIRM_TEXT)
          }
          .width('100%')
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_confirm_soft'))
        .borderRadius(16)

        Text('结果由 AI 服务根据你输入的方言文字生成，仅供文化体验参考；请结合识别依据确认地区。')
          .fontSize(12)
          .fontColor(MUTED)
          .lineHeight(18)
          .padding(14)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)

        if (this.assessment!.isUnknown === true && !this.resultConfirmed && !this.correctionOpen) {
          Button('从已知代表点中选择更接近的结果')
            .width('100%')
            .height(48)
            .fontSize(14)
            .fontColor(INK)
            .backgroundColor($r('app.color.surface_primary'))
            .border({ width: 1, color: $r('app.color.border') })
            .borderRadius(14)
            .onClick((): void => { this.correctionOpen = true; })
        }

        if (this.assessment!.isUnknown !== true && !this.resultConfirmed && !this.correctionOpen) {
          Row({ space: 10 }) {
            Button('不太准确')
              .layoutWeight(1)
              .height(48)
              .fontSize(14)
              .fontColor(INK)
              .backgroundColor($r('app.color.surface_primary'))
              .border({ width: 1, color: $r('app.color.border') })
              .borderRadius(14)
              .onClick((): void => { this.correctionOpen = true; })
            Button('符合我的乡音')
              .layoutWeight(1)
              .height(48)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .backgroundColor(ACCENT_FILL)
              .borderRadius(14)
              .onClick((): void => {
                if (this.assessment !== undefined) {
                  this.assessment = {
                    classificationId: this.assessment!.classificationId,
                    dialectName: this.assessment!.dialectName,
                    ethnicity: this.assessment!.ethnicity,
                    language: this.assessment!.language,
                    dialect: this.assessment!.dialect,
                    dialectFamily: this.assessment!.dialectFamily,
                    dialectGroup: this.assessment!.dialectGroup,
                    dialectBranch: this.assessment!.dialectBranch,
                    regionName: this.assessment!.regionName,
                    regionCandidates: this.assessment!.regionCandidates,
                    confidence: this.assessment!.confidence,
                    retention: this.assessment!.retention,
                    evidence: this.assessment!.evidence,
                    similarDialects: this.assessment!.similarDialects,
                    needsConfirmation: false,
                    isUnknown: false,
                    sourceStatus: 'user_confirmed',
                    isSimulated: false,
                  };
                }
                this.resultConfirmed = true;
              })
          }
          .width('100%')
        }

        if (this.correctionOpen) {
          Column({ space: 10 }) {
            Text('选择更接近的结果')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .width('100%')
            Button('四川话 · 成渝小片')
              .width('100%')
              .height(44)
              .fontColor(INK)
              .backgroundColor($r('app.color.surface_primary'))
              .border({ width: 1, color: $r('app.color.border') })
              .onClick((): void => {
                this.applyCorrection('四川', '四川话');
              })
            Button('重庆话 · 成渝小片')
              .width('100%')
              .height(44)
              .fontColor(INK)
              .backgroundColor($r('app.color.surface_primary'))
              .border({ width: 1, color: $r('app.color.border') })
              .onClick((): void => {
                this.applyCorrection('重庆', '重庆话');
              })
            Button('重新录制')
              .width('100%')
              .height(44)
              .enabled(!this.actionInFlight)
              .fontColor(ACCENT_TEXT)
              .backgroundColor(Color.Transparent)
              .onClick(async (): Promise<void> => {
                await this.restartRecording();
              })
          }
          .padding(16)
          .backgroundColor($r('app.color.surface_confirm_soft'))
          .borderRadius(16)
        }

        if (this.resultConfirmed) {
          Text('已由你确认：' + this.assessment!.dialectName + ' · ' +
            this.assessment!.dialectBranch)
            .fontSize(12)
            .fontColor(CONFIRM_TEXT)
            .width('100%')
          Button(this.completionInFlight ?
            '正在保存乡音护照' :
            '点亮' + this.assessment!.dialectBranch + '并生成乡音护照')
            .width('100%')
            .height(50)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
            .backgroundColor(ACCENT_FILL)
            .borderRadius(14)
            .enabled(!this.completionInFlight)
            .onClick(async (): Promise<void> => { await this.completeAssessment(); })
        }
        Blank().height(24)
      }
      .padding({ left: 20, right: 20 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  private classificationSourceCard() {
    Column({ space: 10 }) {
      Row() {
        Text('分类资料')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Blank()
        Text(this.assessment!.sourceStatus === 'catalog_candidate' ? '候选目录 · 待人工复核' : '来源页已初核')
          .fontSize(12)
          .fontColor(CONFIRM_TEXT)
      }
      .width('100%')

      Text(this.assessment!.sourceStatus === 'catalog_candidate' ?
        '语言/方言候选目录 · 用户提供研究报告' :
        this.currentClassification().sourceTitle + ' · ' + this.currentClassification().sourceEdition)
        .fontSize(12)
        .fontColor(INK)
        .lineHeight(18)
        .width('100%')

      Text('图 ' + this.currentClassification().atlasMapCodes.join('、') +
        ' · PDF ' + this.currentClassification().pdfPages.join('，'))
        .fontSize(12)
        .fontColor(MUTED)
        .lineHeight(18)
        .width('100%')

      Text(this.currentClassification().administrativeScope)
        .fontSize(12)
        .fontColor(ACCENT_TEXT)
        .lineHeight(18)
        .width('100%')

      Text('边界说明：' + this.currentClassification().disputeNote)
        .fontSize(12)
        .fontColor(MUTED)
        .lineHeight(18)
        .width('100%')

      Text(this.assessment!.sourceStatus === 'catalog_candidate' ?
        '该结果来自候选目录，不代表已完成的语言学分类；AI 置信度仅供文化体验参考，第二人复核与资源许可待完成。' :
        '分类结论来自来源页初核；AI 鉴定和置信度仅供文化体验参考。第二人复核与出版授权待完成。')
        .fontSize(12)
        .fontColor(MUTED)
        .lineHeight(18)
        .width('100%')
    }
    .padding(18)
    .backgroundColor($r('app.color.surface_primary'))
    .borderRadius(16)
    .border({ width: 1, color: $r('app.color.border') })
    .accessibilityGroup(true)
    .accessibilityText(
      '分类资料来源页已初核，仍待第二人复核。' + this.currentClassification().administrativeScope +
      '。' + this.currentClassification().disputeNote
    )
  }

  private currentClassification(): DialectClassification {
    return getDialectClassification(
      this.assessment!.regionName,
      this.assessment!.dialectName
    );
  }

  @Builder
  private waveformBars() {
    Row({ space: 4 }) {
      ForEach(this.waveform, (value: number, index: number): void => {
        Row()
          .width(6)
          .height(Math.max(4, value * 42))
          .backgroundColor(ACCENT_TEXT)
          .borderRadius(3)
      }, (_value: number, index: number): string => index.toString())
    }
    .height(44)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .accessibilityLevel('no-hide-descendants')
  }

  private async advance(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    if (this.recordingState === RecordingState.READY) {
      await this.startRealRecording();
      return;
    }
    if (this.recordingState === RecordingState.RECORDING) {
      await this.finishRealRecording();
      return;
    }
    if (this.recordingState === RecordingState.RECORDED) {
      this.actionInFlight = true;
      this.recordingStatusMessage = '正在释放临时录音';
      try {
        await this.captureService.release();
        this.playbackInFlight = false;
        this.recordingState = RecordingState.ASSESSING;
        this.recordingStatusMessage =
          '临时录音已释放；请在文本框输入方言内容后点击 AI 鉴定';
      } finally {
        this.actionInFlight = false;
      }
      return;
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      this.recordingState = RecordingState.RESULT;
    }
  }

  private async completeAssessment(): Promise<void> {
    if (this.completionInFlight || this.assessment === undefined) {
      return;
    }
    this.completionInFlight = true;
    try {
      await this.onComplete(this.assessment);
    } finally {
      this.completionInFlight = false;
    }
  }

  private async assessRecordedVoice(): Promise<void> {
    if (this.voiceAiLoading || this.actionInFlight ||
      this.recordingState !== RecordingState.RECORDED) {
      return;
    }
    this.voiceAiLoading = true;
    this.aiError = undefined;
    this.recordingStatusMessage = '正在上传临时音频并进行语音识别；完成后立即释放原始 PCM';
    try {
      const result = await assessCapturedDialectVoice(
        this.captureService.getCapturedPcmChunks(),
        this.captureService.getCaptureSummary().durationSeconds
      );
      this.assessment = result.assessment;
      this.recordingState = RecordingState.RESULT;
      this.recordingStatusMessage = '语音 AI 鉴定完成；原始 PCM 不会保存';
      await this.captureService.release();
    } catch (error) {
      const voiceError = error as VoiceAiError;
      this.aiError = new AiError(
        AiErrorKind.API_ERROR,
        voiceError.message,
        voiceError.recovery
      );
      this.recordingStatusMessage = this.aiError.message;
    } finally {
      this.voiceAiLoading = false;
    }
  }

  private applyCorrection(regionName: string, dialectName: string): void {
    if (this.assessment !== undefined) {
      this.assessment = {
        classificationId: this.assessment!.classificationId,
        dialectName: dialectName,
        ethnicity: this.assessment!.ethnicity,
        language: this.assessment!.language,
        dialect: this.assessment!.dialect,
        dialectFamily: this.assessment!.dialectFamily,
        dialectGroup: this.assessment!.dialectGroup,
        dialectBranch: this.assessment!.dialectBranch,
        regionName: regionName,
        regionCandidates: this.assessment!.regionCandidates,
        confidence: this.assessment!.confidence,
        retention: this.assessment!.retention,
        evidence: this.assessment!.evidence,
        similarDialects: this.assessment!.similarDialects,
        needsConfirmation: false,
        isUnknown: false,
        sourceStatus: 'user_confirmed',
        isSimulated: false,
      };
    }
    this.correctionOpen = false;
    this.resultConfirmed = true;
  }

  private async restartRecording(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.clearRecordingTimer();
    try {
      await this.captureService.release();
      this.assessment = undefined;
      this.correctionOpen = false;
      this.resultConfirmed = false;
      this.resetRecordingState(
        '录音只用于本次采集验证，不保存、不上传。'
      );
    } finally {
      this.actionInFlight = false;
    }
  }

  private stepEyebrow(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '正在录音';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '录音完成';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '正在处理录音';
    }
    return '第一步';
  }

  private stepTitle(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '说一句家乡话';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '录音已完成';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '正在辨认乡音';
    }
    return '录下你的乡音';
  }

  private stepDescription(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '试着说：“今天吃什么？”';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '录音长度和音量已检查，可试听或重新录制';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '正在比较发音特征与地域表达';
    }
    return '用最自然的语气，说一句你从小常说的话';
  }

  private primaryLabel(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '完成录音';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '释放录音';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '录音已释放';
    }
    return this.actionInFlight ? '正在准备麦克风' : '开始真实录音';
  }

  private async startRealRecording(): Promise<void> {
    this.actionInFlight = true;
    this.recordingStatusMessage = '正在检查麦克风权限';
    try {
      if (!await this.ensureMicrophoneAvailable()) {
        return;
      }
      this.waveform = [0, 0, 0, 0, 0, 0, 0, 0];
      this.amplitude = 0;
      this.lastAmplitudeUpdateAtMs = 0;
      await this.captureService.start();
      this.elapsedSeconds = 0;
      this.recordingState = RecordingState.RECORDING;
      this.recordingStatusMessage = '正在真实采集麦克风音频；音频不会保存或上传';
      this.startRecordingTimer();
    } catch (_error) {
      await this.captureService.release();
      this.recordingStatusMessage = '麦克风启动失败，请确认没有其他应用占用后重试';
    } finally {
      this.actionInFlight = false;
    }
  }

  private async finishRealRecording(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.clearRecordingTimer();
    try {
      await this.captureService.stop();
      const quality: AudioCaptureQualityResult = evaluateAudioCapture(
        this.captureService.getCaptureSummary()
      );
      if (!quality.canContinue) {
        this.resetRecordingState(quality.message + '；本次数据已释放');
        await this.captureService.release();
        return;
      }
      this.recordingState = RecordingState.RECORDED;
      this.recordingStatusMessage =
        quality.message + '；音频仅暂存在当前页面，可试听，离开后立即释放';
    } catch (_error) {
      await this.captureService.release();
      this.resetRecordingState('结束录音失败，采集资源已释放，请重试');
    } finally {
      this.actionInFlight = false;
    }
  }

  private async ensureMicrophoneAvailable(): Promise<boolean> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const atManager = abilityAccessCtrl.createAtManager();
      const microphonePermission: Permissions = 'ohos.permission.MICROPHONE';
      const permissionStatus = atManager.getSelfPermissionStatus(microphonePermission);
      if (permissionStatus === abilityAccessCtrl.PermissionStatus.DENIED) {
        this.microphoneSettingsAvailable = true;
        this.recordingStatusMessage =
          '麦克风权限已被拒绝，请在系统设置中开启；你仍可返回地图继续浏览';
        return false;
      }
      if (permissionStatus === abilityAccessCtrl.PermissionStatus.RESTRICTED) {
        this.microphoneSettingsAvailable = false;
        this.recordingStatusMessage =
          '麦克风权限受设备策略限制，当前无法录音；你仍可返回地图继续浏览';
        return false;
      }
      if (permissionStatus === abilityAccessCtrl.PermissionStatus.INVALID) {
        this.microphoneSettingsAvailable = false;
        this.recordingStatusMessage =
          '当前设备无法确认麦克风权限状态，请稍后重试';
        return false;
      }
      if (permissionStatus === abilityAccessCtrl.PermissionStatus.NOT_DETERMINED) {
        const result: PermissionRequestResult =
          await atManager.requestPermissionsFromUser(context, [microphonePermission]);
        if (result.authResults[0] !== 0) {
          this.microphoneSettingsAvailable = true;
          this.recordingStatusMessage =
            '未获得麦克风权限，请在系统设置中开启；你仍可返回地图继续浏览';
          return false;
        }
      }
      this.microphoneSettingsAvailable = false;

      const volumeManager = audio.getAudioManager().getVolumeManager();
      const volumeGroupManager =
        await volumeManager.getVolumeGroupManager(audio.DEFAULT_VOLUME_GROUP_ID);
      if (await volumeGroupManager.isMicrophoneMute()) {
        const enabled = await atManager.requestGlobalSwitch(
          context,
          abilityAccessCtrl.SwitchType.MICROPHONE
        );
        if (!enabled) {
          this.recordingStatusMessage =
            '系统麦克风总开关仍处于关闭状态，开启后才能录音';
          return false;
        }
      }
      return true;
    } catch (_error) {
      this.recordingStatusMessage =
        '无法检查麦克风状态，请稍后重试；你仍可返回浏览地图';
      return false;
    }
  }

  private async recoverMicrophonePermission(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.recordingStatusMessage = '正在打开系统权限设置';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const microphonePermission: Permissions = 'ohos.permission.MICROPHONE';
      const results = await abilityAccessCtrl.createAtManager()
        .requestPermissionOnSetting(context, [microphonePermission]);
      this.microphoneSettingsAvailable = results[0] !== 0;
      this.recordingStatusMessage = this.microphoneSettingsAvailable ?
        '麦克风权限仍未开启；你可以返回地图继续浏览' :
        '麦克风权限已开启，可以开始录音';
    } catch (_error) {
      this.recordingStatusMessage = '未能打开权限设置，请稍后重试';
    } finally {
      this.actionInFlight = false;
    }
  }

  private async cancelRecording(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.clearRecordingTimer();
    try {
      await this.captureService.release();
      this.resetRecordingState('已取消并释放本次录音，可以重新开始');
    } finally {
      this.actionInFlight = false;
    }
  }

  private async handleRecordingInterruption(): Promise<void> {
    if (this.recordingState !== RecordingState.RECORDING ||
      this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.clearRecordingTimer();
    try {
      await this.captureService.release();
      this.resetRecordingState(
        '录音被通话或其他音频任务中断，本次数据已释放，请重新录制'
      );
    } finally {
      this.actionInFlight = false;
    }
  }

  private async playCapturedAudio(): Promise<void> {
    if (this.actionInFlight) {
      return;
    }
    this.actionInFlight = true;
    this.playbackInFlight = true;
    this.recordingStatusMessage = '正在播放当前页面内的临时录音';
    try {
      await this.captureService.play();
      this.recordingStatusMessage = '播放完成；离开页面后录音会立即释放';
    } catch (_error) {
      this.recordingStatusMessage = '播放失败，可重新录制后再试';
    } finally {
      this.playbackInFlight = false;
      this.actionInFlight = false;
    }
  }

  private startRecordingTimer(): void {
    this.clearRecordingTimer();
    this.recordingTimerId = setInterval((): void => {
      this.elapsedSeconds += 1;
      if (this.elapsedSeconds >= 15) {
        this.finishRealRecording();
      }
    }, 1000);
  }

  private clearRecordingTimer(): void {
    if (this.recordingTimerId >= 0) {
      clearInterval(this.recordingTimerId);
      this.recordingTimerId = -1;
    }
  }

  private formatDuration(seconds: number): string {
    const safeSeconds = Math.max(0, Math.min(99, seconds));
    return '00:' + safeSeconds.toString().padStart(2, '0');
  }

  private liveSoundFeedback(): string {
    if (this.amplitude < 0.008) {
      return '还没听到声音，请确认麦克风没有被遮挡';
    }
    if (this.amplitude < 0.03) {
      return '声音偏小，请靠近麦克风一点';
    }
    if (this.amplitude > 0.94) {
      return '声音很大，请稍微离远一点避免失真';
    }
    return '声音已采集，继续自然地说家乡话';
  }

  private resetRecordingState(message: string): void {
    this.recordingState = RecordingState.READY;
    this.elapsedSeconds = 0;
    this.recordingStatusMessage = message;
    this.waveform = [0, 0, 0, 0, 0, 0, 0, 0];
    this.amplitude = 0;
    this.lastAmplitudeUpdateAtMs = 0;
    this.playbackInFlight = false;
  }
}

@Component
struct AssessmentMetric {
  @Prop label: string;
  @Prop value: number;
  @Prop color: ResourceColor;

  build() {
    Row() {
      Column({ space: 5 }) {
        Text(this.label)
          .fontSize(12)
          .fontColor(MUTED)
        Text(this.value.toString() + '%')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.color)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      Progress({ value: this.value, total: 100, type: ProgressType.Ring })
        .width(58)
        .height(58)
        .color(this.color)
        .backgroundColor($r('app.color.divider'))
    }
    .width('100%')
  }
}
