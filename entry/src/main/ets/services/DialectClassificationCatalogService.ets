import {
  DialectBoundaryType,
  DialectClassification,
  SourceLicenseStatus,
  SourceReviewStatus
} from '../models/DialectModels';

const ATLAS_TITLE: string = '中国语言地图集（第2版）·汉语方言卷';
const ATLAS_EDITION: string = '商务印书馆，2012';

const DIALECT_CLASSIFICATIONS: DialectClassification[] = [
  {
    id: 'sichuan-chengyu',
    regionName: '四川',
    dialectName: '四川话',
    dialectFamily: '官话',
    dialectGroup: '西南官话 · 川黔片',
    dialectBranch: '成渝小片',
    classificationLevel: '小片',
    representativePoint: '成都',
    administrativeScope: '成都代表点，不代表四川省全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-11'],
    pdfPages: ['32（地图）', '140–141（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '四川境内存在其他西南官话小片及非汉语分布，不能把全省统一标为成渝小片。',
    isDemonstration: false
  },
  {
    id: 'chongqing-chengyu',
    regionName: '重庆',
    dialectName: '重庆话',
    dialectFamily: '官话',
    dialectGroup: '西南官话 · 川黔片',
    dialectBranch: '成渝小片',
    classificationLevel: '小片',
    representativePoint: '重庆',
    administrativeScope: '重庆城区代表点，不代表重庆市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-11'],
    pdfPages: ['32（地图）', '140–141（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '重庆代表点属于成渝小片，但不能据此推导重庆市域内各方言点都属于成渝小片。',
    isDemonstration: false
  },
  {
    id: 'guangzhou-guangfu',
    regionName: '广州',
    dialectName: '粤语',
    dialectFamily: '粤语',
    dialectGroup: '广府片',
    dialectBranch: '广州代表点',
    classificationLevel: '片',
    representativePoint: '广州',
    administrativeScope: '广州代表点，不代表广东省全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-18', 'B2-1'],
    pdfPages: ['39、45（地图）', '183–184（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '粤语还包括四邑、高阳、勾漏、吴化、邕浔、钦廉等片，不能以广州话覆盖全广东。',
    isDemonstration: false
  },
  {
    id: 'shanghai-shanghai',
    regionName: '上海',
    dialectName: '上海话',
    dialectFamily: '吴语',
    dialectGroup: '太湖片',
    dialectBranch: '上海小片',
    classificationLevel: '小片',
    representativePoint: '上海城区',
    administrativeScope: '上海城区代表点，不等同于行政区内所有居民的语言使用',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-14', 'B2-11'],
    pdfPages: ['35、55（地图）', '267–268（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '城区与原郊县方言存在差异，上海小片也延伸到江苏局部。',
    isDemonstration: false
  },
  {
    id: 'beijing-jingshi',
    regionName: '北京',
    dialectName: '北京话',
    dialectFamily: '官话',
    dialectGroup: '北京官话',
    dialectBranch: '京师小片',
    classificationLevel: '小片',
    representativePoint: '北京城区',
    administrativeScope: '北京城区代表点，不代表北京市全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-2'],
    pdfPages: ['23（地图）', '98–99（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '北京话专指北京城区话，不等于包含多个片区的北京官话，也不能覆盖北京市全部辖域。',
    isDemonstration: false
  },
  {
    id: 'nanjing-hongchao',
    regionName: '南京',
    dialectName: '南京话',
    dialectFamily: '官话',
    dialectGroup: '江淮官话',
    dialectBranch: '洪巢片',
    classificationLevel: '片',
    representativePoint: '南京',
    administrativeScope: '南京代表点，不代表南京市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-9', 'B2-11'],
    pdfPages: ['30、55（地图）', '133（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '图集把南京市列入洪巢片的江苏分布范围；本记录只表达南京代表点，不据此宣称行政市域内部完全一致。',
    isDemonstration: false
  },
  {
    id: 'suzhou-sujiahu',
    regionName: '苏州',
    dialectName: '苏州话',
    dialectFamily: '吴语',
    dialectGroup: '太湖片',
    dialectBranch: '苏嘉湖小片',
    classificationLevel: '小片',
    representativePoint: '苏州',
    administrativeScope: '苏州代表点，不代表苏州市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-14', 'B2-11'],
    pdfPages: ['35、55（地图）', '161–164（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '第2版采用苏嘉湖小片，并记录维持旧分法等不同意见；产品必须保留来源版本和争议说明。',
    isDemonstration: false
  },
  {
    id: 'hangzhou-hangzhou',
    regionName: '杭州',
    dialectName: '杭州话',
    dialectFamily: '吴语',
    dialectGroup: '太湖片',
    dialectBranch: '杭州小片',
    classificationLevel: '小片',
    representativePoint: '杭州城区',
    administrativeScope: '杭州城区代表点，不代表杭州市全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-14', 'B2-10'],
    pdfPages: ['35、54（地图）', '162、164（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '杭州小片限于图集所列城区范围；杭州市其他地区另有苏嘉湖、临绍、金衢等分类，不能整市统一标注。',
    isDemonstration: false
  },
  {
    id: 'xiamen-quanzhang',
    regionName: '厦门',
    dialectName: '厦门话',
    dialectFamily: '闽语',
    dialectGroup: '闽南片',
    dialectBranch: '泉漳小片',
    classificationLevel: '小片',
    representativePoint: '厦门',
    administrativeScope: '厦门代表点，不代表福建省或闽南地区全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-15', 'B2-5'],
    pdfPages: ['36、49（地图）', '168–171（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '闽南片还包含大田、潮汕、浙东南、赣东北等小片，不能把闽南或福建直接等同于厦门话。',
    isDemonstration: false
  },
  {
    id: 'changsha-changzhutan',
    regionName: '长沙',
    dialectName: '长沙话',
    dialectFamily: '湘语',
    dialectGroup: '长益片',
    dialectBranch: '长株潭小片',
    classificationLevel: '小片',
    representativePoint: '长沙',
    administrativeScope: '长沙代表点，不代表长沙市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-19', 'B2-8'],
    pdfPages: ['40、52（地图）', '193–194（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '图集把长沙市列入长株潭小片；本记录只表达长沙代表点，不推导为整个行政市域完全一致。',
    isDemonstration: false
  },
  {
    id: 'wuhan-ezhong',
    regionName: '武汉',
    dialectName: '武汉话',
    dialectFamily: '官话',
    dialectGroup: '西南官话 · 湖广片',
    dialectBranch: '鄂中小片',
    classificationLevel: '小片',
    representativePoint: '武汉城区',
    administrativeScope: '武汉城区代表点；黄陂区、新洲区另属江淮官话黄孝片',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-10'],
    pdfPages: ['31（地图）', '140–147（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '图集把武汉列为湖广片鄂中小片的重要方言点，但黄陂区、新洲区属于江淮官话，不能整市统一分类。',
    isDemonstration: false
  },
  {
    id: 'nanchang-changdu',
    regionName: '南昌',
    dialectName: '南昌话',
    dialectFamily: '赣语',
    dialectGroup: '昌都片',
    dialectBranch: '南昌代表点',
    classificationLevel: '片',
    representativePoint: '南昌',
    administrativeScope: '南昌代表点，不代表江西省或南昌市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-20', 'B2-9'],
    pdfPages: ['41、53（地图）', '199–201（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '第2版采用昌都片并明确列入南昌市，同时记录其他分区方案；产品必须保留来源版本。',
    isDemonstration: false
  },
  {
    id: 'fuzhou-houguan',
    regionName: '福州',
    dialectName: '福州话',
    dialectFamily: '闽语',
    dialectGroup: '闽东片',
    dialectBranch: '侯官小片',
    classificationLevel: '小片',
    representativePoint: '福州',
    administrativeScope: '福州代表点，不代表福州市全部辖域及居民语言使用完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-15', 'B2-5'],
    pdfPages: ['36、49（地图）', '168–170（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '福州市部分区县、乡镇还存在泉漳小片、莆仙片、畲话等分布，不能把整个行政市域统一标为福州话。',
    isDemonstration: false
  },
  {
    id: 'quanzhou-quanzhang',
    regionName: '泉州',
    dialectName: '泉州话',
    dialectFamily: '闽语',
    dialectGroup: '闽南片',
    dialectBranch: '泉漳小片',
    classificationLevel: '小片',
    representativePoint: '泉州',
    administrativeScope: '泉州代表点，不代表福建省或闽南地区全部辖域',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-15', 'B2-5'],
    pdfPages: ['36、49（地图）', '168–170（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '泉漳小片跨越多个市县，闽南片还包括其他小片，不能把泉州话等同于全部闽南话。',
    isDemonstration: false
  },
  {
    id: 'hefei-hongchao',
    regionName: '合肥',
    dialectName: '合肥话',
    dialectFamily: '官话',
    dialectGroup: '江淮官话',
    dialectBranch: '洪巢片',
    classificationLevel: '片',
    representativePoint: '合肥',
    administrativeScope: '合肥代表点，不代表安徽省或合肥市全部辖域内部完全一致',
    boundaryType: DialectBoundaryType.REPRESENTATIVE_POINT,
    atlasMapCodes: ['B1-9', 'B2-12'],
    pdfPages: ['30、56（地图）', '133（说明）'],
    sourceTitle: ATLAS_TITLE,
    sourceEdition: ATLAS_EDITION,
    reviewStatus: SourceReviewStatus.HUMAN_REVIEWED,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '安徽省同时分布多种官话及赣语、吴语、徽语等，不能以合肥话覆盖全省。',
    isDemonstration: false
  }
];

export function getDialectClassifications(): DialectClassification[] {
  return DIALECT_CLASSIFICATIONS.slice();
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
  return createUnclassifiedDialect(regionName, dialectName);
}

export function getDialectClassificationByDialectName(
  dialectName: string
): DialectClassification {
  const matched = DIALECT_CLASSIFICATIONS.find(
    (item: DialectClassification): boolean => item.dialectName === dialectName
  );
  if (matched !== undefined) {
    return matched;
  }
  return createUnclassifiedDialect('待确认地区', dialectName);
}

function createUnclassifiedDialect(
  regionName: string,
  dialectName: string
): DialectClassification {
  return {
    id: 'unclassified',
    regionName: regionName,
    dialectName: dialectName,
    dialectFamily: '待确认',
    dialectGroup: '分类待确认',
    dialectBranch: '地方口音',
    classificationLevel: '待确认',
    representativePoint: regionName,
    administrativeScope: '尚无已复核的地点分类',
    boundaryType: DialectBoundaryType.UNCERTAIN,
    atlasMapCodes: [],
    pdfPages: [],
    sourceTitle: '暂无已复核来源',
    sourceEdition: '待补充',
    reviewStatus: SourceReviewStatus.CATALOG_ENTRY,
    licenseStatus: SourceLicenseStatus.PENDING_REVIEW,
    disputeNote: '该地点尚未进入已人工复核的地点代表点分类。',
    isDemonstration: true
  };
}
