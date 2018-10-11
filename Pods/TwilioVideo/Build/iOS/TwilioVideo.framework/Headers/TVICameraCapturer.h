//
//  TVICameraCapturer.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

#import "TVIVideoCapturer.h"

@class TVICameraPreviewView;

/**
 *  The smallest possible size, yielding a 1.22:1 aspect ratio useful for multi-party.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize352x288;

/**
 *  Medium quality video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize480x360;

/**
 *  High quality 640x480 video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize640x480;

/**
 *  540p Quarter HD video in a 16:9 aspect ratio.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize960x540;

/**
 *  720p HD video in a 16:9 aspect ratio.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize1280x720;

/**
 *  HD quality 1280x960 video in a 4:3 aspect ratio.
 */
extern CMVideoDimensions const TVIVideoConstraintsSize1280x960;

/**
 *  Default 30fps video, giving a smooth video look.
 */
extern NSUInteger const TVIVideoConstraintsFrameRate30;

/**
 *  Cinematic 24 fps video. Not yet recommended for iOS recipients using `TVIVideoView` renderer, since it
 *  operates on a 60 Hz timer.
 */
extern NSUInteger const TVIVideoConstraintsFrameRate24;

/**
 *  @brief Battery efficient 20 fps video.
 */
extern NSUInteger const TVIVideoConstraintsFrameRate20;

/**
 *  Battery efficient 15 fps video. This setting can be useful if you prefer spatial to temporal resolution.
 */
extern NSUInteger const TVIVideoConstraintsFrameRate15;

/**
 *  Battery saving 10 fps video.
 */
extern NSUInteger const TVIVideoConstraintsFrameRate10;

/**
 *  The capture source you wish to use.
 */
typedef NS_ENUM(NSUInteger, TVICameraCaptureSource) {
    /**
     *  Capture video from the front facing camera.
     */
    TVICameraCaptureSourceFrontCamera = 0,
    /**
     *  Capture video from the wide rear facing camera.
     */
    TVICameraCaptureSourceBackCameraWide,
    /**
     *  Capture video from the telephoto rear facing camera. For the iPhone 7 Plus this is close to a "normal" lens.
     */
    TVICameraCaptureSourceBackCameraTelephoto,
};

@class TVICameraCapturer;

/**
 *  `TVICameraCapturerDelegate` receives important lifecycle events related to the capturer.
 *  By implementing these methods you can override default behavior, or handle errors that may occur.
 */
@protocol TVICameraCapturerDelegate <NSObject>

@optional
/**
 *  @brief The camera capturer has started capturing live video.
 *
 *  @discussion You may wish to update the mirroring property of any local video views depending on the source that is
 *  now being captured.
 *
 *  @param capturer The capturer which started.
 *  @param source   The source which is now being captured.
 */
- (void)cameraCapturer:(nonnull TVICameraCapturer *)capturer
    didStartWithSource:(TVICameraCaptureSource)source;

/**
 *  @brief The camera capturer was temporarily interrupted. Respond to this method to override the default behavior.
 *
 *  @discussion You may wish to pause your `TVILocalVideoTrack`, or update your UI in response to an interruption.
 *
 *  @param capturer The capture which was interrupted.
 *  @param reason The reason why the capture was interrupted.
 */
- (void)cameraCapturerWasInterrupted:(nonnull TVICameraCapturer *)capturer
                              reason:(AVCaptureSessionInterruptionReason)reason;

/**
 *  @brief The camera capturer failed to start or stopped running with a fatal error.
 *
 *  @param capturer The capturer which stopped.
 *  @param error    The error which caused the capturer to stop.
 */
- (void)cameraCapturer:(nonnull TVICameraCapturer *)capturer
      didFailWithError:(nonnull NSError *)error;

@end

/**
 *  `TVICameraCapturer` allows you to preview and share video captured from the device's built in camera(s).
 */
@interface TVICameraCapturer : NSObject <TVIVideoCapturer>

/** 
 *  @brief Obtains the camera that is being shared.
 */
@property (nonatomic, assign, readonly) TVICameraCaptureSource source;

/**
 *  @brief Indicates that video capture (including preview) is active.
 *
 *  @discussion While interrupted, this property will return `NO`.
 */
@property (atomic, assign, readonly, getter=isCapturing) BOOL capturing;

/**
 *  @brief The capturer's delegate.
 */
@property (nonatomic, weak, nullable) id<TVICameraCapturerDelegate> delegate;

/**
 *  @brief A view which allows you to preview the camera source.
 *
 *  @discussion `previewView` will be `nil` unless the TVICameraCapturer is initialized with the 
 *  `initWithSource:delegate:enablePreview:` initializer, passing `YES` as the `enablePreview` argument. 
 */
@property (nonatomic, strong, readonly, nonnull) TVICameraPreviewView *previewView;

/**
 *  Returns `YES` if the capturer is currently interrupted, and `NO` otherwise.
 */
@property (nonatomic, assign, readonly, getter=isInterrupted) BOOL interrupted;

/**
 *  @brief Initializes the capturer with `TVICameraCaptureSourceFrontCamera`.
 *
 *  @return A camera capturer which can be used to create a `TVILocalVideoTrack` if `TVICameraCaptureSourceFrontCamera`
 *  is available, otherwise `nil`.
 */
- (null_unspecified instancetype)init;

/**
 *  @brief Initializes the capturer with a source.
 *
 *  @param source The `TVICameraCaptureSource` to select initially.
 *
 *  @return A camera capturer which can be used to create a `TVILocalVideoTrack` if the video capture source is available,
 *  otherwise `nil`.
 */
- (nullable instancetype)initWithSource:(TVICameraCaptureSource)source;

/**
 *  @brief Creates the capturer with a source and delegate.
 *
 *  @param source The `TVICameraCaptureSource` to select initially.
 *  @param delegate An object which conforms to `TVICameraCapturerDelegate` that will receive callbacks from the capturer.
 *
 *  @return A camera capturer which can be used to create a `TVILocalVideoTrack` if the video capture source is available,
 *  otherwise `nil`.
 */
- (nullable instancetype)initWithSource:(TVICameraCaptureSource)source
                               delegate:(nullable id<TVICameraCapturerDelegate>)delegate;

/**
 *  @brief Creates the capturer with a source, delegate and whether the preview feed should be generated.
 *
 *  @param source The `TVICameraCaptureSource` to select initially.
 *  @param delegate An object which conforms to `TVICameraCapturerDelegate` that will receive callbacks from the capturer.
 *  @param enablePreview Whether the capturer should provide the preview feed via the `previewView`.
 *
 *  @return A camera capturer which can be used to create a `TVILocalVideoTrack` if the video capture source is available,
 *  otherwise `nil`.
 */
- (nullable instancetype)initWithSource:(TVICameraCaptureSource)source
                               delegate:(nullable id<TVICameraCapturerDelegate>)delegate
                          enablePreview:(BOOL)enablePreview;

/**
 *  @brief Selects a new camera source.
 *
 *  @param source The camera source to select.
 *
 *  @return `YES` if the source is available, otherwise `NO`.
 */
- (BOOL)selectSource:(TVICameraCaptureSource)source;

/**
 *  @brief Checks if a `TVICameraCaptureSource` is available on your device.
 *
 *  @param source The source to check.
 *
 *  @return `YES` if the source is available, or `NO` if it is not.
 */
+ (BOOL)isSourceAvailable:(TVICameraCaptureSource)source;

/**
 *  @brief Returns all of the sources which are available on your device.
 *
 *  @discussion If you are on an iOS simulator you should not expect any sources to be returned.
 *
 *  @return An `NSArray` containing zero or more `NSNumber` objects which wrap `TVICameraCaptureSource`.
 */
+ (nonnull NSArray<NSNumber *> *)availableSources;


@end
