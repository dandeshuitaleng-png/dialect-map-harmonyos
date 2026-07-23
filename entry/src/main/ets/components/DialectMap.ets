import { MapMarker } from '../models/DialectModels';

const INK: ResourceColor = $r('app.color.ink_primary');
const SURFACE: ResourceColor = $r('app.color.surface_primary');
const ACCENT: ResourceColor = $r('app.color.accent');
@Component
export struct DialectMap {
  @Prop markers: MapMarker[];
  @State mapScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  private panStartX: number = 0;
  private panStartY: number = 0;
  private pinchStartScale: number = 1;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image($rawfile('china-terrain-map.png'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        ForEach(this.markers, (marker: MapMarker): void => {
          DialectMarker({ marker: marker })
        }, (marker: MapMarker): string => marker.id)
      }
        .width('100%')
        .height('100%')
        .scale({ x: this.mapScale, y: this.mapScale })
        .translate({ x: this.offsetX, y: this.offsetY })

      Column() {
        Text('听见每一方水土')
          .fontSize(12)
          .fontColor($r('app.color.ink_secondary'))
          .fontWeight(FontWeight.Medium)
          .letterSpacing(1.2)
        Text('乡音地图')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .position({ x: 20, y: 16 })
      .zIndex(3)

      Button({ type: ButtonType.Circle }) {
        Text('⌖').fontSize(24).fontColor(INK)
      }
      .width(48)
      .height(48)
      .backgroundColor(SURFACE)
      .position({ x: '82%', y: 16 })
      .zIndex(3)
      .shadow({ radius: 16, color: $r('app.color.shadow_soft') })
      .accessibilityText('恢复地图初始位置')
      .onClick((): void => { this.resetViewport(); })

      Row() {
        Text('单指拖动 · 双指缩放')
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis'))
        Blank()
        Text(Math.round(this.mapScale * 100).toString() + '%')
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis'))
      }
      .height(32)
      .padding({ left: 12, right: 12 })
      .backgroundColor($r('app.color.map_overlay'))
      .borderRadius(10)
      .position({ x: 20, y: 76 })
      .width(224)
      .zIndex(3)

      Button('-')
        .width(48)
        .height(48)
        .fontSize(24)
        .fontColor(INK)
        .backgroundColor(SURFACE)
        .position({ x: 20, y: 124 })
        .zIndex(3)
        .onClick((): void => { this.zoomBy(-0.2); })
        .accessibilityText('缩小地图')

      Button('+')
        .width(48)
        .height(48)
        .fontSize(24)
        .fontColor(INK)
        .backgroundColor(SURFACE)
        .position({ x: 76, y: 124 })
        .zIndex(3)
        .onClick((): void => { this.zoomBy(0.2); })
        .accessibilityText('放大地图')
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .gesture(
      GestureGroup(
        GestureMode.Parallel,
        PanGesture({ fingers: 1, direction: PanDirection.All, distance: 4 })
          .onActionStart((): void => {
            this.panStartX = this.offsetX;
            this.panStartY = this.offsetY;
          })
          .onActionUpdate((event: GestureEvent): void => {
            this.offsetX = this.panStartX + event.offsetX;
            this.offsetY = this.panStartY + event.offsetY;
          }),
        PinchGesture({ fingers: 2, distance: 3 })
          .onActionStart((): void => {
            this.pinchStartScale = this.mapScale;
          })
          .onActionUpdate((event: GestureEvent): void => {
            this.mapScale = this.clampScale(this.pinchStartScale * event.scale);
          })
      )
    )
  }

  private resetViewport(): void {
    this.mapScale = 1;
    this.offsetX = 0;
    this.offsetY = 0;
  }

  private zoomBy(delta: number): void {
    this.mapScale = this.clampScale(this.mapScale + delta);
  }

  private clampScale(scale: number): number {
    return Math.max(0.85, Math.min(2.4, scale));
  }
}

@Component
struct DialectMarker {
  @Prop marker: MapMarker;

  build() {
    Column({ space: 4 }) {
      Stack() {
        Text('声')
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis'))
          .fontWeight(FontWeight.Bold)
      }
      .width(34)
      .height(34)
      .borderRadius(17)
      .backgroundColor(ACCENT)
      .border({ width: 3, color: $r('app.color.surface_primary') })
      .shadow({ radius: 14, color: $r('app.color.shadow_accent') })

      Column({ space: 1 }) {
        Text(this.marker.dialectName)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_emphasis'))
        Text(this.formatCount(this.marker.fellowCount))
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis_secondary'))
      }
      .padding({ left: 7, right: 7, top: 4, bottom: 4 })
      .backgroundColor($r('app.color.map_overlay'))
      .borderRadius(8)
    }
    .width(92)
    .position({
      x: (this.marker.xRatio * 100).toString() + '%',
      y: (this.marker.yRatio * 100).toString() + '%'
    })
    .translate({ x: -46, y: -28 })
    .zIndex(2)
    .accessibilityText(
      this.marker.regionName + '，' + this.marker.dialectName + '，' +
      this.formatCount(this.marker.fellowCount)
    )
  }

  private formatCount(count: number): string {
    return (count / 10000).toFixed(1) + ' 万同乡';
  }
}
