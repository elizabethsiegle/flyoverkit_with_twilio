//
//  TVIVideoCapturer.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TVIVideoFrame.h"
#import "TVIVideoFormat.h"

/**
 *  `TVIVideoCaptureConsumer` consumes frames and status events from a `TVICameraCapturer`.
 */
@protocol TVIVideoCaptureConsumer <NSObject>

/**
 *  @brief Provides a frame to the consumer.
 *
 *  @discussion Before this method returns the consumer will retain the frame's underlying `imageBuffer`. The `CVImageBuffer`
 *  will be asynchronously delivered to the video pipeline, and released once it has been rendered and/or encoded.
 *  Zero-copy rendering is possible if the CVImageBuffer properties contain
 *  `kCVPixelBufferIOSurfacePropertiesKey`, `kCVPixelBufferMetalCompatibilityKey`, or `kCVPixelBufferOpenGLESCompatibilityKey`.
 *  At the moment your renderers will receive an I420 buffer converted from `imageBuffer` which resides in main system memory.
 *
 *  @param frame A `TVIVideoFrame` containing image data, and metadata.
 */
- (void)consumeCapturedFrame:(nonnull TVIVideoFrame *)frame;

/**
 *  @brief Signals to the consumer that capture has started, or failed to start.
 *
 *  @param success `YES` if capture started, or `NO` if capture failed to start.
 *
 *  @discussion It is safe to call this method inside of `startCapture:consumer:`.
 */
- (void)captureDidStart:(BOOL)success;

@end

/**
 *  `TVIVideoCapturer` defines a video capture source which provides frames directly to the video pipeline.
 *  You should expect that all of the methods defined in `TVIVideoCapturer` will be called on an internal
 *  worker thread in response to adding / removing a `TVILocalVideoTrack`. Capture implementations should provide a list 
 *  of supported formats, and specify if their content is screen based or not. Ultimately, `TVIVideoConstraints` are 
 *  used to determine which one of the supported formats is chosen. You should not call these methods directly!
 */
@protocol TVIVideoCapturer <NSObject>

/**
 *  @brief Indicates if the video pipeline should treat the content as a screen capture or normal video.
 */
@property (nonatomic, assign, readonly, getter = isScreencast) BOOL screencast;

/**
 *  @brief Returns a list of all supported video formats this capturer supports.
 *
 *  @discussion This method will be invoked prior to `startCapture`. If you return no formats we will assume 640x480x30
 *  and `TVIPixelFormatYUV420BiPlanarFullRange` as a default.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIVideoFormat *> *supportedFormats;

/**
 *  @brief Start capturing, and begin delivering frames to the capture consumer as soon as possible.
 *
 *  @discussion When this method is called your capturer should prepare any resources it needs, and start capturing video.
 *  Your capturer MUST call `captureDidStart` on the consumer once it has either succeeded or failed to start.
 *  If your capturer starts synchronously you may inform the consumer before this callback returns. As frames are captured
 *  you should deliver them to the consumer by calling `consumeCapturedFrame:` with a `TVIVideoFrame`. You should not
 *  call this method yourself, it is invoked in response to adding a video track to `TVILocalMedia`.
 *
 *  @param format The format which has been selected via `TVIVideoConstraints.` Please note that WebRTC doesn't fully
 *  understand video range vs full range, so if you specify a video range format it will come back as full range.
 *  You can continue to capture and deliver in video range if you wish.
 *
 *  @param consumer The consumer. You should weakly reference this consumer until `stopCapture` is called.
 */
- (void)startCapture:(nonnull TVIVideoFormat *)format
            consumer:(nonnull id<TVIVideoCaptureConsumer>)consumer;

/**
 *  @brief Stop capturing, and do not deliver any more frames to `TVIVideoCaptureConsumer`.
 *
 *  @discussion This method will be invoked on an internal worker thread. Your capturer should block until capture has 
 *  stopped. You should not call this method yourself, it is invoked in response to removing a video track from `TVILocalMedia`.
 */
- (void)stopCapture;

@end
