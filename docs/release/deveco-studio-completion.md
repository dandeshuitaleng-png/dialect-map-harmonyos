# DevEco Studio 配置与发布完成清单

更新日期：2026-08-12
工程：`com.dialectmap.app` / `1.0.0 (1000000)`

## 已在本机完成的工程配置

- DevEco Studio SDK 目录可用：`/Applications/DevEco-Studio.app/Contents/sdk`。
- 项目使用 Stage 模型，`entry` 模块面向 `phone`、`tablet`。
- 项目目标 SDK 为 `6.1.1(24)`，最低兼容 SDK 为 `6.1.0(23)`；应用运行时为 HarmonyOS。
- 已声明互联网、网络状态、定位和麦克风权限；定位和麦克风均限制为 Ability 使用期间。
- `com.dialectmap.app` 已声明 Map Kit 等 capability；发布前必须在 AppGallery Connect 中再次确认同一包名已获对应能力授权。
- release 构建已启用 ArkTS 混淆规则：`entry/obfuscation-rules.txt`。
- 个人签名材料不写入受跟踪工程。`.gitignore` 已忽略 `local.properties`、构建目录和 HAP/APP 产物。

## 本次构建结果

在工程根目录执行的命令：

```bash
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk \
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home \
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node \
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw.js \
clean assembleApp -p buildMode=release --no-daemon --stacktrace
```

结果：`BUILD SUCCESSFUL`。因工程内没有签名配置，产物为 unsigned，不能安装到设备或提交审核。

| 产物 | SHA-256 |
| --- | --- |
| `build/outputs/default/dialect-map-harmonyos-default-unsigned.app` | `ac7aafdab1d44d9aaec128c71c620f566dac287c61fe1168317f734def4d089c` |
| `entry/build/default/outputs/default/entry-default-unsigned.hap` | `ca039124f19f575a4ffe1810e0eb613f39158911c146dd4630a69c23d3c81e88` |
| `entry/build/default/outputs/ohosTest/entry-ohosTest-unsigned.hap` | `9c7ac23e7700e9a997af5ad23f5cb92cbc71c76d5d90043f904d223cbcf32657` |

`ohosTest` 模块也已通过 Hvigor 编译和打包。ArkTS 对目录和每日挑战服务中的网络调用仍可能给出“函数可能抛出异常”警告；这次构建未失败，但应在正式发布前逐项处理或确认其已由调用边界安全接收。

## 必须由账号持有人在 DevEco Studio 完成的签名

签名材料属于个人或组织账号，不能由源码自动补齐，也不应提交到 Git。

1. 在 AppGallery Connect 创建或核对应用，包名必须是 `com.dialectmap.app`，并确认 Map Kit capability。
2. 为调试创建 debug 证书和 debug profile；为上架创建独立的 release 证书和 release profile。不要复用 debug 证书发布。
3. 在 DevEco Studio 打开工程，选择 **File > Project Structure > Project > Signing Configs**。
4. 新建 `debug` 签名（可选择自动签名）用于设备调试；新建 `release` 签名并导入组织的 `.p12`、`.cer`、`.p7b` 用于上架。
5. 将 debug/release 分别关联到产品 `default` 的对应构建模式，Sync Project 后用 Build 菜单构建。
6. 检查生成路径中的 HAP/APP 不再带 `unsigned`；仅将签名后的 `.app` 上传至 AppGallery Connect。

签名会在 `build-profile.json5` 生成敏感字段。若 DevEco 将它写进受跟踪文件，构建后立刻将该改动撤出提交范围，或将签名配置留在 IDE 的本机配置中；不得提交 `.p12`、`.cer`、`.p7b`、口令或证书指纹之外的私密材料。

## 真机调试与验收

当前 `hdc list targets` 返回 `[Empty]`，故本次不能安装或执行设备测试。

1. 在手机/平板开启开发者模式和 USB 调试，使用数据线连接并在设备上接受调试授权。
2. 重新打开 DevEco Studio，选择设备和 `debug` 构建模式，点击 Run。也可使用 `hdc list targets` 确认连接。
3. 安装主 HAP 后再安装 `entry-ohosTest` HAP，并在 DevEco 的测试面板运行 Hypium 测试；不要把“测试 HAP 能打包”当成“测试已通过”。
4. 在手机及平板分别验收：首次启动、定位拒绝/重新授权、麦克风拒绝、录音、试听、鉴定、护照保存/清除/分享、地图离线兜底、群聊加入/退出/键盘避让、Light/Dark、大字体、读屏、系统返回。
5. 对小艺入口在计划支持的设备、华为账号、网络和协议状态下重新验证；`isAgentSupport` 不通过时应保持当前降级状态。

## 上架前外部阻断

- AppGallery Connect 的运营主体、联系邮箱、隐私政策公网 URL、数据安全声明和内容分级。
- Map Kit capability、包名、release 证书指纹及 release profile 的一致性。
- 地点资料的第二人复核、页码定位和出版授权边界。
- 签名 APP Pack 上传后的平台自动检查和人工审核反馈。
- 如 Git 历史曾暴露调试签名材料，先轮换或撤销材料；任何历史重写需单独授权。

参考官方说明：[应用签名配置](https://developer.huawei.com/consumer/en/doc/development/hmscore-common-Guides/harmony-signature-info-0000001167185654)、[build-profile.json5](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-hvigor-build-profile-V5)、[通过 hdc 安装应用包](https://developer.huawei.com/consumer/cn/doc/doccenter-deveco-studio/ide-emulator-install-upload)。
