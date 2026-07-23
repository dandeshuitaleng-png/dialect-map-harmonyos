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

## 仓颉状态

本机未检测到 `cjc` 或 `cjpm`。`cangjie-domain/` 已完成结构与静态检查，但尚未由仓颉编译器编译，也未运行仓颉单元测试。
