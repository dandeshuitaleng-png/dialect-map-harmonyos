import { KeyboardAvoidMode } from '@kit.ArkUI';
import {
  abilityAccessCtrl,
  common,
  PermissionRequestResult,
  Permissions
} from '@kit.AbilityKit';
import {
  CommunityGroup,
  CommunityMessage
} from '../models/DialectModels';
import {
  COMMUNITY_MESSAGE_MAX_LENGTH,
  CommunityMessageStoreResult,
  createLocalCommunityMessage,
  createLocalCommunityVoiceMessage,
  storeLocalCommunityMessage,
  validateCommunityMessageDraft
} from '../services/MockCommunityService';
import { getCommunityMessages, createCommunityMessage } from '../services/CommunityService';
import { TransientAudioCaptureService } from '../services/TransientAudioCaptureService';
import {
  LocalVoiceClip,
  playLocalVoiceClip,
  removeLocalVoiceClip,
  stopLocalVoicePlayback,
  storeLocalVoiceClip
} from '../services/LocalCommunityVoiceService';
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
  @State loadingMessages: boolean = true;
  @State sending: boolean = false;
  @State draft: string = '';
  @State feedback: string = '';
  @State feedbackIsError: boolean = false;
  @State localSessionFull: boolean = false;
  @State safetyExpanded: boolean = false;
  @State groupBlocked: boolean = false;
  @State voiceRecording: boolean = false;
  @State voiceReady: boolean = false;
  @State voiceElapsedSeconds: number = 0;
  @State voiceStatusLabel: string = '';
  @State voiceActionInFlight: boolean = false;
  private readonly chatScroller: Scroller = new Scroller();
  private localMessageSequence: number = 1;
  private previousKeyboardAvoidMode: KeyboardAvoidMode =
    KeyboardAvoidMode.OFFSET;
  private keyboardAvoidModeConfigured: boolean = false;
  private voiceTimerId: number = -1;
  private voiceCapture: TransientAudioCaptureService =
    new TransientAudioCaptureService();
  private pendingVoiceClip?: LocalVoiceClip;

  aboutToAppear(): void {
    this.voiceCapture.setInterruptionListener((): void => {
      this.handleVoiceInterruption();
    });
    this.loadMessages();
    this.previousKeyboardAvoidMode =
      this.getUIContext().getKeyboardAvoidMode();
    this.getUIContext().setKeyboardAvoidMode(
      KeyboardAvoidMode.RESIZE_WITH_CARET
    );
    this.keyboardAvoidModeConfigured = true;
  }

  aboutToDisappear(): void {
    this.clearVoiceTimer();
    this.voiceCapture.setInterruptionListener((): void => {});
    this.voiceCapture.release();
    stopLocalVoicePlayback();
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
            if (this.voiceActionInFlight) {
              this.voiceStatusLabel = '语音处理中，请稍后再切换加入状态';
              this.feedbackIsError = true;
              return;
            }
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
          canSend: this.joined && !this.sending && !this.groupBlocked &&
            !this.localSessionFull && !this.loadingMessages,
          disabledHint: this.groupBlocked ? '已在本机屏蔽此话题组' :
            (this.localSessionFull ? '本机会话已满' :
              (this.loadingMessages ? '正在加载消息' :
                (this.sending ? '正在发送' : '加入后可回应'))),
          feedback: this.feedback,
          feedbackIsError: this.feedbackIsError,
          voiceStateLabel: this.voiceStatusLabel,
          voiceActive: this.voiceRecording,
          voiceReady: this.voiceReady,
          voiceActionInFlight: this.voiceActionInFlight,
          onDraftChange: (value: string): void => {
            this.handleDraftChange(value);
          },
          onSend: (): void => {
            this.sendMessage();
          },
          onVoiceAction: (): void => { this.toggleVoiceRecording(); },
          onVoiceCancel: (): void => { this.cancelVoiceRecording(); },
          onVoicePlay: (): void => { this.playPendingVoice(); },
          onVoiceSend: (): void => { this.sendVoiceMessage(); }
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

      Row() {
        Button(this.groupBlocked ? '取消本机屏蔽' : '本机屏蔽')
          .fontSize(11)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink_primary'))
          .height(44)
          .layoutWeight(1)
          .backgroundColor($r('app.color.surface_muted'))
          .borderRadius(12)
          .enabled(!this.voiceActionInFlight)
          .onClick((): void => {
            if (this.voiceActionInFlight) {
              return;
            }
            this.groupBlocked = !this.groupBlocked;
            this.feedback = this.groupBlocked ?
              '已在本次运行中屏蔽此话题组' : '已取消本机屏蔽';
            this.feedbackIsError = false;
            if (this.groupBlocked) {
              this.discardUnavailableVoice('已屏蔽并释放待发送语音');
            }
          })
          .accessibilityText(this.groupBlocked ?
            '取消本机屏蔽此话题组' : '在本次运行中屏蔽此话题组')
      }
      .width('100%')

      Text('本机体验会话：消息只保留在本次运行，不会同步到服务器。')
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
      if (this.loadingMessages) {
        ListItem() {
          Column({ space: 10 }) {
            LoadingProgress()
              .width(28)
              .height(28)
              .color($r('app.color.accent'))
            Text('正在加载会话')
              .fontSize(13)
              .fontColor($r('app.color.ink_muted'))
          }
          .width('100%')
          .padding({ top: 56, bottom: 56 })
          .accessibilityGroup(true)
        }
      } else if (this.groupBlocked) {
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
            Text(this.joined ? '发送第一条只保留在本次运行的消息。' : '加入后可以发送本机体验消息。')
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
                maxBubbleWidth: this.maxBubbleWidth(),
                onPlayVoice: (clipId: string): void => { this.playVoiceMessage(clipId); }
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

  private async sendMessage(): Promise<void> {
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
    const validationMessage = validateCommunityMessageDraft(this.draft);
    if (validationMessage.length > 0) {
      this.feedback = validationMessage;
      this.feedbackIsError = true;
      return;
    }
    this.sending = true;
    const text = this.draft;
    let sentSuccessfully = false;
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const sent = await createCommunityMessage(this.group.id, text, context);
      if (sent === undefined) throw new Error('send failed');
      this.messages = this.messages.concat(sent);
      this.feedback = '已发送';
      this.feedbackIsError = false;
      sentSuccessfully = true;
    } catch {
      const localMessage = createLocalCommunityMessage(
        this.group.id,
        text,
        this.localMessageSequence,
        this.currentTimeLabel()
      );
      if (localMessage !== undefined) {
        const result = storeLocalCommunityMessage(localMessage);
        if (result === CommunityMessageStoreResult.STORED) {
          this.messages = this.messages.concat(localMessage);
          this.localMessageSequence += 1;
          this.feedback = '网络暂不可用，已保存为本机消息';
          this.feedbackIsError = false;
          sentSuccessfully = true;
        } else if (result === CommunityMessageStoreResult.LIMIT) {
          this.localSessionFull = true;
          this.feedback = '本机会话已满（每群最多 100 条），消息未保存';
          this.feedbackIsError = true;
        } else {
          this.feedback = '消息发送失败，内容仍保留在输入框，请稍后重试';
          this.feedbackIsError = true;
        }
      } else {
        this.feedback = '消息发送失败，内容仍保留在输入框，请稍后重试';
        this.feedbackIsError = true;
      }
    } finally {
      this.sending = false;
    }
    if (sentSuccessfully) {
      this.draft = '';
      setTimeout((): void => {
        this.chatScroller.scrollToIndex(
          this.messages.length - 1,
          true,
          ScrollAlign.END
        );
      }, 30);
    }
  }

  private async loadMessages(): Promise<void> {
    this.loadingMessages = true;
    try {
      const loaded = await getCommunityMessages(this.group.id);
      this.messages = loaded;
    } catch {
      this.feedback = '会话加载失败，请稍后重试';
      this.feedbackIsError = true;
    } finally {
      this.loadingMessages = false;
    }
  }

  private async toggleVoiceRecording(): Promise<void> {
    if (this.voiceActionInFlight) {
      return;
    }
    this.voiceActionInFlight = true;
    try {
      if (this.voiceRecording) {
        await this.finishVoiceRecording();
      } else {
        await this.startVoiceRecording();
      }
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async startVoiceRecording(): Promise<void> {
    if (!this.joined || this.groupBlocked || this.localSessionFull) {
      this.voiceStatusLabel = this.groupBlocked ? '本机已屏蔽该群聊' :
        (this.localSessionFull ? '本机会话已满' : '加入群聊后才能发送语音');
      this.feedbackIsError = true;
      return;
    }
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const permission: Permissions = 'ohos.permission.MICROPHONE';
      const manager = abilityAccessCtrl.createAtManager();
      if (manager.getSelfPermissionStatus(permission) !==
        abilityAccessCtrl.PermissionStatus.GRANTED) {
        const result: PermissionRequestResult =
          await manager.requestPermissionsFromUser(context, [permission]);
        if (result.authResults[0] !== 0) {
          this.voiceStatusLabel = '未获得麦克风权限，请在“隐私与关于”查看权限说明';
          this.feedbackIsError = true;
          return;
        }
      }
      await this.voiceCapture.start();
      this.pendingVoiceClip = undefined;
      this.voiceReady = false;
      this.voiceElapsedSeconds = 0;
      this.voiceRecording = true;
      this.feedbackIsError = false;
      this.voiceStatusLabel = '正在录音 00:00 · 仅保留在本机内存';
      this.startVoiceTimer();
    } catch (_error) {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceRecording = false;
      this.voiceReady = false;
      this.voiceStatusLabel = '麦克风启动失败，可能正被其他应用占用';
      this.feedbackIsError = true;
    }
  }

  private async finishVoiceRecording(): Promise<void> {
    this.clearVoiceTimer();
    try {
      const capturedBytes = await this.voiceCapture.stop();
      this.voiceRecording = false;
      if (capturedBytes <= 0 || this.voiceElapsedSeconds < 2) {
        await this.voiceCapture.release();
        this.voiceElapsedSeconds = 0;
        this.voiceReady = false;
        this.voiceStatusLabel = '录音不足 2 秒，请重新录制';
        this.feedbackIsError = true;
        return;
      }
      const clipId = 'voice-' + this.group.id + '-' +
        this.localMessageSequence.toString();
      this.pendingVoiceClip = this.voiceCapture.createLocalVoiceClip(
        clipId,
        this.voiceElapsedSeconds
      );
      this.voiceReady = this.pendingVoiceClip !== undefined;
      this.voiceStatusLabel = this.voiceReady ?
        '已录制 ' + this.voiceElapsedSeconds.toString() + ' 秒 · 可试听后发送' :
        '语音准备失败，请重新录制';
      this.feedbackIsError = !this.voiceReady;
    } catch (_error) {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceRecording = false;
      this.voiceElapsedSeconds = 0;
      this.voiceReady = false;
      this.voiceStatusLabel = '结束录音失败，采集资源已释放，请重新录制';
      this.feedbackIsError = true;
    }
  }

  private async cancelVoiceRecording(): Promise<void> {
    if (this.voiceActionInFlight) {
      return;
    }
    this.voiceActionInFlight = true;
    this.clearVoiceTimer();
    try {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceRecording = false;
      this.voiceReady = false;
      this.voiceElapsedSeconds = 0;
      this.voiceStatusLabel = '已取消并释放本次语音';
      this.feedbackIsError = false;
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async handleVoiceInterruption(): Promise<void> {
    if (!this.voiceRecording || this.voiceActionInFlight) {
      return;
    }
    this.voiceActionInFlight = true;
    this.clearVoiceTimer();
    try {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceRecording = false;
      this.voiceReady = false;
      this.voiceElapsedSeconds = 0;
      this.voiceStatusLabel = '录音被通话或其他音频任务中断，请重新录制';
      this.feedbackIsError = true;
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async playPendingVoice(): Promise<void> {
    if (this.voiceActionInFlight || !this.joined || this.groupBlocked ||
      this.localSessionFull) {
      this.voiceStatusLabel = '当前状态不能试听或发送语音';
      this.feedbackIsError = true;
      return;
    }
    this.voiceActionInFlight = true;
    try {
      await this.voiceCapture.play();
      this.voiceStatusLabel = '试听完成 · 语音尚未发送';
    } catch (_error) {
      this.voiceStatusLabel = '试听失败，请重新录制';
      this.feedbackIsError = true;
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async sendVoiceMessage(): Promise<void> {
    if (this.voiceActionInFlight) {
      return;
    }
    if (!this.joined || this.groupBlocked || this.localSessionFull) {
      this.voiceStatusLabel = this.groupBlocked ? '已屏蔽此话题组，不能发送语音' :
        (this.localSessionFull ? '本机会话已满，不能发送语音' : '加入后才能发送语音');
      this.feedbackIsError = true;
      return;
    }
    if (this.pendingVoiceClip === undefined) {
      this.voiceStatusLabel = '没有可发送的语音';
      this.feedbackIsError = true;
      return;
    }
    this.voiceActionInFlight = true;
    const clip: LocalVoiceClip = this.pendingVoiceClip;
    const message = createLocalCommunityVoiceMessage(
      this.group.id,
      clip,
      this.localMessageSequence,
      this.currentTimeLabel()
    );
    if (message === undefined || !storeLocalVoiceClip(this.pendingVoiceClip)) {
      this.voiceStatusLabel = '语音未保存：本机体验语音空间已满或数据无效，请重新打开应用后再试';
      this.feedbackIsError = true;
      this.voiceActionInFlight = false;
      return;
    }
    const storeResult = storeLocalCommunityMessage(message);
    if (storeResult !== CommunityMessageStoreResult.STORED) {
      removeLocalVoiceClip(this.pendingVoiceClip.id);
      this.localSessionFull = storeResult === CommunityMessageStoreResult.LIMIT;
      this.voiceStatusLabel = this.localSessionFull ?
        '本机会话已满，语音未保存' : '语音发送失败，请重试';
      this.feedbackIsError = true;
      this.voiceActionInFlight = false;
      return;
    }
    this.messages = this.messages.concat(message);
    this.localMessageSequence += 1;
    try {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceReady = false;
      this.voiceElapsedSeconds = 0;
      this.voiceStatusLabel = '语音已保存在本机内存，未同步';
      this.feedbackIsError = false;
      setTimeout((): void => {
        this.chatScroller.scrollToIndex(this.messages.length - 1, true, ScrollAlign.END);
      }, 30);
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async playVoiceMessage(clipId: string): Promise<void> {
    try {
      const played = await playLocalVoiceClip(clipId);
      this.feedback = played ? '语音播放完成' : '语音已随进程释放';
      this.feedbackIsError = !played;
    } catch (_error) {
      this.feedback = '语音播放失败';
      this.feedbackIsError = true;
    }
  }

  private startVoiceTimer(): void {
    this.clearVoiceTimer();
    this.voiceTimerId = setInterval((): void => {
      this.voiceElapsedSeconds += 1;
      this.voiceStatusLabel = '正在录音 ' +
        this.formatVoiceDuration(this.voiceElapsedSeconds) +
        ' · 仅保留在本机内存';
      if (this.voiceElapsedSeconds >= 60) {
        this.finishVoiceRecordingFromTimer();
      }
    }, 1000);
  }

  private clearVoiceTimer(): void {
    if (this.voiceTimerId >= 0) {
      clearInterval(this.voiceTimerId);
      this.voiceTimerId = -1;
    }
  }

  private formatVoiceDuration(seconds: number): string {
    return '00:' + seconds.toString().padStart(2, '0');
  }

  private confirmMembershipChange(): void {
    if (this.voiceActionInFlight) {
      this.membershipConfirmOpen = false;
      this.voiceStatusLabel = '语音处理中，请稍后再切换加入状态';
      this.feedbackIsError = true;
      return;
    }
    const wasJoined = this.joined;
    this.onToggleMembership(this.group.id);
    this.membershipConfirmOpen = false;
    if (wasJoined) {
      this.draft = '';
      this.feedback = '加入后可发言';
      this.feedbackIsError = false;
      this.discardUnavailableVoice('已退出并释放待发送语音');
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

  private async finishVoiceRecordingFromTimer(): Promise<void> {
    if (this.voiceActionInFlight || !this.voiceRecording) {
      return;
    }
    this.voiceActionInFlight = true;
    try {
      await this.finishVoiceRecording();
    } finally {
      this.voiceActionInFlight = false;
    }
  }

  private async discardUnavailableVoice(statusMessage: string): Promise<void> {
    if (this.voiceActionInFlight) {
      return;
    }
    this.voiceActionInFlight = true;
    this.clearVoiceTimer();
    try {
      await this.voiceCapture.release();
      this.pendingVoiceClip = undefined;
      this.voiceRecording = false;
      this.voiceReady = false;
      this.voiceElapsedSeconds = 0;
      this.voiceStatusLabel = statusMessage;
    } finally {
      this.voiceActionInFlight = false;
    }
  }
}
