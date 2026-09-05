import { audio } from '@kit.AudioKit';
import { LocalVoiceClip } from './LocalCommunityVoiceService';
import { AudioCaptureSummary } from './AudioCaptureQualityService';

const SAMPLE_RATE: number = 16000;
const PCM_MAX_SAMPLE: number = 32768;
const ACTIVE_SAMPLE_THRESHOLD: number = 512;
const CLIPPED_SAMPLE_THRESHOLD: number = 32440;

export class TransientAudioCaptureService {
  private capturer?: audio.AudioCapturer;
  private renderer?: audio.AudioRenderer;
  private stopOperation?: Promise<number>;
  private playbackWriteListener?: audio.AudioRendererWriteDataCallback;
  private playbackCompletion?: () => void;
  private capturedBytes: number = 0;
  private chunks: Array<ArrayBuffer> = [];
  private sampleCount: number = 0;
  private sampleSquareSum: number = 0;
  private peakSample: number = 0;
  private activeSampleCount: number = 0;
  private clippedSampleCount: number = 0;
  private amplitudeListener: (amplitude: number) => void =
    (_amplitude: number): void => {};
  private interruptionListener: () => void = (): void => {};
  private readonly onAudioInterrupt = (event: audio.InterruptEvent): void => {
    if (event.eventType === audio.InterruptType.INTERRUPT_TYPE_BEGIN) {
      this.interruptionListener();
    }
  };
  private readonly onReadData = (buffer: ArrayBuffer): void => {
    this.capturedBytes += buffer.byteLength;
    // PCM 只在调用方当前页面的内存中保留；时长上限由具体页面控制。
    this.chunks.push(buffer.slice(0));
    this.amplitudeListener(this.observeSamples(buffer));
  };

  setAmplitudeListener(listener: (amplitude: number) => void): void {
    this.amplitudeListener = listener;
  }

  setInterruptionListener(listener: () => void): void {
    this.interruptionListener = listener;
  }

  async start(): Promise<void> {
    await this.release();
    const options: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_VOICE_RECOGNITION,
        capturerFlags: 0
      }
    };
    const capturer = await audio.createAudioCapturer(options);
    try {
      capturer.on('readData', this.onReadData);
      capturer.on('audioInterrupt', this.onAudioInterrupt);
    } catch (_error) {
      try {
        await capturer.release();
      } catch (_releaseError) {
        // The capturer was not published to the service, so no retained state remains.
      }
      throw new Error('Unable to register the transient audio read listener');
    }
    this.resetCaptureData();
    this.capturer = capturer;
    await capturer.start();
  }

  async stop(): Promise<number> {
    if (this.stopOperation !== undefined) {
      return await this.stopOperation;
    }
    if (!this.capturer) {
      return this.capturedBytes;
    }
    const capturer = this.capturer;
    this.capturer = undefined;
    const operation = this.stopCapturer(capturer);
    this.stopOperation = operation;
    try {
      return await operation;
    } finally {
      if (this.stopOperation === operation) {
        this.stopOperation = undefined;
      }
    }
  }

  private async stopCapturer(capturer: audio.AudioCapturer): Promise<number> {
    try {
      // 先停止采集，让 readData 接收停止前的最后一批缓冲，再解绑监听。
      await capturer.stop();
    } finally {
      try {
        capturer.off('readData', this.onReadData);
        capturer.off('audioInterrupt');
      } catch (_listenerError) {
        // Continue releasing even when listener removal is unavailable.
      }
      try {
        await capturer.release();
      } catch (_releaseError) {
      }
    }
    return this.capturedBytes;
  }

  async release(): Promise<void> {
    if (this.capturer || this.stopOperation !== undefined) {
      try {
        await this.stop();
      } catch (_error) {
        this.capturer = undefined;
      }
    }
    if (this.renderer) {
      try {
        await this.stopPlayback();
      } catch (_playbackReleaseError) {
      }
    }
    this.resetCaptureData();
    this.amplitudeListener(0);
  }

  async play(): Promise<void> {
    if (this.chunks.length === 0 || this.capturedBytes <= 0) {
      throw new Error('No transient audio is available');
    }
    if (this.renderer) {
      await this.stopPlayback();
    }
    const renderer = await audio.createAudioRenderer({
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      },
      rendererInfo: {
        usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
        rendererFlags: 0
      }
    });
    this.renderer = renderer;
    let chunkIndex = 0;
    let chunkOffset = 0;
    let playbackCompleted = false;
    let completePlayback: () => void = (): void => {};
    const playbackDataSupplied = new Promise<void>((resolve): void => {
      completePlayback = resolve;
    });
    const onWriteData: audio.AudioRendererWriteDataCallback =
      (buffer: ArrayBuffer): audio.AudioDataCallbackResult => {
        if (this.renderer !== renderer) {
          return audio.AudioDataCallbackResult.INVALID;
        }
        const output = new Uint8Array(buffer);
        let outputOffset = 0;
        while (outputOffset < output.length && chunkIndex < this.chunks.length) {
          const source = new Uint8Array(this.chunks[chunkIndex]);
          const available = source.length - chunkOffset;
          const copyLength = Math.min(available, output.length - outputOffset);
          output.set(
            source.subarray(chunkOffset, chunkOffset + copyLength),
            outputOffset
          );
          outputOffset += copyLength;
          chunkOffset += copyLength;
          if (chunkOffset >= source.length) {
            chunkIndex += 1;
            chunkOffset = 0;
          }
        }
        while (outputOffset < output.length) {
          output[outputOffset] = 0;
          outputOffset += 1;
        }
        if (chunkIndex >= this.chunks.length && !playbackCompleted) {
          playbackCompleted = true;
          completePlayback();
        }
        return audio.AudioDataCallbackResult.VALID;
      };
    this.playbackWriteListener = onWriteData;
    this.playbackCompletion = (): void => {
      if (!playbackCompleted) {
        playbackCompleted = true;
        completePlayback();
      }
    };
    try {
      renderer.on('writeData', onWriteData);
    } catch (_listenerError) {
      this.playbackWriteListener = undefined;
      this.playbackCompletion = undefined;
      this.renderer = undefined;
      try {
        await renderer.release();
      } catch (_releaseError) {
      }
      throw new Error('Unable to register the transient audio playback listener');
    }
    try {
      await renderer.start();
      await playbackDataSupplied;
      if (this.renderer === renderer) {
        await renderer.drain();
      }
    } finally {
      try {
        renderer.off('writeData', onWriteData);
      } catch (_listenerError) {
      }
      if (this.playbackWriteListener === onWriteData) {
        this.playbackWriteListener = undefined;
        this.playbackCompletion = undefined;
      }
      if (this.renderer === renderer) {
        await this.stopPlayback();
      }
    }
  }

  getCaptureSummary(): AudioCaptureSummary {
    const safeSampleCount = Math.max(0, this.sampleCount);
    const rmsAmplitude = safeSampleCount === 0 ? 0 :
      Math.sqrt(this.sampleSquareSum / safeSampleCount) / PCM_MAX_SAMPLE;
    return {
      byteLength: this.capturedBytes,
      sampleCount: safeSampleCount,
      durationSeconds: safeSampleCount / SAMPLE_RATE,
      peakAmplitude: Math.min(1, this.peakSample / PCM_MAX_SAMPLE),
      rmsAmplitude: Math.min(1, rmsAmplitude),
      activeSampleRatio: safeSampleCount === 0 ? 0 :
        this.activeSampleCount / safeSampleCount,
      clippedSampleRatio: safeSampleCount === 0 ? 0 :
        this.clippedSampleCount / safeSampleCount
    };
  }

  createLocalVoiceClip(id: string, durationSeconds: number): LocalVoiceClip | undefined {
    if (id.length === 0 || durationSeconds < 2 || this.capturedBytes <= 0 ||
      this.chunks.length === 0) {
      return undefined;
    }
    return {
      id: id,
      chunks: this.chunks.map((chunk: ArrayBuffer): ArrayBuffer => chunk.slice(0)),
      byteLength: this.capturedBytes,
      durationSeconds: durationSeconds
    };
  }

  getCapturedPcmChunks(): Array<ArrayBuffer> {
    return this.chunks.map((chunk: ArrayBuffer): ArrayBuffer => chunk.slice(0));
  }

  async stopPlayback(): Promise<void> {
    if (!this.renderer) {
      return;
    }
    const renderer = this.renderer;
    this.renderer = undefined;
    if (this.playbackWriteListener !== undefined) {
      try {
        renderer.off('writeData', this.playbackWriteListener);
      } catch (_listenerError) {
      }
      this.playbackWriteListener = undefined;
    }
    if (this.playbackCompletion !== undefined) {
      const completion = this.playbackCompletion;
      this.playbackCompletion = undefined;
      completion();
    }
    try {
      await renderer.stop();
    } finally {
      await renderer.release();
    }
  }

  private observeSamples(buffer: ArrayBuffer): number {
    const samples = new Int16Array(buffer, 0, Math.floor(buffer.byteLength / 2));
    if (samples.length === 0) {
      return 0;
    }
    let peak = 0;
    for (let index = 0; index < samples.length; index++) {
      const sample = samples[index];
      const absoluteSample = Math.abs(sample);
      peak = Math.max(peak, absoluteSample);
      this.peakSample = Math.max(this.peakSample, absoluteSample);
      this.sampleSquareSum += sample * sample;
      this.sampleCount += 1;
      if (absoluteSample >= ACTIVE_SAMPLE_THRESHOLD) {
        this.activeSampleCount += 1;
      }
      if (absoluteSample >= CLIPPED_SAMPLE_THRESHOLD) {
        this.clippedSampleCount += 1;
      }
    }
    return Math.min(1, peak / PCM_MAX_SAMPLE);
  }

  private resetCaptureData(): void {
    this.capturedBytes = 0;
    this.chunks = [];
    this.sampleCount = 0;
    this.sampleSquareSum = 0;
    this.peakSample = 0;
    this.activeSampleCount = 0;
    this.clippedSampleCount = 0;
  }
}
