# 乡音地图 HarmonyOS Demo

乡音地图是一份可构建的 HarmonyOS 原生交互 Demo，核心流程为：

`全国乡音地图 → 模拟录音鉴定 → 点亮方言片区并留下地区足迹 → 生成乡音护照 → 查看同乡`

## 已实现

- 全屏 Map Kit 全国地图，呈现五个真实经纬度乡音点位与同乡数量。
- 支持地图拖动、双指缩放、比例尺和用户主动触发“我的位置”。
- Map Kit 初始化或点位加载失败时自动切换本地地图，避免空白页面。
- 手机使用地图与底部面板；宽窗口自动切换地图与同乡列表分栏。
- Light/Dark 语义颜色资源、12fp 文字基线和 48vp 主要交互热区。
- 系统返回、键盘焦点提示、读屏标签和地图单按钮缩放替代。
- 使用系统 HarmonyOS Sans；本地字体包仅作设计核对，不重复打包进 HAP。
- 可拖拽、折叠与展开的底部同乡面板。
- 附近同乡、推荐同乡、当前区域三类列表。
- 从同乡卡片进入对应乡音护照。
- 模拟录音、鉴定、点亮地区和生成当前用户护照。
- 护照身份、方言指标、代表语音演示、点亮地区和社交统计。
- 演示分类统一采用“方言大类 → 方言片区 → 地方口音 → 代表地区”，贯通地图、鉴定结果和乡音护照。
- 独立仓颉领域模型与边界测试草案。

## 演示能力边界

地图已接入 HarmonyOS Map Kit；工程声明联网权限，并只在用户点击“我的位置”后申请前台精确/模糊定位权限。拒绝或定位异常时仍可继续浏览地图，应用不记录或上传用户坐标。

Map Kit 已在真机完成在线地图、3D 地球、手势、定位允许和镜头居中验证。Map Kit 初始化或点位添加报告失败时仍会回退本地地图；定位拒绝与系统设置恢复分支尚待完整复验。

录音、方言鉴定和同乡数据仍为本地模拟。应用不申请麦克风权限，不连接 AI、后端或社交系统，也不保存真实录音。

界面中的鉴定结果明确标注为模拟结果，不代表真实 AI 识别。分享与代表语音为交互演示，不会向外部发送数据。

当前五个分类节点是产品演示数据，不是完整学术分类或语言能力证明。方言范围不等同于行政区划，例如粤语节点使用广州作为代表地区，不把广东整体视为单一粤语区。正式版本需要使用有明确来源与授权的语言地图资料，并表达核心区、过渡区、资料版本和争议边界。

## 工程结构

```text
AppScope/          应用配置与资源
entry/             ArkTS/ArkUI Stage 应用
cangjie-domain/    独立仓颉领域层草案
docs/              产品规格与验证记录
tasks/             实施计划与任务状态
```

HarmonyOS 完整 UX/UI、响应式、状态、Token 与 ArkUI 交付规格见
[docs/harmonyos-design-handoff.md](docs/harmonyos-design-handoff.md)。

## 构建 HarmonyOS HAP

在工程根目录执行：

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
NODE_HOME=/Applications/DevEco-Studio.app/Contents/tools/node \
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
assembleHap --no-daemon --stacktrace
```

默认构建产物位于 `entry/build/default/outputs/default/`。配置本机 DevEco debug 签名时会生成 `entry-default-signed.hap`；个人签名材料不应纳入版本库。当前 signed HAP 已在真机覆盖安装并启动。

测试 HAP 构建命令：

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
NODE_HOME=/Applications/DevEco-Studio.app/Contents/tools/node \
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
--mode module -p product=default -p module=entry@ohosTest \
-p buildMode=test assembleHap --no-daemon --stacktrace
```

测试被编译进 `entry-ohosTest-unsigned.hap`，但仍需连接设备后才能实际执行。

## 仓颉领域层

`cangjie-domain/` 遵循本机 CangjieSkills 的包、命名、不可变模型、`Option<T>` 和 `_test.cj` 约定。本机未安装 `cjc/cjpm`，因此仓颉代码尚未编译，也尚未接入 HAP。详情见 [cangjie-domain/README.md](cangjie-domain/README.md)。

## 当前未完整验证

- 手机、折叠宽窗、自由窗口和全部响应式断点。
- Dark 对比度、系统字体极限缩放、键鼠完整焦点链和读屏实测。
- 用户拒绝定位及系统设置恢复后的真机表现。
- `ohosTest` 在设备上的实际执行。
- 仓颉领域层的编译与测试。
