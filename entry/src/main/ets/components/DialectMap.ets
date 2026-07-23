import { MapMarker } from '../models/DialectModels';

const INK: string = '#173A32';
const SURFACE: string = '#FFFCF6';
const ACCENT: string = '#DB643D';
const MAP_WIDTH: number = 360;
const MAP_HEIGHT: number = 700;

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
      Image($rawfile('china-terrain-map.png'))
        .width(MAP_WIDTH)
        .height(MAP_HEIGHT)
        .objectFit(ImageFit.Cover)
        .scale({ x: this.mapScale, y: this.mapScale })
        .translate({ x: this.offsetX, y: this.offsetY })

      Column() {
        Text('听见每一方水土')
          .fontSize(11)
          .fontColor('#556A61')
          .fontWeight(FontWeight.Medium)
          .letterSpacing(1.2)
        Text('乡音地图')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(INK)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .position({ x: 20, y: 48 })
      .zIndex(3)

      Button({ type: ButtonType.Circle }) {
        Text('⌖').fontSize(22).fontColor(INK)
      }
      .width(44)
      .height(44)
      .backgroundColor(SURFACE)
      .position({ x: 296, y: 52 })
      .zIndex(3)
      .shadow({ radius: 16, color: 'rgba(31,75,64,0.18)' })
      .onClick((): void => { this.resetViewport(); })

      ForEach(this.markers, (marker: MapMarker): void => {
        DialectMarker({ marker: marker })
      }, (marker: MapMarker): string => marker.id)

      Row() {
        Text('单指拖动 · 双指缩放')
          .fontSize(10)
          .fontColor('#F5F8F5')
        Blank()
        Text(Math.round(this.mapScale * 100).toString() + '%')
          .fontSize(10)
          .fontColor('#F5F8F5')
      }
      .height(32)
      .padding({ left: 12, right: 12 })
      .backgroundColor('rgba(21,55,46,0.72)')
      .borderRadius(10)
      .position({ x: 20, y: 112 })
      .width(200)
      .zIndex(3)
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
          .fontSize(11)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(34)
      .height(34)
      .borderRadius(17)
      .backgroundColor(ACCENT)
      .border({ width: 3, color: '#FFF8EE' })
      .shadow({ radius: 14, color: 'rgba(151,68,42,0.35)' })

      Column({ space: 1 }) {
        Text(this.marker.dialectName)
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text(this.formatCount(this.marker.fellowCount))
          .fontSize(8)
          .fontColor('#E7F0EC')
      }
      .padding({ left: 7, right: 7, top: 4, bottom: 4 })
      .backgroundColor('rgba(20,51,43,0.78)')
      .borderRadius(8)
    }
    .width(92)
    .position({
      x: (this.marker.xRatio * 100).toString() + '%',
      y: (this.marker.yRatio * 100).toString() + '%'
    })
    .translate({ x: -46, y: -28 })
    .zIndex(2)
  }

  private formatCount(count: number): string {
    return (count / 10000).toFixed(1) + ' 万同乡';
  }
}
