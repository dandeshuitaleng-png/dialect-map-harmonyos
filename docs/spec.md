# 规格：乡音地图 HarmonyOS App

## 1. 目标

为 HarmonyOS 构建一个可运行、可演示的原生应用，形成以下闭环：

`全国乡音地图 → 录音鉴定 → 点亮地区 → 生成乡音护照 → 查看同乡`

目标用户是希望记录家乡口音、发现同乡并分享乡音身份的普通用户。

首版成功标准：

- 首页以全国地图为主视觉，本地地图立即可用；Map Kit 只有在在线底图与 Marker 都加载成功后才接管。
- 地图展示乡音点位与同乡分布。
- 本地底图和点位共用经纬度到裁剪图像坐标的投影，不再分别维护视觉比例坐标。
- 底部信息面板支持折叠与展开，展示附近、推荐和当前区域用户。
- 用户可以从微信式会话列表进入乡音群聊；加入后可发送只保留于本次运行的本人消息。
- 用户可以主动授权真实麦克风采集；音频不持久化、不上传，鉴定数据明确标注为模拟结果。
- 用户确认或纠正鉴定结果后，领域对象进入已确认状态，再点亮地区并生成乡音护照。
- 未完成鉴定且没有已保存护照时，不展示默认当前用户护照。
- 用户可以从首页同乡列表进入乡音护照。
- 项目通过当前 DevEco/Hvigor 静态构建验证。

## 2. 首版范围

### 2.1 首页：全国乡音地图

- 全屏地图主视觉。
- 乡音点位和同乡数量。
- 地图拖动、缩放、恢复定位。
- 可拖拽底部信息面板。
- 信息面板包含：
  - 附近同乡
  - 推荐同乡
  - 当前区域用户
  - 乡音群聊会话列表
- 录音鉴定主入口。
- 点击用户进入乡音护照。

### 2.2 录音鉴定

- 开始录音、录音中、完成录音三个状态。
- 点击开始录音后场景化申请麦克风权限；拒绝或系统麦克风关闭时保留可恢复说明。
- PCM 音频仅在内存中瞬时读取，停止、离页或失败后释放，不写文件、不上传。
- 地区与方言确认。
- 模拟鉴定进度。
- 输出模拟鉴定结果：
  - 方言归属
  - 鉴定置信度
  - 乡音保留度
- 明确显示“演示结果，不代表真实 AI 鉴定”。
- 点亮对应地区并生成当前用户乡音护照。

### 2.3 乡音护照

- 头像、昵称、所在地。
- 方言归属。
- 鉴定置信度。
- 乡音保留度。
- 代表语音播放状态。
- 已点亮地区。
- 同乡好友、关注、被关注。
- 分享个人乡音名片入口。

护照可用性规则：

- 首次安装且未鉴定时，“我的乡音护照”保持禁用并说明需先鉴定。
- 本地 Preferences 恢复成功，或本次鉴定确认完成后，才创建当前用户护照。
- 分享预览、鉴定纠正面板、鉴定页和护照页按层级响应系统返回。

## 3. 非首版范围

- 权威方言区矢量边界、过渡区表达、资料版本和使用授权。
- 基于真实位置的同乡匹配、精确地理位置上传和位置历史。
- 真实录音文件持久化和云端存储；当前只做瞬时麦克风采集。
- 真实 AI 方言识别模型或远程推理接口。
- 账号、登录、真实成员关系、通知、跨设备同步和社交后端；当前群聊仅为本次运行内存演示。
- 生产级隐私授权、内容审核和举报系统。
- 应用市场签名、发布和上架。

## 4. 技术栈

### HarmonyOS 界面层

- ArkTS
- ArkUI
- Stage 模型
- DevEco Studio 自带 Hvigor
- 当前已安装 OpenHarmony/HMS SDK

### 仓颉能力层

遵循本机 CangjieSkills：

- `cangjie-lang-features`：语言特性、Option、枚举、集合和错误处理。
- `cangjie-regulations`：包结构、命名、格式、测试和安全边界。
- `cangjie-std`：集合、时间、I/O 与单元测试。
- `cangjie-stdx`：后续 JSON、HTTP、日志和安全通信。
- `cangjie-toolchains`：`cjpm`、`cjfmt`、`cjlint`、`cjcov`。
- `cangjie-original-docs`：其他技能无法覆盖时回查原始文档。

当前机器未安装 `cjc` 和 `cjpm`，因此仓颉代码只能先按契约设计，不能声称已编译或已接入 HarmonyOS UI。

## 5. 命令

### 当前可执行

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
NODE_HOME=/Applications/DevEco-Studio.app/Contents/tools/node \
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
assembleHap --no-daemon --stacktrace
```

### 安装仓颉工具链后执行

```bash
cjpm build
cjfmt -d src/
cjlint -f src/
cjpm test
```

## 6. 项目结构

```text
dialect-map-harmonyos/
├── AppScope/                       # HarmonyOS 应用配置与资源
├── entry/
│   └── src/main/
│       ├── ets/
│       │   ├── pages/              # 首页、鉴定、乡音护照
│       │   ├── components/         # 地图点位、抽屉、用户卡片
│       │   ├── models/             # ArkTS 展示模型
│       │   ├── services/           # 地图接入、模拟鉴定和同乡数据
│       │   └── entryability/       # UIAbility
│       └── resources/
├── cangjie-domain/                 # 仓颉领域层，工具链到位后编译
│   ├── cjpm.toml
│   ├── src/
│   │   ├── dialect/                # 方言与鉴定领域模型
│   │   └── passport/               # 乡音护照领域模型
│   └── src/**/**/*_test.cj          # 与被测文件同包的单元测试
├── docs/
│   └── spec.md
└── tasks/
```

## 7. 代码风格

ArkTS 界面模型采用明确、不可变的领域字段：

```ts
export interface DialectProfile {
  readonly dialectName: string
  readonly confidence: number
  readonly retention: number
  readonly litRegions: ReadonlyArray<string>
}
```

仓颉代码遵循 CangjieSkills 规范：

```cangjie
package dialect_domain.dialect

public struct DialectAssessment {
    public let dialectName: String
    public let confidence: Int64
    public let retention: Int64
}
```

- 类型使用 PascalCase。
- 函数与变量使用 camelCase。
- 仓颉文件使用小写下划线命名。
- 优先不可变 `let`，仅在必要时使用 `var`。
- 预期无值使用 `Option<T>`，异常不作为正常控制流。

## 8. 测试策略

- ArkTS：
  - Hvigor 编译作为每个增量的最低门槛。
  - 领域服务提供确定性模拟数据，便于页面状态验证。
  - 对鉴定结果范围、地区点亮和护照生成编写单元测试。
  - 对确认状态、纠正后分类字段和模拟详情一致性编写回归测试。
- 仓颉：
  - 工具链到位后使用 `std.unittest`。
  - 模型与服务测试文件使用 `xxx_test.cj`。
  - 目标分支覆盖率不低于 80%。
- 运行验证：
  - 构建成功与真机/模拟器运行分开报告。
  - 未安装签名 HAP、未在设备启动时，不声称“已经运行”。

## 9. 边界

### 始终执行

- 用户输入和百分比分数做范围校验。
- 真实能力与模拟能力在 UI 和文档中明确区分。
- 每个功能增量后执行构建或对应测试。
- 不在日志中记录录音内容、精确位置或其他敏感数据。

### 需要先询问

- 新增或替换地图/AI 等外部服务、引入 Token，或扩大当前 Map Kit capability。
- 请求麦克风、精确位置、通讯录等敏感权限。
- 新增服务端、数据库或云存储。
- 修改应用签名与发布配置。

### 绝不执行

- 硬编码密钥、Token 或用户隐私数据。
- 将模拟鉴定描述为真实 AI 结果。
- 将仓颉 OpenHarmony 交叉编译能力描述为 ArkUI/Ability 原生支持。
- 未经验证声称 HAP 已安装或应用已在设备运行。

## 10. 待确认问题

当前已确认基线：

1. 地图使用 Map Kit 并保留本地兜底；方言鉴定和同乡数据仍为本地模拟。
2. 当前交付目标是可构建的 HarmonyOS 原生 Demo，不等同于发布级应用。
3. ArkTS UI 与未编译的仓颉领域层保持分离。

## 11. 当前增量草案：质感、群组、小艺与真实数据

> 状态：用户已确认升级到 HarmonyOS 6.0.0 / API 20。群组仍是本机演示；小艺已配置 `agentId` 但未完成真机能力验证；用户资料只接入来源目录，尚不是正式方言数据库。

### 11.1 视觉命题

当前视觉命题为“宣纸上的乡音聚落”：

- 全国地图继续是首页视觉主角，不改造成通用信息流首页。
- 宣纸暖白作为页面与地图基底，黛青承担品牌强调与主操作，低饱和土色只用于少量头像和乡土记忆提示。
- 首页、群聊和护照共享同一套 Light/Dark 语义文字/填充 Token、4/8vp 间距体系、字体层级与圆角层级。
- 交互热区不小于 48×48vp，尺寸使用 vp，字体使用 fp；大字体允许换行和容器增高。
- 减少同层卡片套卡片、重阴影和裸色值；内容面以细边框和微阴影区分层级，文字色与填充色使用不同语义 Token。
- 小艺是辅助入口，不替代地图、同乡、群组和护照的固定导航。

视觉验收：

- 地图、面板、群聊和护照在 Light/Dark 下语义一致。
- 手机竖屏保持底部面板；横屏大窗口使用地图 + 侧栏，不机械放大手机布局。
- 默认、按压、选中、焦点、禁用、加载、空和错误状态均有可辨识反馈。
- 无真实截图或运行证据时，只能报告静态实现与构建结果，不声称视觉验收通过。

### 11.2 乡音群聊本地闭环

乡音群聊围绕地区、方言和共同记忆建立，当前形成以下本次运行演示闭环：

`地图同乡面板 → 切换乡音群聊 → 浏览会话列表 → 打开即已读 → 确认加入 → 本机发送消息`

包含：

- 微信式会话列表：默认“会话”展示已加入群组；推荐和按方言作为发现入口。列表显示群头像、群名、最后消息、时间，以及演示未读或本机状态。
- 群聊消息流：时间分隔、示例发送者、本人气泡、输入框和发送按钮；不再以推荐重点卡、群组介绍页或只读话题卡作为主界面。
- 加入/退出：必须二次确认。未加入和退出后输入区禁用并提示“加入后可发言”，加入后恢复。
- 已读状态：打开群聊时在 session `lastReadMessageId` 中记录已读，返回会话列表后清除对应演示未读角标。
- 输入合同：空白拒绝；单条最多 120 字；每群最多保存 100 条本人消息，达到上限后提示“本机会话已满”并禁用继续发送。
- 键盘避让：聊天页进入时保存原模式并使用 `KeyboardAvoidMode.RESIZE_WITH_CARET`，离开时恢复，避免标题栏整体上移。
- 数据边界：示例消息持续标注“演示”；本人消息仅保留到本次应用运行结束，不自动回复，不伪装服务器送达。

不包含：

- 注册登录、真实成员关系、私聊、通知、离线推送和服务端同步。
- 服务端发帖、评论、审核、举报、封禁和内容推荐。
- 精确位置、通讯录匹配、原始录音上传或真实用户资料。

### 11.3 小艺接入合同

当前本机 SDK 证据：

- 已安装 SDK 为 HarmonyOS 6.1.1 / API 24。
- `@kit.AgentFrameworkKit` 与 `FunctionComponent` 自 HarmonyOS 6.0.0 / API 20 提供。
- `AgentController.isAgentSupport(context, agentId)` 可检查应用、设备和指定智能体是否支持。
- 支持检查可能因参数、隐私协议、华为账号、网络或内部错误失败。
- 工程原目标为 HarmonyOS 5.0.0 / API 12；用户确认后，目标与最低兼容版本均已升级为 HarmonyOS 6.0.0 / API 20，官方组件已通过 ArkTS 编译。

证据来源：

- 本机 SDK：`hms/ets/api/@hms.ai.AgentFramework.d.ets` 与 `hms/ets/kits/@kit.AgentFrameworkKit.d.ts`。
- 华为官方最佳实践：[智能体场景开发案例](https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-agent)。

真实接入前置条件：

1. 用户已确认将目标 SDK 与最低兼容版本升级到 HarmonyOS 6.0.0 / API 20。
2. 在小艺开放平台创建、编排并测试乡音地图智能体，提供非秘密的 `agentId`。当前已配置用户提供的 `agent67ed6c01203b437db99567238ebdc976`。
3. 在支持设备上登录华为账号、接受相关隐私协议并完成白名单/上架状态验证。
4. 通过 `isAgentSupport` 后才展示可用的 `FunctionComponent`；不支持时展示明确原因和重试入口。

小艺首版允许场景：

- 解释方言与地区术语。
- 根据用户选择的地区、方言和兴趣推荐群组。
- 整理、概括用户后续导入且已校验的数据。

安全与交互：

- `queryText` 只传递完成任务所需的最小上下文，不包含精确位置、原始录音、Token 或其他用户隐私。
- AI 输出视为不可信内容；进入 UI 前做长度、类型、枚举和空值校验。
- AI 不直接执行加入群组、退出群组、发布内容或修改护照；所有副作用必须回到固定 UI 并由用户确认。
- 缺少 `agentId`、API 版本不足、设备不支持或服务不可用时，状态为“能力待配置/当前设备不可用”，不生成本地假回复。

### 11.4 真实数据适配合同

后续收到可替换业务模型的结构化数据时，先建立接口和校验层，不把占位数据标为真实数据。首批建议支持 JSON；字段合同如下：

```ts
interface DataEnvelope<T> {
  readonly schemaVersion: '1.0';
  readonly sourceName: string;
  readonly updatedAt: string;
  readonly items: ReadonlyArray<T>;
}

interface GroupRecord {
  readonly id: string;
  readonly name: string;
  readonly regionName: string;
  readonly dialectName: string;
  readonly summary: string;
  readonly memberCount: number;
  readonly activeLabel: string;
  readonly rules: ReadonlyArray<string>;
  readonly recentTopics: ReadonlyArray<string>;
}
```

导入要求：

- `id` 在同一数据集中唯一，字符串去除首尾空白后不得为空。
- `memberCount` 为非负整数；列表设置数量和单字段长度上限，避免无界渲染。
- 未知字段默认忽略，缺少必需字段则整条拒绝并给出可定位错误。
- `sourceName`、`updatedAt` 和“演示/真实”状态必须在内部导入报告中可追溯；研究资料依据不作为前台页面或导航入口。
- 若数据包含姓名、联系方式、精确地址、录音或其他个人信息，导入前需另行确认脱敏与授权边界。

当前用户提供的 `/Users/bjl/Desktop/方言/` 是研究资料集合，不是可直接替换
业务模型的结构化方言数据库。本增量只把索引中的 6 类资料接入内部
`DialectSourceRecord` 目录，不把“资料依据”作为前台页面：

- 保留题名、作者/机构、版本、类型、用途、限制、授权状态和复核状态。
- 所有记录默认 `PENDING_REVIEW + CATALOG_ENTRY + packagedContent=false`。
- 只有授权已核验且达到 `PRODUCT_READY` 的记录，才允许进入正式产品数据。
- 不把本机绝对路径写进 HAP，不复制扫描 PDF、EPUB、地图截图或受限论文全文。
- 当前分类、鉴定、同乡和群组继续显示为演示能力。

### 11.5 本增量完成标准

- 规格经用户确认。
- 视觉 Token、首页信息架构、群聊模型/内存服务、会话列表和消息流保持同一契约。
- 小艺适配层能区分未配置、检查中、不支持、可用和错误；已配置的 `agentId` 仍需设备能力检查。
- 方言资料目录在内部记录授权、复核和未打包原文状态；它不替代后续结构化数据适配器，也不占用用户导航。
- 每个增量后通过相应 ArkTS 测试编译和主 HAP 构建；设备运行结果另行报告。
