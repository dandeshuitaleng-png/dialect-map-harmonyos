import curves from '@ohos.curves';
import {
  CommunityGroup,
  DiscoveryMode,
  FellowSource,
  FellowUser,
  GroupSource
} from '../models/DialectModels';
import { filterFellowsBySource } from '../services/MockDialectService';
import { CommunityGroupList } from './CommunityGroupList';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT_TEXT: ResourceColor = $r('app.color.accent_text');

@Component
export struct FellowPanel {
  @Prop users: FellowUser[];
  @Prop wideMode: boolean = false;
  @Prop portraitTabletMode: boolean = false;
  @Prop availableHeight: number = 720;
  @Prop litDialectCount: number = 0;
  @Prop totalDialectCount: number = 4;
  @Prop hasPassport: boolean = false;
  @Prop selectedRegionName: string = '';
  @Prop groups: CommunityGroup[];
  @Prop joinedGroupIds: string[];
  @Link expanded: boolean;
  @Link discoveryMode: DiscoveryMode;
  @Link selectedSource: FellowSource;
  @Link selectedGroupSource: GroupSource;
  onOpenUser: (userId: string) => void = (_userId: string): void => {};
  onOpenGroup: (groupId: string) => void = (_groupId: string): void => {};
  onStartAssessment: () => void = (): void => {};
  onOpenPassport: () => void = (): void => {};
  onOpenDirectory: () => void = (): void => {};
  onOpenDailyChallenge: () => void = (): void => {};
  onOpenPrivacy: () => void = (): void => {};
  onSelectRegion: (regionName: string) => void = (_regionName: string): void => {};
  @State panelHeight: number = 0;
  @State panelStage: number = 0;
  private panelStartHeight: number = 0;

  build() {
    Column() {
      Column() {
        if (!this.wideMode) {
          Row() {
            Divider()
              .width(38)
              .strokeWidth(4)
              .color($r('app.color.ink_tertiary'))
              .borderRadius(2)
          }
          .height(24)
          .justifyContent(FlexAlign.Center)
          .width('100%')
        }

      }

      Row() {
        Column({ space: 5 }) {
          Text('用声音点亮中国')
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('已点亮 ' + this.litDialectCount.toString() + ' / ' + this.totalDialectCount.toString() + ' 个方言代表点 · 0 点能量')
            .fontSize(14)
            .fontColor(MUTED)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .accessibilityGroup(true)
        .accessibilityText(
          this.panelTitle() + '，' + this.panelMetricValue() + this.panelMetricLabel()
        )

        Column({ space: 8 }) {
          Button({ type: ButtonType.Circle }) {
            Text(this.panelStage >= this.maximumStage() ? '⌄' : '⌃')
              .fontSize(26).fontWeight(FontWeight.Bold).fontColor(ACCENT_TEXT)
          }
          .width(52).height(52)
          .backgroundColor($r('app.color.brand_soft'))
          .onClick((): void => { this.advancePanelStage(); })
          .accessibilityText(this.panelStage >= this.maximumStage() ? '收起探索面板' : '展开探索面板')
        }
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: this.wideMode ? 24 : 0,
        bottom: 14
      })
      .alignItems(VerticalAlign.Center)

      Row() {
        DiscoveryModeTab({
          label: '乡音人物',
          selected: this.discoveryMode === DiscoveryMode.FELLOWS,
          onSelect: (): void => { this.discoveryMode = DiscoveryMode.FELLOWS; }
        })
        DiscoveryModeTab({
          label: '体验会话',
          selected: this.discoveryMode === DiscoveryMode.GROUPS,
          onSelect: (): void => { this.discoveryMode = DiscoveryMode.GROUPS; }
        })
      }
      .padding(4)
      .backgroundColor($r('app.color.surface_sunken'))
      .borderRadius(16)
      .margin({
        left: 20,
        right: 20,
        bottom: 16
      })
      .width('calc(100% - 40vp)')
      .justifyContent(FlexAlign.Start)

      if (this.discoveryMode === DiscoveryMode.FELLOWS) {
        Button({ type: ButtonType.Normal }) {
          this.dailyChallengeCard()
        }
        .width('calc(100% - 40vp)')
        .height(104)
        .margin({ left: 20, right: 20, bottom: 16 })
        .backgroundColor($r('app.color.accent'))
        .borderRadius(24)
        .linearGradient({
          angle: 0,
          colors: [[$r('app.color.accent_gradient_start'), 0], [$r('app.color.accent_gradient_end'), 1]]
        })
        .onClick(this.onOpenDailyChallenge)
        .accessibilityText('今日乡音挑战，听一句，猜一座城')
        Row({ space: 10 }) {
          Button('录音鉴定')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.on_emphasis'))
            .height(48)
            .layoutWeight(1)
            .backgroundColor($r('app.color.accent'))
            .linearGradient({
              angle: 100,
              colors: [
                [$r('app.color.accent_gradient_start'), 0],
                [$r('app.color.accent_gradient_end'), 1]
              ]
            })
            .borderRadius(16)
            .onClick(this.onStartAssessment)
            .accessibilityText('打开乡音录音鉴定面板')

          Button(this.hasPassport ? '我的乡音护照' : '鉴定后生成护照')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.hasPassport ? INK : MUTED)
            .height(48)
            .layoutWeight(1)
            .backgroundColor(this.hasPassport ?
              $r('app.color.surface_elevated') : $r('app.color.surface_disabled'))
            .borderRadius(16)
            .border({
              width: this.hasPassport ? 1 : 0,
              color: $r('app.color.border')
            })
            .enabled(this.hasPassport)
            .onClick(this.onOpenPassport)
            .accessibilityText(this.hasPassport ?
              '打开我的乡音护照' : '完成录音鉴定后生成乡音护照')
        }
        .padding({ left: 20, right: 20, bottom: 16 })
        .width('100%')

        Row({ space: 8 }) {
          SourceTab({
            label: '附近',
            selected: this.selectedSource === FellowSource.NEARBY,
            onSelect: (): void => { this.selectedSource = FellowSource.NEARBY; }
          })
          SourceTab({
            label: '推荐',
            selected: this.selectedSource === FellowSource.RECOMMENDED,
            onSelect: (): void => { this.selectedSource = FellowSource.RECOMMENDED; }
          })
          SourceTab({
            label: '当前地区',
            selected: this.selectedSource === FellowSource.CURRENT_REGION,
            onSelect: (): void => { this.selectedSource = FellowSource.CURRENT_REGION; }
          })
        }
        .padding(4)
        .margin({ left: 20, right: 20, bottom: 12 })
        .backgroundColor($r('app.color.surface_sunken'))
        .borderRadius(14)
        .width('calc(100% - 40vp)')

        Row({ space: 8 }) {
          Text(this.selectedRegionName.length > 0 ?
            '已选：' + this.selectedRegionName : '定位不可用也能手动选地区')
            .fontSize(12)
            .fontColor(MUTED)
            .layoutWeight(1)
            .maxLines(1)

          Button('手动选地区')
            .fontSize(12)
            .fontColor(ACCENT_TEXT)
            .height(40)
            .padding({ left: 14, right: 14 })
            .backgroundColor($r('app.color.brand_soft'))
            .borderRadius(20)
            .bindMenu([
              { value: '四川', action: (): void => { this.selectRegion('四川'); } },
              { value: '重庆', action: (): void => { this.selectRegion('重庆'); } },
              { value: '广州', action: (): void => { this.selectRegion('广州'); } },
              { value: '上海', action: (): void => { this.selectRegion('上海'); } },
              { value: '北京', action: (): void => { this.selectRegion('北京'); } }
            ])
            .accessibilityText('手动选择地区')
        }
        .padding({ left: 20, right: 20, bottom: 12 })
        .width('100%')

        List({ space: 8 }) {
          if (this.visibleUsers().length === 0) {
            ListItem() {
              Column({ space: 12 }) {
                Text('暂无乡音人物')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(INK)
                Text('录下你的第一段乡音，点亮地图。')
                  .fontSize(12)
                  .fontColor(MUTED)
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .padding({ left: 24, right: 24, top: 40, bottom: 40 })
              .accessibilityGroup(true)
            }
          } else {
            ForEach(this.visibleUsers(), (user: FellowUser): void => {
              ListItem() {
                FellowCard({ user: user, onOpen: this.onOpenUser })
              }
            }, (user: FellowUser): string => user.id)
          }
        }
        .margin({ left: 20, right: 20, bottom: 24 })
        .layoutWeight(1)
        .width('calc(100% - 40vp)')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        CommunityGroupList({
          groups: this.groups,
          joinedGroupIds: this.joinedGroupIds,
          selectedSource: $selectedGroupSource,
          onOpenGroup: this.onOpenGroup
        })
      }
    }
    .width('100%')
    .height(this.wideMode ? '100%' : this.currentPanelHeight())
    .backgroundColor($r('app.color.surface_glass'))
    .backgroundBlurStyle(BlurStyle.Regular)
    .linearGradient({
      angle: 115,
      colors: [
        [$r('app.color.glass_tint_warm'), 0],
        [Color.Transparent, 0.46],
        [$r('app.color.glass_tint_cool'), 1]
      ]
    })
    .borderRadius({ topLeft: 32, topRight: 32 })
    .border({
      width: { top: 1, left: 1, right: 1 },
      color: $r('app.color.surface_glass_highlight')
    })
    .shadow({ radius: 24, color: $r('app.color.shadow_soft'), offsetY: -5 })
    .priorityGesture(
      PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 4 })
        .onActionStart((): void => {
          this.panelStartHeight = this.currentPanelHeight();
          this.panelHeight = this.panelStartHeight;
        })
        .onActionUpdate((event: GestureEvent): void => {
          this.panelHeight = this.clampPanelHeight(
            this.panelStartHeight - event.offsetY
          );
        })
        .onActionEnd((event: GestureEvent): void => {
          this.settlePanel(event.velocityY);
        })
        .onActionCancel((): void => {
          this.snapToStage(this.panelStage);
        })
    )
  }

  private visibleUsers(): FellowUser[] {
    if (this.selectedSource === FellowSource.CURRENT_REGION &&
      this.selectedRegionName.length > 0) {
      return this.users.filter((user: FellowUser): boolean =>
        user.location.indexOf(this.selectedRegionName) >= 0
      );
    }
    return filterFellowsBySource(this.users, this.selectedSource);
  }

  private selectRegion(regionName: string): void {
    this.selectedSource = FellowSource.CURRENT_REGION;
    this.onSelectRegion(regionName);
  }

  @Builder
  private dailyChallengeCard() {
    Row({ space: 14 }) {
      Text('✦')
        .fontSize(34)
        .fontColor($r('app.color.on_emphasis'))
        .width(62)
        .height(62)
        .textAlign(TextAlign.Center)
        .padding({ top: 11 })
        .backgroundColor('#337FFFFFF')
        .borderRadius(31)
      Column({ space: 5 }) {
        Text('今日乡音挑战')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.on_emphasis_secondary'))
        Text('听一句，猜一座城')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_emphasis'))
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('↗')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.on_emphasis'))
    }
    .width('100%')
    .height('100%')
    .padding({ left: 18, right: 20 })
    .alignItems(VerticalAlign.Center)
  }

  private panelTitle(): string {
    if (this.discoveryMode === DiscoveryMode.GROUPS) {
      return '本机体验会话';
    }
    return '浏览乡音人物';
  }

  private panelMetricValue(): string {
    if (this.discoveryMode === DiscoveryMode.GROUPS) {
      return this.joinedGroupIds.length.toString();
    }
    return this.litDialectCount.toString();
  }

  private panelMetricLabel(): string {
    if (this.discoveryMode === DiscoveryMode.GROUPS) {
      return '个本机已加入会话';
    }
    return '/ ' + this.totalDialectCount.toString() + ' 个代表点已点亮';
  }

  private compactHeight(): number {
    if (this.portraitTabletMode) {
      return 336;
    }
    return Math.min(500, this.availableHeight * 0.64);
  }

  private middleHeight(): number {
    return Math.max(this.compactHeight(), this.availableHeight * 0.76);
  }

  private maximumHeight(): number {
    return Math.max(this.middleHeight(), this.availableHeight - 8);
  }

  private maximumStage(): number {
    return 2;
  }

  private heightForStage(stage: number): number {
    if (stage <= 0) {
      return this.compactHeight();
    }
    if (stage >= this.maximumStage()) {
      return this.maximumHeight();
    }
    return this.middleHeight();
  }

  private currentPanelHeight(): number {
    if (this.panelHeight <= 0) {
      return this.heightForStage(this.panelStage);
    }
    return this.clampPanelHeight(this.panelHeight);
  }

  private clampPanelHeight(height: number): number {
    return Math.max(this.compactHeight(), Math.min(this.maximumHeight(), height));
  }

  private nearestStage(height: number): number {
    if (!this.portraitTabletMode) {
      return height >= (this.compactHeight() + this.maximumHeight()) / 2 ? 1 : 0;
    }

    const compactDistance = Math.abs(height - this.compactHeight());
    const middleDistance = Math.abs(height - this.middleHeight());
    const maximumDistance = Math.abs(height - this.maximumHeight());
    if (compactDistance <= middleDistance && compactDistance <= maximumDistance) {
      return 0;
    }
    if (middleDistance <= maximumDistance) {
      return 1;
    }
    return 2;
  }

  private settlePanel(velocityY: number): void {
    let targetStage = this.nearestStage(this.currentPanelHeight());
    if (velocityY < -1200) {
      targetStage = this.maximumStage();
    } else if (velocityY > 1200) {
      targetStage = 0;
    } else if (velocityY < -600) {
      targetStage = Math.min(this.maximumStage(), targetStage + 1);
    } else if (velocityY > 600) {
      targetStage = Math.max(0, targetStage - 1);
    }
    this.snapToStage(targetStage);
  }

  private advancePanelStage(): void {
    const targetStage = this.panelStage >= this.maximumStage() ?
      0 : this.panelStage + 1;
    this.snapToStage(targetStage);
  }

  private snapToStage(stage: number): void {
    const targetHeight = this.heightForStage(stage);
    this.panelStage = stage;
    this.expanded = stage > 0;
    this.getUIContext().animateTo({
      curve: curves.responsiveSpringMotion()
    }, (): void => {
      this.panelHeight = targetHeight;
    });
  }

}

@Component
struct DiscoveryModeTab {
  @Prop label: string;
  @Prop selected: boolean;
  onSelect: () => void = (): void => {};

  build() {
    Button({ type: ButtonType.Normal }) {
      Text(this.label)
        .fontSize(16)
        .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.selected ? INK : MUTED)
    }
    .height(44)
    .layoutWeight(1)
    .backgroundColor(this.selected ?
      $r('app.color.surface_elevated') : Color.Transparent)
    .borderRadius(12)
    .shadow({
      radius: this.selected ? 4 : 0,
      color: $r('app.color.shadow_card'),
      offsetY: this.selected ? 1 : 0
    })
    .onClick(this.onSelect)
    .animation({ duration: 150, curve: Curve.EaseOut })
    .accessibilityText(this.label + (this.selected ? '，当前栏目' : ''))
  }
}

@Component
struct SourceTab {
  @Prop label: string;
  @Prop selected: boolean;
  onSelect: () => void = (): void => {};

  build() {
    Button(this.label)
      .fontSize(14)
      .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.selected ? ACCENT_TEXT : MUTED)
      .height(40)
      .layoutWeight(1)
      .backgroundColor(this.selected ?
        $r('app.color.surface_elevated') : Color.Transparent)
      .borderRadius(10)
      .onClick(this.onSelect)
      .animation({ duration: 150, curve: Curve.EaseOut })
      .accessibilityText(this.label + (this.selected ? '，已选中' : ''))
  }
}

@Component
struct FellowCard {
  @Prop user: FellowUser;
  @State focused: boolean = false;
  onOpen: (userId: string) => void = (_userId: string): void => {};

  build() {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        Stack() {
          Text(this.user.initials)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
        }
        .width(48)
        .height(48)
        .borderRadius(24)
        .backgroundColor(this.avatarColor())

        Column({ space: 4 }) {
          Row() {
            Text(this.user.nickname)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(INK)
            Text(this.user.dialectName)
              .fontSize(12)
              .fontColor(ACCENT_TEXT)
              .backgroundColor($r('app.color.brand_soft'))
              .borderRadius(6)
              .padding({ left: 6, right: 6, top: 3, bottom: 3 })
              .margin({ left: 8 })
          }
          Text(this.user.location + ' · ' + this.user.distanceText)
            .fontSize(12)
            .fontColor(MUTED)
            .maxLines(1)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text('›')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(MUTED)
      }
      .width('100%')
    }
    .width('100%')
    .height(76)
    .padding({ left: 14, right: 14 })
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(14)
    .border({
      width: this.focused ? 2 : 1,
      color: this.focused ? $r('app.color.focus') : $r('app.color.border')
    })
    .onClick((): void => { this.onOpen(this.user.id); })
    .focusable(true)
    .onFocus((): void => { this.focused = true; })
    .onBlur((): void => { this.focused = false; })
    .accessibilityGroup(true)
    .accessibilityText(
      this.user.nickname + '，' + this.user.dialectName + '，' +
      this.user.location + '，查看乡音护照'
    )
  }

  private avatarColor(): ResourceColor {
    if (this.user.dialectName === '粤语') {
      return $r('app.color.avatar_cantonese');
    }
    if (this.user.dialectName === '上海话') {
      return $r('app.color.avatar_shanghai');
    }
    if (this.user.dialectName === '北京话') {
      return $r('app.color.avatar_beijing');
    }
    return $r('app.color.avatar_default');
  }
}
