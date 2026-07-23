import { describe, expect, it } from '@ohos/hypium';
import { FellowSource } from '../main/ets/models/DialectModels';
import {
  clampScore,
  createCurrentUserFromAssessment,
  createPassport,
  createSimulatedAssessment,
  filterFellowsBySource,
  getFellowUsers,
  getMapMarkers
} from '../main/ets/services/MockDialectService';

export default function dialectModelsTests(): void {
  describe('DialectModels', (): void => {
    it('clamps assessment scores to the inclusive percentage range', 0, (): void => {
      expect(clampScore(-5)).assertEqual(0);
      expect(clampScore(62.4)).assertEqual(62);
      expect(clampScore(105)).assertEqual(100);
    });

    it('returns deterministic map markers and three fellow sources', 0, (): void => {
      expect(getMapMarkers().length).assertEqual(4);
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.NEARBY).length).assertEqual(1);
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.RECOMMENDED).length).assertEqual(1);
      expect(filterFellowsBySource(getFellowUsers(), FellowSource.CURRENT_REGION).length).assertEqual(2);
    });

    it('always labels the first assessment as simulated', 0, (): void => {
      const assessment = createSimulatedAssessment('四川', '四川话');
      expect(assessment.isSimulated).assertTrue();
      expect(assessment.confidence).assertEqual(87);
      expect(assessment.retention).assertEqual(76);
      expect(assessment.dialectGroup).assertEqual('西南官话');
      expect(assessment.dialectBranch).assertEqual('成渝片');
      expect(assessment.regionCandidates.length).assertEqual(3);
      expect(assessment.evidence.length).assertEqual(3);
      expect(assessment.needsConfirmation).assertTrue();
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
  });
}
