//
//  TVIVideoRenderer.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>

#import "TVIVideoFrame.h"

/**
 *  TVIVideoRenderers render frames from video tracks.
 */
@protocol TVIVideoRenderer <NSObject>

/**
 *  @brief Render an individual frame.
 *
 *  @discussion Your renderer is required to support frames in the format `TVIPixelFormatYUV420PlanarFullRange`.
 *  You should strongly reference (retain) the `TVIVideoFrame` before this call returns if you want to render it later.
 *  Frames are delivered to your renderer at or near their presentation timestamps.
 *
 *  @param frame The frame to be rendered.
 */
- (void)renderFrame:(nonnull TVIVideoFrame *)frame;

/**
 *  @brief Informs your renderer that the size and/or orientation of the video stream is about to change.
 *
 *  @discussion Expect the next delivered frame to have the new size and/or orientation.
 *
 *  @param videoSize The new dimensions for the video stream.
 *  @param orientation The new orientation of the video stream.
 *  Always `TVIVideoOrientationUp` unless you opt into orientation support.
 */
- (void)updateVideoSize:(CMVideoDimensions)videoSize orientation:(TVIVideoOrientation)orientation;

@optional

/**
 *  @brief A list of the optional pixel formats that the renderer supports in addition to `TVIPixelFormatYUV420PlanarFullRange`.
 *
 *  @discussion Allows your renderer to declare support for the optional `TVIPixelFormat` types that it can handle.
 *  Any source format defined in `TVIPixelFormat` can be converted to `TVIPixelFormatYUV420PlanarFullRange`. If
 *  an optional format is not supported then a format conversion is performed before delivering frames to the renderer.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<NSNumber *> *optionalPixelFormats;

/**
 * @brief Informs your renderer that it is no longer being used and allows you to perform any cleanup necessary if
 * you wish to reuse the renderer with another video track.
 *
 * @discussion If implemented, this method will be called when removing the renderer during the invocation of
 * `[TVIVideoTrack removeRenderer:]`. This method will be invoked on the thread in which `[TVIVideoTrack removeRenderer:]`
 * was called. When your Client is unsubscribed from a `TVIRemoteVideoTrack` you are given the opportunity to remove your
 * renderer. If the rendered is not removed manually, this method will automatically be called after the
 * `unsubscribedFromVideoTrack:publication:forParticipant:` delegate method has been invoked.
 */
- (void)invalidateRenderer;

@end
