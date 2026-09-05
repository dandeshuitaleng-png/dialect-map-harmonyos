import {
  DialectClassification,
  DialectAssessment,
  DialectRegionCandidate,
  FellowSource,
  FellowUser,
  MapMarker,
  VoicePassport
} from '../models/DialectModels';
import {
  getDialectClassification,
  getDialectClassifications
} from './DialectClassificationCatalogService';
import { detectDialectByAI, isAiConfigured } from './DialectAiService';

const MIN_SCORE: number = 0;
const MAX_SCORE: number = 100;

interface SimulatedAssessmentDetails {
  readonly regionCandidates: Array<DialectRegionCandidate>;
  readonly evidence: Array<string>;
  readonly similarDialects: Array<string>;
}

export function clampScore(score: number): number {
  return Math.max(MIN_SCORE, Math.min(MAX_SCORE, Math.round(score)));
}

export function getDemonstrationDialectZoneCount(): number {
  const zoneKeys: string[] = [];
  getDialectClassifications().forEach((item: DialectClassification): void => {
    const zoneKey = item.dialectGroup + '|' + item.dialectBranch;
    if (zoneKeys.indexOf(zoneKey) < 0) {
      zoneKeys.push(zoneKey);
    }
  });
  return zoneKeys.length;
}

export function getMapMarkers(): MapMarker[] {
  return [
    {
      id: 'sichuan',
      classificationId: 'sichuan-chengyu',
      regionName: '四川',
      dialectName: '四川话',
      dialectFamily: '官话',
      dialectGroup: '西南官话 · 川黔片',
      dialectBranch: '成渝小片',
      fellowCount: 0,
      latitude: 30.5728,
      longitude: 104.0668,
      xRatio: 0.36,
      yRatio: 0.53
    },
    {
      id: 'chongqing',
      classificationId: 'chongqing-chengyu',
      regionName: '重庆',
      dialectName: '重庆话',
      dialectFamily: '官话',
      dialectGroup: '西南官话 · 川黔片',
      dialectBranch: '成渝小片',
      fellowCount: 0,
      latitude: 29.5630,
      longitude: 106.5516,
      xRatio: 0.42,
      yRatio: 0.57
    },
    {
      id: 'guangdong',
      classificationId: 'guangzhou-guangfu',
      regionName: '广州',
      dialectName: '粤语',
      dialectFamily: '粤语',
      dialectGroup: '广府片',
      dialectBranch: '广州代表点',
      fellowCount: 0,
      latitude: 23.1291,
      longitude: 113.2644,
      xRatio: 0.57,
      yRatio: 0.72
    },
    {
      id: 'shanghai',
      classificationId: 'shanghai-shanghai',
      regionName: '上海',
      dialectName: '上海话',
      dialectFamily: '吴语',
      dialectGroup: '太湖片',
      dialectBranch: '上海小片',
      fellowCount: 0,
      latitude: 31.2304,
      longitude: 121.4737,
      xRatio: 0.76,
      yRatio: 0.5
    },
    {
      id: 'beijing',
      classificationId: 'beijing-jingshi',
      regionName: '北京',
      dialectName: '北京话',
      dialectFamily: '官话',
      dialectGroup: '北京官话',
      dialectBranch: '京师小片',
      fellowCount: 0,
      latitude: 39.9042,
      longitude: 116.4074,
      xRatio: 0.65,
      yRatio: 0.29
    }
  ];
}

export function getFellowUsers(): FellowUser[] {
  return []
}

export function filterFellowsBySource(
  users: FellowUser[],
  source: FellowSource
): FellowUser[] {
  return users.filter((user: FellowUser): boolean => user.source === source);
}

export function createSimulatedAssessment(regionName: string, dialectName: string): DialectAssessment {
  const classification = getDialectClassification(regionName, dialectName);
  const details = getSimulatedAssessmentDetails(classification);
  return {
    classificationId: classification.id,
    dialectName: classification.dialectName,
    dialectFamily: classification.dialectFamily,
    dialectGroup: classification.dialectGroup,
    dialectBranch: classification.dialectBranch,
    regionName: classification.regionName,
    regionCandidates: details.regionCandidates,
    confidence: clampScore(87),
    retention: clampScore(76),
    evidence: details.evidence,
    similarDialects: details.similarDialects,
    needsConfirmation: true,
    isSimulated: true
  };
}

export function confirmSimulatedAssessment(
  assessment: DialectAssessment
): DialectAssessment {
  return {
    classificationId: assessment.classificationId,
    dialectName: assessment.dialectName,
    dialectFamily: assessment.dialectFamily,
    dialectGroup: assessment.dialectGroup,
    dialectBranch: assessment.dialectBranch,
    regionName: assessment.regionName,
    regionCandidates: assessment.regionCandidates,
    confidence: assessment.confidence,
    retention: assessment.retention,
    evidence: assessment.evidence,
    similarDialects: assessment.similarDialects,
    needsConfirmation: false,
    isSimulated: assessment.isSimulated
  };
}

export function correctSimulatedAssessment(
  assessment: DialectAssessment,
  regionName: string,
  dialectName: string
): DialectAssessment {
  const correctedAssessment = createSimulatedAssessment(regionName, dialectName);
  return {
    classificationId: correctedAssessment.classificationId,
    dialectName: correctedAssessment.dialectName,
    dialectFamily: correctedAssessment.dialectFamily,
    dialectGroup: correctedAssessment.dialectGroup,
    dialectBranch: correctedAssessment.dialectBranch,
    regionName: correctedAssessment.regionName,
    regionCandidates: correctedAssessment.regionCandidates,
    confidence: assessment.confidence,
    retention: assessment.retention,
    evidence: correctedAssessment.evidence,
    similarDialects: correctedAssessment.similarDialects,
    needsConfirmation: false,
    isSimulated: assessment.isSimulated
  };
}

function getSimulatedAssessmentDetails(
  classification: DialectClassification
): SimulatedAssessmentDetails {
  if (classification.id === 'sichuan-chengyu') {
    return {
      regionCandidates: [
        { name: '成都', confidence: 82 },
        { name: '眉山', confidence: 11 },
        { name: '重庆', confidence: 7 }
      ],
      evidence: [
        '部分声母与韵母特征接近成都样例',
        '句尾语气与成都周边表达接近',
        '词汇节奏符合四川成渝小片样例'
      ],
      similarDialects: ['重庆话', '自贡话']
    };
  }
  if (classification.id === 'chongqing-chengyu') {
    return {
      regionCandidates: [
        { name: '重庆', confidence: 82 },
        { name: '荣昌', confidence: 11 },
        { name: '成都', confidence: 7 }
      ],
      evidence: [
        '部分声母与韵母特征接近重庆样例',
        '句尾语气与重庆城区表达接近',
        '词汇节奏符合重庆成渝小片样例'
      ],
      similarDialects: ['四川话', '泸州话']
    };
  }
  if (classification.id === 'guangzhou-guangfu') {
    return {
      regionCandidates: [
        { name: '广州', confidence: 82 },
        { name: '佛山', confidence: 11 },
        { name: '香港', confidence: 7 }
      ],
      evidence: [
        '声调组合接近广州话样例',
        '入声韵尾与广府片表达接近',
        '词汇节奏符合粤语广府片样例'
      ],
      similarDialects: ['佛山话', '香港粤语']
    };
  }
  if (classification.id === 'shanghai-shanghai') {
    return {
      regionCandidates: [
        { name: '上海', confidence: 82 },
        { name: '苏州', confidence: 11 },
        { name: '嘉兴', confidence: 7 }
      ],
      evidence: [
        '声母清浊特征接近上海话样例',
        '连读节奏与上海城区表达接近',
        '词汇特征符合吴语太湖片样例'
      ],
      similarDialects: ['苏州话', '嘉兴话']
    };
  }
  if (classification.id === 'beijing-jingshi') {
    return {
      regionCandidates: [
        { name: '北京', confidence: 82 },
        { name: '承德', confidence: 11 },
        { name: '天津', confidence: 7 }
      ],
      evidence: [
        '部分声韵特征接近北京话样例',
        '语流节奏与北京城区表达接近',
        '词汇特征符合北京官话京师小片样例'
      ],
      similarDialects: ['承德话', '天津话']
    };
  }
  return {
    regionCandidates: [
      { name: classification.regionName, confidence: 100 }
    ],
    evidence: ['当前分类目录没有该乡音的细分识别依据'],
    similarDialects: []
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
    dialectFamily: user.dialectFamily,
    dialectGroup: user.dialectGroup,
    dialectBranch: user.dialectBranch,
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
    location: assessment.regionName,
    dialectName: assessment.dialectName,
    dialectFamily: assessment.dialectFamily,
    dialectGroup: assessment.dialectGroup,
    dialectBranch: assessment.dialectBranch,
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

export async function createAiAssessment(text: string): Promise<DialectAssessment> {
  return await detectDialectByAI(text);
}

export async function getNearbyFellowUsers(lat: number, lon: number): Promise<FellowUser[]> {
  void lat;
  void lon;
  return [];
}
