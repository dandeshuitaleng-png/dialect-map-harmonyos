import {
  DialectClassification,
  DialectAssessment,
  DialectRegionCandidate,
  FellowSource,
  FellowUser,
  MapMarker,
  VoicePassport
} from '../models/DialectModels';

const MIN_SCORE: number = 0;
const MAX_SCORE: number = 100;

interface SimulatedAssessmentDetails {
  readonly regionCandidates: Array<DialectRegionCandidate>;
  readonly evidence: Array<string>;
  readonly similarDialects: Array<string>;
}

const DIALECT_CLASSIFICATIONS: DialectClassification[] = [
  {
    id: 'sichuan-chengyu',
    regionName: '四川',
    dialectName: '四川话',
    dialectFamily: '官话',
    dialectGroup: '西南官话',
    dialectBranch: '成渝片',
    isDemonstration: true
  },
  {
    id: 'chongqing-chengyu',
    regionName: '重庆',
    dialectName: '重庆话',
    dialectFamily: '官话',
    dialectGroup: '西南官话',
    dialectBranch: '成渝片',
    isDemonstration: true
  },
  {
    id: 'guangzhou-guangfu',
    regionName: '广州',
    dialectName: '粤语',
    dialectFamily: '粤语',
    dialectGroup: '广府片',
    dialectBranch: '广州话',
    isDemonstration: true
  },
  {
    id: 'shanghai-suhujia',
    regionName: '上海',
    dialectName: '上海话',
    dialectFamily: '吴语',
    dialectGroup: '太湖片',
    dialectBranch: '苏沪嘉小片',
    isDemonstration: true
  },
  {
    id: 'beijing-jingshi',
    regionName: '北京',
    dialectName: '北京话',
    dialectFamily: '官话',
    dialectGroup: '北京官话',
    dialectBranch: '京师片',
    isDemonstration: true
  }
];

export function clampScore(score: number): number {
  return Math.max(MIN_SCORE, Math.min(MAX_SCORE, Math.round(score)));
}

export function getDialectClassifications(): DialectClassification[] {
  return DIALECT_CLASSIFICATIONS;
}

export function getDemonstrationDialectZoneCount(): number {
  const zoneKeys: string[] = [];
  DIALECT_CLASSIFICATIONS.forEach((item: DialectClassification): void => {
    const zoneKey = item.dialectGroup + '|' + item.dialectBranch;
    if (zoneKeys.indexOf(zoneKey) < 0) {
      zoneKeys.push(zoneKey);
    }
  });
  return zoneKeys.length;
}

export function getDialectClassification(
  regionName: string,
  dialectName: string
): DialectClassification {
  const matched = DIALECT_CLASSIFICATIONS.find(
    (item: DialectClassification): boolean =>
      item.regionName === regionName && item.dialectName === dialectName
  );
  if (matched !== undefined) {
    return matched;
  }
  return {
    id: 'unclassified',
    regionName: regionName,
    dialectName: dialectName,
    dialectFamily: '待确认',
    dialectGroup: '分类待确认',
    dialectBranch: '地方口音',
    isDemonstration: true
  };
}

export function getMapMarkers(): MapMarker[] {
  return [
    {
      id: 'sichuan',
      classificationId: 'sichuan-chengyu',
      regionName: '四川',
      dialectName: '四川话',
      dialectFamily: '官话',
      dialectGroup: '西南官话',
      dialectBranch: '成渝片',
      fellowCount: 87000,
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
      dialectGroup: '西南官话',
      dialectBranch: '成渝片',
      fellowCount: 62000,
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
      dialectBranch: '广州话',
      fellowCount: 54000,
      latitude: 23.1291,
      longitude: 113.2644,
      xRatio: 0.57,
      yRatio: 0.72
    },
    {
      id: 'shanghai',
      classificationId: 'shanghai-suhujia',
      regionName: '上海',
      dialectName: '上海话',
      dialectFamily: '吴语',
      dialectGroup: '太湖片',
      dialectBranch: '苏沪嘉小片',
      fellowCount: 36000,
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
      dialectBranch: '京师片',
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
      dialectFamily: '官话',
      dialectGroup: '西南官话',
      dialectBranch: '成渝片',
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
      dialectFamily: '粤语',
      dialectGroup: '广府片',
      dialectBranch: '广州话',
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
      dialectFamily: '吴语',
      dialectGroup: '太湖片',
      dialectBranch: '苏沪嘉小片',
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
      dialectFamily: '官话',
      dialectGroup: '北京官话',
      dialectBranch: '京师片',
      distanceText: '家乡推荐',
      source: FellowSource.RECOMMENDED,
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
        '词汇节奏符合四川成渝片样例'
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
        '词汇节奏符合重庆成渝片样例'
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
  if (classification.id === 'shanghai-suhujia') {
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
        '词汇特征符合北京官话京师片样例'
      ],
      similarDialects: ['承德话', '天津话']
    };
  }
  return {
    regionCandidates: [
      { name: classification.regionName, confidence: 100 }
    ],
    evidence: ['当前演示库没有该乡音的细分识别依据'],
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
