import { VoicePassport } from '../models/DialectModels';

const PAPER: string = '#F4EFE5';
const INK: string = '#173A32';
const MUTED: string = '#6D7771';
const ACCENT: string = '#DB643D';
const GREEN: string = '#2F7766';

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
        .width(42)
        .height(42)
        .backgroundColor('#FFFDF8')
        .onClick(this.onBack)
        Blank()
        Column({ space: 2 }) {
          Text('乡音护照')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('VOICE PASSPORT')
            .fontSize(9)
            .fontColor(MUTED)
            .letterSpacing(1.1)
        }
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('↗').fontSize(18).fontColor(INK)
        }
        .width(42)
        .height(42)
        .backgroundColor('#FFFDF8')
        .onClick((): void => { this.shareReady = true; })
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
                .fontColor('#FFFFFF')
            }
            .width(82)
            .height(82)
            .borderRadius(41)
            .backgroundColor(GREEN)
            .border({ width: 4, color: '#FFFDF8' })
            .shadow({ radius: 20, color: 'rgba(31,89,75,0.22)' })

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
              .backgroundColor('#FFEDE2')
              .borderRadius(8)
          }
          .width('100%')
          .padding({ top: 18, bottom: 12 })

          Column({ space: 14 }) {
            Text('方言归属')
              .fontSize(11)
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
              Divider().vertical(true).height(54).color('#E3DED4')
              PassportMetric({
                label: '乡音保留度',
                value: this.passport.retention,
                color: GREEN
              })
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor('#FFFDF8')
          .borderRadius(18)
          .border({ width: 1, color: '#E9E3D9' })

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
                  .fontColor('#FFFFFF')
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
                  .backgroundColor('#E4E1D9')
                  .height(4)
                Text(this.formatDuration(this.passport.representativeVoiceDurationSeconds))
                  .fontSize(10)
                  .fontColor(MUTED)
                  .width('100%')
                  .textAlign(TextAlign.End)
              }
              .layoutWeight(1)
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor('#FFFDF8')
          .borderRadius(18)
          .border({ width: 1, color: '#E9E3D9' })

          Column({ space: 12 }) {
            Text('已点亮地区')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(this.passport.litRegions as string[], (region: string): void => {
                Text(region)
                  .fontSize(11)
                  .fontColor(GREEN)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor('#EAF3EF')
                  .borderRadius(8)
              }, (region: string): string => region)
            }
            .width('100%')
          }
          .padding(18)
          .backgroundColor('#FFFDF8')
          .borderRadius(18)
          .border({ width: 1, color: '#E9E3D9' })

          Row() {
            SocialMetric({ value: this.passport.fellowFriends, label: '同乡好友' })
            SocialMetric({ value: this.passport.following, label: '关注' })
            SocialMetric({ value: this.passport.followers, label: '被关注' })
          }
          .width('100%')
          .padding({ top: 17, bottom: 17 })
          .backgroundColor('#FFFDF8')
          .borderRadius(18)
          .border({ width: 1, color: '#E9E3D9' })

          Button(this.shareReady ? '乡音名片已准备（演示）' : '分享个人乡音名片')
            .height(48)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
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
  @Prop color: string;

  build() {
    Column({ space: 5 }) {
      Text(this.label)
        .fontSize(11)
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
        .fontSize(10)
        .fontColor(MUTED)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}

