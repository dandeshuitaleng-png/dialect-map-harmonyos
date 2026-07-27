import { KeyboardAvoidMode } from '@kit.ArkUI';
import {
  CommunityGroup,
  CommunityMessage
} from '../models/DialectModels';
import {
  COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP,
  COMMUNITY_MESSAGE_MAX_LENGTH,
  CommunityMessageStoreResult,
  createLocalCommunityMessage,
  getCommunityMessages,
  getLocalCommunityMessageCount,
  storeLocalCommunityMessage,
  validateCommunityMessageDraft
} from '../services/MockCommunityService';
import { CommunityChatBubble } from './CommunityChatBubble';
import { CommunityChatComposer } from './CommunityChatComposer';
import { CommunityChatHeader } from './CommunityChatHeader';
import { CommunityMembershipSheet } from './CommunityMembershipSheet';

@Component
export struct CommunityGroupPage {
  @Prop group: CommunityGroup;
  @Prop joined: boolean = false;
  @Link membershipConfirmOpen: boolean;
  onBack: () => void = (): void => {};
  onToggleMembership: (groupId: string) => void =
    (_groupId: string): void => {};
  @State windowWidth: number = 360;
  @State messages: CommunityMessage[] = [];
  @State draft: string = '';
  @State feedback: string = '';
  @State feedbackIsError: boolean = false;
  @State localSessionFull: boolean = false;
  @State safetyExpanded: boolean = false;
  @State reportRecorded: boolean = false;
  @State groupBlocked: boolean = false;
  private readonly chatScroller: Scroller = new Scroller();
  private localMessageSequence: number = 1;
  private previousKeyboardAvoidMode: KeyboardAvoidMode =
    KeyboardAvoidMode.OFFSET;
  private keyboardAvoidModeConfigured: boolean = false;

  aboutToAppear(): void {
    this.messages = getCommunityMessages(this.group.id);
    this.localMessageSequence = this.messages.filter(
      (message: CommunityMessage): boolean => message.isLocalOnly
    ).length + 1;
    this.localSessionFull = getLocalCommunityMessageCount(this.group.id) >=
      COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP;
    this.previousKeyboardAvoidMode =
      this.getUIContext().getKeyboardAvoidMode();
    this.getUIContext().setKeyboardAvoidMode(
      KeyboardAvoidMode.RESIZE_WITH_CARET
    );
    this.keyboardAvoidModeConfigured = true;
  }

  aboutToDisappear(): void {
    if (!this.keyboardAvoidModeConfigured) {
      return;
    }
    this.getUIContext().setKeyboardAvoidMode(
      this.previousKeyboardAvoidMode
    );
    this.keyboardAvoidModeConfigured = false;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        CommunityChatHeader({
          group: this.group,
          joined: this.joined,
          onBack: this.onBack,
          onMembership: (): void => {
            this.membershipConfirmOpen = true;
          },
          onSafety: (): void => {
            this.safetyExpanded = !this.safetyExpanded;
          }
        })
        if (this.safetyExpanded) {
          this.safetyPanel()
        }
        this.topicPrompt()
        this.messageStream()
        CommunityChatComposer({
          draft: $draft,
          canSend: this.joined && !this.localSessionFull && !this.groupBlocked,
          disabledHint: this.groupBlocked ? '已在本机屏蔽此话题组' :
            (this.localSessionFull ? '本机会话已满' : '加入后可回应'),
          feedback: this.feedback,
          feedbackIsError: this.feedbackIsError,
          onDraftChange: (value: string): void => {
            this.handleDraftChange(value);
          },
          onSend: (): void => {
            this.sendMessage();
          }
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background_page'))

      if (this.membershipConfirmOpen) {
        CommunityMembershipSheet({
          groupName: this.group.name,
          joined: this.joined,
          onCancel: (): void => {
            this.membershipConfirmOpen = false;
          },
          onConfirm: (): void => {
            this.confirmMembershipChange();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.windowWidth = Number(newValue.width);
    })
  }

  @Builder
  private topicPrompt() {
    if (this.group.recentTopics.length > 0) {
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text('今日乡音问题')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.accent_text'))
          Text(this.group.recentTopics[0].activityLabel)
            .fontSize(10)
            .fontColor($r('app.color.ink_tertiary'))
        }
        .width('100%')

        Text(this.group.recentTopics[0].title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink_primary'))
          .lineHeight(23)
          .width('100%')

        Row() {
          Text('从共同记忆开始，避免公开精确位置或个人联系方式')
            .fontSize(10)
            .fontColor($r('app.color.ink_muted'))
            .maxLines(2)
            .layoutWeight(1)

          Button('回应话题')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.accent_text'))
            .height(40)
            .padding({ left: 12, right: 12 })
            .backgroundColor($r('app.color.brand_soft'))
            .borderRadius(12)
            .enabled(!this.groupBlocked)
            .onClick((): void => {
              this.replyToTopic();
            })
            .accessibilityText('在消息输入框中回应今日乡音问题')
        }
        .width('100%')
      }
      .margin({ left: 14, right: 14, top: 12 })
      .padding({ left: 14, right: 12, top: 12, bottom: 12 })
      .backgroundColor($r('app.color.surface_elevated'))
      .border({ width: 1, color: $r('app.color.border') })
      .borderRadius(14)
      .accessibilityGroup(true)
    }
  }

  @Builder
  private safetyPanel() {
    Column({ space: 10 }) {
      Text('群规与隐私')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.ink_primary'))
        .width('100%')

      ForEach(
        this.group.rules as string[],
        (rule: string, index: number): void => {
          Row({ space: 8 }) {
            Text((index + 1).toString())
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .textAlign(TextAlign.Center)
              .width(20)
              .height(20)
              .backgroundColor($r('app.color.confirm'))
              .borderRadius(10)
            Text(rule)
              .fontSize(11)
              .fontColor($r('app.color.ink_muted'))
              .lineHeight(17)
              .layoutWeight(1)
          }
          .width('100%')
        },
        (_rule: string, index: number): string => index.toString()
      )

      Row({ space: 10 }) {
        Button(this.reportRecorded ? '已记录举报' : '举报演示内容')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.reportRecorded ?
            $r('app.color.confirm_text') : $r('app.color.danger'))
          .height(44)
          .layoutWeight(1)
          .backgroundColor(this.reportRecorded ?
            $r('app.color.surface_confirm_soft') :
            $r('app.color.surface_recording'))
          .borderRadius(12)
          .enabled(!this.reportRecorded)
          .onClick((): void => {
            this.reportRecorded = true;
            this.feedback = '举报已记录在本次运行，未提交到服务器';
            this.feedbackIsError = false;
          })
          .accessibilityText(this.reportRecorded ?
            '举报已记录在本次运行' : '在本次运行中记录举报')

        Button(this.groupBlocked ? '取消本机屏蔽' : '本机屏蔽')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink_primary'))
          .height(44)
          .layoutWeight(1)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)
          .onClick((): void => {
            this.groupBlocked = !this.groupBlocked;
            this.feedback = this.groupBlocked ?
              '已在本次运行中屏蔽此话题组' : '已取消本机屏蔽';
            this.feedbackIsError = false;
          })
          .accessibilityText(this.groupBlocked ?
            '取消本机屏蔽此话题组' : '在本次运行中屏蔽此话题组')
      }
      .width('100%')

      Text('演示边界：以上状态仅保存在本次运行，不代表服务器已受理。')
        .fontSize(10)
        .fontColor($r('app.color.ink_tertiary'))
        .width('100%')
    }
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor($r('app.color.surface_muted'))
    .border({
      width: { bottom: 1 },
      color: $r('app.color.divider')
    })
    .accessibilityGroup(true)
  }

  @Builder
  private messageStream() {
    List({
      space: 14,
      scroller: this.chatScroller,
      initialIndex: Math.max(0, this.messages.length - 1)
    }) {
      if (this.groupBlocked) {
        ListItem() {
          Column({ space: 8 }) {
            Text('此话题组已在本机屏蔽')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ink_primary'))
            Text('可在“群规与安全”中取消屏蔽，状态不会同步到服务器。')
              .fontSize(13)
              .fontColor($r('app.color.ink_muted'))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 56, bottom: 56, left: 24, right: 24 })
          .accessibilityGroup(true)
        }
      } else if (this.messages.length === 0) {
        ListItem() {
          Column({ space: 8 }) {
            Text('还没有本机会话消息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ink_primary'))
            Text(this.joined ? '发送第一条只保留在本次运行的消息。' : '加入后可以发送本机演示消息。')
              .fontSize(13)
              .fontColor($r('app.color.ink_muted'))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 56, bottom: 56, left: 24, right: 24 })
          .accessibilityGroup(true)
        }
      } else {
        ForEach(
          this.messages,
          (message: CommunityMessage): void => {
            ListItem() {
              CommunityChatBubble({
                message: message,
                maxBubbleWidth: this.maxBubbleWidth()
              })
            }
            .padding({ left: 14, right: 14 })
          },
          (message: CommunityMessage): string => message.id
        )
      }
    }
    .layoutWeight(1)
    .width('100%')
    .padding({ top: 14, bottom: 14 })
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  private handleDraftChange(value: string): void {
    if (this.groupBlocked) {
      this.feedback = '已在本机屏蔽此话题组';
      this.feedbackIsError = true;
      return;
    }
    if (!this.joined) {
      this.feedback = '加入后可发言';
      this.feedbackIsError = true;
      return;
    }
    if (this.localSessionFull) {
      this.feedback = '本机会话已满';
      this.feedbackIsError = true;
      return;
    }
    if (value.length >= COMMUNITY_MESSAGE_MAX_LENGTH) {
      this.feedback = '已达到 ' +
        COMMUNITY_MESSAGE_MAX_LENGTH.toString() + ' 字上限';
      this.feedbackIsError = false;
      return;
    }
    this.feedback = '';
    this.feedbackIsError = false;
  }

  private sendMessage(): CommunityMessageStoreResult {
    if (this.groupBlocked) {
      this.feedback = '已在本机屏蔽此话题组';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.INVALID;
    }
    if (!this.joined) {
      this.feedback = '加入后可发言';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.INVALID;
    }
    if (this.localSessionFull) {
      this.feedback = '本机会话已满';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.LIMIT;
    }
    const validationMessage = validateCommunityMessageDraft(this.draft);
    if (validationMessage.length > 0) {
      this.feedback = validationMessage;
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.INVALID;
    }

    const localMessage = createLocalCommunityMessage(
      this.group.id,
      this.draft,
      this.localMessageSequence,
      this.currentTimeLabel()
    );
    if (localMessage === undefined) {
      this.feedback = '消息无效，请检查后重试';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.INVALID;
    }
    const storeResult = storeLocalCommunityMessage(localMessage);
    if (storeResult === CommunityMessageStoreResult.LIMIT) {
      this.localSessionFull = true;
      this.feedback = '本机会话已满';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.LIMIT;
    }
    if (storeResult === CommunityMessageStoreResult.DUPLICATE) {
      this.localMessageSequence += 1;
      this.feedback = '消息未保存，请再次发送';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.DUPLICATE;
    }
    if (storeResult === CommunityMessageStoreResult.INVALID) {
      this.feedback = '消息无效，请检查后重试';
      this.feedbackIsError = true;
      return CommunityMessageStoreResult.INVALID;
    }

    this.localMessageSequence += 1;
    this.messages = this.messages.concat(localMessage);
    this.draft = '';
    this.localSessionFull = getLocalCommunityMessageCount(this.group.id) >=
      COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP;
    this.feedback = this.localSessionFull ?
      '本机会话已满' : '已保存在本机，未同步';
    this.feedbackIsError = false;
    setTimeout((): void => {
      this.chatScroller.scrollToIndex(
        this.messages.length - 1,
        true,
        ScrollAlign.END
      );
    }, 30);
    return CommunityMessageStoreResult.STORED;
  }

  private confirmMembershipChange(): void {
    const wasJoined = this.joined;
    this.onToggleMembership(this.group.id);
    this.membershipConfirmOpen = false;
    if (wasJoined) {
      this.draft = '';
      this.feedback = '加入后可发言';
      this.feedbackIsError = false;
      return;
    }
    this.feedback = '';
    this.feedbackIsError = false;
  }

  private replyToTopic(): void {
    if (this.groupBlocked) {
      this.feedback = '已在本机屏蔽此话题组';
      this.feedbackIsError = true;
      return;
    }
    if (!this.joined) {
      this.feedback = '先加入话题组，再回应今日乡音问题';
      this.feedbackIsError = true;
      return;
    }
    if (this.group.recentTopics.length === 0) {
      return;
    }
    this.draft = '回应“' + this.group.recentTopics[0].title + '”：';
    this.feedback = '已带入今日话题，可继续补充';
    this.feedbackIsError = false;
  }

  private currentTimeLabel(): string {
    const now = new Date();
    return this.twoDigits(now.getHours()) + ':' +
      this.twoDigits(now.getMinutes());
  }

  private twoDigits(value: number): string {
    return value < 10 ? '0' + value.toString() : value.toString();
  }

  private maxBubbleWidth(): number {
    return Math.min(520, Math.max(240, this.windowWidth * 0.64));
  }
}
