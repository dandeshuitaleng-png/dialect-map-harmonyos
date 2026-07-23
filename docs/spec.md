# 规格：乡音地图 HarmonyOS App

## 1. 目标

为 HarmonyOS 构建一个可运行、可演示的原生应用，形成以下闭环：

`全国乡音地图 → 录音鉴定 → 点亮地区 → 生成乡音护照 → 查看同乡`

目标用户是希望记录家乡口音、发现同乡并分享乡音身份的普通用户。

首版成功标准：

- 首页以全国乡音地图为主视觉，支持模拟拖动、缩放和定位。
- 地图展示乡音点位与同乡分布。
- 底部信息面板支持折叠与展开，展示附近、推荐和当前区域用户。
- 用户可以进入录音鉴定流程并获得明确标注为模拟结果的鉴定数据。
- 鉴定完成后点亮地区并生成乡音护照。
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
- 录音鉴定主入口。
- 点击用户进入乡音护照。

### 2.2 录音鉴定

- 开始录音、录音中、完成录音三个状态。
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

## 3. 非首版范围

- 真实地图服务、地图 Token 和在线瓦片。
- 真实定位权限与精确地理位置上传。
- 真实录音文件持久化和云端存储。
- 真实 AI 方言识别模型或远程推理接口。
- 账号、登录、关注关系和社交后端。
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
│       │   ├── services/           # 模拟地图、鉴定和同乡数据
│       │   └── entryability/       # UIAbility
│       └── resources/
├── cangjie-domain/                 # 仓颉领域层，工具链到位后编译
│   ├── cjpm.toml
│   ├── src/
│   │   ├── dialect/                # 方言与鉴定领域模型
│   │   └── passport/               # 乡音护照领域模型
│   └── tests/
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
package dialect

public struct DialectAssessment {
    public let dialectName: String
    public let confidence: UInt8
    public let retention: UInt8
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

- 引入在线地图 SDK、AI 服务或任何需要 Token 的第三方依赖。
- 请求麦克风、精确位置、通讯录等敏感权限。
- 新增服务端、数据库或云存储。
- 修改应用签名与发布配置。

### 绝不执行

- 硬编码密钥、Token 或用户隐私数据。
- 将模拟鉴定描述为真实 AI 结果。
- 将仓颉 OpenHarmony 交叉编译能力描述为 ArkUI/Ability 原生支持。
- 未经验证声称 HAP 已安装或应用已在设备运行。

## 10. 待确认问题

1. 首版是否接受地图、鉴定和同乡数据全部使用本地模拟数据？
2. 首版是否以“可构建的 HarmonyOS 原生 Demo”为交付目标？
3. 是否接受 ArkTS UI 与待安装工具链的仓颉领域层分离？

