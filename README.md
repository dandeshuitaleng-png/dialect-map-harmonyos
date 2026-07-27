# 乡音地图 HarmonyOS Demo

乡音地图是一份可构建的 HarmonyOS 原生交互 Demo，核心流程为：

`全国乡音地图 → 发现同乡/乡音群聊 → 真实录音采集与模拟鉴定 → 点亮方言片区 → 生成乡音护照`

## 已实现

- 首页先显示可交互的本地全国地图与五个经纬度乡音点位，不等待在线服务。
- 本地底图与点位共用“经纬度 → 裁剪图像坐标”的仿射投影，缩放和平移时保持同一坐标平面。
- Map Kit 在后台连接；只有在线底图和 Marker 都成功加载后才接管，失败或超时继续使用本地地图。
- 本地地图支持拖动、双指/按钮缩放与复位；在线地图成功接管后提供比例尺和用户主动触发“我的位置”。
- 手机使用地图与底部面板；宽窗口自动切换地图与同乡列表分栏。
- 宣纸暖白与黛青品牌基线、Light/Dark 语义文字/填充 Token、细边框与微阴影层级，以及 48vp 主要交互热区。
- 系统返回、键盘焦点提示、读屏标签和地图单按钮缩放替代。
- 使用系统 HarmonyOS Sans；本地字体包仅作设计核对，不重复打包进 HAP。
- 可拖拽、折叠与展开的底部同乡面板。
- 同乡/乡音群聊固定一级切换；资料目录只作为内部数据参考，不占用用户导航。
- 群聊入口默认显示“会话”（已加入群组）；推荐和按方言作为发现入口，并显示群头像、最后消息、时间与本机会话状态。
- 点开会话进入消息流，区分演示消息与本人气泡；打开即在本次运行内记录已读。
- 未加入时输入区禁用并提示“加入后可发言”；加入/退出需要确认，退出后立即恢复禁用。
- 本人消息仅保存在本次应用运行的内存会话，不自动回复、不伪装服务器送达；单条最多 120 字，每群最多 100 条。
- 群聊输入使用 `KeyboardAvoidMode.RESIZE_WITH_CARET`，离开聊天页时恢复此前键盘避让模式。
- 附近同乡、推荐同乡、当前区域三类列表。
- 从同乡卡片进入对应乡音护照。
- 用户主动触发的真实麦克风采集、模拟鉴定、点亮地区和生成当前用户护照。
- 未完成鉴定或恢复到已保存护照前，不创建默认用户，也不开放“我的乡音护照”。
- 鉴定确认会写回领域状态；纠正结果会同步更换候选地域、识别依据与相似乡音。
- 护照身份、方言指标、代表语音演示、点亮地区和社交统计。
- 工程目标与最低兼容版本已升级到 HarmonyOS 6.0.0 / API 20。
- 已接入官方 `@kit.AgentFrameworkKit` 适配层；只有官方能力检查通过才显示小艺组件。
- 已配置用户提供的小艺开放平台 `agentId`，并校验 `agent` 前缀与标识格式。
- 已为 6 组用户提供资料建立内部来源目录，记录用途、限制、授权与复核状态，不在前台展示，也不打包原始出版物。
- 演示分类统一采用“方言大类 → 方言片区 → 地方口音 → 代表地区”，贯通地图、鉴定结果和乡音护照。
- 独立仓颉领域模型与边界测试草案。

## 演示能力边界

地图采用“本地先行、在线成功后接管”：页面进入时本地地图立即可用，Map Kit 在后台完成在线底图与 Marker 加载后才提升到前台。工程声明联网权限，并只在用户点击“我的位置”后申请前台精确/模糊定位权限。拒绝、定位异常或在线地图失败时仍可继续浏览本地地图，应用不记录或上传用户坐标。

旧应用身份曾在真机完成 Map Kit 在线地图、3D 地球、手势、定位允许和镜头居中验证。当前本机调试签名生成了新的应用身份，在线瓦片返回 `403 / no map permission`；组件会保持可拖动、双指/按钮缩放的本地地图，并提供在线重试。恢复在线瓦片仍需在平台为当前应用身份开通 Map Kit。

录音页会在用户点击“开始真实录音”后申请麦克风权限，瞬时读取 PCM
数据以验证真实采集，停止后立即释放，不写入文件、不上传。方言鉴定、
同乡和群聊数据仍为本地模拟，应用不连接社交后端。群聊的加入、已读
和本人消息只存在于本次应用运行的内存状态，重启后清空。

小艺入口使用官方 `AgentFrameworkKit` API，已写入用户提供的公开 `agentId`。
应用仍只会在支持设备上通过华为账号、隐私协议、网络和 `isAgentSupport`
检查后显示官方组件；当前仅完成配置与编译，不能据此声称小艺已在真机可用。

界面中的鉴定结果明确标注为模拟结果，不代表真实 AI 识别。分享与代表语音为交互演示，不会向外部发送数据。

当前五个分类节点是产品演示数据，不是完整学术分类或语言能力证明。方言范围不等同于行政区划，例如粤语节点使用广州作为代表地区，不把广东整体视为单一粤语区。正式版本需要使用有明确来源与授权的语言地图资料，并表达核心区、过渡区、资料版本和争议边界。

用户提供的方言资料当前只接入为 6 条内部来源元数据，包括地图集、语音/语法卷、
解释与通俗读物，以及《方言》2016—2026 期次索引。所有记录默认是
“授权待核验 / 资料入口 / 未打包原文”，不会出现在用户首页，不会自动升级
现有演示分类，也不会把扫描 PDF、EPUB、地图截图或受限论文全文复制进 HAP。

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

默认构建产物位于 `entry/build/default/outputs/default/`。受跟踪的
`build-profile.json5` 不包含个人签名路径或口令；默认命令生成 unsigned HAP。
需要安装调试时，应由 DevEco 在本机临时配置个人 debug 签名，并确保相关材料
不提交、不分享。

测试 HAP 构建命令：

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
NODE_HOME=/Applications/DevEco-Studio.app/Contents/tools/node \
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
--mode module -p product=default -p module=entry@ohosTest \
-p buildMode=test assembleHap --no-daemon --stacktrace
```

测试被编译进 `entry-ohosTest` HAP；是否签名取决于本机配置。测试 HAP 构建成功
不能代替安装到已解锁设备后的实际执行结果。

## 仓颉领域层

`cangjie-domain/` 遵循本机 CangjieSkills 的包、命名、不可变模型、`Option<T>` 和 `_test.cj` 约定。本机未安装 `cjc/cjpm`，因此仓颉代码尚未编译，也尚未接入 HAP。详情见 [cangjie-domain/README.md](cangjie-domain/README.md)。

## 当前未完整验证

- 手机、折叠宽窗、自由窗口和全部响应式断点。
- Dark 对比度、系统字体极限缩放、键鼠完整焦点链和读屏实测。
- 用户拒绝定位及系统设置恢复后的真机表现。
- 当前源码的分享预览/纠正面板系统返回层级、护照门控和 Map Marker 再次点亮刷新。
- 当前微信式会话列表、加入后发言门槛、打开即已读、100 条上限、键盘避让与系统返回仍需统一构建和真机复验。
- 当前设备的 `isAgentSupport` 返回不支持；仍需在计划支持的其他设备、账号和发布状态下复核小艺真实可用性。
- 方言资料的具体页码、版本年份、地图/调查点、授权与人工复核。
- 可替换演示分类的结构化方言数据；当前接入的是来源目录，不是方言数据库。
- 定位拒绝、系统设置恢复、全部自由窗口断点、Dark、大字体与完整读屏流程。
- 仓颉领域层的编译与测试。
