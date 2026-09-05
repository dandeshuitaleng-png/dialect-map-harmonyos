/**
 * 首次引导 — 用户首次打开 App 时展示的多步欢迎流程。
 */

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent');
const CONFIRM: ResourceColor = $r('app.color.confirm');
const CONFIRM_TEXT: ResourceColor = $r('app.color.confirm_text');

interface GuideStep {
  title: string;
  description: string;
  icon: string;
}

const STEPS: GuideStep[] = [
  {
    icon: '🗺️',
    title: '方言地图',
    description: '以中国地图为首页，点击任一地区查看方言详情。已点亮区域会在乡音护照中留下记录。',
  },
  {
    icon: '🎤',
    title: 'AI 方言鉴定',
    description: '输入一句家乡话，调用 AI 判断方言归属，并展示置信度与识别依据。',
  },
  {
    icon: '📖',
    title: '乡音护照',
    description: '每完成一次鉴定并确认点亮，将获得一枚方言印章。收集印章，留下属于你的乡音足迹。',
  },
  {
    icon: '🤖',
    title: '小艺 · 乡音助手',
    description: '点击地图右上角的「艺」按钮，可向小艺询问方言特点、推荐群组或整理已校验数据。',
  },
];

@Component
export struct FirstRunGuide {
  onSkip: () => void = (): void => {};
  onStartAssessment: () => void = (): void => {};
  @State stepIndex: number = 0;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column({ space: 20 }) {
        // 步骤指示器
        Row({ space: 6 }) {
          ForEach(STEPS, (_: GuideStep, index: number): void => {
            Row()
              .width(index === this.stepIndex ? 20 : 6)
              .height(6)
              .borderRadius(3)
              .backgroundColor(index === this.stepIndex ? ACCENT : $r('app.color.divider'))
              .animation({ duration: 200 })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Text(STEPS[this.stepIndex].icon)
          .fontSize(56)

        Column({ space: 8 }) {
          Text(STEPS[this.stepIndex].title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
            .textAlign(TextAlign.Center)

          Text(STEPS[this.stepIndex].description)
            .fontSize(14)
            .lineHeight(24)
            .fontColor(MUTED)
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: 300 })
        }

        // 底部操作区
        Column({ space: 10 }) {
          if (this.stepIndex < STEPS.length - 1) {
            Button('下一步')
              .height(50)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .backgroundColor(ACCENT)
              .borderRadius(14)
              .onClick((): void => { this.stepIndex++; })
              .accessibilityText('进入下一引导页')
          } else {
            Button('开始第一次鉴定')
              .height(50)
              .width('100%')
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.on_emphasis'))
              .backgroundColor(CONFIRM)
              .borderRadius(14)
              .onClick(this.onStartAssessment)
              .accessibilityText('开始第一次乡音鉴定')
          }

          Button(this.stepIndex < STEPS.length - 1 ? '跳过引导' : '先看看地图')
            .height(44)
            .width('100%')
            .fontColor(MUTED)
            .backgroundColor(Color.Transparent)
            .onClick(this.onSkip)
            .accessibilityText('跳过首次引导，进入地图')
        }

        // 隐私声明
        Text('不会上传原始录音 · 无需账号 · 可随时清除护照')
          .fontSize(11)
          .fontColor($r('app.color.accent_text'))
          .textAlign(TextAlign.Center)
      }
      .width('calc(100% - 40vp)')
      .constraintSize({ maxWidth: 460 })
      .padding(24)
      .backgroundColor($r('app.color.surface_elevated'))
      .borderRadius(24)
      .shadow({ radius: 24, color: $r('app.color.shadow_soft') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.map_overlay'))
  }
}
