import { http } from '@kit.NetworkKit';
import {
  LanguageDirectoryCoverage,
  LanguageDirectoryEntity,
  LanguageDirectoryResponse,
  LanguageDirectorySource,
  LanguageDirectorySurveyPoint,
  LanguageDirectoryVariant
} from '../models/DialectModels';
const DIRECTORY_URL: string = 'https://hnp666.me/functions/v1/language-directory';

class DirectoryRequestOptions {
  method: http.RequestMethod = http.RequestMethod.GET;
  header: Record<string, string> = {
    'Content-Type': 'application/json'
  };
  connectTimeout: number = 15000;
  readTimeout: number = 20000;
}

function stringValue(value: Object | undefined): string {
  return typeof value === 'string' ? value.trim() : '';
}

function numberValue(value: Object | undefined): number {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function optionalNumberValue(value: Object | undefined): number | undefined {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

function rowValue(value: Object): Record<string, Object> {
  return value as Record<string, Object>;
}

function parseDirectoryObject(value: string): Record<string, Object> {
  try {
    return JSON.parse(value) as Record<string, Object>;
  } catch (_error) {
    throw new Error('invalid_language_directory_response');
  }
}

function mapEntity(value: Object): LanguageDirectoryEntity {
  const row = rowValue(value);
  return {
    id: stringValue(row['id']),
    ethnicityName: stringValue(row['ethnicity_name']),
    languageName: stringValue(row['language_name']),
    languageFamily: stringValue(row['language_family']),
    entityLevel: stringValue(row['entity_level']),
    regionScope: stringValue(row['region_scope']),
    sourceId: stringValue(row['source_id']),
    reviewStatus: stringValue(row['review_status']),
    licenseStatus: stringValue(row['license_status']),
    disputeNote: stringValue(row['dispute_note'])
  };
}

function mapVariant(value: Object): LanguageDirectoryVariant {
  const row = rowValue(value);
  return {
    id: stringValue(row['id']),
    ethnicityName: stringValue(row['ethnicity_name']),
    languageName: stringValue(row['language_name']),
    dialectName: stringValue(row['dialect_name']),
    languageFamily: stringValue(row['language_family']),
    regionScope: stringValue(row['region_scope']),
    reviewStatus: stringValue(row['review_status']),
    licenseStatus: stringValue(row['license_status']),
    disputeNote: stringValue(row['dispute_note'])
  };
}

function mapCoverage(value: Object): LanguageDirectoryCoverage {
  const row = rowValue(value);
  return {
    id: stringValue(row['id']),
    variantId: stringValue(row['variant_id']),
    ethnicityName: stringValue(row['ethnicity_name']),
    languageName: stringValue(row['language_name']),
    dialectName: stringValue(row['dialect_name']),
    regionName: stringValue(row['region_name']),
    coverageLevel: stringValue(row['coverage_level']),
    coordinateStatus: stringValue(row['coordinate_status']),
    reviewStatus: stringValue(row['review_status']),
    licenseStatus: stringValue(row['license_status'])
  };
}

function mapSurveyPoint(value: Object): LanguageDirectorySurveyPoint {
  const row = rowValue(value);
  return {
    id: stringValue(row['id']),
    coverageId: stringValue(row['coverage_id']),
    variantId: stringValue(row['variant_id']),
    ethnicityName: stringValue(row['ethnicity_name']),
    languageName: stringValue(row['language_name']),
    dialectName: stringValue(row['dialect_name']),
    provinceName: stringValue(row['province_name']),
    prefectureName: stringValue(row['prefecture_name']),
    countyName: stringValue(row['county_name']),
    townshipName: stringValue(row['township_name']),
    surveyPoint: stringValue(row['survey_point']),
    latitude: optionalNumberValue(row['latitude']),
    longitude: optionalNumberValue(row['longitude']),
    coordinateStatus: stringValue(row['coordinate_status']),
    coordinatePrecision: stringValue(row['coordinate_precision']),
    sourceId: stringValue(row['source_id']),
    sourceLocator: stringValue(row['source_locator']),
    reviewStatus: stringValue(row['review_status']),
    licenseStatus: stringValue(row['license_status']),
    disputeNote: stringValue(row['dispute_note'])
  };
}

function mapSource(value: Object): LanguageDirectorySource {
  const row = rowValue(value);
  return {
    id: stringValue(row['id']),
    title: stringValue(row['title']),
    authority: stringValue(row['authority']),
    reviewStatus: stringValue(row['review_status']),
    licenseStatus: stringValue(row['license_status'])
  };
}

export async function fetchLanguageDirectory(): Promise<LanguageDirectoryResponse> {
  if (DIRECTORY_URL.length === 0) {
    throw new Error('语言目录服务尚未配置');
  }
  const request = http.createHttp();
  try {
    const response = await request.request(DIRECTORY_URL, new DirectoryRequestOptions());
    if (response.responseCode < 200 || response.responseCode >= 300) {
      throw new Error(`HTTP ${response.responseCode}`);
    }
    const parsed = parseDirectoryObject(response.result as string);
    let counts: Record<string, Object> = {};
    if (parsed['counts'] !== undefined) {
      counts = rowValue(parsed['counts'] as Object);
    }
    const variantsRaw = Array.isArray(parsed['variants']) ? parsed['variants'] as Array<Object> : [];
    const coverageRaw = Array.isArray(parsed['coverageScopes']) ? parsed['coverageScopes'] as Array<Object> : [];
    const entitiesRaw = Array.isArray(parsed['entities']) ? parsed['entities'] as Array<Object> : [];
    const surveyPointsRaw = Array.isArray(parsed['surveyPoints']) ? parsed['surveyPoints'] as Array<Object> : [];
    const sourcesRaw = Array.isArray(parsed['sources']) ? parsed['sources'] as Array<Object> : [];
    const limitationsRaw = Array.isArray(parsed['limitations']) ? parsed['limitations'] as Array<Object> : [];
    return {
      schemaVersion: stringValue(parsed['schemaVersion']),
      generatedAt: stringValue(parsed['generatedAt']),
      counts: {
        ethnicities: numberValue(counts['ethnicities']),
        entities: numberValue(counts['entities']),
        variants: numberValue(counts['variants']),
        coverageScopes: numberValue(counts['coverageScopes']),
        surveyPoints: numberValue(counts['surveyPoints'])
      },
      entities: entitiesRaw.map((item: Object): LanguageDirectoryEntity => mapEntity(item)),
      variants: variantsRaw.map((item: Object): LanguageDirectoryVariant => mapVariant(item)),
      coverageScopes: coverageRaw.map((item: Object): LanguageDirectoryCoverage => mapCoverage(item)),
      surveyPoints: surveyPointsRaw.map((item: Object): LanguageDirectorySurveyPoint => mapSurveyPoint(item)),
      sources: sourcesRaw.map((item: Object): LanguageDirectorySource => mapSource(item)),
      limitations: limitationsRaw
        .filter((item: Object): boolean => typeof item === 'string')
        .map((item: Object): string => String(item))
        .slice(0, 8)
    };
  } finally {
    request.destroy();
  }
}
