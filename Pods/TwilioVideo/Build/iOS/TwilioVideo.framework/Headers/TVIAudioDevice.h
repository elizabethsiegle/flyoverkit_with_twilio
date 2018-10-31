//
//  TVIAudioDevice.h
//  TwilioVideo
//
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import "TVIAudioFormat.h"

typedef void* TVIAudioDeviceContext;

#ifdef __cplusplus
extern "C" {
#endif

/**
 *  This method should be called any time the capturing or rendering format changes. If both formats change
 *  simultaneously its fine to call this method just once. As a result the media engine will read the new audio format,
 *  stop capturing and/or rendering by calling `stopCapturing` and/or `stopRendering` and then call `startRendering:`
 *  and/or `startRendering:`.
 *
 *  @param context The context pointer. You should use the same context provided in `startCapturing:` and/or
 * `startRendering:` here.
 */
void TVIAudioDeviceFormatChanged(TVIAudioDeviceContext _Nonnull context);

/**
 *  This method is called by your `TVIAudioDeviceCapturer` to provide captured data to the media engine.
 *
 *  @param context The context pointer. You should use the same context provided in `startCapturing:` here.
 *  @param data A pointer to the audio data you wish to deliver.
 *  @param sizeInBytes The size (in bytes) of the audio data you are delivering. This must be less than or equal to the
 *  value returned by `TVIAudioFormat.bufferSize`.
 *
 *  @see [TVIAudioFormat](TVIAudioFormat.h)
 */
void TVIAudioDeviceWriteCaptureData(TVIAudioDeviceContext _Nonnull context, int8_t *_Nonnull data, size_t sizeInBytes);

/**
 *  This method is called by your `TVIAudioDeviceRenderer` to pull renderable audio data from the media engine.
 *
 *  @param context The context pointer. You should use the same context provided in `startRendering:` here.
 *  @param data A pointer to a buffer where the signed 16-bit LPCM audio data will be copied into.
 *  @param sizeInBytes The size (in bytes) of the audio data you are rendering. This must be less than or equal to
 *  the value returned by `TVIAudioFormat.bufferSize`.
 *
 *  @see [TVIAudioFormat](TVIAudioFormat.h)
 */
void TVIAudioDeviceReadRenderData(TVIAudioDeviceContext _Nonnull context, int8_t *_Nonnull data, size_t sizeInBytes);

/**
 *  A block which is executed on the media engine's worker thread.
 */
typedef void (^ TVIAudioDeviceWorkerBlock)(void);

/**
 *  A utility method to execute a block on the media engine's worker thread asynchronously.
 *
 *  @param context The context pointer. You should use the same context provided in `startRendering:` or
 *  `startCapturing:` here.
 *  @param block A block which will be executed on the media engine's worker thread.
 *
 *  @discussion TVIAudioDevice invokes the callbacks on the media engine's worker thread. If you wish to initialize,
 *  start or stop the audio device from your application code, to avoid the thread-safety problems, you should execute
 *  code from the media engine's worker thread.
 *  Example:
        - (void)handleMediaServiceLost:(NSNotification *)notification {
            TVIAudioDeviceWorkerBlock workerBlock =  ^{
                [self stopAudioUnit];
            };
            TVIAudioDeviceExecuteWorkerBlock(context, workerBlock);
        }
 */
void TVIAudioDeviceExecuteWorkerBlock(TVIAudioDeviceContext _Nonnull context, TVIAudioDeviceWorkerBlock _Nonnull block);

/*
 * Use this API to notify the Video SDK when AVAudioSession gets activated.
 *
 *  @param context The context pointer. You should use the same context provided in `startCapturing:` and/or
 * `startRendering:` here.
 *
 *  @discussion The Video SDK uses this information to determine if the signaling connection should be terminated when
 *  the app is backgrounded. The SDK will not terminate the signaling connection when AVAudioSession is active.
 */
void TVIAudioSessionActivated(TVIAudioDeviceContext _Nonnull context);

/*
 * Use this API to notify the Video SDK when AVAudioSession gets deactivated.
 *
 *  @param context The context pointer. You should use the same context provided in `startCapturing:` and/or
 * `startRendering:` here.
 *
 *  @discussion The Video SDK uses this information to determine if the signaling connection should be terminated when
 *  the app is backgrounded. The SDK will terminate the signaling connection when AVAudioSession is inactive.
 */
void TVIAudioSessionDeactivated(TVIAudioDeviceContext _Nonnull context);

#ifdef __cplusplus
}
#endif

/**
 *  TVIAudioDeviceRenderer defines the rendering half of `TVIAudioDevice`. An audio renderer consumes samples by
 *  repeatedly calling `TVIAudioDeviceReadRenderData()` when it needs new data. A renderer need not playback audio
 *  through the device loudspeaker, it could perform other operations such as writing audio samples to disk instead.
 */
@protocol TVIAudioDeviceRenderer <NSObject>

/**
 *  @brief Provides the format to be used for rendering audio.
 *
 *  @return A `TVIAudioFormat` instance which describes the audio which will be rendered. Returning `nil` indicates
 *  that audio rendering is not supported.
 *
 *  @discussion This method is called once before rendering starts. If you wish to change the format after you've started
 *  rendering audio then you should call `TVIAudioDeviceFormatChanged()` and prepare for this method to be queried again.
 */
- (nullable TVIAudioFormat *)renderFormat;

/**
 *  @brief Initializes the renderer.
 *
 *  @return `YES` if initialization succeeded, or `NO` if it did not.
 *
 *  @discussion This method is called before `startRendering:`. You should use this opportunity to pre-allocate any
 *  fixed size buffers or other resources that you need for audio processing.
 */
- (BOOL)initializeRenderer;

/**
 *  @brief Starts the renderer.
 *
 *  @param context A context pointer to be used with the audio renderer function callbacks
 *  TVIAudioDeviceFormatChanged(), TVIAudioDeviceReadRenderData() and TVIAudioDeviceExecuteWorkerBlock().
 *
 *  @return `YES` if rendering started, or `NO` if it did not.
 *
 *  @discussion This method is called after `initializeRenderer`. Before your implementation returns it should have
 *  started your audio rendering pipeline. This may involve spinning up audio threads via CoreAudio or starting your own
 *  high priority rendering thread.
 */
- (BOOL)startRendering:(nonnull TVIAudioDeviceContext)context;

/**
 *  @brief Stops the renderer.
 *
 *  @return `YES` if rendering stopped, or `NO` if it did not.
 *
 *  @discussion This method is called some time after `startRendering` when audio rendering is no longer needed by the
 *  media engine. Before your implementation returns it should have stopped your audio rendering pipeline.
 */
- (BOOL)stopRendering;

@end

/**
 *  TVIAudioDeviceCapturer defines the capturing half of `TVIAudioDevice`. An audio capturer produces samples by
 *  repeatedly calling `TVIAudioDeviceWriteCaptureData()` when it needs to deliver new data. A capturer need not record
 *  audio from the device microphone, it could perform other operations such as reading audio samples from disk instead.
 */
@protocol TVIAudioDeviceCapturer <NSObject>

/**
 *  @brief Provides the format to be used for capturing audio.
 *
 *  @return A `TVIAudioFormat` instance which describes the audio which will be captured. Returning `nil` indicates
 *  that audio capture is not supported.
 *
 *  @discussion This method is called once before capture starts. If you wish to change the format after you've started
 *  capturing audio then you should call `TVIAudioDeviceFormatChanged()` and prepare for this method to be queried again.
 */
- (nullable TVIAudioFormat *)captureFormat;

/**
 *  @brief Initializes the capturer.
 *
 *  @return `YES` if initialization succeeded, or `NO` if it did not.
 *
 *  @discussion This method is called before `startCapturing:`. You should use this opportunity to pre-allocate any
 *  fixed size buffers or other resources that you need for audio processing.
 */
- (BOOL)initializeCapturer;

/**
 *  @brief Starts the capturer.
 *
 *  @param context A context pointer to be used with the audio capture function callbacks
 *  TVIAudioDeviceFormatChanged(), TVIAudioDeviceWriteCaptureData() and TVIAudioDeviceExecuteWorkerBlock().
 *
 *  @return `YES` if capturing started, or `NO` if it did not.
 *
 *  @discussion This method is called after `initializeCapturer`. Before your implementation returns it should have
 *  started your audio capturing pipeline. This may involve spinning up audio threads via CoreAudio or starting your own
 *  high priority capture thread.
 */
- (BOOL)startCapturing:(nonnull TVIAudioDeviceContext)context;

/**
 *  @brief Stops the capturer.
 *
 *  @return `YES` if capturing stopped, or `NO` if it did not.
 *
 *  @discussion This method is called some time after `startCapturing` when audio capturing is no longer needed by the
 *  media engine. Before your implementation returns it should have stopped your audio capturing pipeline.
 */
- (BOOL)stopCapturing;

@end

/**
 *  TVIAudioDevice represents full duplex audio capturing and rendering capabilities. By implementing this
 *  protocol you can replace the mechanism by which audio is used by the media engine.
 */
@protocol TVIAudioDevice <TVIAudioDeviceRenderer, TVIAudioDeviceCapturer>
@end
