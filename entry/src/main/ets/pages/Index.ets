import { common } from '@kit.AbilityKit';
import { HarmonyDialectMap } from '../components/HarmonyDialectMap';
import { FellowPanel } from '../components/FellowPanel';
import { VoicePassportPage } from '../components/VoicePassportPage';
import { VoiceAssessmentPage } from '../components/VoiceAssessmentPage';
import { DialectAssessment, FellowSource, FellowUser, MapMarker } from '../models/DialectModels';
import {
  createCurrentUserFromAssessment,
  correctSimulatedAssessment,
  createPassport,
  createSimulatedAssessment,
  getFellowUsers,
  getMapMarkers
} from '../services/MockDialectService';
import {
  loadPassportState,
  savePassportState,
  SavedPassportState
} from '../services/PassportPersistenceService';

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedUserId: string = '';
  @State assessmentOpen: boolean = false;
  @State windowWidth: number = 360;
  @State windowHeight: number = 720;
  @State litRegionName: string = '';
  @State currentUser: FellowUser =
    createCurrentUserFromAssessment(createSimulatedAssessment('四川', '四川话'));
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();

  aboutToAppear(): void {
    this.restorePassportState();
  }

  build() {
    Stack() {
      if (this.selectedUser() !== undefined) {
        VoicePassportPage({
          passport: createPassport(
            this.selectedUser()!,
            this.selectedUser()!.id === this.currentUser.id
          ),
          onBack: (): void => { this.selectedUserId = ''; }
        })
      } else if (this.isWideLayout()) {
        this.wideHome()
      } else {
        this.compactHome()
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
    if (this.assessmentOpen) {
      this.assessmentOpen = false;
      return true;
    }
    if (this.selectedUserId.length > 0) {
      this.selectedUserId = '';
      return true;
    }
    return false;
  }

  @Builder
  private compactHome() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      this.mapContent()

      FellowPanel({
        users: this.users,
        wideMode: false,
        portraitTabletMode: this.isPortraitTablet(),
        availableHeight: this.windowHeight,
        litDialectCount: this.litRegionName.length > 0 ? 1 : 0,
        totalDialectCount: 4,
        expanded: $panelExpanded,
        selectedSource: $selectedSource,
        onOpenUser: (userId: string): void => { this.selectedUserId = userId; },
        onStartAssessment: (): void => { this.assessmentOpen = true; },
        onOpenPassport: (): void => { this.selectedUserId = this.currentUser.id; }
      })
        .zIndex(4)
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

      FellowPanel({
        users: this.users,
        wideMode: true,
        portraitTabletMode: false,
        availableHeight: this.windowHeight,
        litDialectCount: this.litRegionName.length > 0 ? 1 : 0,
        totalDialectCount: 4,
        expanded: $panelExpanded,
        selectedSource: $selectedSource,
        onOpenUser: (userId: string): void => { this.selectedUserId = userId; },
        onStartAssessment: (): void => { this.assessmentOpen = true; },
        onOpenPassport: (): void => { this.selectedUserId = this.currentUser.id; }
      })
        .width(this.windowWidth >= 1200 ? 400 : 360)
        .height('100%')
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
        onBack: (): void => { this.assessmentOpen = false; },
        onComplete: (assessment: DialectAssessment): void => {
          this.currentUser = createCurrentUserFromAssessment(assessment);
          this.litRegionName = assessment.regionName;
          this.persistPassportState(assessment);
          this.assessmentOpen = false;
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
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    const savedState: SavedPassportState | undefined = await loadPassportState(context);
    if (savedState === undefined) {
      return;
    }

    const baseAssessment = createSimulatedAssessment(
      savedState.regionName,
      savedState.dialectName
    );
    const restoredAssessment = correctSimulatedAssessment(
      baseAssessment,
      savedState.regionName,
      savedState.dialectName,
      savedState.dialectBranch
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

  private selectedUser(): FellowUser | undefined {
    if (this.selectedUserId === this.currentUser.id) {
      return this.currentUser;
    }
    return this.users.find((user: FellowUser): boolean => user.id === this.selectedUserId);
  }
}
