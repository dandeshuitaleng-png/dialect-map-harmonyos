# 乡音地图 HarmonyOS Demo

乡音地图是一份可构建的 HarmonyOS 原生交互 Demo，核心流程为：

`全国乡音地图 → 模拟录音鉴定 → 点亮地区 → 生成乡音护照 → 查看同乡`

## 已实现

- 全屏全国乡音地图，本地图片呈现乡音点位与同乡数量。
- 地图拖动、双指缩放和恢复定位。
- 手机使用地图与底部面板；宽窗口自动切换地图与同乡列表分栏。
- Light/Dark 语义颜色资源、12fp 文字基线和 48vp 主要交互热区。
- 系统返回、键盘焦点提示、读屏标签和地图单按钮缩放替代。
- 可拖拽、折叠与展开的底部同乡面板。
- 附近同乡、推荐同乡、当前区域三类列表。
- 从同乡卡片进入对应乡音护照。
- 模拟录音、鉴定、点亮地区和生成当前用户护照。
- 护照身份、方言指标、代表语音演示、点亮地区和社交统计。
- 独立仓颉领域模型与边界测试草案。

## 演示能力边界

地图、位置、录音、方言鉴定和同乡数据均为本地模拟。应用没有申请麦克风或定位权限，不连接在线地图、AI 服务、后端或社交系统，也不保存真实录音与精确位置。

界面中的鉴定结果明确标注为模拟结果，不代表真实 AI 识别。分享与代表语音为交互演示，不会向外部发送数据。

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

构建产物为 `entry/build/default/outputs/default/entry-default-unsigned.hap`。工程未配置签名，因此该产物是 unsigned HAP；构建成功不等同于已安装或已在设备运行。

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

## 当前未验证

- Previewer 或真机上的手机、折叠宽窗、平板布局及手势表现。
- Dark 对比度、系统字体极限缩放、键鼠完整焦点链和读屏实测。
- 主 HAP 的签名、安装和启动。
- `ohosTest` 在设备上的实际执行。
- 仓颉领域层的编译与测试。
