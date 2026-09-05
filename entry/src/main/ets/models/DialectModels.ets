export enum FellowSource {
  NEARBY = 'nearby',
  RECOMMENDED = 'recommended',
  CURRENT_REGION = 'currentRegion'
}

export enum DiscoveryMode {
  FELLOWS = 'fellows',
  GROUPS = 'groups'
}

export enum GroupSource {
  RECOMMENDED = 'recommended',
  JOINED = 'joined',
  DIALECT = 'dialect'
}

export enum XiaoyiAvailability {
  UNCONFIGURED = 'unconfigured',
  CHECKING = 'checking',
  UNSUPPORTED = 'unsupported',
  AVAILABLE = 'available',
  ERROR = 'error'
}

export enum DialectSourceType {
  CLASSIFICATION_ATLAS = 'classificationAtlas',
  PHONETIC_ATLAS = 'phoneticAtlas',
  EXPLANATION_REFERENCE = 'explanationReference',
  POPULAR_REFERENCE = 'popularReference',
  GRAMMAR_ATLAS = 'grammarAtlas',
  JOURNAL_INDEX = 'journalIndex'
}

export enum SourceLicenseStatus {
  PENDING_REVIEW = 'pendingReview',
  CLEARED = 'cleared'
}

export enum SourceReviewStatus {
  CATALOG_ENTRY = 'catalogEntry',
  HUMAN_REVIEWED = 'humanReviewed',
  PRODUCT_READY = 'productReady'
}

export enum DialectBoundaryType {
  REPRESENTATIVE_POINT = 'representativePoint',
  CORE_AREA = 'coreArea',
  TRANSITION_AREA = 'transitionArea',
  DIALECT_ISLAND = 'dialectIsland',
  UNCERTAIN = 'uncertain'
}

export enum RecordingState {
  READY = 'ready',
  RECORDING = 'recording',
  RECORDED = 'recorded',
  ASSESSING = 'assessing',
  RESULT = 'result'
}

/**
 * The daily challenge is deliberately backed only by a reviewed, time-bounded
 * human recording.  It is not a synthetic sample or an inference result.
 */
export interface LicensedDialectAudio {
  readonly recordingId: string;
  readonly dialectName: string;
  readonly attributionText: string;
  readonly speakerConsentVersion: string;
  readonly licenseName: string;
  readonly licenseUrl: string;
  readonly sourceUrl: string;
  readonly audioUrl: string;
  readonly expiresAt: string;
}

export interface DailyDialectChallenge {
  readonly id: string;
  readonly kindLabel: string;
  readonly icon: string;
  readonly title: string;
  readonly instruction: string;
  readonly answers: Array<string>;
  readonly correctAnswer: string;
  readonly audio: LicensedDialectAudio;
}

export interface DailyChallengeProgress {
  readonly lastCompletedDay: string;
  readonly energy: number;
  readonly streak: number;
  readonly totalCompletions: number;
}

export interface DialectClassification {
  readonly id: string;
  readonly regionName: string;
  readonly dialectName: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly classificationLevel: string;
  readonly representativePoint: string;
  readonly administrativeScope: string;
  readonly boundaryType: DialectBoundaryType;
  readonly atlasMapCodes: ReadonlyArray<string>;
  readonly pdfPages: ReadonlyArray<string>;
  readonly sourceTitle: string;
  readonly sourceEdition: string;
  readonly reviewStatus: SourceReviewStatus;
  readonly licenseStatus: SourceLicenseStatus;
  readonly disputeNote: string;
  readonly isDemonstration: boolean;
}

export interface MapMarker {
  readonly id: string;
  readonly classificationId: string;
  readonly regionName: string;
  readonly dialectName: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly fellowCount: number;
  readonly latitude: number;
  readonly longitude: number;
  readonly xRatio: number;
  readonly yRatio: number;
}

export interface FellowUser {
  readonly id: string;
  readonly nickname: string;
  readonly initials: string;
  readonly location: string;
  readonly dialectName: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly distanceText: string;
  readonly source: FellowSource;
  readonly confidence: number;
  readonly retention: number;
  readonly litRegions: ReadonlyArray<string>;
  readonly fellowFriends: number;
  readonly following: number;
  readonly followers: number;
  readonly voiceTitle: string;
  readonly voiceDurationSeconds: number;
}

export interface DialectAssessment {
  readonly classificationId: string;
  readonly dialectName: string;
  readonly ethnicity?: string;
  readonly language?: string;
  readonly dialect?: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly regionName: string;
  readonly regionCandidates: Array<DialectRegionCandidate>;
  readonly coverageScopes?: Array<DialectCoverageScope>;
  readonly confidence: number;
  readonly retention: number;
  readonly evidence: Array<string>;
  readonly similarDialects: Array<string>;
  readonly needsConfirmation: boolean;
  readonly isUnknown?: boolean;
  readonly sourceStatus?: string;
  readonly isSimulated: boolean;
}

export interface DialectRegionCandidate {
  readonly name: string;
  readonly region?: string;
  readonly confidence: number;
}

export interface DialectCoverageScope {
  readonly name: string;
  readonly provinceName: string;
  readonly prefectureName: string;
  readonly countyName: string;
  readonly coverageLevel: string;
  readonly coordinateStatus: string;
}

export interface LanguageDirectoryCounts {
  readonly ethnicities: number;
  readonly entities: number;
  readonly variants: number;
  readonly coverageScopes: number;
  readonly surveyPoints: number;
}

export interface LanguageDirectoryEntity {
  readonly id: string;
  readonly ethnicityName: string;
  readonly languageName: string;
  readonly languageFamily: string;
  readonly entityLevel: string;
  readonly regionScope: string;
  readonly sourceId: string;
  readonly reviewStatus: string;
  readonly licenseStatus: string;
  readonly disputeNote: string;
}

export interface LanguageDirectoryVariant {
  readonly id: string;
  readonly ethnicityName: string;
  readonly languageName: string;
  readonly dialectName: string;
  readonly languageFamily: string;
  readonly regionScope: string;
  readonly reviewStatus: string;
  readonly licenseStatus: string;
  readonly disputeNote: string;
}

export interface LanguageDirectoryCoverage {
  readonly id: string;
  readonly variantId: string;
  readonly ethnicityName: string;
  readonly languageName: string;
  readonly dialectName: string;
  readonly regionName: string;
  readonly coverageLevel: string;
  readonly coordinateStatus: string;
  readonly reviewStatus: string;
  readonly licenseStatus: string;
}

export interface LanguageDirectorySurveyPoint {
  readonly id: string;
  readonly coverageId: string;
  readonly variantId: string;
  readonly ethnicityName: string;
  readonly languageName: string;
  readonly dialectName: string;
  readonly provinceName: string;
  readonly prefectureName: string;
  readonly countyName: string;
  readonly townshipName: string;
  readonly surveyPoint: string;
  readonly latitude?: number;
  readonly longitude?: number;
  readonly coordinateStatus: string;
  readonly coordinatePrecision: string;
  readonly sourceId: string;
  readonly sourceLocator: string;
  readonly reviewStatus: string;
  readonly licenseStatus: string;
  readonly disputeNote: string;
}

export interface LanguageDirectorySource {
  readonly id: string;
  readonly title: string;
  readonly authority: string;
  readonly reviewStatus: string;
  readonly licenseStatus: string;
}

export interface LanguageDirectoryResponse {
  readonly schemaVersion: string;
  readonly generatedAt: string;
  readonly counts: LanguageDirectoryCounts;
  readonly entities: Array<LanguageDirectoryEntity>;
  readonly variants: Array<LanguageDirectoryVariant>;
  readonly coverageScopes: Array<LanguageDirectoryCoverage>;
  readonly surveyPoints: Array<LanguageDirectorySurveyPoint>;
  readonly sources: Array<LanguageDirectorySource>;
  readonly limitations: Array<string>;
}

export interface VoicePassport {
  readonly userId: string;
  readonly nickname: string;
  readonly initials: string;
  readonly location: string;
  readonly dialectName: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly confidence: number;
  readonly retention: number;
  readonly representativeVoiceTitle: string;
  readonly representativeVoiceDurationSeconds: number;
  readonly litRegions: ReadonlyArray<string>;
  readonly fellowFriends: number;
  readonly following: number;
  readonly followers: number;
  readonly isCurrentUser: boolean;
}

export interface CommunityTopic {
  readonly id: string;
  readonly title: string;
  readonly authorLabel: string;
  readonly activityLabel: string;
}

export interface CommunityMessage {
  readonly id: string;
  readonly groupId: string;
  readonly senderId: string;
  readonly senderLabel: string;
  readonly senderInitials: string;
  readonly content: string;
  readonly voiceDurationSeconds?: number;
  readonly voiceClipId?: string;
  readonly timeLabel: string;
  readonly timeSeparatorLabel: string;
  readonly isCurrentUser: boolean;
  readonly isLocalOnly: boolean;
  readonly isDemonstration: boolean;
}

export interface CommunityGroup {
  readonly id: string;
  readonly name: string;
  readonly avatarText: string;
  readonly regionName: string;
  readonly dialectName: string;
  readonly summary: string;
  readonly memberCount: number;
  readonly activeLabel: string;
  readonly lastMessagePreview: string;
  readonly lastMessageTimeLabel: string;
  readonly unreadCount: number;
  readonly accentLabel: string;
  readonly recommended: boolean;
  readonly rules: ReadonlyArray<string>;
  readonly recentTopics: ReadonlyArray<CommunityTopic>;
  readonly isDemonstration: boolean;
}

export interface DialectSourceRecord {
  readonly id: string;
  readonly title: string;
  readonly authorOrInstitution: string;
  readonly editionOrYear: string;
  readonly sourceType: DialectSourceType;
  readonly priorityLabel: string;
  readonly formatLabel: string;
  readonly useCases: ReadonlyArray<string>;
  readonly limitations: ReadonlyArray<string>;
  readonly licenseStatus: SourceLicenseStatus;
  readonly reviewStatus: SourceReviewStatus;
  readonly packagedContent: boolean;
}
