---
title: Xiangyin Qwen3 ASR
emoji: 🎙️
colorFrom: green
colorTo: blue
sdk: gradio
sdk_version: 5.49.1
app_file: app.py
pinned: false
python_version: "3.12"
suggested_hardware: zero-a10g
---

# 乡音地图 Qwen3-ASR 测试服务

这是“乡音地图”的开发测试声学入口，使用 `Qwen/Qwen3-ASR-0.6B`。

它只返回模型实际提供的转写文字与语言/方言标签。Qwen3-ASR 的公开
`ASRTranscription` 不包含校准置信度，因此这里不会制造置信度，也不会直接
把省级口音标签冒充为 186 个地图代表点中的某一个。

在 Space 的 Settings 中：

1. 将 Hardware 设为 ZeroGPU。
2. 新增 Secret：`SERVICE_TOKEN`，使用至少 32 个随机字符。
3. 仅允许阿里云服务端调用该 Space，不要把 Secret 写入鸿蒙应用。
