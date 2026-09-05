const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');

@Component
export struct PrivacyAboutPage {
  @Prop hasPassport: boolean = false;
  @Prop statusMessage: string = '';
  onBack: () => void = (): void => {};
  onClearData: () => void = (): void => {};

  build() {
    Column() {
      Row() {
        Button('‹')
          .width(48)
          .height(48)
          .fontSize(28)
          .fontColor(INK)
          .backgroundColor(Color.Transparent)
          .onClick(this.onBack)
          .accessibilityText('返回乡音地图')
        Text('隐私与关于')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
        Blank()
        Blank().width(48)
      }
      .height(56)
      .width('100%')
      .padding({ left: 8, right: 8 })
      .border({ width: { bottom: 1 }, color: $r('app.color.divider') })

      Scroll() {
        Column({ space: 14 }) {
          this.infoCard(
            '本地数据',
            '乡音护照、已点亮地区和分类结果仅保存在本机。原始录音不会写入文件，也不会上传。'
          )
          this.infoCard(
            '权限用途',
            '麦克风只在你主动录音时申请；位置只在你点击“我的位置”时申请。拒绝后仍可浏览地图并手动选择地区。'
          )
          this.infoCard(
            '体验边界',
            '方言鉴定为本机模拟；乡音人物、话题和消息为预置样例，不代表真实 AI 识别、实际用户或线上社交服务。'
          )
          this.infoCard(
            '版本与来源',
            '乡音地图 1.0.0 · HarmonyOS 6 / API 20
            分类目录版本：catalog-2026.07。十五个地点代表点已记录资料版本与定位页；出版授权仍待核验，应用未打包原图或原文。'
          )
          this.infoCard(
            '分类争议说明',
            '方言分区会随研究口径、调查点、时代与行政区边界而不同。当前点位和候选地域用于乡音文化体验，不构成权威分类；用户确认只修正本机展示，不会训练模型。'
          )

          if (this.statusMessage.length > 0) {
            Text(this.statusMessage)
              .fontSize(13)
              .fontColor(MUTED)
              .width('100%')
              .padding(14)
              .backgroundColor($r('app.color.surface_muted'))
              .borderRadius(12)
              .accessibilityText(this.statusMessage)
          }

          Button(this.hasPassport ? '清除乡音护照与点亮记录' : '当前没有可清除的乡音数据')
            .height(50)
            .width('100%')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.hasPassport ? $r('app.color.on_emphasis') : MUTED)
            .backgroundColor(this.hasPassport ? ACCENT : $r('app.color.surface_disabled'))
            .borderRadius(14)
            .enabled(this.hasPassport)
            .onClick(this.onClearData)
            .accessibilityText(this.hasPassport ?
              '清除本机乡音护照与点亮记录' : '当前没有可清除的数据')
        }
        .padding({ left: 20, right: 20, top: 20, bottom: 32 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }

  @Builder
  private infoCard(title: string, description: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
        .width('100%')
      Text(description)
        .fontSize(13)
        .lineHeight(20)
        .fontColor(MUTED)
        .width('100%')
    }
    .padding(18)
    .width('100%')
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(16)
    .border({ width: 1, color: $r('app.color.border') })
    .accessibilityGroup(true)
  }
}
