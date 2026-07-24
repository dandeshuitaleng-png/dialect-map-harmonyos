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
  @State sharePreviewOpen: boolean = false;
  @State shareReady: boolean = false;
  @State windowWidth: number = 360;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.titleBar()

        Scroll() {
          if (this.isWideLayout()) {
            Row({ space: 20 }) {
              Column({ space: 16 }) {
                this.identityPassportCard(false)
                this.shareAction()
              }
              .width('40%')

              Column({ space: 16 }) {
                this.metricsCard()
                this.voiceCard()
                this.litRegionsCard()
                this.socialCard()
              }
              .layoutWeight(1)
            }
            .alignItems(VerticalAlign.Top)
            .width('100%')
            .constraintSize({ maxWidth: 1180 })
            .padding({ left: 32, right: 32, top: 20, bottom: 40 })
          } else {
            Column({ space: 14 }) {
              this.identityPassportCard(false)
              this.metricsCard()
              this.voiceCard()
              this.litRegionsCard()
              this.socialCard()
              this.shareAction()
            }
            .width('100%')
            .constraintSize({ maxWidth: 620 })
            .padding({ left: 18, right: 18, top: 10, bottom: 36 })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(PAPER)

      if (this.sharePreviewOpen) {
        this.sharePreview()
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.windowWidth = Number(newValue.width);
    })
  }

  @Builder
  private titleBar() {
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
      .onClick((): void => { this.sharePreviewOpen = true; })
      .accessibilityText('预览并分享个人乡音名片')
    }
    .width('100%')
    .height(72)
    .padding({ left: this.isWideLayout() ? 32 : 18, right: this.isWideLayout() ? 32 : 18 })
    .backgroundColor(PAPER)
  }

  @Builder
  private identityPassportCard(compact: boolean) {
    Column({ space: compact ? 12 : 16 }) {
      Row() {
        Column({ space: 2 }) {
          Text('中国乡音护照')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis_secondary'))
            .letterSpacing(1)
          Text('VOICE IDENTITY')
            .fontSize(12)
            .fontColor($r('app.color.on_emphasis_secondary'))
            .letterSpacing(1.2)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text('NO. ' + this.passportNumber())
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis_secondary'))
      }
      .width('100%')

      Row({ space: 14 }) {
        Stack() {
          Text(this.passport.initials)
            .fontSize(compact ? 20 : 26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
        }
        .width(compact ? 60 : 74)
        .height(compact ? 60 : 74)
        .borderRadius(compact ? 30 : 37)
        .backgroundColor(ACCENT)
        .border({ width: 3, color: $r('app.color.on_emphasis') })

        Column({ space: 5 }) {
          Text(this.passport.nickname)
            .fontSize(compact ? 22 : 28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
          Text(this.passport.location)
            .fontSize(13)
            .fontColor($r('app.color.on_emphasis_secondary'))
          Text(this.passport.dialectName)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
          Text(this.passport.dialectFamily + ' · ' + this.passport.dialectGroup +
            ' · ' + this.passport.dialectBranch)
            .fontSize(12)
            .fontColor($r('app.color.on_emphasis_secondary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Divider().color($r('app.color.on_emphasis_secondary'))

      Column({ space: 10 }) {
        Row() {
          Text('乡音足迹')
            .fontSize(12)
            .fontColor($r('app.color.on_emphasis_secondary'))
          Blank()
          Text(this.passport.litRegions.length.toString() + ' 个地区')
            .fontSize(12)
            .fontColor($r('app.color.on_emphasis_secondary'))
        }
        .width('100%')

        Row({ space: 8 }) {
          ForEach(this.passport.litRegions as string[], (region: string, index: number): void => {
            if (index > 0) {
              Divider()
                .width(24)
                .strokeWidth(2)
                .color($r('app.color.on_emphasis_secondary'))
            }
            Column({ space: 4 }) {
              Circle()
                .width(12)
                .height(12)
                .fill(index === 0 ? ACCENT : $r('app.color.on_emphasis'))
              Text(region)
                .fontSize(12)
                .fontColor($r('app.color.on_emphasis'))
            }
          }, (region: string): string => region)
        }
        .width('100%')
      }

      Row() {
        Text('方言归属')
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis_secondary'))
        Blank()
        Column({ space: 2 }) {
          Text(this.passport.dialectGroup + ' · ' + this.passport.dialectBranch)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
          Text(this.passport.dialectName)
            .fontSize(12)
            .fontColor($r('app.color.on_emphasis_secondary'))
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
    .width('100%')
    .padding(compact ? 18 : 22)
    .backgroundColor(GREEN)
    .borderRadius(22)
    .shadow({ radius: 22, color: $r('app.color.shadow_soft'), offsetY: 8 })
    .accessibilityGroup(true)
    .accessibilityText(
      this.passport.nickname + '，' + this.passport.location + '，' +
      this.passport.dialectName + '乡音护照'
    )
  }

  @Builder
  private metricsCard() {
    Column({ space: 16 }) {
      Row() {
        Text('乡音鉴定')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Blank()
        Text(this.passport.dialectName)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(ACCENT)
          .padding({ left: 9, right: 9, top: 5, bottom: 5 })
          .backgroundColor($r('app.color.surface_accent_soft'))
          .borderRadius(8)
      }
      .width('100%')

      Text(this.passport.dialectFamily + ' · ' + this.passport.dialectGroup +
        ' · ' + this.passport.dialectBranch)
        .fontSize(12)
        .fontColor(MUTED)
        .width('100%')

      Row() {
        PassportMetric({
          label: '鉴定置信度',
          value: this.passport.confidence,
          color: ACCENT
        })
        Divider().vertical(true).height(62).color($r('app.color.divider'))
        PassportMetric({
          label: '乡音保留度',
          value: this.passport.retention,
          color: GREEN
        })
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
    .backgroundColor($r('app.color.surface_primary'))
    .borderRadius(18)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private voiceCard() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('代表语音')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(this.passport.representativeVoiceTitle)
            .fontSize(13)
            .fontColor(MUTED)
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.formatDuration(this.passport.representativeVoiceDurationSeconds))
          .fontSize(12)
          .fontColor(MUTED)
      }
      .width('100%')

      Row({ space: 14 }) {
        Button({ type: ButtonType.Circle }) {
          Text(this.voicePlaying ? 'Ⅱ' : '▶')
            .fontSize(14)
            .fontColor($r('app.color.on_emphasis'))
        }
        .width(48)
        .height(48)
        .backgroundColor(ACCENT)
        .onClick((): void => { this.voicePlaying = !this.voicePlaying; })
        .accessibilityText(this.voicePlaying ? '暂停代表语音' : '播放代表语音')

        Column({ space: 7 }) {
          Progress({
            value: this.voicePlaying ? 62 : 0,
            total: 100,
            type: ProgressType.Linear
          })
            .color(ACCENT)
            .backgroundColor($r('app.color.divider'))
            .height(4)
          Row({ space: 3 }) {
            ForEach([8, 14, 10, 19, 12, 16, 7, 13], (height: number): void => {
              Divider()
                .vertical(true)
                .height(height)
                .strokeWidth(3)
                .color(this.voicePlaying ? ACCENT : $r('app.color.ink_tertiary'))
                .borderRadius(2)
            })
          }
          .height(20)
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
    .backgroundColor($r('app.color.surface_primary'))
    .borderRadius(18)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private litRegionsCard() {
    Column({ space: 14 }) {
      Text('已点亮地区')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(this.passport.litRegions as string[], (region: string): void => {
          Text(region)
            .fontSize(13)
            .fontColor(GREEN)
            .padding({ left: 12, right: 12, top: 7, bottom: 7 })
            .backgroundColor($r('app.color.surface_confirm_soft'))
            .borderRadius(9)
            .margin({ right: 8, bottom: 8 })
        }, (region: string): string => region)
      }
      .width('100%')
    }
    .padding(20)
    .width('100%')
    .backgroundColor($r('app.color.surface_primary'))
    .borderRadius(18)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private socialCard() {
    Row() {
      SocialMetric({ value: this.passport.fellowFriends, label: '同乡好友' })
      SocialMetric({ value: this.passport.following, label: '关注' })
      SocialMetric({ value: this.passport.followers, label: '被关注' })
    }
    .width('100%')
    .padding({ top: 18, bottom: 18 })
    .backgroundColor($r('app.color.surface_primary'))
    .borderRadius(18)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private shareAction() {
    Button('分享个人乡音名片')
      .height(50)
      .width('100%')
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor($r('app.color.on_emphasis'))
      .backgroundColor(INK)
      .borderRadius(14)
      .onClick((): void => { this.sharePreviewOpen = true; })
      .accessibilityText('预览并分享个人乡音名片')
  }

  @Builder
  private sharePreview() {
    Stack({ alignContent: this.isWideLayout() ? Alignment.Center : Alignment.Bottom }) {
      Column({ space: 16 }) {
        Row() {
          Column({ space: 3 }) {
            Text('分享乡音名片')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text('分享前不会包含精确位置或原始录音')
              .fontSize(12)
              .fontColor(MUTED)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button('×')
            .width(48)
            .height(48)
            .fontSize(22)
            .fontColor(INK)
            .backgroundColor(Color.Transparent)
            .onClick((): void => { this.sharePreviewOpen = false; })
            .accessibilityText('关闭分享预览')
        }
        .width('100%')

        this.identityPassportCard(true)

        Button(this.shareReady ? '乡音名片已准备（演示）' : '使用系统分享')
          .height(50)
          .width('100%')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_emphasis'))
          .backgroundColor(this.shareReady ? GREEN : ACCENT)
          .borderRadius(14)
          .onClick((): void => { this.shareReady = true; })
          .accessibilityText(this.shareReady ? '乡音名片已准备' : '使用系统分享')
      }
      .width(this.isWideLayout() ? 520 : '100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 28 })
      .backgroundColor(PAPER)
      .borderRadius(this.isWideLayout() ? 28 : { topLeft: 28, topRight: 28 })
      .shadow({ radius: 30, color: $r('app.color.shadow_soft') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.map_overlay'))
    .zIndex(10)
  }

  private isWideLayout(): boolean {
    return this.windowWidth >= 840;
  }

  private passportNumber(): string {
    return this.passport.nickname.length.toString().padStart(2, '0') +
      this.passport.confidence.toString() + this.passport.retention.toString();
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
    Column({ space: 6 }) {
      Text(this.label)
        .fontSize(12)
        .fontColor(MUTED)
      Text(this.value.toString() + '%')
        .fontSize(28)
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
    Column({ space: 5 }) {
      Text(this.value.toString())
        .fontSize(20)
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
