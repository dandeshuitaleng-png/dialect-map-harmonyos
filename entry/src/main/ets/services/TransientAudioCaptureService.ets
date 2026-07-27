import { audio } from '@kit.AudioKit';

export class TransientAudioCaptureService {
  private capturer?: audio.AudioCapturer;
  private capturedBytes: number = 0;
  private readonly onReadData = (buffer: ArrayBuffer): void => {
    // The demo verifies real microphone capture without retaining voice data.
    this.capturedBytes += buffer.byteLength;
  };

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
    } catch (_error) {
      try {
        await capturer.release();
      } catch (_releaseError) {
        // The capturer was not published to the service, so no retained state remains.
      }
      throw new Error('Unable to register the transient audio read listener');
    }
    this.capturedBytes = 0;
    this.capturer = capturer;
    await capturer.start();
  }

  async stop(): Promise<number> {
    const capturedBytes = this.capturedBytes;
    if (!this.capturer) {
      return capturedBytes;
    }
    const capturer = this.capturer;
    this.capturer = undefined;
    try {
      try {
        capturer.off('readData', this.onReadData);
      } catch (_listenerError) {
        // Continue stopping and releasing even when listener removal is unavailable.
      }
      await capturer.stop();
    } finally {
      try {
        await capturer.release();
      } catch (_releaseError) {
        this.capturedBytes = 0;
      }
    }
    return capturedBytes;
  }

  async release(): Promise<void> {
    if (!this.capturer) {
      return;
    }
    try {
      await this.stop();
    } catch (_error) {
      this.capturer = undefined;
      this.capturedBytes = 0;
    }
  }
}
