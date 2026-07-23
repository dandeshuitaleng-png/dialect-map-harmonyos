import { HarmonyDialectMap } from '../components/HarmonyDialectMap';
import { FellowPanel } from '../components/FellowPanel';
import { VoicePassportPage } from '../components/VoicePassportPage';
import { VoiceAssessmentPage } from '../components/VoiceAssessmentPage';
import { DialectAssessment, FellowSource, FellowUser, MapMarker } from '../models/DialectModels';
import {
  createCurrentUserFromAssessment,
  createPassport,
  createSimulatedAssessment,
  getFellowUsers,
  getMapMarkers
} from '../services/MockDialectService';

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedUserId: string = '';
  @State assessmentOpen: boolean = false;
  @State windowWidth: number = 360;
  @State currentUser: FellowUser =
    createCurrentUserFromAssessment(createSimulatedAssessment('四川', '四川话'));
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();

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
      HarmonyDialectMap({ markers: this.markers })

      FellowPanel({
        users: this.users,
        wideMode: false,
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
        HarmonyDialectMap({ markers: this.markers })
      }
      .layoutWeight(this.windowWidth >= 840 ? 7 : 3)
      .height('100%')

      FellowPanel({
        users: this.users,
        wideMode: true,
        expanded: $panelExpanded,
        selectedSource: $selectedSource,
        onOpenUser: (userId: string): void => { this.selectedUserId = userId; },
        onStartAssessment: (): void => { this.assessmentOpen = true; },
        onOpenPassport: (): void => { this.selectedUserId = this.currentUser.id; }
      })
        .width(this.windowWidth >= 840 ? '30%' : '40%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
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
    return this.windowWidth >= 600;
  }

  private selectedUser(): FellowUser | undefined {
    if (this.selectedUserId === this.currentUser.id) {
      return this.currentUser;
    }
    return this.users.find((user: FellowUser): boolean => user.id === this.selectedUserId);
  }
}
