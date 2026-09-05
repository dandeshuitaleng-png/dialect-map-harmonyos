import {
  LanguageDirectoryCoverage,
  LanguageDirectoryEntity,
  LanguageDirectoryResponse,
  LanguageDirectorySurveyPoint,
  LanguageDirectoryVariant
} from '../models/DialectModels';
import { fetchLanguageDirectory } from '../services/LanguageDirectoryService';

const INK: ResourceColor = $r('app.color.ink_primary');
const MUTED: ResourceColor = $r('app.color.ink_muted');
const ACCENT: ResourceColor = $r('app.color.accent_text');

@Component
export struct LanguageDirectoryPage {
  onBack: () => void = (): void => {};
  @State loading: boolean = true;
  @State query: string = '';
  @State response: LanguageDirectoryResponse | undefined = undefined;
  @State errorMessage: string = '';
  @State selectedTab: number = 0;

  aboutToAppear(): void {
    this.loadDirectory();
  }

  build() {
    Column() {
      Row() {
        Button('关闭')
          .fontSize(16).fontWeight(FontWeight.Medium).fontColor(INK).height(48)
          .padding({ left: 18, right: 18 }).backgroundColor($r('app.color.surface_elevated')).borderRadius(24)
          .onClick(this.onBack).accessibilityText('关闭全国语言目录')
        Blank()
      }
      .padding({ left: 20, right: 20, top: 14 }).height(70).width('100%')
      Text('全国语言目录').fontSize(38).fontWeight(FontWeight.Bold).fontColor(INK)
        .width('100%').padding({ left: 28, right: 28, top: 22, bottom: 30 })

      if (this.loading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .margin({ top: 32, bottom: 16 })
        Text('正在加载语言目录…')
          .fontSize(15)
          .fontColor(MUTED)
      } else if (this.errorMessage.length > 0) {
        Column({ space: 12 }) {
          Text('全国目录暂时不可用')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(INK)
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor(MUTED)
            .textAlign(TextAlign.Center)
          Button('重新加载')
            .height(48)
            .fontColor($r('app.color.on_emphasis'))
            .backgroundColor($r('app.color.accent'))
            .borderRadius(16)
            .onClick((): void => { this.loadDirectory(); })
        }
        .padding(24)
        .width('100%')
      } else if (this.response !== undefined) {
        this.directoryContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_map'))
  }

  @Builder
  private directoryContent() {
    Column() {
      this.summary()
      Text(this.selectedTab === 0 ? this.visibleEntities().length.toString() + ' 个民族的语言与方言' :
        (this.selectedTab === 1 ? '语言/方言候选' : (this.selectedTab === 2 ? '区域范围摘要' : '已核验调查点')))
        .fontSize(20).fontWeight(FontWeight.Bold).fontColor(MUTED).width('100%')
        .padding({ left: 28, right: 28, top: 22, bottom: 14 })
      List({ space: 8 }) {
        if (this.selectedTab === 0) {
          ForEach(this.visibleEntities(), (item: LanguageDirectoryEntity): void => {
            ListItem() { this.entityRow(item); }
          }, (item: LanguageDirectoryEntity): string => item.id)
        } else if (this.selectedTab === 1) {
          ForEach(this.visibleVariants(), (item: LanguageDirectoryVariant): void => {
            ListItem() { this.variantRow(item); }
          }, (item: LanguageDirectoryVariant): string => item.id)
        } else if (this.selectedTab === 2) {
          ForEach(this.visibleCoverage(), (item: LanguageDirectoryCoverage): void => {
            ListItem() { this.coverageRow(item); }
          }, (item: LanguageDirectoryCoverage): string => item.id)
        } else {
          if (this.visibleSurveyPoints().length === 0) {
            ListItem() { this.emptySurveyPoints(); }
          } else {
            ForEach(this.visibleSurveyPoints(), (item: LanguageDirectorySurveyPoint): void => {
              ListItem() { this.surveyPointRow(item); }
            }, (item: LanguageDirectorySurveyPoint): string => item.id)
          }
        }
      }
      .layoutWeight(1)
      .margin({ left: 20, right: 20, bottom: 72 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .layoutWeight(1)
    .overlay(this.searchBar())
  }

  @Builder
  private summary() {
    if (this.response !== undefined) {
      Column({ space: 0 }) {
        Text('覆盖概览').fontSize(18).fontWeight(FontWeight.Bold).fontColor(MUTED)
          .width('100%').padding({ bottom: 16 })
        this.summaryLine('民族入口', `${this.response.counts.ethnicities}`)
        this.summaryLine('语言/方言候选', `${this.response.counts.variants}`)
        this.summaryLine('区域范围摘要', `${this.response.counts.coverageScopes}`)
        this.summaryLine('已核验调查点', `${this.response.counts.surveyPoints}`)
        Text('民族入口用于资源治理，不代表从声音推断民族身份。区域范围摘要也不是精确籍贯或行政边界。')
          .fontSize(13).fontColor(MUTED).lineHeight(19).margin({ top: 16 })
      }
      .padding(22).margin({ left: 20, right: 20 }).width('calc(100% - 40vp)')
      .backgroundColor($r('app.color.surface_elevated')).borderRadius(28)
    }
  }

  @Builder
  private summaryLine(label: string, value: string) {
    Row() {
      Text(label).fontSize(19).fontColor(INK).layoutWeight(1)
      Text(value).fontSize(20).fontColor(MUTED)
    }
    .width('100%').padding({ top: 13, bottom: 13 })
    .border({ width: { bottom: 1 }, color: $r('app.color.divider') })
  }

  @Builder
  private searchBar() {
    Column() {
      Blank().layoutWeight(1)
      TextInput({ placeholder: '⌕  搜索民族、语言、方言或地区', text: this.query })
        .height(58).fontSize(18).margin({ left: 28, right: 28, bottom: 18 })
        .padding({ left: 18, right: 18 }).backgroundColor($r('app.color.surface_elevated')).borderRadius(29)
        .shadow({ radius: 18, color: $r('app.color.shadow_soft'), offsetY: 6 })
        .onChange((value: string): void => { this.query = value; })
        .accessibilityText('搜索民族、语言、方言或地区')
    }
    .width('100%').height('100%')
  }

  @Builder
  private tabButton(label: string, index: number) {
    Button(label)
      .height(44)
      .layoutWeight(1)
      .fontSize(14)
      .fontWeight(this.selectedTab === index ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.selectedTab === index ? ACCENT : MUTED)
      .backgroundColor(this.selectedTab === index ? $r('app.color.surface_elevated') : Color.Transparent)
      .borderRadius(12)
      .onClick((): void => { this.selectedTab = index; })
      .accessibilityText(label + (this.selectedTab === index ? '，当前栏目' : ''))
  }

  @Builder
  private entityRow(item: LanguageDirectoryEntity) {
    Column({ space: 5 }) {
      Text(item.ethnicityName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text(item.languageName + ' · ' + item.languageFamily)
        .fontSize(13)
        .fontColor(ACCENT)
      Text(item.regionScope)
        .fontSize(12)
        .fontColor(MUTED)
        .maxLines(2)
      Text('民族入口 · ' + item.reviewStatus + ' · ' + item.licenseStatus)
        .fontSize(11)
        .fontColor(MUTED)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(14)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private variantRow(item: LanguageDirectoryVariant) {
    Column({ space: 5 }) {
      Text(item.dialectName.length > 0 ? item.dialectName : item.languageName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text(item.ethnicityName + ' · ' + item.languageName)
        .fontSize(13)
        .fontColor(ACCENT)
      Text(item.regionScope)
        .fontSize(12)
        .fontColor(MUTED)
        .maxLines(2)
      Text(item.reviewStatus + ' · ' + item.licenseStatus)
        .fontSize(11)
        .fontColor(MUTED)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(14)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private surveyPointRow(item: LanguageDirectorySurveyPoint) {
    Column({ space: 5 }) {
      Text(item.surveyPoint.length > 0 ? item.surveyPoint : '未命名调查点')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text(item.ethnicityName + ' · ' + item.languageName +
        (item.dialectName.length > 0 ? ' · ' + item.dialectName : ''))
        .fontSize(13)
        .fontColor(ACCENT)
      Text(item.provinceName + item.prefectureName + item.countyName + item.townshipName)
        .fontSize(12)
        .fontColor(MUTED)
      Text('坐标：' + item.coordinateStatus + ' · 来源：' + item.sourceId)
        .fontSize(11)
        .fontColor(MUTED)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(14)
    .border({ width: 1, color: $r('app.color.border') })
  }

  @Builder
  private emptySurveyPoints() {
    Column({ space: 8 }) {
      Text('当前没有已核验调查点')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text('目录中的区域范围只是来源摘要。只有来源、许可和坐标都核验后，才会进入生产地图。')
        .fontSize(13)
        .fontColor(MUTED)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(24)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private coverageRow(item: LanguageDirectoryCoverage) {
    Column({ space: 5 }) {
      Text(item.regionName)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(INK)
      Text(item.ethnicityName + ' · ' + item.languageName +
        (item.dialectName.length > 0 ? ' · ' + item.dialectName : ''))
        .fontSize(13)
        .fontColor(ACCENT)
      Text(item.coverageLevel + ' · 坐标：' + item.coordinateStatus)
        .fontSize(12)
        .fontColor(MUTED)
      Text('区域范围摘要，不是精确调查点或籍贯结论')
        .fontSize(11)
        .fontColor(MUTED)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.surface_elevated'))
    .borderRadius(14)
    .border({ width: 1, color: $r('app.color.border') })
  }

  private visibleVariants(): Array<LanguageDirectoryVariant> {
    const values = this.response?.variants ?? [];
    const q = this.query.trim();
    if (q.length === 0) return values;
    return values.filter((item: LanguageDirectoryVariant): boolean =>
      (item.ethnicityName + item.languageName + item.dialectName + item.regionScope).indexOf(q) >= 0
    );
  }

  private visibleEntities(): Array<LanguageDirectoryEntity> {
    const values = this.response?.entities ?? [];
    const q = this.query.trim();
    if (q.length === 0) return values;
    return values.filter((item: LanguageDirectoryEntity): boolean =>
      (item.ethnicityName + item.languageName + item.languageFamily + item.regionScope).indexOf(q) >= 0
    );
  }

  private visibleCoverage(): Array<LanguageDirectoryCoverage> {
    const values = this.response?.coverageScopes ?? [];
    const q = this.query.trim();
    if (q.length === 0) return values.slice(0, 120);
    return values.filter((item: LanguageDirectoryCoverage): boolean =>
      (item.ethnicityName + item.languageName + item.dialectName + item.regionName).indexOf(q) >= 0
    ).slice(0, 120);
  }

  private visibleSurveyPoints(): Array<LanguageDirectorySurveyPoint> {
    const values = this.response?.surveyPoints ?? [];
    const q = this.query.trim();
    if (q.length === 0) return values;
    return values.filter((item: LanguageDirectorySurveyPoint): boolean =>
      (item.ethnicityName + item.languageName + item.dialectName + item.surveyPoint +
        item.provinceName + item.prefectureName + item.countyName + item.townshipName).indexOf(q) >= 0
    );
  }

  private async loadDirectory(): Promise<void> {
    this.loading = true;
    this.errorMessage = '';
    try {
      this.response = await fetchLanguageDirectory();
    } catch (_error) {
      this.response = undefined;
      this.errorMessage = '目录服务尚未配置或暂时不可用，请稍后重试。';
    } finally {
      this.loading = false;
    }
  }
}
