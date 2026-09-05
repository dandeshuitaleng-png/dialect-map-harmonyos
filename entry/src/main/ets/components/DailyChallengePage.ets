import { common, Want } from '@kit.AbilityKit';
import { DailyChallengeProgress, DailyDialectChallenge } from '../models/DialectModels';
import { completeDailyChallenge, fetchDailyDialectChallenge, loadDailyChallengeProgress } from '../services/DailyChallengeService';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent_text');

@Component
export struct DailyChallengePage {
  onBack: () => void = (): void => {};
  @State loading: boolean = true;
  @State challenge: DailyDialectChallenge | undefined = undefined;
  @State progress: DailyChallengeProgress = { lastCompletedDay: '', energy: 0, streak: 0, totalCompletions: 0 };
  @State selectedAnswer: string = '';
  @State submitted: boolean = false;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    this.load();
  }

  build() {
    Column() {
      Row() {
        Button('关闭').height(48).fontSize(16).fontWeight(FontWeight.Medium).fontColor(INK)
          .padding({ left: 18, right: 18 }).backgroundColor($r('app.color.surface_elevated')).borderRadius(24)
          .onClick(this.onBack).accessibilityText('关闭每日乡音挑战')
        Blank()
      }
      .height(68).padding({ left: 20, right: 20, top: 12 }).width('100%')

      if (this.loading) {
        LoadingProgress().width(32).height(32).margin({ top: 48, bottom: 16 })
        Text('正在核验今日真实方言语料…').fontSize(15).fontColor(MUTED)
      } else if (this.errorMessage.length > 0) {
        this.errorContent()
      } else if (this.challenge !== undefined) {
        this.challengeContent(this.challenge)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private errorContent() {
    Column({ space: 14 }) {
      Text('今日挑战暂不可用').fontSize(20).fontWeight(FontWeight.Bold).fontColor(INK)
      Text(this.errorMessage).fontSize(14).fontColor(MUTED).textAlign(TextAlign.Center)
      Button('重新加载').height(48).fontColor($r('app.color.on_emphasis'))
        .backgroundColor($r('app.color.accent')).borderRadius(16).onClick((): void => { this.load(); })
    }
    .padding(28).width('100%').margin({ top: 72 })
  }

  @Builder
  private challengeContent(challenge: DailyDialectChallenge) {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text(challenge.kindLabel).fontSize(14).fontWeight(FontWeight.Bold).fontColor(ACCENT)
          Text(challenge.title).fontSize(32).fontWeight(FontWeight.Bold).fontColor(INK).textAlign(TextAlign.Center)
          Text(challenge.instruction).fontSize(14).fontColor(MUTED).textAlign(TextAlign.Center)
        }
        .padding({ left: 22, right: 22, top: 16, bottom: 8 }).width('100%')

        Column({ space: 10 }) {
          Text('◉').fontSize(46).fontColor($r('app.color.on_emphasis')).width(82).height(82)
            .textAlign(TextAlign.Center).padding({ top: 15 }).backgroundColor($r('app.color.accent')).borderRadius(41)
          Text('播放真人授权录音').fontSize(20).fontWeight(FontWeight.Bold).fontColor(INK)
          Text(challenge.audio.dialectName + ' · ' + challenge.audio.attributionText).fontSize(13).fontColor(MUTED).textAlign(TextAlign.Center)
          Button('播放录音').height(52).width('100%').fontSize(17).fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis')).backgroundColor($r('app.color.accent')).borderRadius(18)
            .onClick((): void => { this.openUrl(challenge.audio.audioUrl); })
            .accessibilityText('在浏览器播放真人授权录音')
          Button(challenge.audio.licenseName + ' · 查看来源').height(40).width('100%').fontSize(12).fontColor(ACCENT)
            .backgroundColor(Color.Transparent)
            .onClick((): void => { this.openUrl(challenge.audio.sourceUrl); })
        }
        .padding(24).width('100%').backgroundColor($r('app.color.surface_elevated')).borderRadius(28)
        .alignItems(HorizontalAlign.Center)

        Text('你听到的是哪一种乡音？').fontSize(20).fontWeight(FontWeight.Bold).fontColor(INK).width('100%')
        ForEach(challenge.answers, (answer: string): void => {
          Button({ type: ButtonType.Normal }) {
            Text(answer).fontSize(16).fontWeight(FontWeight.Medium)
              .fontColor(this.answerColor(answer, challenge))
              .width('100%').textAlign(TextAlign.Start)
          }
            .width('100%').height(64).padding({ left: 20, right: 20 })
            .fontColor(this.answerColor(answer, challenge))
            .backgroundColor(this.answerBackground(answer, challenge)).borderRadius(20)
            .border({ width: 1, color: this.answerBorder(answer, challenge) })
            .onClick((): void => { this.selectAnswer(answer); })
            .accessibilityText('选择答案：' + answer)
        }, (answer: string): string => answer)

        if (!this.submitted) {
          Button('提交答案').height(56).width('100%').fontSize(17).fontWeight(FontWeight.Bold)
            .enabled(this.selectedAnswer.length > 0).fontColor($r('app.color.on_emphasis'))
            .backgroundColor($r('app.color.accent')).borderRadius(16).onClick((): void => { this.submit(challenge); })
        } else {
          this.resultCard(challenge)
        }
      }
      .padding({ left: 24, right: 24, top: 14, bottom: 30 }).width('100%').alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1).width('100%')
  }

  @Builder
  private resultCard(challenge: DailyDialectChallenge) {
    Column({ space: 7 }) {
      Text(this.selectedAnswer === challenge.correctAnswer ? '回答正确' : '答案揭晓')
        .fontSize(19).fontWeight(FontWeight.Bold).fontColor(INK)
      Text('正确答案：' + challenge.correctAnswer).fontSize(15).fontColor(ACCENT)
      Text('连续 ' + this.progress.streak.toString() + ' 天 · 已收集 ' + this.progress.energy.toString() + ' 点乡音能量')
        .fontSize(13).fontColor(MUTED)
      Text('奖励仅保存在本机；录音不会因作答被上传或用于鉴定。').fontSize(12).fontColor(MUTED).textAlign(TextAlign.Center)
    }
    .padding(20).width('100%').backgroundColor($r('app.color.brand_soft')).borderRadius(20)
  }

  private async load(): Promise<void> {
    this.loading = true; this.errorMessage = ''; this.challenge = undefined; this.selectedAnswer = ''; this.submitted = false;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.progress = await loadDailyChallengeProgress(context);
    try { this.challenge = await fetchDailyDialectChallenge(); }
    catch (error) { this.errorMessage = error instanceof Error ? error.message : '无法加载今日挑战'; }
    this.loading = false;
  }

  private async submit(challenge: DailyDialectChallenge): Promise<void> {
    if (this.selectedAnswer.length === 0) return;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.progress = await completeDailyChallenge(context);
    this.submitted = true;
  }

  private selectAnswer(answer: string): void { if (!this.submitted) this.selectedAnswer = answer; }
  private answerColor(answer: string, challenge: DailyDialectChallenge): ResourceColor {
    return this.submitted && answer === challenge.correctAnswer ? ACCENT : (answer === this.selectedAnswer ? ACCENT : INK);
  }
  private answerBackground(answer: string, _challenge: DailyDialectChallenge): ResourceColor {
    return answer === this.selectedAnswer ? $r('app.color.brand_soft') : $r('app.color.surface_elevated');
  }
  private answerBorder(answer: string, _challenge: DailyDialectChallenge): ResourceColor {
    return answer === this.selectedAnswer ? $r('app.color.accent') : $r('app.color.border');
  }
  private dateLabel(value: string): string { return value.length >= 10 ? value.slice(0, 10) : value; }
  private openUrl(value: string): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const want: Want = { action: 'ohos.want.action.viewData', uri: value };
    try { context.startAbility(want); } catch (_error) {}
  }
}
