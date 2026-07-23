import { VoicePassport } from '../models/DialectModels';

const PAPER: ResourceColor = $r('app.color.background_page');
const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');
const GREEN: ResourceColor = $r('app.color.confirm');

@Component
export struct VoicePassportPage {
  @Prop passport: VoicePassport;
  onBack: () => void = (): void => {};
  @State voicePlaying: boolean = false;
  @State shareReady: boolean = false;

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle }) {
          Text('‹').fontSize(28).fontColor(INK)
        }
        .width(48)
        .height(48)
        .backgroundColor($r('app.color.surface_primary'))
        .onClick(this.onBack)
        .accessibilityText('返回上一页')
        Blank()
        Column({ space: 2 }) {
          Text('乡音护照')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('VOICE PASSPORT')
            .fontSize(12)
            .fontColor(MUTED)
            .letterSpacing(1.1)
        }
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('↗').fontSize(18).fontColor(INK)
        }
        .width(48)
        .height(48)
        .backgroundColor($r('app.color.surface_primary'))
        .onClick((): void => { this.shareReady = true; })
        .accessibilityText('分享个人乡音名片')
      }
      .width('100%')
      .padding({ left: 18, right: 18, top: 42, bottom: 16 })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 10 }) {
            Stack() {
              Text(this.passport.initials)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.on_emphasis'))
            }
            .width(82)
            .height(82)
            .borderRadius(41)
            .backgroundColor(GREEN)
            .border({ width: 4, color: $r('app.color.surface_primary') })
            .shadow({ radius: 20, color: $r('app.color.shadow_soft') })

            Text(this.passport.nickname)
              .fontSize(27)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text(this.passport.location)
              .fontSize(13)
              .fontColor(MUTED)
            Text(this.passport.dialectName)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(ACCENT)
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor($r('app.color.surface_accent_soft'))
              .borderRadius(8)
          }
          .width('100%')
          .padding({ top: 18, bottom: 12 })

          Column({ space: 14 }) {
            Text('方言归属')
              .fontSize(12)
              .fontColor(MUTED)
              .width('100%')
            Text(this.passport.dialectName)
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .width('100%')

            Row() {
              PassportMetric({
                label: '鉴定置信度',
                value: this.passport.confidence,
                color: ACCENT
              })
              Divider().vertical(true).height(54).color($r('app.color.divider'))
              PassportMetric({
                label: '乡音保留度',
                value: this.passport.retention,
                color: GREEN
              })
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(18)
          .border({ width: 1, color: $r('app.color.border') })

          Column({ space: 12 }) {
            Text('代表语音')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .width('100%')
            Text(this.passport.representativeVoiceTitle)
              .fontSize(13)
              .fontColor(MUTED)
              .width('100%')
            Row({ space: 12 }) {
              Button({ type: ButtonType.Circle }) {
                Text(this.voicePlaying ? 'Ⅱ' : '▶')
                  .fontSize(14)
                  .fontColor($r('app.color.on_emphasis'))
              }
              .width(38)
              .height(38)
              .backgroundColor(ACCENT)
              .onClick((): void => { this.voicePlaying = !this.voicePlaying; })
              Column({ space: 5 }) {
                Progress({
                  value: this.voicePlaying ? 62 : 0,
                  total: 100,
                  type: ProgressType.Linear
                })
                  .color(ACCENT)
                  .backgroundColor($r('app.color.divider'))
                  .height(4)
                Text(this.formatDuration(this.passport.representativeVoiceDurationSeconds))
                  .fontSize(12)
                  .fontColor(MUTED)
                  .width('100%')
                  .textAlign(TextAlign.End)
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(18)
          .border({ width: 1, color: $r('app.color.border') })

          Column({ space: 12 }) {
            Text('已点亮地区')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(this.passport.litRegions as string[], (region: string): void => {
                Text(region)
              .fontSize(12)
                  .fontColor(GREEN)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor($r('app.color.surface_confirm_soft'))
                  .borderRadius(8)
              }, (region: string): string => region)
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(18)
          .border({ width: 1, color: $r('app.color.border') })

          Row() {
            SocialMetric({ value: this.passport.fellowFriends, label: '同乡好友' })
            SocialMetric({ value: this.passport.following, label: '关注' })
            SocialMetric({ value: this.passport.followers, label: '被关注' })
          }
          .width('100%')
          .padding({ top: 17, bottom: 17 })
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(18)
          .border({ width: 1, color: $r('app.color.border') })

          Button(this.shareReady ? '乡音名片已准备（演示）' : '分享个人乡音名片')
            .height(48)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
            .backgroundColor(this.shareReady ? GREEN : INK)
            .borderRadius(14)
            .onClick((): void => { this.shareReady = true; })
        }
        .padding({ left: 18, right: 18, bottom: 36 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(PAPER)
  }

  private formatDuration(seconds: number): string {
    return '00:' + (seconds < 10 ? '0' : '') + seconds.toString();
  }
}

@Component
struct PassportMetric {
  @Prop label: string;
  @Prop value: number;
  @Prop color: ResourceColor;

  build() {
    Column({ space: 5 }) {
      Text(this.label)
        .fontSize(12)
        .fontColor(MUTED)
      Text(this.value.toString() + '%')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
struct SocialMetric {
  @Prop value: number;
  @Prop label: string;

  build() {
    Column({ space: 4 }) {
      Text(this.value.toString())
        .fontSize(19)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      Text(this.label)
        .fontSize(12)
        .fontColor(MUTED)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}
