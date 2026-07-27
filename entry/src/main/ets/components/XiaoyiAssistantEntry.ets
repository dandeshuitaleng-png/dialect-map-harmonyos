import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  ButtonType as AgentButtonType,
  FunctionComponent,
  FunctionController
} from '@kit.AgentFrameworkKit';
import { XiaoyiAvailability } from '../models/DialectModels';
import {
  hasConfiguredXiaoyiAgent,
  XIAOYI_AGENT_ID
} from '../services/XiaoyiAgentConfig';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT_FILL: ResourceColor = $r('app.color.accent');
const ACCENT_TEXT: ResourceColor = $r('app.color.accent_text');

@Component
export struct XiaoyiAssistantEntry {
  @Prop queryText: string = '帮我推荐一个适合加入的乡音群组';
  @State availability: XiaoyiAvailability = XiaoyiAvailability.UNCONFIGURED;
  @State statusMessage: string = '需要配置小艺智能体 ID 后才能使用';
  private readonly agentId: string = XIAOYI_AGENT_ID;
  private readonly controller: FunctionController = new FunctionController();

  aboutToAppear(): void {
    this.refreshAvailability();
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Stack() {
          Text('艺')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
        }
        .width(40)
        .height(40)
        .backgroundColor(ACCENT_FILL)
        .borderRadius(20)

        Column({ space: 3 }) {
          Text('小艺 · 乡音助手')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text('解释方言、推荐群组、整理已校验数据')
            .fontSize(12)
            .fontColor(MUTED)
            .maxLines(2)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (this.availability === XiaoyiAvailability.AVAILABLE) {
        FunctionComponent({
          agentId: this.agentId,
          controller: this.controller,
          options: {
            title: '问小艺',
            queryText: this.queryText,
            buttonType: AgentButtonType.CAPSULE,
            isShowShadow: false,
            backgroundColor: ACCENT_FILL,
            iconColors: [$r('app.color.on_emphasis')],
            titleColors: [$r('app.color.on_emphasis')]
          },
          onError: (error: BusinessError): void => {
            this.availability = XiaoyiAvailability.ERROR;
            this.statusMessage = this.agentErrorMessage(error);
          }
        })
      } else {
        Row({ space: 10 }) {
          Text(this.statusLabel())
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.availability === XiaoyiAvailability.ERROR ?
              ACCENT_TEXT : MUTED)
            .layoutWeight(1)
          if (this.canRetry()) {
            Button('重试')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(INK)
              .height(48)
              .padding({ left: 16, right: 16 })
              .backgroundColor($r('app.color.surface_pure'))
              .borderRadius(16)
              .onClick((): void => { this.refreshAvailability(); })
              .accessibilityText('重新检查小艺能力')
          } else {
            Text(this.availability === XiaoyiAvailability.CHECKING ?
              '检查中' : '待配置')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(ACCENT_TEXT)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor($r('app.color.surface_accent_soft'))
              .borderRadius(10)
          }
        }
        .width('100%')
        .height(48)
      }

      Text(this.statusMessage)
        .fontSize(11)
        .fontColor(MUTED)
        .lineHeight(18)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface_confirm_soft'))
    .borderRadius(16)
    .border({ width: 1, color: $r('app.color.border') })
    .shadow({ radius: 8, color: $r('app.color.shadow_card'), offsetY: 3 })
  }

  private async refreshAvailability(): Promise<void> {
    if (!hasConfiguredXiaoyiAgent(this.agentId)) {
      this.availability = XiaoyiAvailability.UNCONFIGURED;
      this.statusMessage = '需要提供小艺开放平台的 agentId，当前不会生成模拟回复。';
      return;
    }

    this.availability = XiaoyiAvailability.CHECKING;
    this.statusMessage = '正在检查当前设备与账号是否支持小艺智能体';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const supported = await this.controller.isAgentSupport(context, this.agentId);
      this.availability = supported ?
        XiaoyiAvailability.AVAILABLE : XiaoyiAvailability.UNSUPPORTED;
      this.statusMessage = supported ?
        '已通过官方能力检查，可向小艺询问当前乡音场景。' :
        '当前设备或应用状态不支持此小艺智能体。';
    } catch (error) {
      this.availability = XiaoyiAvailability.ERROR;
      this.statusMessage = this.agentErrorMessage(error as BusinessError);
    }
  }

  private statusLabel(): string {
    if (this.availability === XiaoyiAvailability.CHECKING) {
      return '正在检查官方能力';
    }
    if (this.availability === XiaoyiAvailability.UNSUPPORTED) {
      return '当前设备不可用';
    }
    if (this.availability === XiaoyiAvailability.ERROR) {
      return '能力检查失败';
    }
    return '官方能力尚未配置';
  }

  private canRetry(): boolean {
    return this.availability === XiaoyiAvailability.UNSUPPORTED ||
      this.availability === XiaoyiAvailability.ERROR;
  }

  private agentErrorMessage(error: BusinessError): string {
    if (error.code === 1022400011) {
      return '需要先接受小艺相关隐私协议，再重新检查。';
    }
    if (error.code === 1022400012) {
      return '当前设备尚未登录华为账号，登录后可重新检查。';
    }
    if (error.code === 1022400013) {
      return '网络暂不可用，未向用户展示任何本地模拟回复。';
    }
    if (error.code === 1022400010) {
      return '小艺智能体参数无效，请检查 agentId 配置。';
    }
    return '小艺能力暂不可用，请稍后重试。';
  }
}
