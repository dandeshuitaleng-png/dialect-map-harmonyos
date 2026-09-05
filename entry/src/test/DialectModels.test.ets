import { describe, expect, it } from '@ohos/hypium';
import {
  FellowSource,
  GroupSource,
  SourceLicenseStatus,
  SourceReviewStatus
} from '../main/ets/models/DialectModels';
import {
  clampScore,
  confirmSimulatedAssessment,
  correctSimulatedAssessment,
  createCurrentUserFromAssessment,
  createPassport,
  createSimulatedAssessment,
  filterFellowsBySource,
  getDemonstrationDialectZoneCount,
  getFellowUsers,
  getMapMarkers
} from '../main/ets/services/MockDialectService';
import {
  getDialectClassification,
  getDialectClassifications
} from '../main/ets/services/DialectClassificationCatalogService';
import {
  COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP,
  COMMUNITY_MESSAGE_MAX_LENGTH,
  CommunityMessageStoreResult,
  createLocalCommunityMessage,
  filterCommunityGroups,
  getCommunityGroups,
  getCommunityLastReadMessageId,
  getCommunityMessages,
  getCommunityUnreadCount,
  getInitialJoinedGroupIds,
  getLatestCommunityMessage,
  markCommunityGroupRead,
  storeLocalCommunityMessage,
  validateCommunityMessageDraft,
  toggleLocalGroupMembership
} from '../main/ets/services/MockCommunityService';
import {
  hasConfiguredXiaoyiAgent,
  XIAOYI_AGENT_ID
} from '../main/ets/services/XiaoyiAgentConfig';
import {
  canUseSourceAsProductData,
  getDialectSourceCatalog
} from '../main/ets/services/DialectSourceCatalogService';
import {
  AudioCaptureQualityStatus,
  AudioCaptureSummary,
  evaluateAudioCapture
} from '../main/ets/services/AudioCaptureQualityService';
import {
  LocalVoiceClip,
  removeLocalVoiceClip,
  storeLocalVoiceClip
} from '../main/ets/services/LocalCommunityVoiceService';

export default function dialectModelsTests(): void {
  describe('DialectModels', (): void => {
    it('clamps assessment scores to the inclusive percentage range', 0, (): void => {
      expect(clampScore(-5)).assertEqual(0);
      expect(clampScore(62.4)).assertEqual(62);
      expect(clampScore(105)).assertEqual(100);
    });

    it('rejects short, silent, quiet, or clipped microphone capture', 0,
      (): void => {
      const tooShort: AudioCaptureSummary = {
        byteLength: 48000,
        sampleCount: 24000,
        durationSeconds: 1.5,
        peakAmplitude: 0.3,
        rmsAmplitude: 0.08,
        activeSampleRatio: 0.4,
        clippedSampleRatio: 0
      };
      const silent: AudioCaptureSummary = {
        byteLength: 96000,
        sampleCount: 48000,
        durationSeconds: 3,
        peakAmplitude: 0.001,
        rmsAmplitude: 0.0005,
        activeSampleRatio: 0,
        clippedSampleRatio: 0
      };
      const tooQuiet: AudioCaptureSummary = {
        byteLength: 96000,
        sampleCount: 48000,
        durationSeconds: 3,
        peakAmplitude: 0.02,
        rmsAmplitude: 0.01,
        activeSampleRatio: 0.4,
        clippedSampleRatio: 0
      };
      const lowRms: AudioCaptureSummary = {
        byteLength: 96000,
        sampleCount: 48000,
        durationSeconds: 3,
        peakAmplitude: 0.2,
        rmsAmplitude: 0.005,
        activeSampleRatio: 0.4,
        clippedSampleRatio: 0
      };
      const almostNoActiveSamples: AudioCaptureSummary = {
        byteLength: 96000,
        sampleCount: 48000,
        durationSeconds: 3,
        peakAmplitude: 0.2,
        rmsAmplitude: 0.08,
        activeSampleRatio: 0.01,
        clippedSampleRatio: 0
      };
      const clipped: AudioCaptureSummary = {
        byteLength: 96000,
        sampleCount: 48000,
        durationSeconds: 3,
        peakAmplitude: 1,
        rmsAmplitude: 0.4,
        activeSampleRatio: 0.8,
        clippedSampleRatio: 0.09
      };

      expect(evaluateAudioCapture(tooShort).status)
        .assertEqual(AudioCaptureQualityStatus.TOO_SHORT);
      expect(evaluateAudioCapture(silent).status)
        .assertEqual(AudioCaptureQualityStatus.SILENT);
      expect(evaluateAudioCapture(tooQuiet).status)
        .assertEqual(AudioCaptureQualityStatus.TOO_QUIET);
      expect(evaluateAudioCapture(lowRms).status)
        .assertEqual(AudioCaptureQualityStatus.TOO_QUIET);
      expect(evaluateAudioCapture(almostNoActiveSamples).status)
        .assertEqual(AudioCaptureQualityStatus.TOO_QUIET);
      expect(evaluateAudioCapture(clipped).status)
        .assertEqual(AudioCaptureQualityStatus.CLIPPED);
    });

    it('accepts microphone capture with enough duration and signal', 0, (): void => {
      const usable: AudioCaptureSummary = {
        byteLength: 64000,
        sampleCount: 32000,
        durationSeconds: 2,
        peakAmplitude: 0.3,
        rmsAmplitude: 0.08,
        activeSampleRatio: 0.4,
        clippedSampleRatio: 0
      };
      const result = evaluateAudioCapture(usable);
      expect(result.status).assertEqual(AudioCaptureQualityStatus.USABLE);
      expect(result.canContinue).assertTrue();
    });

    it('returns deterministic map markers and three fellow sources', 0, (): void => {
      expect(getMapMarkers().length).assertEqual(5);
      expect(getMapMarkers()[1].regionName).assertEqual('重庆');
      expect(getDialectClassifications().length).assertEqual(15);
      expect(getDemonstrationDialectZoneCount()).assertEqual(12);
      expect(getDialectClassification('上海', '上海话').dialectFamily).assertEqual('吴语');
      expect(getDialectClassification('上海', '上海话').dialectBranch).assertEqual('上海小片');
      expect(getDialectClassification('广州', '粤语').dialectGroup).assertEqual('广府片');
      expect(getDialectClassification('北京', '北京话').dialectBranch).assertEqual('京师小片');
      expect(getDialectClassification('北京', '北京话').atlasMapCodes[0]).assertEqual('B1-2');
      expect(getDialectClassification('四川', '四川话').representativePoint).assertEqual('成都');
      expect(getDialectClassification('四川', '四川话').isDemonstration).assertFalse();
      expect(getDialectClassification('南京', '南京话').dialectBranch).assertEqual('洪巢片');
      expect(getDialectClassification('苏州', '苏州话').dialectBranch).assertEqual('苏嘉湖小片');
      expect(getDialectClassification('杭州', '杭州话').representativePoint).assertEqual('杭州城区');
      expect(getDialectClassification('厦门', '厦门话').dialectGroup).assertEqual('闽南片');
      expect(getDialectClassification('长沙', '长沙话').dialectBranch).assertEqual('长株潭小片');
      expect(getDialectClassification('武汉', '武汉话').dialectBranch).assertEqual('鄂中小片');
      expect(getDialectClassification('武汉', '武汉话').administrativeScope.indexOf('黄陂区') >= 0)
        .assertTrue();
      expect(getDialectClassification('南昌', '南昌话').dialectGroup).assertEqual('昌都片');
      expect(getDialectClassification('福州', '福州话').dialectBranch).assertEqual('侯官小片');
      expect(getDialectClassification('泉州', '泉州话').dialectBranch).assertEqual('泉漳小片');
      expect(getDialectClassification('合肥', '合肥话').dialectBranch).assertEqual('洪巢片');
      expect(getDialectClassification('未知地区', '未知口音').dialectFamily).assertEqual('待确认');
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.NEARBY).length).assertEqual(1);
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.RECOMMENDED).length).assertEqual(1);
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.CURRENT_REGION).length).assertEqual(2);
    });

    it('always labels the first assessment as simulated', 0, (): void => {
      const assessment = createSimulatedAssessment('四川', '四川话');
      expect(assessment.isSimulated).assertTrue();
      expect(assessment.confidence).assertEqual(87);
      expect(assessment.retention).assertEqual(76);
      expect(assessment.dialectFamily).assertEqual('官话');
      expect(assessment.dialectGroup).assertEqual('西南官话 · 川黔片');
      expect(assessment.dialectBranch).assertEqual('成渝小片');
      expect(assessment.regionCandidates.length).assertEqual(3);
      expect(assessment.evidence.length).assertEqual(3);
      expect(assessment.needsConfirmation).assertTrue();
    });

    it('marks an accepted assessment as confirmed', 0, (): void => {
      const assessment = createSimulatedAssessment('四川', '四川话');
      const confirmedAssessment = confirmSimulatedAssessment(assessment);
      expect(confirmedAssessment.classificationId).assertEqual(assessment.classificationId);
      expect(confirmedAssessment.regionName).assertEqual('四川');
      expect(confirmedAssessment.needsConfirmation).assertFalse();
    });

    it('uses details that belong to the corrected dialect classification', 0, (): void => {
      const assessment = createSimulatedAssessment('四川', '四川话');
      const correctedAssessment = correctSimulatedAssessment(
        assessment,
        '重庆',
        '重庆话'
      );
      const classification = getDialectClassification('重庆', '重庆话');
      expect(correctedAssessment.classificationId).assertEqual(classification.id);
      expect(correctedAssessment.dialectFamily).assertEqual(classification.dialectFamily);
      expect(correctedAssessment.dialectGroup).assertEqual(classification.dialectGroup);
      expect(correctedAssessment.dialectBranch).assertEqual(classification.dialectBranch);
      expect(correctedAssessment.regionName).assertEqual(classification.regionName);
      expect(correctedAssessment.regionCandidates[0].name).assertEqual('重庆');
      expect(correctedAssessment.evidence.join('|').indexOf('四川')).assertEqual(-1);
      expect(correctedAssessment.needsConfirmation).assertFalse();
    });

    it('creates a passport from the same fellow identity data', 0, (): void => {
      const user = getFellowUsers()[0];
      const passport = createPassport(user);
      expect(passport.userId).assertEqual(user.id);
      expect(passport.dialectName).assertEqual(user.dialectName);
      expect(passport.litRegions.length).assertEqual(user.litRegions.length);
      expect(passport.isCurrentUser).assertFalse();
    });

    it('creates the current user from a simulated assessment and lights its region', 0, (): void => {
      const assessment = createSimulatedAssessment('四川', '四川话');
      const currentUser = createCurrentUserFromAssessment(assessment);
      expect(currentUser.id).assertEqual('current-user');
      expect(currentUser.litRegions[0]).assertEqual('四川');
      expect(currentUser.confidence).assertEqual(assessment.confidence);
      expect(createPassport(currentUser, true).isCurrentUser).assertTrue();
    });

    it('filters deterministic community groups without inventing server membership', 0, (): void => {
      const groups = getCommunityGroups();
      const joinedGroupIds = getInitialJoinedGroupIds();
      expect(groups.length).assertEqual(4);
      expect(filterCommunityGroups(
        groups,
        GroupSource.RECOMMENDED,
        joinedGroupIds
      ).length).assertEqual(3);
      expect(filterCommunityGroups(
        groups,
        GroupSource.JOINED,
        joinedGroupIds
      ).length).assertEqual(0);
      expect(filterCommunityGroups(
        groups,
        GroupSource.DIALECT,
        joinedGroupIds
      ).length).assertEqual(4);
      expect(groups[0].isDemonstration).assertTrue();
    });

    it('returns a new local membership list for join and leave', 0, (): void => {
      const original = getInitialJoinedGroupIds();
      const joined = toggleLocalGroupMembership(original, 'group-chengyu-memory');
      expect(original.length).assertEqual(0);
      expect(joined.length).assertEqual(1);
      expect(joined.indexOf('group-chengyu-memory') >= 0).assertTrue();

      const left = toggleLocalGroupMembership(joined, 'group-chengyu-memory');
      expect(left.length).assertEqual(0);
      expect(left.indexOf('group-chengyu-memory')).assertEqual(-1);
      expect(toggleLocalGroupMembership(left, '   ').length).assertEqual(0);
    });

    it('rejects empty or oversized community messages and trims valid content', 0,
      (): void => {
      expect(validateCommunityMessageDraft('   ')).assertEqual('先输入消息内容');
      expect(validateCommunityMessageDraft(
        '乡'.repeat(COMMUNITY_MESSAGE_MAX_LENGTH + 1)
      )).assertEqual(
        '消息最多 ' + COMMUNITY_MESSAGE_MAX_LENGTH.toString() + ' 个字'
      );

      const message = createLocalCommunityMessage(
        'test-local-chat',
        '  我也这样说  ',
        1,
        '10:30'
      );
      if (message === undefined) {
        expect(false).assertTrue();
        return;
      }
      expect(message.content).assertEqual('我也这样说');
      expect(message.isCurrentUser).assertTrue();
      expect(message.isLocalOnly).assertTrue();
      expect(message.isDemonstration).assertFalse();
      expect(createLocalCommunityMessage('', '有内容', 2, '10:31')).assertUndefined();
    });

    it('stores each local community message once for the current app session', 0,
      (): void => {
      const message = createLocalCommunityMessage(
        'test-local-chat-store',
        '这是一条本机会话消息',
        1,
        '10:32'
      );
      if (message === undefined) {
        expect(false).assertTrue();
        return;
      }
      expect(storeLocalCommunityMessage(message))
        .assertEqual(CommunityMessageStoreResult.STORED);
      expect(storeLocalCommunityMessage(message))
        .assertEqual(CommunityMessageStoreResult.DUPLICATE);
      expect(storeLocalCommunityMessage(
        getCommunityMessages('group-chengyu-memory')[0]
      )).assertEqual(CommunityMessageStoreResult.INVALID);
      expect(getCommunityMessages('test-local-chat-store').length).assertEqual(1);
      expect(getLatestCommunityMessage('test-local-chat-store')?.id)
        .assertEqual(message.id);
    });

    it('caps each in-memory community session at one hundred local messages', 0,
      (): void => {
      const groupId = 'test-local-chat-limit';
      for (let index = 1;
        index <= COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP;
        index += 1) {
        const message = createLocalCommunityMessage(
          groupId,
          '第' + index.toString() + '条本机消息',
          index,
          '10:40'
        );
        if (message === undefined) {
          expect(false).assertTrue();
          return;
        }
        expect(storeLocalCommunityMessage(message))
          .assertEqual(CommunityMessageStoreResult.STORED);
      }

      const overflowMessage = createLocalCommunityMessage(
        groupId,
        '超过上限的消息',
        COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP + 1,
        '10:41'
      );
      if (overflowMessage === undefined) {
        expect(false).assertTrue();
        return;
      }
      expect(storeLocalCommunityMessage(overflowMessage))
        .assertEqual(CommunityMessageStoreResult.LIMIT);
      expect(getCommunityMessages(groupId).length)
        .assertEqual(COMMUNITY_LOCAL_MESSAGE_LIMIT_PER_GROUP);
    });

    it('can roll back a stored local voice clip when message storage fails', 0,
      (): void => {
      const clip: LocalVoiceClip = {
        id: 'test-local-voice-rollback',
        chunks: [new ArrayBuffer(4)],
        byteLength: 4,
        durationSeconds: 2
      };
      expect(storeLocalVoiceClip(clip)).assertTrue();
      expect(removeLocalVoiceClip(clip.id)).assertTrue();
      expect(removeLocalVoiceClip(clip.id)).assertFalse();
      expect(storeLocalVoiceClip(clip)).assertTrue();
      expect(removeLocalVoiceClip(clip.id)).assertTrue();
    });

    it('rejects a local voice clip whose declared bytes do not match its chunks', 0,
      (): void => {
      const mismatchedClip: LocalVoiceClip = {
        id: 'test-local-voice-mismatched-bytes',
        chunks: [new ArrayBuffer(4)],
        byteLength: 8,
        durationSeconds: 2
      };
      expect(storeLocalVoiceClip(mismatchedClip)).assertFalse();
      expect(removeLocalVoiceClip(mismatchedClip.id)).assertFalse();
    });

    it('clears the demonstration unread badge by recording a session lastRead id', 0,
      (): void => {
      const group = getCommunityGroups()[2];
      expect(group.id).assertEqual('group-shanghai-alley');
      expect(getCommunityUnreadCount(group)).assertEqual(2);
      markCommunityGroupRead(group.id);
      expect(getCommunityUnreadCount(group)).assertEqual(0);
      expect(getCommunityLastReadMessageId(group.id))
        .assertEqual(getLatestCommunityMessage(group.id)?.id);
    });

    it('only accepts a configured Xiaoyi agent id with the expected public id format', 0,
      (): void => {
      expect(hasConfiguredXiaoyiAgent('')).assertFalse();
      expect(hasConfiguredXiaoyiAgent('   ')).assertFalse();
      expect(hasConfiguredXiaoyiAgent('agent-demo-id')).assertFalse();
      expect(hasConfiguredXiaoyiAgent(
        'agent67ed6c01203b437db99567238ebdc976'
      )).assertTrue();
      expect(hasConfiguredXiaoyiAgent(XIAOYI_AGENT_ID)).assertTrue();
    });

    it('keeps provided publications as non-packaged catalog entries until review', 0,
      (): void => {
      const sources = getDialectSourceCatalog();
      expect(sources.length).assertEqual(6);
      expect(sources[0].title).assertEqual(
        '中国语言地图集（第 2 版）·汉语方言卷'
      );
      expect(sources[0].reviewStatus).assertEqual(SourceReviewStatus.HUMAN_REVIEWED);
      expect(canUseSourceAsProductData(sources[0])).assertFalse();
      sources.forEach((source, index: number): void => {
        expect(source.licenseStatus).assertEqual(SourceLicenseStatus.PENDING_REVIEW);
        if (index > 0) {
          expect(source.reviewStatus).assertEqual(SourceReviewStatus.CATALOG_ENTRY);
        }
        expect(source.packagedContent).assertFalse();
        expect(canUseSourceAsProductData(source)).assertFalse();
      });
    });
  });
}
