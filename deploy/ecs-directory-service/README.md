# 阿里云 ECS 部署

本目录包含可部署到阿里云 ECS 的语言目录、华为帐号会话、文字方言识别及语音方言评测服务。应用端调用
`GET /v1/language-directory`，并调用 `POST /v1/dialect-ai`、`POST /v1/dialect-voice-assess` 和
`POST /functions/v1/huawei-login`。

部署前，将本目录复制到 `/opt/xiangyin-directory`，安装 systemd 单元后执行：

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now xiangyin-directory
```

生产环境应在 Nginx 或 API Gateway 后提供 HTTPS，并把 `app.py` 的监听地址保留在
`127.0.0.1`。AI 鉴定、语音鉴定和每日挑战可用同一个域名分别实现
`/v1/dialect-ai`、`/v1/dialect-voice-assess` 和 `/v1/daily-dialect-challenge`；密钥仅保存在
阿里云服务端环境变量中。

## AI 与语音环境变量

文字鉴定沿用原 Supabase Edge Function 的 DeepSeek 模型；语音鉴定先将鸿蒙端 16 kHz 单声道
PCM 转交原 STT 服务，再用同一文字鉴定链路返回目录候选。将下列值仅写入 ECS 的
`/etc/xiangyin-directory.env`，不要放入 HAP、Git 或部署压缩包：

```ini
DEEPSEEK_API_KEY=原 Supabase Edge Function 使用的值
STT_ENDPOINT=原 Supabase Edge Function 使用的转写接口
STT_API_KEY=原 Supabase Edge Function 使用的转写密钥
STT_MODEL=原 Supabase Edge Function 使用的模型名（未填时为 whisper-1）
```

## 华为帐号登录

客户端仅上报华为帐号组件返回的 `authorizationCode`。服务端使用 AppGallery Connect
的 OAuth 2.0 Client ID 与 Client Secret 向华为帐号服务换取 ID Token，然后签发本服务
的 7 天会话 JWT。不要把 Client Secret、会话签名密钥或华为 Access Token 写入应用源码。

在 ECS 创建权限为 `600` 的 `/etc/xiangyin-directory.env`：

```ini
HUAWEI_OAUTH_CLIENT_ID=从 AppGallery Connect 项目设置获取
HUAWEI_OAUTH_CLIENT_SECRET=从 AppGallery Connect 项目设置获取
HUAWEI_OAUTH_REDIRECT_URI=与华为帐号授权配置完全一致的回调地址
XIANGYIN_SESSION_SIGNING_KEY=至少 32 个随机字符
```

配置后执行 `sudo systemctl daemon-reload && sudo systemctl restart xiangyin-directory`。
应用不会在服务端配置完成前把本地 OpenID 当作已登录身份。
