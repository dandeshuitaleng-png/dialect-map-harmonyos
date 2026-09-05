/**
 * Local-only demonstration community data. No remote account or database is used.
 */
import { CommunityGroup, CommunityMessage, GroupSource } from '../models/DialectModels';
import { LocalVoiceClip } from './LocalCommunityVoiceService';

export const COMMUNITY_MESSAGE_MAX_LENGTH: number = 120;
export const COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP: number = 100;

export enum CommunityMessageStoreResult {
  STORED = 'stored',
  DUPLICATE = 'duplicate',
  LIMIT = 'limit',
  INVALID = 'invalid'
}

const DEMONSTRATION_GROUPS: CommunityGroup[] = [
  makeGroup('group-chengyu-memory', '成渝乡音记忆馆', '川渝', '四川 · 重庆', '西南官话', true, 0),
  makeGroup('group-guangfu-tea', '广府饮茶声', '广府', '广州 · 佛山', '粤语广府片', true, 0),
  makeGroup('group-shanghai-alley', '上海弄堂声音志', '沪语', '上海', '吴语太湖片', false, 2),
  makeGroup('group-beijing-greeting', '京城招呼研究所', '京味', '北京', '北京官话', true, 0)
];

const DEMONSTRATION_MESSAGES: CommunityMessage[] = [
  demoMessage('message-chengyu-1', 'group-chengyu-memory', '示例·小川', '川', '你们家里怎么说“外婆”？我家一直喊“婆婆”。', '09:42'),
  demoMessage('message-chengyu-2', 'group-chengyu-memory', '示例·山城', '渝', '重庆这边也有喊“婆婆”的，不同区县的说法还会变。', '09:45'),
  demoMessage('message-guangfu-1', 'group-guangfu-tea', '示例·西关', '西', '在我家，“得闲饮茶”不一定马上约时间，也是在表达惦记。', '18:20'),
  demoMessage('message-guangfu-2', 'group-guangfu-tea', '示例·阿粤', '粤', '对，是很自然的邀约。大家也可以写下所在地区。', '18:23'),
  demoMessage('message-shanghai-1', 'group-shanghai-alley', '示例·弄堂口', '弄', '以前傍晚最熟悉的是隔壁叫小囡回去吃饭的声音。', '20:06'),
  demoMessage('message-shanghai-2', 'group-shanghai-alley', '示例·阿拉', '沪', '这句招呼我小时候天天听见，现在想起来还是很有画面。', '20:08'),
  demoMessage('message-beijing-1', 'group-beijing-greeting', '示例·胡同边', '胡', '同一个“您”，熟人见面和请人帮忙时的语气就不一样。', '11:12'),
  demoMessage('message-beijing-2', 'group-beijing-greeting', '示例·小京', '京', '是，“您”得放进具体语境里听，不能只看一个字。', '11:15')
];

const LOCAL_SESSION_MESSAGES: CommunityMessage[] = [];
const READ_MESSAGE_IDS: Map<string, string> = new Map<string, string>();
const INITIAL_JOINED_GROUP_IDS: string[] = ['group-shanghai-alley'];

function makeGroup(id: string, name: string, avatarText: string, regionName: string,
  dialectName: string, recommended: boolean, unreadCount: number): CommunityGroup {
  return {
    id, name, avatarText, regionName, dialectName,
    summary: '从一句乡音、一个称呼或一段共同记忆开始体验。',
    memberCount: 0, activeLabel: '本机示例会话', lastMessagePreview: '示例消息，仅供体验',
    lastMessageTimeLabel: '今天', unreadCount, accentLabel: '本机样例', recommended,
    rules: ['尊重不同地区的表达，不比较口音高低。', '不发布联系方式、精确地址或未经授权的录音。'],
    recentTopics: [{ id: id + '-topic', title: '你家乡最熟悉的一句称呼是什么？', authorLabel: '本机样例', activityLabel: '演示回应' }],
    isDemonstration: true
  };
}

function demoMessage(id: string, groupId: string, senderLabel: string, senderInitials: string,
  content: string, timeLabel: string): CommunityMessage {
  return { id, groupId, senderId: 'demo', senderLabel, senderInitials, content, timeLabel,
    timeSeparatorLabel: '', isCurrentUser: false, isLocalOnly: false, isDemonstration: true };
}

export function getCommunityGroups(): CommunityGroup[] {
  return DEMONSTRATION_GROUPS;
}

export function getInitialJoinedGroupIds(): string[] {
  return INITIAL_JOINED_GROUP_IDS.slice();
}

export function getCommunityMessages(groupId: string): CommunityMessage[] {
  return DEMONSTRATION_MESSAGES.filter(m => m.groupId === groupId)
    .concat(LOCAL_SESSION_MESSAGES.filter(m => m.groupId === groupId));
}

export function getLatestCommunityMessage(groupId: string): CommunityMessage | undefined {
  const msgs = getCommunityMessages(groupId);
  return msgs.length > 0 ? msgs[msgs.length - 1] : undefined;
}

export function markCommunityGroupRead(groupId: string): void {
  const latest = getLatestCommunityMessage(groupId);
  if (latest !== undefined) READ_MESSAGE_IDS.set(groupId, latest.id);
}

export function getCommunityLastReadMessageId(groupId: string): string {
  return READ_MESSAGE_IDS.get(groupId) ?? '';
}

export function getCommunityUnreadCount(group: CommunityGroup): number {
  const readId = getCommunityLastReadMessageId(group.id);
  if (readId.length === 0) return group.unreadCount;
  const messages = getCommunityMessages(group.id);
  const index = messages.findIndex((message: CommunityMessage): boolean => message.id === readId);
  return index < 0 ? group.unreadCount : messages.slice(index + 1)
    .filter((message: CommunityMessage): boolean => !message.isCurrentUser).length;
}

export function getLocalCommunityMessageCount(groupId: string): number {
  return LOCAL_SESSION_MESSAGES.filter(m => m.groupId === groupId).length;
}

export function validateCommunityMessageDraft(rawText: string): string {
  const content = rawText.trim();
  if (content.length === 0) return '先输入消息内容';
  if (content.length > COMMUNITY_MESSAGE_MAX_LENGTH) return '消息最多 ' + COMMUNITY_MESSAGE_MAX_LENGTH.toString() + ' 个字';
  return '';
}

export function createLocalCommunityMessage(
  groupId: string, rawText: string, sequence: number, timeLabel: string
): CommunityMessage | undefined {
  const content = rawText.trim();
  if (groupId.trim().length === 0 || validateCommunityMessageDraft(content).length > 0) return undefined;
  const msg: CommunityMessage = {
    id: 'local-' + groupId + '-' + sequence.toString(),
    groupId: groupId, senderId: 'me', senderLabel: '我', senderInitials: '我',
    content: content, timeLabel: timeLabel, timeSeparatorLabel: '',
    isCurrentUser: true, isLocalOnly: true, isDemonstration: false,
  };
  return msg;
}

export function storeLocalCommunityMessage(message: CommunityMessage): CommunityMessageStoreResult {
  if (!message.isCurrentUser || !message.isLocalOnly || message.isDemonstration) return CommunityMessageStoreResult.INVALID;
  const dup = LOCAL_SESSION_MESSAGES.some(m => m.id === message.id);
  if (dup) return CommunityMessageStoreResult.DUPLICATE;
  const count = getLocalCommunityMessageCount(message.groupId);
  if (count >= COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP) return CommunityMessageStoreResult.LIMIT;
  LOCAL_SESSION_MESSAGES.push(message);
  return CommunityMessageStoreResult.STORED;
}

export function filterCommunityGroups(
  groups: CommunityGroup[], source: GroupSource, joinedGroupIds: string[]
): CommunityGroup[] {
  if (source === GroupSource.JOINED) return groups.filter(g => joinedGroupIds.indexOf(g.id) >= 0);
  if (source === GroupSource.RECOMMENDED) return groups.filter(g => g.recommended);
  return groups;
}

export function toggleLocalGroupMembership(joinedGroupIds: string[], groupId: string): string[] {
  const joined = joinedGroupIds.indexOf(groupId) >= 0;
  if (joined) return joinedGroupIds.filter(id => id !== groupId);
  return joinedGroupIds.concat(groupId);
}

// Voice message stubs — keep existing component interface
const voiceClips: LocalVoiceClip[] = [];

export function createLocalCommunityVoiceMessage(
  groupId: string, clip: LocalVoiceClip, sequence: number, timeLabel: string
): CommunityMessage {
  return {
    id: 'voice-' + groupId + '-' + sequence.toString(),
    groupId, senderId: 'me', senderLabel: '我', senderInitials: '我',
    content: `🎤 语音消息 (${clip.durationSeconds}s)`,
    timeLabel, timeSeparatorLabel: '',
    isCurrentUser: true, isLocalOnly: true, isDemonstration: false,
  };
}

export function storeLocalCommunityVoiceClip(clip: LocalVoiceClip): void {
  voiceClips.push(clip);
}

export function playLocalVoiceClip(_clipId: string): Promise<void> {
  return Promise.resolve();
}

export function removeLocalVoiceClip(_clipId: string): void {
  // no-op for now
}
