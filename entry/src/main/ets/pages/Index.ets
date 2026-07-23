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

const ACCENT: string = '#DB643D';

@Entry
@Component
struct Index {
  @State panelExpanded: boolean = false;
  @State selectedSource: FellowSource = FellowSource.NEARBY;
  @State selectedUserId: string = '';
  @State assessmentOpen: boolean = false;
  @State currentUserCreated: boolean = false;
  private readonly markers: MapMarker[] = getMapMarkers();
  private readonly users: FellowUser[] = getFellowUsers();
  private readonly currentUser: FellowUser =
    createCurrentUserFromAssessment(createSimulatedAssessment('四川', '四川话'));

  build() {
    if (this.assessmentOpen) {
      VoiceAssessmentPage({
        onBack: (): void => { this.assessmentOpen = false; },
        onComplete: (assessment: DialectAssessment): void => {
          this.currentUserCreated = true;
          this.assessmentOpen = false;
          this.selectedUserId = this.currentUser.id;
        }
      })
    } else if (this.selectedUser() !== undefined) {
      VoicePassportPage({
        passport: createPassport(this.selectedUser()!),
        onBack: (): void => { this.selectedUserId = ''; }
      })
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        DialectMap({ markers: this.markers })

        Button() {
          Row({ space: 7 }) {
            Text('●')
              .fontSize(12)
              .fontColor('#FFFFFF')
            Text('录音鉴定')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .height(46)
        .padding({ left: 17, right: 17 })
        .backgroundColor(ACCENT)
        .borderRadius(23)
        .shadow({ radius: 20, color: 'rgba(147,61,34,0.30)' })
        .position({ x: 214, y: 356 })
        .zIndex(5)
        .onClick((): void => { this.assessmentOpen = true; })

        FellowPanel({
          users: this.users,
          expanded: $panelExpanded,
          selectedSource: $selectedSource,
          onOpenUser: (userId: string): void => { this.selectedUserId = userId; }
        })
        .zIndex(4)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#DDE5DC')
    }
  }

  private selectedUser(): FellowUser | undefined {
    if (this.currentUserCreated && this.selectedUserId === this.currentUser.id) {
      return this.currentUser;
    }
    return this.users.find((user: FellowUser): boolean => user.id === this.selectedUserId);
  }
}
