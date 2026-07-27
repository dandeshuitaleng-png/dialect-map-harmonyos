import {
  DialectSourceRecord,
  DialectSourceType,
  SourceLicenseStatus,
  SourceReviewStatus
} from '../models/DialectModels';

const DIALECT_SOURCE_CATALOG: DialectSourceRecord[] = [
  {
    id: 'source-language-atlas-dialect-volume-2',
    title: '中国语言地图集（第 2 版）·汉语方言卷',
    authorOrInstitution: '中国社会科学院语言研究所等',
    editionOrYear: '第 2 版',
    sourceType: DialectSourceType.CLASSIFICATION_ATLAS,
    priorityLabel: 'A 级 · 分类与地图研究',
    formatLabel: '291 页扫描型 PDF',
    useCases: [
      '方言大类、片区与区域分布的研究入口',
      '建立分类、代表地区和地图边界的来源字段'
    ],
    limitations: [
      '未核对具体页码、调查点和地图授权',
      '不得截图或复制地图作为产品底图'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  },
  {
    id: 'source-dialect-atlas-phonetics',
    title: '汉语方言地图集·语音卷',
    authorOrInstitution: '曹志耘',
    editionOrYear: '版本年份待核对',
    sourceType: DialectSourceType.PHONETIC_ATLAS,
    priorityLabel: 'A 级 · 语音特征研究',
    formatLabel: '249 页扫描型 PDF',
    useCases: [
      '声母、韵母、声调等可解释特征的研究入口',
      '设计相似乡音与待确认状态'
    ],
    limitations: [
      '当前 App 没有真实语音特征提取能力',
      '书中分布不能直接转换为 AI 置信度'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  },
  {
    id: 'source-dialect-explanation-map',
    title: '汉语方言解释地图',
    authorOrInstitution: '岩田礼',
    editionOrYear: '版本年份待核对',
    sourceType: DialectSourceType.EXPLANATION_REFERENCE,
    priorityLabel: 'B 级 · 通俗解释参考',
    formatLabel: '348 页扫描型 PDF',
    useCases: [
      '参考面向普通用户的地图说明与知识卡组织',
      '设计“为什么这样判断”的解释文案'
    ],
    limitations: [
      '解释方式不等于当前 App 的权威分类',
      '不得改写成 AI 已识别事实'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  },
  {
    id: 'source-east-west-language',
    title: '东言西语',
    authorOrInstitution: '郑子宁',
    editionOrYear: '版本年份待核对',
    sourceType: DialectSourceType.POPULAR_REFERENCE,
    priorityLabel: 'B 级 · 产品叙事参考',
    formatLabel: 'EPUB 出版物',
    useCases: [
      '参考普通用户能理解的方言故事与引导语气',
      '避免把方言简化为行政区标签或刻板印象'
    ],
    limitations: [
      '不作为分类、地图边界或模型训练依据',
      '不得复制大段原文、插图或其他出版内容'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  },
  {
    id: 'source-dialect-atlas-grammar',
    title: '汉语方言地图集·语法卷',
    authorOrInstitution: '曹志耘',
    editionOrYear: '版本年份待核对',
    sourceType: DialectSourceType.GRAMMAR_ATLAS,
    priorityLabel: 'C 级 · 后续专题研究',
    formatLabel: '132 页扫描型 PDF',
    useCases: [
      '后续研究例句、表达差异和语法特征',
      '扩展乡音护照的代表语句内容'
    ],
    limitations: [
      '不是当前地图和鉴定主流程的首要依赖',
      '第一版不加入复杂语法判定'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  },
  {
    id: 'source-fangyan-journal-index-2016-2026',
    title: '《方言》2016—2026 资料整理包',
    authorOrInstitution: '《方言》期刊资料索引（机构信息待核对）',
    editionOrYear: '2016—2026',
    sourceType: DialectSourceType.JOURNAL_INDEX,
    priorityLabel: 'C 级 · 专题检索入口',
    formatLabel: '42 期期次索引与 7 份公开目录 PDF',
    useCases: [
      '检索方言地理、分区、语音、声调与调查专题',
      '补齐题名、作者、期次、页码和研究地区字段'
    ],
    limitations: [
      '当前是期次结构和官方入口，不是方言数据库',
      '不得绕过登录获取或打包受限论文全文'
    ],
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    packagedContent: false
  }
];

export function getDialectSourceCatalog(): DialectSourceRecord[] {
  return DIALECT_SOURCE_CATALOG.slice();
}

export function canUseSourceAsProductData(source: DialectSourceRecord): boolean {
  return source.licenseStatus === SourceLicenseStatus.CLEARED &&
    source.reviewStatus === SourceReviewStatus.PRODUCT_READY;
}
