import { audio } from '@kit.AudioKit';

export interface LocalVoiceClip {
  readonly id: string;
  readonly chunks: Array<ArrayBuffer>;
  readonly byteLength: number;
  readonly durationSeconds: number;
}

const LOCAL_VOICE_CLIPS: LocalVoiceClip[] = [];
const LOCAL_VOICE_MAX_CLIP_COUNT: number = 20;
const LOCAL_VOICE_MAX_TOTAL_BYTES: number = 32 * 1024 * 1024;
let localVoiceStoredBytes: number = 0;
let activeRenderer: audio.AudioRenderer | undefined = undefined;
let activeWriteListener: audio.AudioRendererWriteDataCallback | undefined = undefined;
let activePlaybackCompletion: (() => void) | undefined = undefined;

export function storeLocalVoiceClip(clip: LocalVoiceClip): boolean {
  const actualByteLength = calculateClipByteLength(clip.chunks);
  if (clip.id.length === 0 || clip.byteLength <= 0 || clip.durationSeconds < 2 ||
    clip.byteLength !== actualByteLength ||
    LOCAL_VOICE_CLIPS.length >= LOCAL_VOICE_MAX_CLIP_COUNT ||
    localVoiceStoredBytes + actualByteLength > LOCAL_VOICE_MAX_TOTAL_BYTES ||
    LOCAL_VOICE_CLIPS.some((item: LocalVoiceClip): boolean => item.id === clip.id)) {
    return false;
  }
  LOCAL_VOICE_CLIPS.push(clip);
  localVoiceStoredBytes += actualByteLength;
  return true;
}

export function removeLocalVoiceClip(clipId: string): boolean {
  const index = LOCAL_VOICE_CLIPS.findIndex(
    (item: LocalVoiceClip): boolean => item.id === clipId
  );
  if (index < 0) {
    return false;
  }
  localVoiceStoredBytes = Math.max(
    0,
    localVoiceStoredBytes - LOCAL_VOICE_CLIPS[index].byteLength
  );
  LOCAL_VOICE_CLIPS.splice(index, 1);
  return true;
}

function calculateClipByteLength(chunks: Array<ArrayBuffer>): number {
  let byteLength = 0;
  chunks.forEach((chunk: ArrayBuffer): void => {
    byteLength += chunk.byteLength;
  });
  return byteLength;
}

export async function playLocalVoiceClip(clipId: string): Promise<boolean> {
  const clip = LOCAL_VOICE_CLIPS.find(
    (item: LocalVoiceClip): boolean => item.id === clipId
  );
  if (clip === undefined) {
    return false;
  }
  await stopLocalVoicePlayback();
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
  activeRenderer = renderer;
  let chunkIndex = 0;
  let chunkOffset = 0;
  let playbackCompleted = false;
  let completePlayback: () => void = (): void => {};
  const playbackDataSupplied = new Promise<void>((resolve): void => {
    completePlayback = resolve;
  });
  const onWriteData: audio.AudioRendererWriteDataCallback =
    (buffer: ArrayBuffer): audio.AudioDataCallbackResult => {
      if (activeRenderer !== renderer) {
        return audio.AudioDataCallbackResult.INVALID;
      }
      const output = new Uint8Array(buffer);
      let outputOffset = 0;
      while (outputOffset < output.length && chunkIndex < clip.chunks.length) {
        const source = new Uint8Array(clip.chunks[chunkIndex]);
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
      if (chunkIndex >= clip.chunks.length && !playbackCompleted) {
        playbackCompleted = true;
        completePlayback();
      }
      return audio.AudioDataCallbackResult.VALID;
    };
  activeWriteListener = onWriteData;
  activePlaybackCompletion = (): void => {
    if (!playbackCompleted) {
      playbackCompleted = true;
      completePlayback();
    }
  };
  try {
    renderer.on('writeData', onWriteData);
  } catch (_listenerError) {
    activeWriteListener = undefined;
    activePlaybackCompletion = undefined;
    activeRenderer = undefined;
    try {
      await renderer.release();
    } catch (_releaseError) {
    }
    throw new Error('Unable to register the local voice playback listener');
  }
  try {
    await renderer.start();
    await playbackDataSupplied;
    if (activeRenderer !== renderer) {
      return false;
    }
    await renderer.drain();
    return true;
  } finally {
    try {
      renderer.off('writeData', onWriteData);
    } catch (_listenerError) {
    }
    if (activeWriteListener === onWriteData) {
      activeWriteListener = undefined;
      activePlaybackCompletion = undefined;
    }
    if (activeRenderer === renderer) {
      await stopLocalVoicePlayback();
    }
  }
}

export async function stopLocalVoicePlayback(): Promise<void> {
  if (activeRenderer === undefined) {
    return;
  }
  const renderer = activeRenderer;
  activeRenderer = undefined;
  const writeListener = activeWriteListener;
  activeWriteListener = undefined;
  const completePlayback = activePlaybackCompletion;
  activePlaybackCompletion = undefined;
  if (completePlayback !== undefined) {
    completePlayback();
  }
  if (writeListener !== undefined) {
    try {
      renderer.off('writeData', writeListener);
    } catch (_listenerError) {
    }
  }
  try {
    await renderer.stop();
  } catch (_error) {
  }
  try {
    await renderer.release();
  } catch (_error) {
  }
}
