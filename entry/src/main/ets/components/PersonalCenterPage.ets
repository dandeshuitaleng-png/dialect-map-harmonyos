import { FellowUser } from '../models/DialectModels';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent_text');

@Component
export struct PersonalCenterPage {
  @Prop currentUser: FellowUser | undefined = undefined;
  onBack: () => void = (): void => {};
  onStartAssessment: () => void = (): void => {};
  onOpenPassport: () => void = (): void => {};

  build() {
    Column() {
      Row() {
        Text('我的').fontSize(30).fontWeight(FontWeight.Bold).fontColor(INK).layoutWeight(1)
        Button('完成').height(44).fontSize(15).fontColor(ACCENT).backgroundColor(Color.Transparent)
          .onClick(this.onBack).accessibilityText('关闭个人中心')
      }
      .width('100%').padding({ left: 20, right: 16, top: 14, bottom: 12 })
      Scroll() {
        Column({ space: 22 }) {
          this.identityHero()
          this.passportCard()
          this.collectionCard()
          this.settingsRows()
        }
        .padding({ left: 20, right: 20, top: 8, bottom: 34 })
        .width('100%')
      }
      .layoutWeight(1).width('100%')
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background_page'))
  }

  @Builder
  private identityHero() {
    Column({ space: 20 }) {
      Row({ space: 14 }) {
        Text(this.currentUser === undefined ? '我' : this.currentUser!.initials)
          .fontSize(23).fontWeight(FontWeight.Bold).fontColor($r('app.color.on_emphasis'))
          .width(60).height(60).textAlign(TextAlign.Center).padding({ top: 16 })
          .backgroundColor('#33FFFFFF').borderRadius(30)
        Column({ space: 4 }) {
          Text(this.currentUser === undefined ? '等你的第一段乡音' : this.currentUser!.nickname)
            .fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.on_emphasis'))
          Text(this.currentUser === undefined ? '完成一次鉴定，生成你的乡音护照' : this.currentUser!.location + ' · ' + this.currentUser!.dialectName)
            .fontSize(13).fontColor($r('app.color.on_emphasis_secondary')).maxLines(2)
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('•••').fontSize(18).fontColor($r('app.color.on_emphasis')).width(36).textAlign(TextAlign.Center)
      }
      Row() {
        this.metric(this.currentUser === undefined ? '0' : this.currentUser!.litRegions.length.toString(), '点亮地区')
        Divider().vertical(true).height(38).color('#55FFFFFF')
        this.metric(this.currentUser === undefined ? '0' : '1', '乡音记录')
      }
      .width('100%')
    }
    .width('100%').padding(22).borderRadius(30)
    .linearGradient({ angle: 135, colors: [['#09514D', 0], ['#28766F', 0.55], ['#4F9B8B', 1]] })
  }

  @Builder
  private metric(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(25).fontWeight(FontWeight.Bold).fontColor($r('app.color.on_emphasis'))
      Text(label).fontSize(12).fontColor($r('app.color.on_emphasis_secondary'))
    }
    .layoutWeight(1).alignItems(HorizontalAlign.Center)
  }

  @Builder
  private passportCard() {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 10 }) {
        Text('乡音护照').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#FFF2E8').width('100%')
        Text(this.currentUser === undefined ? '你的乡音地图，等待第一枚印章' : this.currentUser!.dialectName + ' · ' + this.currentUser!.location)
          .fontSize(21).fontWeight(FontWeight.Bold).fontColor($r('app.color.on_emphasis')).width('100%')
        Text(this.currentUser === undefined ? '确认一次鉴定结果，即可生成专属护照' : '查看护照与已点亮代表点')
          .fontSize(13).fontColor('#FFF2E8').width('100%')
      }
      .width('100%').padding(22).alignItems(HorizontalAlign.Start)
    }
    .width('100%').borderRadius(26)
    .linearGradient({ angle: 135, colors: [['#A94031', 0], ['#C75E42', 0.55], ['#DD8145', 1]] })
    .onClick(this.currentUser === undefined ? this.onStartAssessment : this.onOpenPassport)
    .accessibilityText(this.currentUser === undefined ? '开始录音鉴定' : '打开乡音护照')
  }

  @Builder
  private collectionCard() {
    Column({ space: 7 }) {
      Text('继续探索').fontSize(13).fontWeight(FontWeight.Medium).fontColor(MUTED).width('100%')
      Text(this.currentUser === undefined ? '还没有乡音记录' : '最近一段乡音').fontSize(18).fontWeight(FontWeight.Bold).fontColor(INK).width('100%')
      Text(this.currentUser === undefined ? '录下第一段自然乡音，开始收集旅程。' : this.currentUser!.dialectName + ' · ' + this.currentUser!.location)
        .fontSize(14).fontColor(MUTED).width('100%')
    }
    .width('100%').padding(20).backgroundColor($r('app.color.surface_elevated')).borderRadius(22)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private settingsRows() {
    Column({ space: 0 }) {
      this.settingRow('语言与地区', '管理显示语言和地区偏好')
      this.settingRow('隐私与账号', '查看本机数据与服务状态')
      this.settingRow('关于乡音地图', '版本、资料与使用说明')
    }
    .width('100%').backgroundColor($r('app.color.surface_elevated')).borderRadius(22)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private settingRow(title: string, detail: string) {
    Row() {
      Column({ space: 3 }) {
        Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor(INK)
        Text(detail).fontSize(12).fontColor(MUTED)
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text('›').fontSize(28).fontColor(MUTED)
    }
    .width('100%').padding({ left: 18, right: 18, top: 16, bottom: 16 })
  }
}
