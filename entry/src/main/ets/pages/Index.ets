import { DialectMap } from '../components/DialectMap';
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

const ACCENT: ResourceColor = $r('app.color.accent');

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedUserId: string = '';
  @State assessmentOpen: boolean = false;
  @State currentUserCreated: boolean = false;
  @State windowWidth: number = 360;
  @State currentUser: FellowUser =
    createCurrentUserFromAssessment(createSimulatedAssessment('四川', '四川话'));
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();

  build() {
    Stack() {
      if (this.assessmentOpen) {
        VoiceAssessmentPage({
          onBack: (): void => { this.assessmentOpen = false; },
          onComplete: (assessment: DialectAssessment): void => {
            this.currentUser = createCurrentUserFromAssessment(assessment);
            this.currentUserCreated = true;
            this.assessmentOpen = false;
            this.selectedUserId = this.currentUser.id;
          }
        })
      } else if (this.selectedUser() !== undefined) {
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
      DialectMap({ markers: this.markers })

      this.assessmentButton(20, 330)

      FellowPanel({
        users: this.users,
        wideMode: false,
        expanded: $panelExpanded,
        selectedSource: $selectedSource,
        onOpenUser: (userId: string): void => { this.selectedUserId = userId; }
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
      Stack({ alignContent: Alignment.BottomEnd }) {
        DialectMap({ markers: this.markers })
        this.assessmentButton(24, 24)
      }
      .layoutWeight(5)
      .height('100%')

      FellowPanel({
        users: this.users,
        wideMode: true,
        expanded: $panelExpanded,
        selectedSource: $selectedSource,
        onOpenUser: (userId: string): void => { this.selectedUserId = userId; }
      })
        .width(this.windowWidth >= 840 ? '34%' : '40%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private assessmentButton(rightMargin: number, bottomMargin: number) {
    Button() {
      Row({ space: 8 }) {
        Text('●')
          .fontSize(12)
          .fontColor($r('app.color.on_emphasis'))
        Text('录音鉴定')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_emphasis'))
      }
    }
    .height(48)
    .padding({ left: 20, right: 20 })
    .backgroundColor(ACCENT)
    .borderRadius(24)
    .shadow({ radius: 20, color: $r('app.color.shadow_accent') })
    .margin({ right: rightMargin, bottom: bottomMargin })
    .zIndex(5)
    .onClick((): void => { this.assessmentOpen = true; })
    .accessibilityText('开始模拟乡音录音鉴定')
  }

  private isWideLayout(): boolean {
    return this.windowWidth >= 600;
  }

  private selectedUser(): FellowUser | undefined {
    if (this.currentUserCreated && this.selectedUserId === this.currentUser.id) {
      return this.currentUser;
    }
    return this.users.find((user: FellowUser): boolean => user.id === this.selectedUserId);
  }
}
