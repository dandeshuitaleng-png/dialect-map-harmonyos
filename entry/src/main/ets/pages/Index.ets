const BACKGROUND: string = '#F4EFE5';
const INK: string = '#173A32';
const MUTED: string = '#6D7771';

@Entry
@Component
struct Index {
  build() {
    Column({ space: 12 }) {
      Text('乡音地图')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(INK)
      Text('听见每一方水土')
        .fontSize(15)
        .fontColor(MUTED)
      Text('工程骨架已就绪')
        .fontSize(13)
        .fontColor(MUTED)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24, top: 72 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(BACKGROUND)
  }
}

