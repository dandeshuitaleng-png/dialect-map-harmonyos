import { CommunityMessage } from '../models/DialectModels';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');

@Component
export struct CommunityChatBubble {
  @Prop message: CommunityMessage;
  @Prop maxBubbleWidth: number = 276;

  build() {
    Column({ space: 9 }) {
      if (this.message.timeSeparatorLabel.length > 0) {
        Text(this.message.timeSeparatorLabel)
          .fontSize(11)
          .fontColor($r('app.color.ink_tertiary'))
          .textAlign(TextAlign.Center)
          .width('100%')
      }

      if (this.message.isCurrentUser) {
        Row({ space: 9 }) {
          Blank()
          Column({ space: 5 }) {
            this.messageSurface()
            Text('未同步 · ' + this.message.timeLabel)
              .fontSize(10)
              .fontColor($r('app.color.ink_tertiary'))
          }
          .alignItems(HorizontalAlign.End)

          this.avatar(true)
        }
        .alignItems(VerticalAlign.Top)
        .width('100%')
      } else {
        Row({ space: 9 }) {
          this.avatar(false)

          Column({ space: 5 }) {
            Text(this.message.senderLabel)
              .fontSize(11)
              .fontColor(MUTED)
            this.messageSurface()
            Text(this.message.timeLabel)
              .fontSize(10)
              .fontColor($r('app.color.ink_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)

          Blank()
        }
        .alignItems(VerticalAlign.Top)
        .width('100%')
      }
    }
    .width('100%')
    .accessibilityGroup(true)
    .accessibilityText(this.accessibilityLabel())
  }

  @Builder
  private avatar(currentUser: boolean) {
    Stack() {
      Text(this.message.senderInitials)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(currentUser ?
          $r('app.color.on_emphasis') : $r('app.color.confirm_text'))
    }
    .width(38)
    .height(38)
    .backgroundColor(currentUser ?
      $r('app.color.accent') : $r('app.color.brand_soft'))
    .borderRadius(11)
    .border({
      width: currentUser ? 0 : 1,
      color: $r('app.color.border')
    })
  }

  @Builder
  private messageSurface() {
    Text(this.message.content)
      .fontSize(15)
      .fontColor(INK)
      .lineHeight(23)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .constraintSize({ maxWidth: this.maxBubbleWidth })
      .backgroundColor(this.message.isCurrentUser ?
        $r('app.color.brand_soft') : $r('app.color.surface_elevated'))
      .borderRadius(this.message.isCurrentUser ?
        { topLeft: 16, topRight: 5, bottomLeft: 16, bottomRight: 16 } :
        { topLeft: 5, topRight: 16, bottomLeft: 16, bottomRight: 16 })
      .border({
        width: 1,
        color: $r('app.color.border')
      })
      .shadow({
        radius: 6,
        color: $r('app.color.shadow_card'),
        offsetY: 2
      })
  }

  private accessibilityLabel(): string {
    if (this.message.isCurrentUser) {
      return '我发送的本机消息，未同步：' + this.message.content;
    }
    return this.message.senderLabel + '的演示消息：' + this.message.content;
  }
}
