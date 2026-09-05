import { CommunityGroup } from '../models/DialectModels';

@Component
export struct CommunityChatHeader {
  @Prop group: CommunityGroup;
  @Prop joined: boolean = false;
  onBack: () => void = (): void => {};
  onMembership: () => void = (): void => {};
  onSafety: () => void = (): void => {};

  build() {
    Column({ space: 8 }) {
      Row({ space: 10 }) {
        Button({ type: ButtonType.Circle }) {
          Text('‹')
            .fontSize(28)
            .fontColor($r('app.color.ink_primary'))
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(this.onBack)
        .accessibilityText('返回乡音话题组列表')

        Column({ space: 3 }) {
          Text(this.group.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink_primary'))
            .maxLines(1)
          Text(this.group.regionName + ' · ' + this.group.dialectName +
            ' · 本机体验')
            .fontSize(11)
            .fontColor($r('app.color.ink_muted'))
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .accessibilityGroup(true)

        Button(this.joined ? '已加入' : '加入')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.joined ?
            $r('app.color.confirm_text') : $r('app.color.ink_primary'))
          .height(48)
          .padding({ left: 12, right: 12 })
          .backgroundColor(this.joined ?
            $r('app.color.surface_confirm_soft') :
            $r('app.color.surface_muted'))
          .borderRadius(12)
          .onClick(this.onMembership)
          .accessibilityText(this.joined ?
            '管理本机加入状态' : '标记为本机已加入')
      }
      .width('100%')

      Row({ space: 8 }) {
        Text(this.group.accentLabel)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent_text'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor($r('app.color.brand_soft'))
          .borderRadius(8)

        Text('预置样例 · 未同步')
          .fontSize(10)
          .fontColor($r('app.color.ink_muted'))
          .layoutWeight(1)

        Button('说明与设置')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent_text'))
          .height(40)
          .padding({ left: 10, right: 10 })
          .backgroundColor(Color.Transparent)
          .onClick(this.onSafety)
          .accessibilityText('查看体验说明、隐私和本机屏蔽选项')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 10, right: 14, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.surface_primary'))
    .border({
      width: { bottom: 1 },
      color: $r('app.color.divider')
    })
  }
}
