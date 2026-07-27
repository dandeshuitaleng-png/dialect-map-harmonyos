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

export enum RecordingState {
  READY = 'ready',
  RECORDING = 'recording',
  RECORDED = 'recorded',
  ASSESSING = 'assessing',
  RESULT = 'result'
}

export interface DialectClassification {
  readonly id: string;
  readonly regionName: string;
  readonly dialectName: string;
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
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
  readonly dialectFamily: string;
  readonly dialectGroup: string;
  readonly dialectBranch: string;
  readonly regionName: string;
  readonly regionCandidates: Array<DialectRegionCandidate>;
  readonly confidence: number;
  readonly retention: number;
  readonly evidence: Array<string>;
  readonly similarDialects: Array<string>;
  readonly needsConfirmation: boolean;
  readonly isSimulated: boolean;
}

export interface DialectRegionCandidate {
  readonly name: string;
  readonly confidence: number;
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
