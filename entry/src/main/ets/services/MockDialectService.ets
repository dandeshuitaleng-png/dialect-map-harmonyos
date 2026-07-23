import {
  DialectAssessment,
  FellowSource,
  FellowUser,
  MapMarker,
  VoicePassport
} from '../models/DialectModels';

const MIN_SCORE: number = 0;
const MAX_SCORE: number = 100;

export function clampScore(score: number): number {
  return Math.max(MIN_SCORE, Math.min(MAX_SCORE, Math.round(score)));
}

export function getMapMarkers(): ReadonlyArray<MapMarker> {
  return [
    {
      id: 'sichuan',
      regionName: '四川',
      dialectName: '四川话',
      fellowCount: 87000,
      xRatio: 0.36,
      yRatio: 0.53
    },
    {
      id: 'guangdong',
      regionName: '广东',
      dialectName: '粤语',
      fellowCount: 54000,
      xRatio: 0.57,
      yRatio: 0.72
    },
    {
      id: 'shanghai',
      regionName: '上海',
      dialectName: '上海话',
      fellowCount: 36000,
      xRatio: 0.76,
      yRatio: 0.5
    },
    {
      id: 'beijing',
      regionName: '北京',
      dialectName: '北京话',
      fellowCount: 41000,
      xRatio: 0.65,
      yRatio: 0.29
    }
  ];
}

export function getFellowUsers(): ReadonlyArray<FellowUser> {
  return [
    {
      id: 'user-xiaoman',
      nickname: '小满',
      initials: '满',
      location: '北京 · 朝阳区',
      dialectName: '四川话',
      distanceText: '1.2 km',
      source: FellowSource.NEARBY,
      confidence: 87,
      retention: 76,
      litRegions: ['四川', '北京'],
      fellowFriends: 128,
      following: 256,
      followers: 318,
      voiceTitle: '离家以后，最想念这句话',
      voiceDurationSeconds: 16
    },
    {
      id: 'user-aqing',
      nickname: '阿晴',
      initials: '晴',
      location: '广州 · 越秀区',
      dialectName: '粤语',
      distanceText: '同城',
      source: FellowSource.RECOMMENDED,
      confidence: 93,
      retention: 88,
      litRegions: ['广东', '香港'],
      fellowFriends: 96,
      following: 184,
      followers: 427,
      voiceTitle: '得闲饮茶',
      voiceDurationSeconds: 12
    },
    {
      id: 'user-zhou',
      nickname: '周叔',
      initials: '周',
      location: '上海 · 黄浦区',
      dialectName: '上海话',
      distanceText: '当前区域',
      source: FellowSource.CURRENT_REGION,
      confidence: 91,
      retention: 82,
      litRegions: ['上海'],
      fellowFriends: 72,
      following: 118,
      followers: 209,
      voiceTitle: '弄堂里的叫卖声',
      voiceDurationSeconds: 34
    },
    {
      id: 'user-dayu',
      nickname: '大宇',
      initials: '宇',
      location: '北京 · 西城区',
      dialectName: '北京话',
      distanceText: '当前区域',
      source: FellowSource.CURRENT_REGION,
      confidence: 89,
      retention: 79,
      litRegions: ['北京', '天津'],
      fellowFriends: 110,
      following: 146,
      followers: 268,
      voiceTitle: '您吃了吗',
      voiceDurationSeconds: 11
    }
  ];
}

export function filterFellowsBySource(
  users: ReadonlyArray<FellowUser>,
  source: FellowSource
): ReadonlyArray<FellowUser> {
  return users.filter((user: FellowUser): boolean => user.source === source);
}

export function createSimulatedAssessment(regionName: string, dialectName: string): DialectAssessment {
  return {
    dialectName: dialectName,
    regionName: regionName,
    confidence: clampScore(87),
    retention: clampScore(76),
    isSimulated: true
  };
}

export function createPassport(
  user: FellowUser,
  isCurrentUser: boolean = false
): VoicePassport {
  return {
    userId: user.id,
    nickname: user.nickname,
    initials: user.initials,
    location: user.location,
    dialectName: user.dialectName,
    confidence: clampScore(user.confidence),
    retention: clampScore(user.retention),
    representativeVoiceTitle: user.voiceTitle,
    representativeVoiceDurationSeconds: user.voiceDurationSeconds,
    litRegions: user.litRegions,
    fellowFriends: user.fellowFriends,
    following: user.following,
    followers: user.followers,
    isCurrentUser: isCurrentUser
  };
}

