import { FellowUser } from '../models/DialectModels';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');

@Component
export struct PassportPreviewPanel {
  @Prop fellow: FellowUser | undefined = undefined;
  onOpenDetail: () => void = (): void => {};
  onClose: () => void = (): void => {};

  build() {
    Column() {
      if (this.fellow === undefined) {
        this.emptyState();
      } else {
        this.passportPreview(this.fellow!);
      }
    }
    .width(320)
    .height('100%')
    .padding({ left: 20, right: 20, top: 28, bottom: 28 })
    .backgroundColor($r('app.color.background_page'))
    .border({ width: { left: 1 }, color: $r('app.color.divider') })
  }

  @Builder
  private emptyState() {
    Column({ space: 12 }) {
      Text('乡音护照')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      Text('VOICE PASSPORT')
        .fontSize(12)
        .fontColor(MUTED)
        .letterSpacing(1.1)
      Divider().color($r('app.color.divider'))
      Text('从中间栏选择一位乡音人物，即可在这里查看护照摘要。')
        .fontSize(14)
        .fontColor(MUTED)
        .lineHeight(22)
        .textAlign(TextAlign.Center)
        .margin({ top: 36 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .accessibilityGroup(true)
    .accessibilityText('乡音护照预览，尚未选择乡音人物')
  }

  @Builder
  private passportPreview(fellow: FellowUser) {
    Column({ space: 18 }) {
      Row() {
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
        .alignItems(HorizontalAlign.Start)
        Blank()
        Button({ type: ButtonType.Circle }) {
          Text('×').fontSize(20).fontColor(MUTED)
        }
        .width(40).height(40)
        .backgroundColor($r('app.color.surface_primary'))
        .onClick(this.onClose)
        .accessibilityText('关闭乡音护照预览')
      }
      .width('100%')

      Column({ space: 14 }) {
        Row({ space: 12 }) {
          Stack() {
            Text(fellow.initials)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
          }
          .width(64).height(64)
          .borderRadius(32)
          .backgroundColor(ACCENT)
          .border({ width: 3, color: $r('app.color.on_emphasis') })

          Column({ space: 4 }) {
            Text(fellow.nickname)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text(fellow.location + ' · ' + fellow.distanceText)
              .fontSize(12)
              .fontColor(MUTED)
            Text(fellow.dialectName)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(ACCENT)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Divider().color($r('app.color.divider'))

        this.detailRow('方言归属', fellow.dialectFamily + ' · ' + fellow.dialectGroup)
        this.detailRow('细分片区', fellow.dialectBranch)
        this.detailRow('乡音足迹', fellow.litRegions.join(' · '))

        Row() {
          this.metric('鉴定置信度', fellow.confidence.toString() + '%')
          Divider().vertical(true).height(42).color($r('app.color.divider'))
          this.metric('乡音保留度', fellow.retention.toString() + '%')
        }
        .width('100%')
      }
      .width('100%')
      .padding(18)
      .backgroundColor($r('app.color.passport_surface_tint'))
      .borderRadius(20)

      Button('查看完整护照')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.on_emphasis'))
        .backgroundColor(ACCENT)
        .borderRadius(16)
        .onClick(this.onOpenDetail)
        .accessibilityText('查看' + fellow.nickname + '的完整乡音护照')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .accessibilityGroup(true)
    .accessibilityText(fellow.nickname + '的乡音护照预览，' + fellow.dialectName)
  }

  @Builder
  private detailRow(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor(MUTED)
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
        .maxLines(2)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private metric(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ACCENT)
      Text(label)
        .fontSize(12)
        .fontColor(MUTED)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }
}
