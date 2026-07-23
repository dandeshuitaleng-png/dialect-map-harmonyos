# 验证记录

验证日期：2026-07-23

## 能力边界检查

- `entry/src/main/module.json5` 只声明 Map Kit 联网所需的 `INTERNET`、`GET_NETWORK_INFO`，以及前台 `LOCATION`、`APPROXIMATELY_LOCATION`。
- 定位权限只在用户点击“我的位置”后动态申请；拒绝或异常不阻断地图，同一次运行不循环请求。
- 应用未声明麦克风权限，不记录或上传用户坐标。
- `build-profile.json5` 未配置签名。
- Map Kit 地图、手势、四个经纬度 Marker 与本地地图兜底已通过 ArkTS 编译；AGC 开通、应用身份、证书/Profile、签名与设备鉴权未验证。
- 录音、鉴定和同乡数据仍为本地模拟。
- 未硬编码 Client ID、Token、API Key、证书指纹、AI API、后端地址或用户隐私数据。

## 构建状态

- 主 HAP：Hvigor `BUILD SUCCESSFUL`。
  - 路径：`entry/build/default/outputs/default/entry-default-unsigned.hap`
  - 大小：2,626,228 bytes
  - SHA-256：`2e428e290e4449d7979f18119bfa03d1dc96b0063998ec9c66392187ab481584`
- `ohosTest` HAP：Hvigor `BUILD SUCCESSFUL`。
  - 路径：`entry/build/default/outputs/ohosTest/entry-ohosTest-unsigned.hap`
  - 大小：3,622,353 bytes
  - SHA-256：`9cb0a49ec4e1815c1061ad21a390ff74467bf9ca184fb9db5b8584fed19aebed`
- 两个产物均因未配置 `signingConfigs` 而跳过签名。
- `ohosTest` 仅完成编译打包，尚未在设备执行。

## 运行状态

当前未发现已连接的 HDC 目标，因此尚无 Previewer 或设备运行证据。构建成功只证明工程可被当前 Hvigor/SDK 编译打包，不能证明 Map Kit 已通过在线鉴权或定位已在真机工作。

## 可信鉴定与持久化增量

- 模拟鉴定结果现包含方言大区、分支、候选地域、识别依据和相似乡音。
- 用户必须确认结果、选择纠正结果或重新录制，未经确认不能点亮地区。
- Preferences 只保存地区、方言和分支，不保存原始录音或精确位置。
- 读取或写入异常会降级为当前会话状态，不阻断鉴定和护照流程。
- 地图点位增加独立“已点亮”图标；本地兜底地图同时显示文字状态。
- 主 HAP 与 `ohosTest` HAP 已通过 Hvigor 编译；确认、纠正、重启恢复和点亮图标仍待真机验证。

## 2026-07-23 真机面板复验

- 设备 `2PN6R24402004396` 成功安装并启动 `com.dialectmap.app` 0.1.0。
- 包管理信息确认应用为 HarmonyOS Stage 模型、debug provision，目标与兼容版本为 5.0.0(12)。
- Map Kit 3D 地球、四个乡音点位和“我的位置”入口已在真机显示。
- 同乡面板紧凑态约 220vp，真机截图未再出现原42%收起态的大面积空白。
- 通过设备输入完成紧凑态向上拖动、充分展开向下拖动，两个方向均成功吸附。
- 从同乡入口打开乡音护照成功，系统返回可回到地图。
- 首次位置权限弹窗真实显示用途说明及允许/不允许选项；选择“仅使用期间允许”后 HDC 断开，定位结果回调与镜头居中仍未形成最终证据。

## 仓颉状态

本机未检测到 `cjc` 或 `cjpm`。`cangjie-domain/` 已完成结构与静态检查，但尚未由仓颉编译器编译，也未运行仓颉单元测试。
