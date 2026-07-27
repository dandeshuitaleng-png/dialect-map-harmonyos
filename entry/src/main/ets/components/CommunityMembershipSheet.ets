@Component
export struct CommunityMembershipSheet {
  @Prop groupName: string;
  @Prop joined: boolean = false;
  onCancel: () => void = (): void => {};
  onConfirm: () => void = (): void => {};

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column({ space: 16 }) {
        Divider()
          .width(36)
          .strokeWidth(4)
          .color($r('app.color.ink_tertiary'))
          .borderRadius(2)
          .alignSelf(ItemAlign.Center)

        Text(this.joined ? '退出本机会话？' : '标记为已加入？')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink_primary'))
          .width('100%')

        Text(this.joined ?
          '“' + this.groupName + '”只会从本机的已加入列表移除，消息不会发送到服务器。' :
          '“' + this.groupName + '”只会加入本机列表，不会创建真实群成员关系。')
          .fontSize(14)
          .fontColor($r('app.color.ink_muted'))
          .lineHeight(22)

        Row({ space: 12 }) {
          Button('取消')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink_primary'))
            .height(48)
            .layoutWeight(1)
            .backgroundColor($r('app.color.surface_muted'))
            .borderRadius(15)
            .onClick(this.onCancel)

          Button(this.joined ? '确认退出' : '确认加入')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.joined ?
              $r('app.color.danger') : $r('app.color.on_emphasis'))
            .height(48)
            .layoutWeight(1)
            .backgroundColor(this.joined ?
              $r('app.color.surface_recording') : $r('app.color.accent'))
            .borderRadius(15)
            .onClick(this.onConfirm)
        }
        .width('100%')
      }
      .width('100%')
      .constraintSize({ maxWidth: 560 })
      .padding({ left: 22, right: 22, top: 24, bottom: 28 })
      .backgroundColor($r('app.color.surface_primary'))
      .borderRadius({ topLeft: 28, topRight: 28 })
      .shadow({
        radius: 20,
        color: $r('app.color.shadow_soft'),
        offsetY: -4
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.map_overlay'))
    .zIndex(20)
  }
}
