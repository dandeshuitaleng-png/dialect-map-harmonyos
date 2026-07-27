import {
  CommunityGroup,
  CommunityMessage
} from '../models/DialectModels';
import {
  getCommunityUnreadCount,
  getLatestCommunityMessage
} from '../services/MockCommunityService';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');

@Component
export struct CommunityConversationRow {
  @Prop group: CommunityGroup;
  @Prop joined: boolean = false;
  @Prop showDivider: boolean = true;
  @State focused: boolean = false;
  onOpen: (groupId: string) => void = (_groupId: string): void => {};

  build() {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 10 }) {
        Row({ space: 12 }) {
          Stack() {
            Text(this.group.avatarText)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .maxLines(1)
          }
          .width(48)
          .height(48)
          .backgroundColor(this.avatarColor())
          .borderRadius(12)

          Column({ space: 5 }) {
            Row({ space: 8 }) {
              Text(this.group.name)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(INK)
                .maxLines(1)
                .layoutWeight(1)

              if (this.joined) {
                Text('已加入')
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.confirm_text'))
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor($r('app.color.surface_confirm_soft'))
                  .borderRadius(8)
              }
            }
            .width('100%')

            Text(this.group.regionName + ' · ' + this.group.dialectName)
              .fontSize(12)
              .fontColor(MUTED)
              .maxLines(1)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')

        Text(this.group.summary)
          .fontSize(13)
          .fontColor(MUTED)
          .lineHeight(20)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row({ space: 8 }) {
          Text(this.group.accentLabel)
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.accent_text'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor($r('app.color.brand_soft'))
            .borderRadius(8)

          Text(this.group.memberCount.toString() + ' 人关注')
            .fontSize(11)
            .fontColor($r('app.color.ink_tertiary'))

          Blank()

          Text(this.lastMessageTimeLabel())
            .fontSize(11)
            .fontColor($r('app.color.ink_tertiary'))
        }
        .width('100%')

        Divider()
          .strokeWidth(1)
          .color($r('app.color.divider'))

        Row({ space: 8 }) {
          Text(this.lastMessagePreview())
            .fontSize(12)
            .fontColor(MUTED)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.joined && this.unreadCount() > 0) {
            Text(this.unreadLabel())
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .textAlign(TextAlign.Center)
              .minFontSize(9)
              .width(this.unreadCount() > 9 ? 24 : 18)
              .height(18)
              .backgroundColor($r('app.color.accent'))
              .borderRadius(9)
          }
        }
        .width('100%')
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 15, bottom: 14 })
    .backgroundColor($r('app.color.surface_elevated'))
    .border({
      width: this.focused ? 2 : 1,
      color: this.focused ?
        $r('app.color.focus') : $r('app.color.border')
    })
    .borderRadius(16)
    .onClick((): void => { this.onOpen(this.group.id); })
    .focusable(true)
    .onFocus((): void => { this.focused = true; })
    .onBlur((): void => { this.focused = false; })
    .accessibilityGroup(true)
    .accessibilityText(this.accessibilityLabel())
  }

  private unreadLabel(): string {
    return this.unreadCount() > 99 ?
      '99+' : this.unreadCount().toString();
  }

  private accessibilityLabel(): string {
    let label = this.group.name + '，' + this.group.regionName + '，' +
      this.group.dialectName + '，' + this.group.summary + '，' +
      this.lastMessagePreview() + '，本机演示话题组';
    if (this.joined && this.unreadCount() > 0) {
      label += '，' + this.unreadCount().toString() + '条演示未读';
    }
    return label;
  }

  private latestMessage(): CommunityMessage | undefined {
    return getLatestCommunityMessage(this.group.id);
  }

  private unreadCount(): number {
    return getCommunityUnreadCount(this.group);
  }

  private lastMessagePreview(): string {
    const message = this.latestMessage();
    if (message !== undefined && message.isLocalOnly) {
      return '我：' + message.content;
    }
    return this.group.lastMessagePreview;
  }

  private lastMessageTimeLabel(): string {
    const message = this.latestMessage();
    if (message !== undefined && message.isLocalOnly) {
      return message.timeLabel;
    }
    return this.group.lastMessageTimeLabel;
  }

  private avatarColor(): ResourceColor {
    if (this.group.dialectName.indexOf('粤语') >= 0) {
      return $r('app.color.avatar_cantonese');
    }
    if (this.group.regionName.indexOf('上海') >= 0) {
      return $r('app.color.avatar_shanghai');
    }
    if (this.group.regionName.indexOf('北京') >= 0) {
      return $r('app.color.avatar_beijing');
    }
    return $r('app.color.avatar_default');
  }
}
