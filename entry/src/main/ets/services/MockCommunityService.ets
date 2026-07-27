import {
  CommunityGroup,
  CommunityMessage,
  GroupSource
} from '../models/DialectModels';

export const COMMUNITY_MESSAGE_MAX_LENGTH: number = 120;
export const COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP: number = 100;

export enum CommunityMessageStoreResult {
  STORED = 'stored',
  DUPLICATE = 'duplicate',
  LIMIT = 'limit',
  INVALID = 'invalid'
}

interface CommunitySessionReadState {
  readonly groupId: string;
  lastReadMessageId: string;
}

const DEMONSTRATION_GROUPS: CommunityGroup[] = [
  {
    id: 'group-chengyu-memory',
    name: '成渝乡音记忆馆',
    avatarText: '川渝',
    regionName: '四川 · 重庆',
    dialectName: '西南官话',
    summary: '从儿时称呼、街巷声音到离家后的第一句乡音，一起保存成渝共同记忆。',
    memberCount: 2864,
    activeLabel: '本机示例会话',
    lastMessagePreview: '示例·山城：重庆这边也有喊“婆婆”的',
    lastMessageTimeLabel: '09:45',
    unreadCount: 0,
    accentLabel: '共同记忆',
    recommended: true,
    rules: [
      '尊重不同地区的读音和表达，不比较口音高低。',
      '演示话题不代表真实成员发言，不上传个人录音。',
      '引用方言资料时标注来源，存疑内容主动说明。'
    ],
    recentTopics: [
      {
        id: 'topic-chengyu-1',
        title: '你小时候怎么称呼“外婆”？',
        authorLabel: '成都乡音',
        activityLabel: '24 条演示回应'
      },
      {
        id: 'topic-chengyu-2',
        title: '一听就回到夏天的街巷叫卖声',
        authorLabel: '重庆乡音',
        activityLabel: '18 条演示回应'
      }
    ],
    isDemonstration: true
  },
  {
    id: 'group-guangfu-tea',
    name: '广府饮茶声',
    avatarText: '广府',
    regionName: '广州 · 佛山',
    dialectName: '粤语广府片',
    summary: '以茶楼、街市和家庭称谓为线索，收集仍在生活里使用的广府表达。',
    memberCount: 1942,
    activeLabel: '本机示例会话',
    lastMessagePreview: '示例·阿粤：“得闲饮茶”是很自然的邀约',
    lastMessageTimeLabel: '昨天',
    unreadCount: 0,
    accentLabel: '生活表达',
    recommended: true,
    rules: [
      '欢迎补充地区差异，避免把单一读音当成唯一标准。',
      '不发布联系方式、精确地址和未经授权的录音。',
      '演示阶段的话题仅供界面和流程验证。'
    ],
    recentTopics: [
      {
        id: 'topic-guangfu-1',
        title: '“得闲饮茶”在你家通常什么时候说？',
        authorLabel: '越秀乡音',
        activityLabel: '31 条演示回应'
      },
      {
        id: 'topic-guangfu-2',
        title: '街市里最有画面的那句粤语',
        authorLabel: '佛山乡音',
        activityLabel: '16 条演示回应'
      }
    ],
    isDemonstration: true
  },
  {
    id: 'group-shanghai-alley',
    name: '上海弄堂声音志',
    avatarText: '沪语',
    regionName: '上海',
    dialectName: '吴语太湖片',
    summary: '记录弄堂生活、家庭称谓与城市变化中的上海话声音线索。',
    memberCount: 1328,
    activeLabel: '本机示例会话',
    lastMessagePreview: '示例·阿拉：这句招呼我小时候天天听见',
    lastMessageTimeLabel: '周二',
    unreadCount: 2,
    accentLabel: '城市声音',
    recommended: false,
    rules: [
      '区分演示内容与有来源的方言资料。',
      '讨论城市记忆时尊重不同年代和社区经验。',
      '不公开真实住址或可识别个人的信息。'
    ],
    recentTopics: [
      {
        id: 'topic-shanghai-1',
        title: '弄堂里曾经最常听见的招呼',
        authorLabel: '黄浦乡音',
        activityLabel: '14 条演示回应'
      }
    ],
    isDemonstration: true
  },
  {
    id: 'group-beijing-greeting',
    name: '京城招呼研究所',
    avatarText: '京味',
    regionName: '北京',
    dialectName: '北京官话',
    summary: '从一句“您吃了吗”出发，辨认语气、称呼和城市日常中的亲近感。',
    memberCount: 1686,
    activeLabel: '本机示例会话',
    lastMessagePreview: '示例·小京：“您”得放进语境里听',
    lastMessageTimeLabel: '周一',
    unreadCount: 0,
    accentLabel: '称谓语气',
    recommended: true,
    rules: [
      '不以儿化音多少评价口音是否地道。',
      '引用他人表达时去除可识别个人的信息。',
      '当前成员数和话题均为演示数据。'
    ],
    recentTopics: [
      {
        id: 'topic-beijing-1',
        title: '哪种“您”听起来最亲切？',
        authorLabel: '西城乡音',
        activityLabel: '22 条演示回应'
      }
    ],
    isDemonstration: true
  }
];

const DEMONSTRATION_MESSAGES: CommunityMessage[] = [
  {
    id: 'message-chengyu-1',
    groupId: 'group-chengyu-memory',
    senderId: 'demo-chuan',
    senderLabel: '示例·小川',
    senderInitials: '川',
    content: '你们家里怎么说“外婆”？我家一直喊“婆婆”。',
    timeLabel: '09:42',
    timeSeparatorLabel: '今天 09:40',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-chengyu-2',
    groupId: 'group-chengyu-memory',
    senderId: 'demo-shancheng',
    senderLabel: '示例·山城',
    senderInitials: '渝',
    content: '重庆这边也有喊“婆婆”的，不同区县的说法还会变。',
    timeLabel: '09:45',
    timeSeparatorLabel: '',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-guangfu-1',
    groupId: 'group-guangfu-tea',
    senderId: 'demo-xiguan',
    senderLabel: '示例·西关',
    senderInitials: '西',
    content: '在我家，“得闲饮茶”不一定马上约时间，也是在表达惦记。',
    timeLabel: '18:20',
    timeSeparatorLabel: '昨天 18:18',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-guangfu-2',
    groupId: 'group-guangfu-tea',
    senderId: 'demo-ayue',
    senderLabel: '示例·阿粤',
    senderInitials: '粤',
    content: '对，是很自然的邀约。大家也可以写下所在地区，方便对照差异。',
    timeLabel: '18:23',
    timeSeparatorLabel: '',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-shanghai-1',
    groupId: 'group-shanghai-alley',
    senderId: 'demo-longtang',
    senderLabel: '示例·弄堂口',
    senderInitials: '弄',
    content: '以前傍晚最熟悉的是隔壁叫小囡回去吃饭的声音。',
    timeLabel: '20:06',
    timeSeparatorLabel: '周二 20:05',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-shanghai-2',
    groupId: 'group-shanghai-alley',
    senderId: 'demo-ala',
    senderLabel: '示例·阿拉',
    senderInitials: '沪',
    content: '这句招呼我小时候天天听见，现在想起来还是很有画面。',
    timeLabel: '20:08',
    timeSeparatorLabel: '',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-beijing-1',
    groupId: 'group-beijing-greeting',
    senderId: 'demo-hutong',
    senderLabel: '示例·胡同边',
    senderInitials: '胡',
    content: '同一个“您”，熟人见面和请人帮忙时的语气就不一样。',
    timeLabel: '11:12',
    timeSeparatorLabel: '周一 11:10',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  },
  {
    id: 'message-beijing-2',
    groupId: 'group-beijing-greeting',
    senderId: 'demo-xiaojing',
    senderLabel: '示例·小京',
    senderInitials: '京',
    content: '是，“您”得放进具体语境里听，不能只看一个字。',
    timeLabel: '11:15',
    timeSeparatorLabel: '',
    isCurrentUser: false,
    isLocalOnly: false,
    isDemonstration: true
  }
];

const LOCAL_SESSION_MESSAGES: CommunityMessage[] = [];
const LOCAL_SESSION_READ_STATES: CommunitySessionReadState[] = [];

const INITIAL_JOINED_GROUP_IDS: string[] = ['group-shanghai-alley'];

export function getCommunityGroups(): CommunityGroup[] {
  return DEMONSTRATION_GROUPS;
}

export function getInitialJoinedGroupIds(): string[] {
  return INITIAL_JOINED_GROUP_IDS.slice();
}

export function getCommunityMessages(groupId: string): CommunityMessage[] {
  const demonstrationMessages = DEMONSTRATION_MESSAGES.filter(
    (message: CommunityMessage): boolean => message.groupId === groupId
  );
  const localMessages = LOCAL_SESSION_MESSAGES.filter(
    (message: CommunityMessage): boolean => message.groupId === groupId
  );
  return demonstrationMessages.concat(localMessages);
}

export function getLatestCommunityMessage(
  groupId: string
): CommunityMessage | undefined {
  const messages = getCommunityMessages(groupId);
  if (messages.length === 0) {
    return undefined;
  }
  return messages[messages.length - 1];
}

export function markCommunityGroupRead(groupId: string): void {
  const latestMessage = getLatestCommunityMessage(groupId);
  if (latestMessage === undefined) {
    return;
  }
  const readState = LOCAL_SESSION_READ_STATES.find(
    (state: CommunitySessionReadState): boolean => state.groupId === groupId
  );
  if (readState !== undefined) {
    readState.lastReadMessageId = latestMessage.id;
    return;
  }
  LOCAL_SESSION_READ_STATES.push({
    groupId: groupId,
    lastReadMessageId: latestMessage.id
  });
}

export function getCommunityLastReadMessageId(groupId: string): string {
  const readState = LOCAL_SESSION_READ_STATES.find(
    (state: CommunitySessionReadState): boolean => state.groupId === groupId
  );
  return readState === undefined ? '' : readState.lastReadMessageId;
}

export function getCommunityUnreadCount(group: CommunityGroup): number {
  const lastReadMessageId = getCommunityLastReadMessageId(group.id);
  if (lastReadMessageId.length === 0) {
    return group.unreadCount;
  }
  const messages = getCommunityMessages(group.id);
  const lastReadIndex = messages.findIndex(
    (message: CommunityMessage): boolean => message.id === lastReadMessageId
  );
  if (lastReadIndex < 0) {
    return group.unreadCount;
  }
  return messages.slice(lastReadIndex + 1).filter(
    (message: CommunityMessage): boolean => !message.isCurrentUser
  ).length;
}

export function getLocalCommunityMessageCount(groupId: string): number {
  return LOCAL_SESSION_MESSAGES.filter(
    (message: CommunityMessage): boolean => message.groupId === groupId
  ).length;
}

export function validateCommunityMessageDraft(rawText: string): string {
  const content = rawText.trim();
  if (content.length === 0) {
    return '先输入消息内容';
  }
  if (content.length > COMMUNITY_MESSAGE_MAX_LENGTH) {
    return '消息最多 ' + COMMUNITY_MESSAGE_MAX_LENGTH.toString() + ' 个字';
  }
  return '';
}

export function createLocalCommunityMessage(
  groupId: string,
  rawText: string,
  sequence: number,
  timeLabel: string
): CommunityMessage | undefined {
  const content = rawText.trim();
  if (groupId.trim().length === 0 ||
    validateCommunityMessageDraft(content).length > 0) {
    return undefined;
  }
  return {
    id: 'local-message-' + groupId + '-' + sequence.toString(),
    groupId: groupId,
    senderId: 'current-user',
    senderLabel: '我',
    senderInitials: '我',
    content: content,
    timeLabel: timeLabel,
    timeSeparatorLabel: '',
    isCurrentUser: true,
    isLocalOnly: true,
    isDemonstration: false
  };
}

export function storeLocalCommunityMessage(
  message: CommunityMessage
): CommunityMessageStoreResult {
  if (message.groupId.trim().length === 0 ||
    !message.isCurrentUser || !message.isLocalOnly ||
    message.isDemonstration ||
    validateCommunityMessageDraft(message.content).length > 0) {
    return CommunityMessageStoreResult.INVALID;
  }
  const alreadyStored = LOCAL_SESSION_MESSAGES.some(
    (storedMessage: CommunityMessage): boolean =>
      storedMessage.id === message.id
  );
  if (alreadyStored) {
    return CommunityMessageStoreResult.DUPLICATE;
  }
  const groupMessageCount = getLocalCommunityMessageCount(message.groupId);
  if (groupMessageCount >= COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP) {
    return CommunityMessageStoreResult.LIMIT;
  }
  LOCAL_SESSION_MESSAGES.push(message);
  return CommunityMessageStoreResult.STORED;
}

export function filterCommunityGroups(
  groups: CommunityGroup[],
  source: GroupSource,
  joinedGroupIds: string[]
): CommunityGroup[] {
  if (source === GroupSource.JOINED) {
    return groups.filter((group: CommunityGroup): boolean =>
      joinedGroupIds.indexOf(group.id) >= 0
    );
  }
  if (source === GroupSource.RECOMMENDED) {
    return groups.filter((group: CommunityGroup): boolean => group.recommended);
  }
  return groups;
}

export function toggleLocalGroupMembership(
  joinedGroupIds: string[],
  groupId: string
): string[] {
  if (groupId.trim().length === 0) {
    return joinedGroupIds.slice();
  }
  if (joinedGroupIds.indexOf(groupId) >= 0) {
    return joinedGroupIds.filter((id: string): boolean => id !== groupId);
  }
  return joinedGroupIds.concat(groupId);
}
