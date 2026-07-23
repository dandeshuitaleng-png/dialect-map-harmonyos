import { FellowSource, FellowUser } from '../models/DialectModels';
import { filterFellowsBySource } from '../services/MockDialectService';

const PAPER: ResourceColor = $r('app.color.surface_primary');
const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');

@Component
export struct FellowPanel {
  @Prop users: FellowUser[];
  @Prop wideMode: boolean = false;
  @Link expanded: boolean;
  @Link selectedSource: FellowSource;
  onOpenUser: (userId: string) => void = (_userId: string): void => {};
  private panelStartExpanded: boolean = false;

  build() {
    Column() {
      Column() {
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

        Row() {
          Column({ space: 3 }) {
            Text('发现同乡')
              .fontSize(21)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text('地图上的声音，正在靠近')
              .fontSize(12)
              .fontColor(MUTED)
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button(this.expanded ? '收起' : '展开')
            .fontSize(12)
            .fontColor(ACCENT)
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(Color.Transparent)
            .onClick((): void => { this.expanded = !this.expanded; })
            .accessibilityText(this.expanded ? '收起同乡面板' : '展开同乡面板')
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 14 })
      }
      .gesture(
        PanGesture({ fingers: 1, direction: PanDirection.Vertical, distance: 4 })
          .onActionStart((): void => {
            this.panelStartExpanded = this.expanded;
          })
          .onActionEnd((event: GestureEvent): void => {
            if (event.offsetY < -36) {
              this.expanded = true;
            } else if (event.offsetY > 36) {
              this.expanded = false;
            } else {
              this.expanded = this.panelStartExpanded;
            }
          })
      )

      Row({ space: 8 }) {
        SourceTab({
          label: '附近同乡',
          selected: this.selectedSource === FellowSource.NEARBY,
          onSelect: (): void => { this.selectedSource = FellowSource.NEARBY; }
        })
        SourceTab({
          label: '推荐同乡',
          selected: this.selectedSource === FellowSource.RECOMMENDED,
          onSelect: (): void => { this.selectedSource = FellowSource.RECOMMENDED; }
        })
        SourceTab({
          label: '当前区域',
          selected: this.selectedSource === FellowSource.CURRENT_REGION,
          onSelect: (): void => { this.selectedSource = FellowSource.CURRENT_REGION; }
        })
      }
      .padding({ left: 20, right: 20, bottom: 12 })
      .width('100%')

      Scroll() {
        if (this.visibleUsers().length === 0) {
          Column({ space: 12 }) {
            Text('这里还没有可展示的同乡')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text('可以切换到推荐同乡，或录下第一段乡音。')
              .fontSize(12)
              .fontColor(MUTED)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 40, bottom: 40 })
          .accessibilityGroup(true)
        } else {
          Column({ space: 10 }) {
            ForEach(this.visibleUsers(), (user: FellowUser): void => {
              FellowCard({ user: user, onOpen: this.onOpenUser })
            }, (user: FellowUser): string => user.id)
          }
          .padding({ left: 20, right: 20, bottom: 32 })
          .width('100%')
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height(this.wideMode ? '100%' : (this.expanded ? '72%' : 315))
    .backgroundColor(PAPER)
    .borderRadius({ topLeft: 26, topRight: 26 })
    .shadow({ radius: 30, color: $r('app.color.shadow_soft'), offsetY: -8 })
  }

  private visibleUsers(): FellowUser[] {
    return filterFellowsBySource(this.users, this.selectedSource);
  }
}

@Component
struct SourceTab {
  @Prop label: string;
  @Prop selected: boolean;
  onSelect: () => void = (): void => {};

  build() {
    Button(this.label)
      .fontSize(12)
      .fontWeight(this.selected ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.selected ? $r('app.color.on_emphasis') : MUTED)
      .height(48)
      .layoutWeight(1)
      .backgroundColor(this.selected ? INK : $r('app.color.surface_muted'))
      .borderRadius(10)
      .onClick(this.onSelect)
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
        .width(44)
        .height(44)
        .borderRadius(22)
        .backgroundColor(this.avatarColor())

        Column({ space: 4 }) {
          Row() {
            Text(this.user.nickname)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
            Text(this.user.dialectName)
              .fontSize(12)
              .fontColor(ACCENT)
              .backgroundColor($r('app.color.surface_accent_soft'))
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
          .fontColor($r('app.color.ink_tertiary'))
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.surface_pure'))
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
