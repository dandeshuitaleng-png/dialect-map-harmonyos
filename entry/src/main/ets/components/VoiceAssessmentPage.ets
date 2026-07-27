import {
  DialectAssessment,
  DialectRegionCandidate,
  RecordingState
} from '../models/DialectModels';
import {
  confirmSimulatedAssessment,
  correctSimulatedAssessment,
  createSimulatedAssessment
} from '../services/MockDialectService';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import { audio } from '@kit.AudioKit';
import { TransientAudioCaptureService } from '../services/TransientAudioCaptureService';

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
  onBack: () => void = (): void => {};
  onComplete: (assessment: DialectAssessment) => void =
    (_assessment: DialectAssessment): void => {};
  @State recordingState: RecordingState = RecordingState.READY;
  @State assessment: DialectAssessment =
    createSimulatedAssessment('四川', '四川话');
  @State resultConfirmed: boolean = false;
  @State elapsedSeconds: number = 0;
  @State recordingStatusMessage: string =
    '录音只用于本次采集验证，不保存、不上传；鉴定结果仍为模拟。';
  @State actionInFlight: boolean = false;
  private captureService: TransientAudioCaptureService =
    new TransientAudioCaptureService();
  private recordingTimerId: number = -1;

  aboutToDisappear(): void {
    this.clearRecordingTimer();
    this.captureService.release();
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
          .onClick(this.onBack)
          .accessibilityText('返回乡音地图')

          Blank()

          Text('真实录音 · 模拟鉴定')
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

      if (this.recordingState === RecordingState.RESULT) {
        this.resultContent()
      } else {
        this.recordingContent()
      }

      Text('麦克风音频不会保存或上传；鉴定结果仍是固定模拟数据，不代表真实 AI 识别。')
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

  @Builder
  resultContent() {
    Scroll() {
      Column({ space: 14 }) {
        Column({ space: 9 }) {
          Text('模拟鉴定完成')
            .fontSize(12)
            .fontColor(CONFIRM_TEXT)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(1)
          Text(this.assessment.dialectName)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(this.assessment.dialectFamily + ' · ' +
            this.assessment.dialectGroup + ' · ' + this.assessment.dialectBranch)
            .fontSize(12)
            .fontColor(MUTED)
        }
        .padding({ top: 24, bottom: 12 })

        Column({ space: 18 }) {
          AssessmentMetric({
            label: '鉴定置信度',
            value: this.assessment.confidence,
            color: ACCENT_TEXT
          })
          Divider().color($r('app.color.divider'))
          AssessmentMetric({
            label: '乡音保留度',
            value: this.assessment.retention,
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
          ForEach(this.assessment.regionCandidates, (candidate: DialectRegionCandidate): void => {
            Row() {
              Text(candidate.name)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(INK)
              Blank()
              Text(candidate.confidence.toString() + '%')
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(candidate.name === this.assessment.regionCandidates[0].name ?
                  ACCENT_TEXT : MUTED)
            }
            .width('100%')
          }, (candidate: DialectRegionCandidate): string => candidate.name)
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_primary'))
        .borderRadius(16)
        .border({ width: 1, color: $r('app.color.border') })

        Column({ space: 10 }) {
          Text('识别依据')
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
          ForEach(this.assessment.evidence, (item: string): void => {
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
          Text('相似乡音：' + this.assessment.similarDialects.join('、'))
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_muted'))
        .borderRadius(16)

        Column({ space: 10 }) {
          Text('即将点亮')
            .fontSize(12)
            .fontColor(MUTED)
            .width('100%')
          Row() {
            Column({ space: 3 }) {
              Text(this.assessment.dialectGroup + ' · ' + this.assessment.dialectBranch)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(INK)
              Text('在' + this.assessment.regionName + '留下乡音足迹')
                .fontSize(12)
                .fontColor(MUTED)
            }
            .alignItems(HorizontalAlign.Start)
            Blank()
            Text('演示片区')
              .fontSize(12)
              .fontColor(CONFIRM_TEXT)
          }
          .width('100%')
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_confirm_soft'))
        .borderRadius(16)

        Text('这是固定模拟数据，仅用于验证产品流程。真实鉴定需另行接入模型、隐私授权与内容审核。')
          .fontSize(12)
          .fontColor(MUTED)
          .lineHeight(18)
          .padding(14)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)

        if (!this.resultConfirmed && !this.correctionOpen) {
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
                this.assessment = confirmSimulatedAssessment(this.assessment);
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
            Button('四川话 · 成渝片')
              .width('100%')
              .height(44)
              .fontColor(INK)
              .backgroundColor($r('app.color.surface_primary'))
              .border({ width: 1, color: $r('app.color.border') })
              .onClick((): void => {
                this.applyCorrection('四川', '四川话');
              })
            Button('重庆话 · 成渝片')
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
              .fontColor(ACCENT_TEXT)
              .backgroundColor(Color.Transparent)
              .onClick((): void => { this.restartRecording(); })
          }
          .padding(16)
          .backgroundColor($r('app.color.surface_confirm_soft'))
          .borderRadius(16)
        }

        if (this.resultConfirmed) {
          Text('已由你确认：' + this.assessment.dialectName + ' · ' +
            this.assessment.dialectBranch)
            .fontSize(12)
            .fontColor(CONFIRM_TEXT)
            .width('100%')
          Button('点亮' + this.assessment.dialectBranch + '并生成乡音护照')
            .width('100%')
            .height(50)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
            .backgroundColor(ACCENT_FILL)
            .borderRadius(14)
            .onClick((): void => { this.onComplete(this.assessment); })
        }
        Blank().height(24)
      }
      .padding({ left: 20, right: 20 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
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
      this.recordingState = RecordingState.ASSESSING;
      return;
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      this.recordingState = RecordingState.RESULT;
    }
  }

  private applyCorrection(regionName: string, dialectName: string): void {
    this.assessment = correctSimulatedAssessment(
      this.assessment,
      regionName,
      dialectName
    );
    this.correctionOpen = false;
    this.resultConfirmed = true;
  }

  private restartRecording(): void {
    this.clearRecordingTimer();
    this.captureService.release();
    this.assessment = createSimulatedAssessment('四川', '四川话');
    this.correctionOpen = false;
    this.resultConfirmed = false;
    this.recordingState = RecordingState.READY;
    this.elapsedSeconds = 0;
    this.recordingStatusMessage =
      '录音只用于本次采集验证，不保存、不上传；鉴定结果仍为模拟。';
  }

  private stepEyebrow(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '正在录音';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '录音完成';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '正在模拟鉴定';
    }
    return '第一步';
  }

  private stepTitle(): string {
    if (this.recordingState === RecordingState.RECORDING) {
      return '说一句家乡话';
    }
    if (this.recordingState === RecordingState.RECORDED) {
      return '听起来很清楚';
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
      return '确认后将使用固定模拟数据展示鉴定结果';
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
      return '开始模拟鉴定';
    }
    if (this.recordingState === RecordingState.ASSESSING) {
      return '查看模拟结果';
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
    this.actionInFlight = true;
    this.clearRecordingTimer();
    try {
      const capturedBytes = await this.captureService.stop();
      if (capturedBytes <= 0) {
        this.recordingStatusMessage = '没有采集到有效音频，请重新录制';
        this.recordingState = RecordingState.READY;
        this.elapsedSeconds = 0;
        return;
      }
      this.recordingState = RecordingState.RECORDED;
      this.recordingStatusMessage =
        '已完成真实录音采集，音频数据已释放；下一步使用固定模拟结果';
    } catch (_error) {
      await this.captureService.release();
      this.recordingState = RecordingState.READY;
      this.elapsedSeconds = 0;
      this.recordingStatusMessage = '结束录音失败，采集资源已释放，请重试';
    } finally {
      this.actionInFlight = false;
    }
  }

  private async ensureMicrophoneAvailable(): Promise<boolean> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const atManager = abilityAccessCtrl.createAtManager();
      const microphonePermission: Permissions = 'ohos.permission.MICROPHONE';
      if (atManager.getSelfPermissionStatus(microphonePermission) !==
        abilityAccessCtrl.PermissionStatus.GRANTED) {
        const result: PermissionRequestResult =
          await atManager.requestPermissionsFromUser(context, [microphonePermission]);
        if (result.authResults[0] !== 0) {
          this.recordingStatusMessage =
            '未获得麦克风权限。你仍可返回浏览地图；再次录音时可在系统设置中授权。';
          return false;
        }
      }

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
