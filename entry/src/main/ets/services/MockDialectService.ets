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

export function getMapMarkers(): MapMarker[] {
  return [
    {
      id: 'sichuan',
      regionName: '四川',
      dialectName: '四川话',
      fellowCount: 87000,
      latitude: 30.5728,
      longitude: 104.0668,
      xRatio: 0.36,
      yRatio: 0.53
    },
    {
      id: 'guangdong',
      regionName: '广东',
      dialectName: '粤语',
      fellowCount: 54000,
      latitude: 23.1291,
      longitude: 113.2644,
      xRatio: 0.57,
      yRatio: 0.72
    },
    {
      id: 'shanghai',
      regionName: '上海',
      dialectName: '上海话',
      fellowCount: 36000,
      latitude: 31.2304,
      longitude: 121.4737,
      xRatio: 0.76,
      yRatio: 0.5
    },
    {
      id: 'beijing',
      regionName: '北京',
      dialectName: '北京话',
      fellowCount: 41000,
      latitude: 39.9042,
      longitude: 116.4074,
      xRatio: 0.65,
      yRatio: 0.29
    }
  ];
}

export function getFellowUsers(): FellowUser[] {
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
  users: FellowUser[],
  source: FellowSource
): FellowUser[] {
  return users.filter((user: FellowUser): boolean => user.source === source);
}

export function createSimulatedAssessment(regionName: string, dialectName: string): DialectAssessment {
  return {
    dialectName: dialectName,
    dialectGroup: '西南官话',
    dialectBranch: '成渝片',
    regionName: regionName,
    regionCandidates: [
      { name: '成都', confidence: 82 },
      { name: '眉山', confidence: 11 },
      { name: '重庆', confidence: 7 }
    ],
    confidence: clampScore(87),
    retention: clampScore(76),
    evidence: ['部分声母与韵母特征', '句尾语气与成都周边表达接近', '词汇节奏符合西南官话样例'],
    similarDialects: ['重庆话', '自贡话'],
    needsConfirmation: true,
    isSimulated: true
  };
}

export function correctSimulatedAssessment(
  assessment: DialectAssessment,
  regionName: string,
  dialectName: string,
  dialectBranch: string
): DialectAssessment {
  return {
    dialectName: dialectName,
    dialectGroup: assessment.dialectGroup,
    dialectBranch: dialectBranch,
    regionName: regionName,
    regionCandidates: assessment.regionCandidates,
    confidence: assessment.confidence,
    retention: assessment.retention,
    evidence: assessment.evidence,
    similarDialects: assessment.similarDialects,
    needsConfirmation: false,
    isSimulated: assessment.isSimulated
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

export function createCurrentUserFromAssessment(assessment: DialectAssessment): FellowUser {
  return {
    id: 'current-user',
    nickname: '我的乡音',
    initials: '我',
    location: assessment.regionName + ' · 成都',
    dialectName: assessment.dialectName,
    distanceText: '当前用户',
    source: FellowSource.CURRENT_REGION,
    confidence: clampScore(assessment.confidence),
    retention: clampScore(assessment.retention),
    litRegions: [assessment.regionName],
    fellowFriends: 0,
    following: 0,
    followers: 0,
    voiceTitle: '我的第一段乡音',
    voiceDurationSeconds: 14
  };
}
