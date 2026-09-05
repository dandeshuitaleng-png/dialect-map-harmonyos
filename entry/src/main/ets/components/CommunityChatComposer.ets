import { COMMUNITY_MESSAGE_MAX_LENGTH } from '../services/MockCommunityService';

@Component
export struct CommunityChatComposer {
  @Link draft: string;
  @Prop canSend: boolean = true;
  @Prop disabledHint: string = '加入后可发言';
  @Prop feedback: string = '';
  @Prop feedbackIsError: boolean = false;
  @Prop voiceStateLabel: string = '';
  @Prop voiceActive: boolean = false;
  @Prop voiceReady: boolean = false;
  @Prop voiceActionInFlight: boolean = false;
  onDraftChange: (value: string) => void = (_value: string): void => {};
  onSend: () => void = (): void => {};
  onVoiceAction: () => void = (): void => {};
  onVoiceCancel: () => void = (): void => {};
  onVoicePlay: () => void = (): void => {};
  onVoiceSend: () => void = (): void => {};

  build() {
    Column({ space: 6 }) {
      Row({ space: 10 }) {
        Button(this.voiceActive ? '停止' : '语音')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.canSend ?
            $r('app.color.accent_text') : $r('app.color.ink_muted'))
          .height(48)
          .width(58)
          .backgroundColor(this.voiceActive ?
            $r('app.color.surface_recording') : $r('app.color.brand_soft'))
          .borderRadius(14)
          .enabled(this.canSend && !this.voiceActionInFlight)
          .onClick(this.onVoiceAction)
          .accessibilityText(this.voiceActive ? '停止体验会话语音录制' : '开始体验会话语音录制')

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
              '体验会话消息输入框，消息仅保存在当前本机会话，最多' +
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

      if (this.voiceStateLabel.length > 0) {
        Row() {
          Text(this.voiceStateLabel)
            .fontSize(11)
            .fontColor(this.feedbackIsError ?
              $r('app.color.danger') : $r('app.color.accent_text'))
            .layoutWeight(1)
          if (this.voiceReady) {
            Button('试听')
              .height(40)
              .fontSize(11)
              .fontColor($r('app.color.accent_text'))
              .backgroundColor(Color.Transparent)
              .enabled(this.canSend && !this.voiceActionInFlight)
              .onClick(this.onVoicePlay)
            Button('发送语音')
              .height(40)
              .fontSize(11)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .backgroundColor($r('app.color.accent'))
              .borderRadius(12)
              .enabled(this.canSend && !this.voiceActionInFlight)
              .onClick(this.onVoiceSend)
          }
          if (this.voiceActive || this.voiceReady) {
            Button('取消')
              .height(40)
              .fontSize(11)
              .fontColor($r('app.color.ink_muted'))
              .backgroundColor(Color.Transparent)
              .enabled(!this.voiceActionInFlight)
              .onClick(this.onVoiceCancel)
          }
        }
        .width('100%')
      }

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
      this.feedback : '支持文字与语音消息';
  }
}
