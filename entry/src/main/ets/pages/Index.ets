import { common } from '@kit.AbilityKit';
import { HarmonyDialectMap } from '../components/HarmonyDialectMap';
import { FellowPanel } from '../components/FellowPanel';
import { CommunityGroupPage } from '../components/CommunityGroupPage';
import { VoicePassportPage } from '../components/VoicePassportPage';
import { VoiceAssessmentPage } from '../components/VoiceAssessmentPage';
import {
  CommunityGroup,
  DialectAssessment,
  DiscoveryMode,
  FellowSource,
  FellowUser,
  GroupSource,
  MapMarker
} from '../models/DialectModels';
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
  loadPassportState,
  savePassportState,
  SavedPassportState
} from '../services/PassportPersistenceService';
import {
  getCommunityGroups,
  getInitialJoinedGroupIds,
  markCommunityGroupRead,
  toggleLocalGroupMembership
} from '../services/MockCommunityService';

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State discoveryMode: DiscoveryMode = DiscoveryMode.FELLOWS;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedGroupSource: GroupSource = GroupSource.JOINED;
  @State selectedUserId: string = '';
  @State selectedGroupId: string = '';
  @State joinedGroupIds: string[] = getInitialJoinedGroupIds();
  @State groupMembershipConfirmOpen: boolean = false;
  @State assessmentOpen: boolean = false;
  @State assessmentCorrectionOpen: boolean = false;
  @State passportSharePreviewOpen: boolean = false;
  @State windowWidth: number = 360;
  @State windowHeight: number = 720;
  @State litRegionName: string = '';
  @State currentUser: FellowUser | undefined = undefined;
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();
  private readonly groups: CommunityGroup[] = getCommunityGroups();
  private readonly totalDialectCount: number = getDemonstrationDialectZoneCount();
  private passportStateRevision: number = 0;

  aboutToAppear(): void {
    this.restorePassportState();
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
            this.joinedGroupIds = toggleLocalGroupMembership(
              this.joinedGroupIds,
              groupId
            );
          }
        })
          .zIndex(20)
      } else if (this.selectedUser() !== undefined) {
        VoicePassportPage({
          passport: createPassport(
            this.selectedUser()!,
            this.currentUser !== undefined &&
              this.selectedUser()!.id === this.currentUser.id
          ),
          sharePreviewOpen: $passportSharePreviewOpen,
          onBack: (): void => { this.closePassport(); }
        })
          .zIndex(20)
      }

      if (this.assessmentOpen && this.selectedUser() === undefined) {
        this.assessmentOverlay()
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
          onOpenPassport: (): void => { this.openCurrentUserPassport(); }
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
          onOpenPassport: (): void => { this.openCurrentUserPassport(); }
        })
          .width(this.windowWidth >= 1200 ? 400 : 360)
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private mapContent() {
    if (this.litRegionName.length > 0) {
      HarmonyDialectMap({
        markers: this.markers,
        litRegionName: this.litRegionName
      })
    } else {
      HarmonyDialectMap({
        markers: this.markers,
        litRegionName: ''
      })
    }
  }

  @Builder
  private assessmentOverlay() {
    Stack({
      alignContent: this.isWideLayout() ? Alignment.End : Alignment.Bottom
    }) {
      VoiceAssessmentPage({
        correctionOpen: $assessmentCorrectionOpen,
        onBack: (): void => { this.closeAssessment(); },
        onComplete: (assessment: DialectAssessment): void => {
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
    this.selectedUserId = '';
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
