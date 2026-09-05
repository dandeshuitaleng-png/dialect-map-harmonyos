/**
 * 全局错误状态页 — 可用于地图加载失败、护照恢复失败、数据不可用等场景。
 * 支持四种预设错误类型或自定义消息。
 */

export enum ErrorPageKind {
  NETWORK = 'network',
  DATA = 'data',
  PERMISSION = 'permission',
  GENERIC = 'generic',
}

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');
const CONFIRM: ResourceColor = $r('app.color.confirm');

interface ErrorPageConfig {
  icon: string;
  title: string;
  message: string;
}

function configFor(kind: ErrorPageKind): ErrorPageConfig {
  switch (kind) {
    case ErrorPageKind.NETWORK:
      return { icon: '📡', title: '网络连接失败', message: '无法加载数据，请检查网络连接后重试。' };
    case ErrorPageKind.DATA:
      return { icon: '📭', title: '暂无可用数据', message: '当前没有可展示的内容，连接网络后将自动刷新。' };
    case ErrorPageKind.PERMISSION:
      return { icon: '🔐', title: '需要权限', message: '部分功能需要授权后才能使用，请在系统设置中开启相关权限。' };
    default:
      return { icon: '⚠️', title: '出错了', message: '遇到意外错误，请稍后重试。' };
  }
}

@Component
export struct ErrorStatePage {
  @Prop kind: ErrorPageKind = ErrorPageKind.GENERIC;
  @Prop customTitle: string = '';
  @Prop customMessage: string = '';
  onRetry?: () => void;
  onBack?: () => void;

  build() {
    const cfg = configFor(this.kind);
    const title = this.customTitle.length > 0 ? this.customTitle : cfg.title;
    const message = this.customMessage.length > 0 ? this.customMessage : cfg.message;

    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 16 }) {
        Text(cfg.icon)
          .fontSize(48)

        Column({ space: 6 }) {
          Text(title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
            .textAlign(TextAlign.Center)
          Text(message)
            .fontSize(14)
            .lineHeight(22)
            .fontColor(MUTED)
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: 300 })
        }

        if (this.onRetry !== undefined) {
          Button('重试')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.on_emphasis'))
            .height(48)
            .padding({ left: 32, right: 32 })
            .backgroundColor(ACCENT)
            .borderRadius(14)
            .onClick((): void => { this.onRetry?.(); })
            .accessibilityText('重新尝试加载')
        }

        if (this.onBack !== undefined) {
          Button('返回')
            .fontSize(14)
            .fontColor(MUTED)
            .height(44)
            .backgroundColor(Color.Transparent)
            .onClick((): void => { this.onBack?.(); })
            .accessibilityText('返回上一页')
        }
      }
      .alignItems(HorizontalAlign.Center)
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_page'))
  }
}
