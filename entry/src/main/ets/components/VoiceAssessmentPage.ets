import { DialectAssessment, RecordingState } from '../models/DialectModels';
import { createSimulatedAssessment } from '../services/MockDialectService';

const PAPER: string = '#F4EFE5';
const INK: string = '#173A32';
const MUTED: string = '#6D7771';
const ACCENT: string = '#DB643D';
const GREEN: string = '#2F7766';

@Component
export struct VoiceAssessmentPage {
  onBack: () => void = (): void => {};
  onComplete: (assessment: DialectAssessment) => void =
    (_assessment: DialectAssessment): void => {};
  @State recordingState: RecordingState = RecordingState.READY;
  @State assessment: DialectAssessment =
    createSimulatedAssessment('四川', '四川话');

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('‹').fontSize(28).fontColor(INK)
        }
        .width(42)
        .height(42)
        .backgroundColor('#FFFDF8')
        .onClick(this.onBack)
        Blank()
        Text('录音鉴定')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Blank()
        Text('模拟')
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(ACCENT)
          .backgroundColor('#FFEDE2')
          .borderRadius(7)
          .padding({ left: 8, right: 8, top: 5, bottom: 5 })
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 42, bottom: 18 })

      if (this.recordingState === RecordingState.RESULT) {
        this.resultContent()
      } else {
        this.recordingContent()
      }

      Text('演示流程：不会调用麦克风，也不代表真实 AI 方言鉴定。')
        .fontSize(10)
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
          .fontSize(11)
          .fontColor(ACCENT)
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
          .fill(this.recordingState === RecordingState.RECORDING ? '#F8D9CA' : '#E9E2D7')
        Circle()
          .width(104)
          .height(104)
          .fill(this.recordingState === RecordingState.RECORDING ? ACCENT : GREEN)
        Text(this.recordingState === RecordingState.RECORDING ? '00:14' : '声')
          .fontSize(this.recordingState === RecordingState.RECORDING ? 20 : 26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
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
            Text('00:14')
              .fontSize(11)
              .fontColor(MUTED)
          }
          .width('100%')
          Progress({
            value: this.recordingState === RecordingState.ASSESSING ? 78 : 100,
            total: 100,
            type: ProgressType.Linear
          })
            .height(5)
            .color(this.recordingState === RecordingState.ASSESSING ? GREEN : ACCENT)
            .backgroundColor('#E2DDD3')
        }
        .padding(18)
        .width('100%')
        .backgroundColor('#FFFDF8')
        .borderRadius(16)
        .margin({ top: 22 })
      }

      Blank()

      Button(this.primaryLabel())
        .width('100%')
        .height(50)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor(this.recordingState === RecordingState.ASSESSING ? GREEN : ACCENT)
        .borderRadius(14)
        .onClick((): void => { this.advance(); })
    }
    .padding({ left: 20, right: 20, bottom: 18 })
    .layoutWeight(1)
    .width('100%')
  }

  @Builder
  resultContent() {
    Scroll() {
      Column({ space: 14 }) {
        Column({ space: 9 }) {
          Text('模拟鉴定完成')
            .fontSize(11)
            .fontColor(GREEN)
            .fontWeight(FontWeight.Bold)
            .letterSpacing(1)
          Text(this.assessment.dialectName)
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('发音接近：成都、眉山一带')
            .fontSize(12)
            .fontColor(MUTED)
        }
        .padding({ top: 24, bottom: 12 })

        Column({ space: 18 }) {
          AssessmentMetric({
            label: '鉴定置信度',
            value: this.assessment.confidence,
            color: ACCENT
          })
          Divider().color('#E8E2D8')
          AssessmentMetric({
            label: '乡音保留度',
            value: this.assessment.retention,
            color: GREEN
          })
        }
        .padding(20)
        .backgroundColor('#FFFDF8')
        .borderRadius(18)
        .border({ width: 1, color: '#E7E1D7' })

        Column({ space: 10 }) {
          Text('即将点亮')
            .fontSize(11)
            .fontColor(MUTED)
            .width('100%')
          Row() {
            Text('四川')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Blank()
            Text('乡音地区')
              .fontSize(11)
              .fontColor(GREEN)
          }
          .width('100%')
        }
        .padding(18)
        .backgroundColor('#EAF3EF')
        .borderRadius(16)

        Text('这是固定模拟数据，仅用于验证产品流程。真实鉴定需另行接入模型、隐私授权与内容审核。')
          .fontSize(11)
          .fontColor(MUTED)
          .lineHeight(18)
          .padding(14)
          .backgroundColor('#EFECE5')
          .borderRadius(12)

        Button('点亮四川并生成乡音护照')
          .width('100%')
          .height(50)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor(ACCENT)
          .borderRadius(14)
          .margin({ top: 8, bottom: 24 })
          .onClick((): void => { this.onComplete(this.assessment); })
      }
      .padding({ left: 20, right: 20 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  private advance(): void {
    if (this.recordingState === RecordingState.READY) {
      this.recordingState = RecordingState.RECORDING;
      return;
    }
    if (this.recordingState === RecordingState.RECORDING) {
      this.recordingState = RecordingState.RECORDED;
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
    return '开始录音演示';
  }
}

@Component
struct AssessmentMetric {
  @Prop label: string;
  @Prop value: number;
  @Prop color: string;

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
        .backgroundColor('#E8E3DA')
    }
    .width('100%')
  }
}

