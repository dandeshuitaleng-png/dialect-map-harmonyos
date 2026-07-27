import {
  CommunityGroup,
  GroupSource
} from '../models/DialectModels';
import { filterCommunityGroups } from '../services/MockCommunityService';
import { CommunityConversationRow } from './CommunityConversationRow';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT_TEXT: ResourceColor = $r('app.color.accent_text');

@Component
export struct CommunityGroupList {
  @Prop groups: CommunityGroup[];
  @Prop joinedGroupIds: string[];
  @Link selectedSource: GroupSource;
  onOpenGroup: (groupId: string) => void = (_groupId: string): void => {};

  build() {
    Column({ space: 12 }) {
      Column({ space: 5 }) {
        Row({ space: 9 }) {
          Text('方言话题组')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('本机演示')
            .fontSize(10)
            .fontWeight(FontWeight.Bold)
            .fontColor(ACCENT_TEXT)
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor($r('app.color.brand_soft'))
            .borderRadius(8)
        }
        .width('100%')

        Text('从一句乡音、一个称呼或一段共同记忆开始交流')
          .fontSize(12)
          .fontColor(MUTED)
          .maxLines(2)
          .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 2 })
      .accessibilityGroup(true)

      Row({ space: 9 }) {
        Text('内容未同步')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(ACCENT_TEXT)
        Text('加入、回应、举报与屏蔽只在本次运行中生效')
          .fontSize(11)
          .fontColor(MUTED)
          .maxLines(2)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .accessibilityGroup(true)

      Row({ space: 4 }) {
        GroupSourceTab({
          label: '已加入',
          selected: this.selectedSource === GroupSource.JOINED,
          onSelect: (): void => {
            this.selectedSource = GroupSource.JOINED;
          }
        })
        GroupSourceTab({
          label: '为你推荐',
          selected: this.selectedSource === GroupSource.RECOMMENDED,
          onSelect: (): void => {
            this.selectedSource = GroupSource.RECOMMENDED;
          }
        })
        GroupSourceTab({
          label: '全部方言',
          selected: this.selectedSource === GroupSource.DIALECT,
          onSelect: (): void => {
            this.selectedSource = GroupSource.DIALECT;
          }
        })
      }
      .padding(4)
      .margin({ left: 20, right: 20 })
      .width('100%')
      .backgroundColor($r('app.color.surface_sunken'))
      .borderRadius(13)

      if (this.visibleGroups().length === 0) {
        this.emptyState()
      } else {
        List({ space: 10 }) {
          ForEach(
            this.visibleGroups(),
            (group: CommunityGroup, index: number): void => {
              ListItem() {
                CommunityConversationRow({
                  group: group,
                  joined: this.isJoined(group.id),
                  showDivider: index < this.visibleGroups().length - 1,
                  onOpen: this.onOpenGroup
                })
              }
            },
            (group: CommunityGroup): string => group.id
          )
        }
        .margin({ left: 20, right: 20 })
        .padding({ bottom: 20 })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  private emptyState() {
    Column({ space: 8 }) {
      Text(this.emptyTitle())
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      Text(this.emptyDescription())
        .fontSize(13)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
        .lineHeight(20)
    }
    .margin({ left: 20, right: 20 })
    .width('100%')
      .padding({ left: 24, right: 24, top: 34, bottom: 34 })
      .backgroundColor($r('app.color.surface_elevated'))
      .borderRadius(16)
      .border({ width: 1, color: $r('app.color.border') })
      .shadow({
        radius: 6,
        color: $r('app.color.shadow_card'),
        offsetY: 2
      })
    .accessibilityGroup(true)
  }

  private visibleGroups(): CommunityGroup[] {
    return filterCommunityGroups(
      this.groups,
      this.selectedSource,
      this.joinedGroupIds
    );
  }

  private emptyTitle(): string {
    if (this.selectedSource === GroupSource.JOINED) {
      return '还没有加入话题组';
    }
    return '该分类暂时没有群聊';
  }

  private emptyDescription(): string {
    if (this.selectedSource === GroupSource.JOINED) {
      return '切换到“为你推荐”或“全部方言”，找到想参与的乡音话题。';
    }
    return '试试其他分类，或稍后再来看看。';
  }

  private isJoined(groupId: string): boolean {
    return this.joinedGroupIds.indexOf(groupId) >= 0;
  }
}

@Component
struct GroupSourceTab {
  @Prop label: string;
  @Prop selected: boolean;
  onSelect: () => void = (): void => {};

  build() {
    Button(this.label)
      .fontSize(12)
      .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.selected ? ACCENT_TEXT : MUTED)
      .height(38)
      .layoutWeight(1)
      .backgroundColor(this.selected ?
        $r('app.color.brand_soft') : Color.Transparent)
      .borderRadius(10)
      .border({
        width: this.selected ? 1 : 0,
        color: this.selected ? ACCENT_TEXT : Color.Transparent
      })
      .onClick(this.onSelect)
      .accessibilityText(this.label + (this.selected ? '，已选中' : ''))
  }
}
