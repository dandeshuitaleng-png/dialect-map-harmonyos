import hmac
import os

import gradio as gr
import spaces
import torch
from qwen_asr import Qwen3ASRModel


MODEL_ID = os.getenv("MODEL_ID", "Qwen/Qwen3-ASR-0.6B")
SERVICE_TOKEN = os.getenv("SERVICE_TOKEN", "")

model = Qwen3ASRModel.from_pretrained(
    MODEL_ID,
    dtype=torch.bfloat16,
    device_map="cuda:0",
    max_inference_batch_size=1,
    max_new_tokens=512,
)


@spaces.GPU(duration=60)
def transcribe(audio_path: str | None, access_token: str) -> dict:
    """Return only fields that Qwen3-ASR actually produces."""
    if not SERVICE_TOKEN:
        raise gr.Error("Space 尚未配置 SERVICE_TOKEN。")
    if not hmac.compare_digest(access_token or "", SERVICE_TOKEN):
        raise gr.Error("服务令牌无效。")
    if not audio_path:
        raise gr.Error("请上传或录制音频。")

    results = model.transcribe(audio=audio_path, language=None)
    if not results:
        return {
            "transcript": "",
            "detected_language": "",
            "model_version": MODEL_ID,
            "confidence_available": False,
            "is_unknown": True,
        }

    result = results[0]
    transcript = (result.text or "").strip()
    detected_language = (result.language or "").strip()
    return {
        "transcript": transcript,
        "detected_language": detected_language,
        "model_version": MODEL_ID,
        "confidence_available": False,
        "is_unknown": not transcript or not detected_language,
    }


with gr.Blocks(title="乡音地图 · Qwen3-ASR") as demo:
    gr.Markdown(
        "# 乡音地图 · Qwen3-ASR\n"
        "开发测试服务：返回转写和模型检测标签，不提供未经校准的置信度。"
    )
    audio = gr.Audio(
        sources=["upload", "microphone"],
        type="filepath",
        label="上传或录制 2–15 秒乡音",
    )
    access_token = gr.Textbox(label="服务令牌", type="password")
    button = gr.Button("开始识别", variant="primary")
    output = gr.JSON(label="模型原始能力范围内的结果")
    button.click(
        fn=transcribe,
        inputs=[audio, access_token],
        outputs=output,
        api_name="transcribe",
    )

demo.queue(default_concurrency_limit=1).launch()
