import { common } from '@kit.AbilityKit';
import { HarmonyDialectMap } from '../components/HarmonyDialectMap';
import { FellowPanel } from '../components/FellowPanel';
import { CommunityGroupPage } from '../components/CommunityGroupPage';
import { VoicePassportPage } from '../components/VoicePassportPage';
import { VoiceAssessmentPage } from '../components/VoiceAssessmentPage';
import { FirstRunGuide } from '../components/FirstRunGuide';
import { ErrorStatePage, ErrorPageKind } from '../components/ErrorStatePage';
import { XiaoyiAssistantEntry } from '../components/XiaoyiAssistantEntry';
import { AuthPage } from '../components/AuthPage';
import { LanguageDirectoryPage } from '../components/LanguageDirectoryPage';
import { DailyChallengePage } from '../components/DailyChallengePage';
import { PersonalCenterPage } from '../components/PersonalCenterPage';
import { PassportPreviewPanel } from '../components/PassportPreviewPanel';
import {
  CommunityGroup,
  DialectAssessment,
  DiscoveryMode,
  FellowSource,
  FellowUser,
  GroupSource,
  MapMarker
} from '../models/DialectModels';
import { HuaweiAccountSession, restoreHuaweiAccountSession } from '../services/HuaweiAccountService';
import {
  createCurrentUserFromAssessment,
  correctSimulatedAssessment,
  createPassport,
  createSimulatedAssessment,
  getFellowUsers,
  getDemonstrationDialectZoneCount,
  getMapMarkers
} from '../services/MockDialectService';
import {
  hasSeenFirstRunGuide,
  loadPassportState,
  markFirstRunGuideSeen,
  savePassportState,
  SavedPassportState
} from '../services/PassportPersistenceService';
import {
  getCommunityGroups,
  toggleGroupMembership
} from '../services/CommunityService';
import { markCommunityGroupRead } from '../services/MockCommunityService';

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State discoveryMode: DiscoveryMode = DiscoveryMode.FELLOWS;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedGroupSource: GroupSource = GroupSource.JOINED;
  @State selectedUserId: string = '';
  @State selectedGroupId: string = '';
  @State joinedGroupIds: string[] = [];
  @State groupMembershipConfirmOpen: boolean = false;
  @State assessmentOpen: boolean = false;
  @State assessmentCorrectionOpen: boolean = false;
  @State assessmentCompletionInFlight: boolean = false;
  @State passportSharePreviewOpen: boolean = false;
  @State passportDetailOpen: boolean = false;
  @State windowWidth: number = 360;
  @State windowHeight: number = 720;
  @State litRegionName: string = '';
  @State currentUser: FellowUser | undefined = undefined;
  @State firstRunGuideOpen: boolean = false;
  @State xiaoyiOpen: boolean = false;
  @State privacyOpen: boolean = false;
  @State languageDirectoryOpen: boolean = false;
  @State dailyChallengeOpen: boolean = false;
  @State personalCenterOpen: boolean = false;
  @State privacyStatusMessage: string = '';
  @State authSession: HuaweiAccountSession | undefined = undefined;
  @State authChecking: boolean = true;
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();
  @State groups: CommunityGroup[] = [];
  private readonly totalDialectCount: number = getDemonstrationDialectZoneCount();
  private passportStateRevision: number = 0;

  aboutToAppear(): void {
    this.loadCommunityGroups();
    this.restorePassportState();
    this.restoreFirstRunGuideState();
    this.restoreAuthSession();
  }

  private async loadCommunityGroups(): Promise<void> {
    this.groups = await getCommunityGroups();
  }

  build() {
    Stack() {
      // Keep the home/map tree mounted while secondary pages are shown.
      // Map Kit owns camera state internally; unmounting the map causes its
      // 3D globe camera to be recreated and reset when returning home.
      if (this.isWideLayout()) {
        this.wideHome()
      } else {
        this.compactHome()
      }

      if (this.selectedGroup() !== undefined) {
        CommunityGroupPage({
          group: this.selectedGroup()!,
          joined: this.isGroupJoined(this.selectedGroup()!.id),
          membershipConfirmOpen: $groupMembershipConfirmOpen,
          onBack: (): void => { this.closeGroup(); },
          onToggleMembership: (groupId: string): void => {
            this.updateGroupMembership(groupId);
          }
        })
          .zIndex(20)
      } else if (this.selectedUser() !== undefined &&
        (!this.isThreeColumnLayout() || this.passportDetailOpen)) {
        VoicePassportPage({
          passport: createPassport(
            this.selectedUser()!,
            this.currentUser !== undefined &&
              this.selectedUser()!.id === this.currentUser.id
          ),
          sharePreviewOpen: $passportSharePreviewOpen,
          onBack: (): void => {
            if (this.isThreeColumnLayout()) {
              this.closePassportDetail();
            } else {
              this.closePassport();
            }
          }
        })
          .zIndex(20)
      }

      if (this.languageDirectoryOpen) {
        LanguageDirectoryPage({
          onBack: (): void => { this.languageDirectoryOpen = false; }
        })
          .zIndex(30)
      }

      if (this.dailyChallengeOpen) {
        DailyChallengePage({
          onBack: (): void => { this.dailyChallengeOpen = false; }
        })
          .zIndex(31)
      }

      if (this.personalCenterOpen) {
        PersonalCenterPage({
          currentUser: this.currentUser,
          onBack: (): void => { this.personalCenterOpen = false; },
          onStartAssessment: (): void => { this.personalCenterOpen = false; this.openAssessment(); },
          onOpenPassport: (): void => { this.personalCenterOpen = false; this.openCurrentUserPassport(); }
        })
          .zIndex(32)
      }

      if (this.assessmentOpen && this.selectedUser() === undefined) {
        this.assessmentOverlay()
      }

      if (this.firstRunGuideOpen) {
        FirstRunGuide({
          onSkip: (): void => { this.dismissFirstRunGuide(); },
          onStartAssessment: (): void => {
            this.dismissFirstRunGuide();
            this.openAssessment();
          }
        })
          .zIndex(40)
      }

      if (this.xiaoyiOpen) {
        Stack() {
          XiaoyiAssistantEntry({ queryText: '帮我介绍乡音地图的功能' })
          Button({ type: ButtonType.Circle }) {
            Text('✕').fontSize(18).fontColor($r('app.color.ink_primary'))
          }
          .width(40).height(40)
          .position({ x: '100%', y: 12 })
          .translate({ x: -52, y: 0 })
          .onClick((): void => { this.xiaoyiOpen = false; })
        }
        .width('100%').height('100%')
        .backgroundColor($r('app.color.map_overlay'))
        .zIndex(50)
      }

      if (!this.authChecking && this.authSession === undefined) {
        AuthPage({
          onAuthenticated: (session: HuaweiAccountSession): void => {
            this.authSession = session;
            this.authChecking = false;
          }
        })
          .zIndex(100)
      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_oldValue: Area, newValue: Area): void => {
      this.windowWidth = Number(newValue.width);
      this.windowHeight = Number(newValue.height);
    })
  }

  onBackPress(): boolean {
    if (this.firstRunGuideOpen) {
      this.dismissFirstRunGuide();
      return true;
    }
    if (this.languageDirectoryOpen) {
      this.languageDirectoryOpen = false;
      return true;
    }
    if (this.dailyChallengeOpen) {
      this.dailyChallengeOpen = false;
      return true;
    }
    if (this.personalCenterOpen) {
      this.personalCenterOpen = false;
      return true;
    }
    if (this.passportSharePreviewOpen) {
      this.passportSharePreviewOpen = false;
      return true;
    }
    if (this.groupMembershipConfirmOpen) {
      this.groupMembershipConfirmOpen = false;
      return true;
    }
    if (this.assessmentCorrectionOpen) {
      this.assessmentCorrectionOpen = false;
      return true;
    }
    if (this.assessmentOpen) {
      this.closeAssessment();
      return true;
    }
    if (this.selectedUserId.length > 0) {
      this.closePassport();
      return true;
    }
    if (this.selectedGroupId.length > 0) {
      this.closeGroup();
      return true;
    }
    return false;
  }

  @Builder
  private compactHome() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      this.mapContent()

      if (!this.assessmentOpen) {
        FellowPanel({
          users: this.users,
          wideMode: false,
          portraitTabletMode: this.isPortraitTablet(),
          availableHeight: this.windowHeight,
          litDialectCount: this.litRegionName.length > 0 ? 1 : 0,
          totalDialectCount: this.totalDialectCount,
          hasPassport: this.currentUser !== undefined,
          groups: this.groups,
          joinedGroupIds: this.joinedGroupIds,
          expanded: $panelExpanded,
          discoveryMode: $discoveryMode,
          selectedSource: $selectedSource,
          selectedGroupSource: $selectedGroupSource,
          onOpenUser: (userId: string): void => { this.openPassport(userId); },
          onOpenGroup: (groupId: string): void => { this.openGroup(groupId); },
          onStartAssessment: (): void => { this.openAssessment(); },
          onOpenPassport: (): void => { this.openCurrentUserPassport(); },
          onOpenDirectory: (): void => { this.languageDirectoryOpen = true; },
          onOpenDailyChallenge: (): void => { this.dailyChallengeOpen = true; }
        })
          .zIndex(4)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private wideHome() {
    Row() {
      Stack() {
        this.mapContent()
      }
      .layoutWeight(this.windowWidth >= 840 ? 7 : 3)
      .height('100%')

      if (!this.assessmentOpen) {
        FellowPanel({
          users: this.users,
          wideMode: true,
          portraitTabletMode: false,
          availableHeight: this.windowHeight,
          litDialectCount: this.litRegionName.length > 0 ? 1 : 0,
          totalDialectCount: this.totalDialectCount,
          hasPassport: this.currentUser !== undefined,
          groups: this.groups,
          joinedGroupIds: this.joinedGroupIds,
          expanded: $panelExpanded,
          discoveryMode: $discoveryMode,
          selectedSource: $selectedSource,
          selectedGroupSource: $selectedGroupSource,
          onOpenUser: (userId: string): void => { this.openPassport(userId); },
          onOpenGroup: (groupId: string): void => { this.openGroup(groupId); },
          onStartAssessment: (): void => { this.openAssessment(); },
          onOpenPassport: (): void => { this.openCurrentUserPassport(); },
          onOpenDirectory: (): void => { this.languageDirectoryOpen = true; },
          onOpenDailyChallenge: (): void => { this.dailyChallengeOpen = true; }
        })
          .width(this.windowWidth >= 1200 ? 400 : 360)
          .height('100%')
      }

      if (this.isThreeColumnLayout() && !this.assessmentOpen) {
        PassportPreviewPanel({
          fellow: this.selectedUser(),
          onOpenDetail: (): void => { this.passportDetailOpen = true; },
          onClose: (): void => { this.closePassport(); }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private mapContent() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.litRegionName.length > 0) {
        HarmonyDialectMap({ markers: this.markers, litRegionName: this.litRegionName })
      } else {
        HarmonyDialectMap({ markers: this.markers, litRegionName: '' })
      }
      Button({ type: ButtonType.Circle }) {
        Text('我').fontSize(15).fontWeight(FontWeight.Bold).fontColor($r('app.color.accent_text'))
      }
      .width(48).height(48).margin({ left: 18, top: 18 })
      .backgroundColor($r('app.color.surface_primary')).shadow({ radius: 10, color: $r('app.color.shadow_soft') })
      .onClick((): void => { this.personalCenterOpen = true; })
      .accessibilityText('打开个人中心')
    }
    .width('100%').height('100%')
  }

  @Builder
  private assessmentOverlay() {
    Stack({
      alignContent: this.isWideLayout() ? Alignment.End : Alignment.Bottom
    }) {
      VoiceAssessmentPage({
        correctionOpen: $assessmentCorrectionOpen,
        completionInFlight: $assessmentCompletionInFlight,
        onBack: (): void => { this.closeAssessment(); },
        onComplete: async (assessment: DialectAssessment): Promise<void> => {
          this.passportStateRevision += 1;
          this.currentUser = createCurrentUserFromAssessment(assessment);
          this.litRegionName = assessment.regionName;
          this.persistPassportState(assessment);
          this.closeAssessment();
          this.passportSharePreviewOpen = false;
          this.selectedUserId = this.currentUser.id;
        }
      })
        .width(this.isWideLayout() ? 480 : '100%')
        .height(this.isWideLayout() ? '100%' : '88%')
        .borderRadius(this.isWideLayout() ?
          { topLeft: 28, bottomLeft: 28 } :
          { topLeft: 28, topRight: 28 })
        .clip(true)
        .shadow({ radius: 30, color: $r('app.color.shadow_soft') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.map_overlay'))
    .zIndex(10)
  }

  private isWideLayout(): boolean {
    return this.windowWidth >= 840 && this.windowWidth > this.windowHeight;
  }

  private isThreeColumnLayout(): boolean {
    return this.windowWidth >= 1200 && this.windowWidth > this.windowHeight;
  }

  private async restorePassportState(): Promise<void> {
    const revision = this.passportStateRevision;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const savedState: SavedPassportState | undefined = await loadPassportState(context);
    if (savedState === undefined || revision !== this.passportStateRevision) {
      return;
    }

    const baseAssessment = createSimulatedAssessment(
      savedState.regionName,
      savedState.dialectName
    );
    const restoredAssessment = correctSimulatedAssessment(
      baseAssessment,
      savedState.regionName,
      savedState.dialectName
    );
    this.currentUser = createCurrentUserFromAssessment(restoredAssessment);
    this.litRegionName = savedState.regionName;
  }

  private async restoreAuthSession(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.authSession = await restoreHuaweiAccountSession(context);
    this.authChecking = false;
  }

  private async restoreFirstRunGuideState(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    if (!(await hasSeenFirstRunGuide(context))) {
      this.firstRunGuideOpen = true;
    }
  }

  private dismissFirstRunGuide(): void {
    this.firstRunGuideOpen = false;
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    markFirstRunGuideSeen(context);
  }

  private async persistPassportState(assessment: DialectAssessment): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    await savePassportState(context, assessment);
  }

  private isPortraitTablet(): boolean {
    return this.windowWidth >= 600 && this.windowHeight >= this.windowWidth;
  }

  private openAssessment(): void {
    this.passportStateRevision += 1;
    this.selectedUserId = '';
    this.selectedGroupId = '';
    this.groupMembershipConfirmOpen = false;
    this.passportSharePreviewOpen = false;
    this.assessmentCorrectionOpen = false;
    this.assessmentOpen = true;
  }

  private closeAssessment(): void {
    this.assessmentCorrectionOpen = false;
    this.assessmentOpen = false;
  }

  private openPassport(userId: string): void {
    this.closeAssessment();
    this.passportSharePreviewOpen = false;
    this.passportDetailOpen = false;
    this.selectedGroupId = '';
    this.groupMembershipConfirmOpen = false;
    this.selectedUserId = userId;
  }

  private openCurrentUserPassport(): void {
    if (this.currentUser !== undefined) {
      this.openPassport(this.currentUser.id);
    }
  }

  private closePassport(): void {
    this.passportSharePreviewOpen = false;
    this.passportDetailOpen = false;
    this.selectedUserId = '';
  }

  private closePassportDetail(): void {
    this.passportSharePreviewOpen = false;
    this.passportDetailOpen = false;
  }

  private openGroup(groupId: string): void {
    this.closeAssessment();
    this.selectedUserId = '';
    this.passportSharePreviewOpen = false;
    this.groupMembershipConfirmOpen = false;
    markCommunityGroupRead(groupId);
    this.selectedGroupId = groupId;
  }

  private closeGroup(): void {
    this.groupMembershipConfirmOpen = false;
    this.selectedGroupId = '';
  }

  private async updateGroupMembership(groupId: string): Promise<void> {
    if (this.authSession === undefined || this.authSession.userId.length === 0) {
      return;
    }
    const joined = this.isGroupJoined(groupId);
    try {
      await toggleGroupMembership(groupId, this.authSession.userId, joined);
      this.joinedGroupIds = joined
        ? this.joinedGroupIds.filter((id: string): boolean => id !== groupId)
        : this.joinedGroupIds.concat(groupId);
    } catch {
      // The page keeps its previous membership state when the server rejects it.
    }
  }

  private selectedUser(): FellowUser | undefined {
    if (this.currentUser !== undefined &&
      this.selectedUserId === this.currentUser.id) {
      return this.currentUser;
    }
    return this.users.find((user: FellowUser): boolean => user.id === this.selectedUserId);
  }

  private selectedGroup(): CommunityGroup | undefined {
    return this.groups.find((group: CommunityGroup): boolean =>
      group.id === this.selectedGroupId
    );
  }

  private isGroupJoined(groupId: string): boolean {
    return this.joinedGroupIds.indexOf(groupId) >= 0;
  }
}
