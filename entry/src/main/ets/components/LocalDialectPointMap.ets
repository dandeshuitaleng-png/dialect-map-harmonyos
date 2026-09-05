import { MapMarker } from '../models/DialectModels';

const MIN_LOCAL_SCALE: number = 1;
const MAX_LOCAL_SCALE: number = 2.5;
const LOCAL_SCALE_STEP: number = 0.25;

@Component
export struct LocalDialectPointMap {
  @Prop markers: MapMarker[];
  @Prop litRegionName: string = '';
  @Prop selectedRegionName: string = '';
  onSelectRegion: (regionName: string) => void = (_regionName: string): void => {};
  @State mapWidth: number = 360;
  @State mapHeight: number = 720;
  @State localScale: number = MIN_LOCAL_SCALE;
  @State translateX: number = 0;
  @State translateY: number = 0;
  private panStartX: number = 0;
  private panStartY: number = 0;
  private pinchStartScale: number = MIN_LOCAL_SCALE;
  private readonly gridRatios: number[] = [0.2, 0.4, 0.6, 0.8];

  build() {
    Stack() {
      Row()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.background_map'))

      Stack() {
        ForEach(this.gridRatios, (ratio: number): void => {
          Row()
            .width('100%')
            .height(1)
            .backgroundColor($r('app.color.map_image_tint'))
            .position({ x: 0, y: this.mapHeight * ratio })
          Column()
            .width(1)
            .height('100%')
            .backgroundColor($r('app.color.map_image_tint'))
            .position({ x: this.mapWidth * ratio, y: 0 })
        }, (ratio: number): string => ratio.toString())

        Text('北方')
          .fontSize(12)
          .fontColor($r('app.color.ink_muted'))
          .position({ x: this.mapWidth * 0.5, y: this.mapHeight * 0.16 })
        Text('西部')
          .fontSize(12)
          .fontColor($r('app.color.ink_muted'))
          .position({ x: this.mapWidth * 0.14, y: this.mapHeight * 0.48 })
        Text('东部')
          .fontSize(12)
          .fontColor($r('app.color.ink_muted'))
          .position({ x: this.mapWidth * 0.81, y: this.mapHeight * 0.48 })
        Text('南方')
          .fontSize(12)
          .fontColor($r('app.color.ink_muted'))
          .position({ x: this.mapWidth * 0.5, y: this.mapHeight * 0.8 })

        ForEach(this.markers, (marker: MapMarker): void => {
          Button({ type: ButtonType.Normal }) {
            Column({ space: 2 }) {
              Text(marker.regionName)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.isHighlighted(marker) ?
                  $r('app.color.on_emphasis') : $r('app.color.ink_primary'))
              Text(marker.dialectName)
                .fontSize(10)
                .fontColor(this.isHighlighted(marker) ?
                  $r('app.color.on_emphasis_secondary') : $r('app.color.ink_muted'))
            }
          }
          .width(76)
          .height(48)
          .padding({ left: 8, right: 8 })
          .backgroundColor(this.isHighlighted(marker) ?
            $r('app.color.accent') : $r('app.color.surface_elevated'))
          .border({
            width: marker.regionName === this.litRegionName ? 2 : 1,
            color: marker.regionName === this.litRegionName ?
              $r('app.color.confirm_text') : $r('app.color.border')
          })
          .borderRadius(16)
          .shadow({ radius: 8, color: $r('app.color.shadow_soft') })
          .position({
            x: this.mapWidth * marker.xRatio - 38,
            y: this.mapHeight * marker.yRatio - 24
          })
          .onClick((): void => { this.onSelectRegion(marker.regionName); })
          .accessibilityText(this.markerAccessibilityText(marker))
        }, (marker: MapMarker): string => marker.id)
      }
      .width('100%')
      .height('100%')
      .scale({ x: this.localScale, y: this.localScale })
      .translate({ x: this.translateX, y: this.translateY })
      .gesture(
        GestureGroup(
          GestureMode.Parallel,
          PanGesture({ fingers: 1, direction: PanDirection.All, distance: 4 })
            .onActionStart((): void => {
              this.panStartX = this.translateX;
              this.panStartY = this.translateY;
            })
            .onActionUpdate((event: GestureEvent): void => {
              this.translateX = this.clampTranslateX(this.panStartX + event.offsetX);
              this.translateY = this.clampTranslateY(this.panStartY + event.offsetY);
            })
            .onActionEnd((): void => { this.clampTranslation(); }),
          PinchGesture({ fingers: 2, distance: 1 })
            .onActionStart((): void => { this.pinchStartScale = this.localScale; })
            .onActionUpdate((event: GestureEvent): void => {
              this.localScale = this.clampScale(this.pinchStartScale * event.scale);
              this.clampTranslation();
            })
            .onActionEnd((): void => { this.clampTranslation(); })
        )
      )

      Text('本地点位图 · 不描绘行政边界')
        .fontSize(12)
        .fontColor($r('app.color.ink_primary'))
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.surface_primary'))
        .borderRadius(12)
        .position({ x: 16, y: 112 })
        .zIndex(2)
        .accessibilityText('本地乡音代表点示意图，不描绘行政边界')

      Column({ space: 8 }) {
        Button('+')
          .width(48)
          .height(48)
          .fontSize(22)
          .fontColor($r('app.color.ink_primary'))
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(16)
          .enabled(this.localScale < MAX_LOCAL_SCALE)
          .onClick((): void => { this.updateScale(LOCAL_SCALE_STEP); })
          .accessibilityText('放大本地点位图')
        Button('−')
          .width(48)
          .height(48)
          .fontSize(22)
          .fontColor($r('app.color.ink_primary'))
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(16)
          .enabled(this.localScale > MIN_LOCAL_SCALE)
          .onClick((): void => { this.updateScale(-LOCAL_SCALE_STEP); })
          .accessibilityText('缩小本地点位图')
        Button('复位')
          .width(56)
          .height(48)
          .fontSize(12)
          .fontColor($r('app.color.ink_primary'))
          .backgroundColor($r('app.color.surface_primary'))
          .borderRadius(16)
          .onClick((): void => { this.resetView(); })
          .accessibilityText('复位本地点位图')
      }
      .position({ x: Math.max(16, this.mapWidth - 72), y: 112 })
      .zIndex(2)
    }
    .width('100%')
    .height('100%')
    .clip(true)
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.mapWidth = Math.max(1, Number(newValue.width));
      this.mapHeight = Math.max(1, Number(newValue.height));
      this.clampTranslation();
    })
  }

  private isHighlighted(marker: MapMarker): boolean {
    return marker.regionName === this.selectedRegionName ||
      marker.regionName === this.litRegionName;
  }

  private markerAccessibilityText(marker: MapMarker): string {
    const state = marker.regionName === this.litRegionName ? '，已点亮' :
      (marker.regionName === this.selectedRegionName ? '，已选择' : '');
    return marker.regionName + '，' + marker.dialectName + state;
  }

  private updateScale(delta: number): void {
    this.localScale = this.clampScale(this.localScale + delta);
    this.clampTranslation();
  }

  private resetView(): void {
    this.localScale = MIN_LOCAL_SCALE;
    this.translateX = 0;
    this.translateY = 0;
  }

  private clampScale(scale: number): number {
    return Math.max(MIN_LOCAL_SCALE, Math.min(MAX_LOCAL_SCALE, scale));
  }

  private clampTranslation(): void {
    this.translateX = this.clampTranslateX(this.translateX);
    this.translateY = this.clampTranslateY(this.translateY);
  }

  private clampTranslateX(value: number): number {
    const maximum = this.mapWidth * (this.localScale - 1) / 2;
    return Math.max(-maximum, Math.min(maximum, value));
  }

  private clampTranslateY(value: number): number {
    const maximum = this.mapHeight * (this.localScale - 1) / 2;
    return Math.max(-maximum, Math.min(maximum, value));
  }
}
