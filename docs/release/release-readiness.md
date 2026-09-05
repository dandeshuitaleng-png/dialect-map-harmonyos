# 乡音地图 1.0.0 上架就绪清单

评审日期：2026-08-03
评审模式：`release_gate`
当前结论：`stopped_not_passed`——工程已进入发布候选收口并能生成 unsigned APP Pack，但尚不具备提交审核所需的正式签名、当前设备证据和外部合规材料。

## 已具备的工程证据

- [x] App 形态为手机 + 平板完整 HarmonyOS 应用。
- [x] `versionName=1.0.0`、`versionCode=1000000`、`debug=false`。
- [x] release 构建启用顶层混淆、压缩和日志移除。
- [x] 受跟踪工作树不再包含签名配置、证书路径或口令字段。
- [x] 麦克风和位置权限均由用户场景触发，拒绝后保留回退。
- [x] 原始录音不持久化、不上传；护照只保存地区和方言分类状态。
- [x] Map Kit 未就绪或失败时保留可拖动、缩放和选择的本地点位图，不把在线地图故障变成首页阻断。
- [x] 本机会话语音的录制、试听、发送、退出和屏蔽状态已互斥；消息保存失败会回滚对应音频。
- [x] 本机 PCM 体验语音仓库限制为最多 20 条、总计 32 MiB，并拒绝字节声明不一致的音频块。
- [x] 护照保存与清除已串行化，完成页等待保存落盘；分享图片资源在成功和失败路径均释放，清除护照时同步删除应用内分享图片缓存。
- [x] 虚构距离、成员数、关注数、假播放和假举报已从用户可见流程移除。
- [x] 预置人物、话题和消息持续标注为本机样例，不包装成真实社交服务。
- [x] 前景/背景双层 1024×1024 图标已生成；背景层不透明且未预裁系统圆角。
- [x] 隐私政策草案、上架文案、更新记录和回滚方案已建立。
- [x] clean 后的 `ohosTest` HAP 编译与 unsigned 打包成功，资源重名警告已消除；测试用例尚未在设备执行。
- [x] release 模式主 HAP 编译、混淆流程与 unsigned 打包成功。
- [x] `assembleApp` 成功生成 unsigned `.app` APP Pack，归档敏感字段扫描无命中。

## 当前产物

- `build/outputs/default/dialect-map-harmonyos-default-unsigned.app`
  SHA-256：`174146092f45f334f0aeb86f2d1e5be70730baf661a1c68735ceacf17e775462`
- `entry/build/default/outputs/default/entry-default-unsigned.hap`
  SHA-256：`6b7ffc386380741b12f90d31dc68cf7b42b3e3dce249f07794351fc2c721b59a`
- `entry/build/default/outputs/ohosTest/entry-ohosTest-unsigned.hap`
  SHA-256：`a17a414dbed75f8571272ee58084c45774a2938f4731f79045b65bb1a39868f2`

当前 `hdc list targets` 返回 `[Empty]`，因此本轮没有安装、运行、测试执行、操作或视觉证据。

## 发布前阻断项

- [ ] 在 AppGallery Connect 确认运营主体、应用登记、包名和 Map Kit capability。
- [ ] 轮换或撤销 Git 历史中曾暴露的调试签名材料；如需清理远端历史，另行审批破坏性历史重写。
- [ ] 由发布负责人配置正式 release 证书，将已验证的 unsigned 打包流程转换为可提交的签名 `.app` APP Pack。
- [ ] 补齐经法务确认的运营主体、联系邮箱、隐私政策公网 URL 和数据安全声明。
- [ ] 对十五个地点代表点的文字、定位页、第二人复核和出版授权边界完成内容审核。
- [ ] 在当前候选构建上执行测试 HAP 的实际测试，不以编译成功代替用例通过。
- [ ] 在目标手机和平板完成安装、启动、地图、权限拒绝/恢复、录音、试听、模拟鉴定、点亮、护照、分享和本机会话操作证据。
- [ ] 采集当前候选构建的手机和平板截图，验收 Light/Dark、大字体、读屏、截断和系统返回。
- [ ] 上传签名 APP Pack 后完成 AppGallery Connect 自动检查、人工审核反馈和最终版本核验。

## 证据边界

- unsigned HAP/APP Pack 构建成功不等于 APP Pack 已正式签名、安装或运行。
- 测试 HAP 编译成功不等于测试用例实际执行成功。
- 历史真机截图不能证明当前 1.0.0 候选构建。
- 只有上述阻断全部清除并完成当前产物复评，状态才能改为 `passed`。
