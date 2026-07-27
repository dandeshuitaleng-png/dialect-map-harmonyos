import { COMMUNITY_MESSAGE_MAX_LENGTH } from '../services/MockCommunityService';

@Component
export struct CommunityChatComposer {
  @Link draft: string;
  @Prop canSend: boolean = true;
  @Prop disabledHint: string = '加入后可发言';
  @Prop feedback: string = '';
  @Prop feedbackIsError: boolean = false;
  onDraftChange: (value: string) => void = (_value: string): void => {};
  onSend: () => void = (): void => {};

  build() {
    Column({ space: 6 }) {
      Row({ space: 10 }) {
        TextInput({
          text: this.draft,
          placeholder: this.canSend ? '发一条本机消息…' : this.disabledHint
        })
          .fontSize(15)
          .fontColor(this.canSend ?
            $r('app.color.ink_primary') : $r('app.color.ink_muted'))
          .placeholderColor(this.canSend ?
            $r('app.color.ink_tertiary') : $r('app.color.ink_muted'))
          .height(48)
          .layoutWeight(1)
          .padding({ left: 14, right: 14 })
          .backgroundColor(this.canSend ?
            $r('app.color.surface_pure') :
            $r('app.color.surface_disabled'))
          .border({
            width: 1,
            color: this.feedbackIsError ?
              $r('app.color.danger') : $r('app.color.border')
          })
          .borderRadius(14)
          .caretColor($r('app.color.accent'))
          .maxLength(COMMUNITY_MESSAGE_MAX_LENGTH)
          .enterKeyType(EnterKeyType.Send)
          .enabled(this.canSend)
          .onChange((value: string): void => {
            this.draft = value;
            this.onDraftChange(value);
          })
          .onSubmit((
            _enterKey: EnterKeyType,
            _event: SubmitEvent
          ): void => {
            this.onSend();
          })
          .accessibilityText(
            this.canSend ?
              '群聊消息输入框，消息仅保存在当前本机会话，最多' +
                COMMUNITY_MESSAGE_MAX_LENGTH.toString() + '个字' :
              this.disabledHint
          )

        Button('发送')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.canSend ?
            $r('app.color.on_emphasis') : $r('app.color.ink_muted'))
          .height(48)
          .width(70)
          .backgroundColor(this.canSend ?
            $r('app.color.accent') : $r('app.color.surface_disabled'))
          .borderRadius(14)
          .enabled(this.canSend)
          .onClick(this.onSend)
          .accessibilityText(this.canSend ?
            '发送到当前本机会话，不会同步' : this.disabledHint)
      }
      .width('100%')

      Row() {
        Text(this.statusText())
          .fontSize(10)
          .fontColor(this.feedbackIsError ?
            $r('app.color.danger') : $r('app.color.ink_tertiary'))
          .maxLines(1)
          .layoutWeight(1)

        Text(this.draft.length.toString() + ' / ' +
          COMMUNITY_MESSAGE_MAX_LENGTH.toString())
          .fontSize(10)
          .fontColor(this.draft.length >= COMMUNITY_MESSAGE_MAX_LENGTH ?
            $r('app.color.danger') : $r('app.color.ink_tertiary'))
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.surface_primary'))
    .border({
      width: { top: 1 },
      color: $r('app.color.divider')
    })
  }

  private statusText(): string {
    if (!this.canSend) {
      return this.disabledHint;
    }
    return this.feedback.length > 0 ?
      this.feedback : '本次运行有效 · 消息不会同步';
  }
}
