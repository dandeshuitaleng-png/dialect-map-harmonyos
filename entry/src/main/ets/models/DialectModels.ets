export enum FellowSource {
  NEARBY = 'nearby',
  RECOMMENDED = 'recommended',
  CURRENT_REGION = 'currentRegion'
}

export enum RecordingState {
  READY = 'ready',
  RECORDING = 'recording',
  RECORDED = 'recorded',
  ASSESSING = 'assessing',
  RESULT = 'result'
}

export interface MapMarker {
  readonly id: string;
  readonly regionName: string;
  readonly dialectName: string;
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
  readonly dialectName: string;
  readonly regionName: string;
  readonly confidence: number;
  readonly retention: number;
  readonly isSimulated: boolean;
}

export interface VoicePassport {
  readonly userId: string;
  readonly nickname: string;
  readonly initials: string;
  readonly location: string;
  readonly dialectName: string;
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
