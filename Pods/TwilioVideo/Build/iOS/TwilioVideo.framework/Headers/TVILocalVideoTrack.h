//
//  TVILocalVideoTrack.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TVIVideoTrack.h"

@class TVIVideoConstraints;
@protocol TVIVideoCapturer;

/**
 * `TVILocalVideoTrack` represents local video produced by a `TVIVideoCapturer`.
 */
@interface TVILocalVideoTrack : TVIVideoTrack

/**
 *  @brief Indicates if track is enabled.
 *
 *  @discussion It is possible to enable and disable local tracks. The results of this operation are signaled to other
 *  Participants in the same Room. When a video track is disabled, black frames are sent in place of normal video.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/**
 *  @brief The capturer that is associated with this track.
 */
@property (nonatomic, strong, readonly, nonnull) id<TVIVideoCapturer> capturer;

/**
 *  @brief The video constraints.
 */
@property (nonatomic, strong, readonly, nonnull) TVIVideoConstraints *constraints;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Use `trackWithCapturer:` or `trackWithCapturer:enabled:constraints:name:` to create a `TVILocalVideoTrack`.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use `trackWithCapturer:` or `trackWithCapturer:enabled:constraints:name:` to create a `TVILocalVideoTrack`.")));

/**
 *  @brief Creates a `TVILocalVideoTrack` with a `TVIVideoCapturer`.
 *
 *  @discussion This method allows you to provide a `TVIVideoCapturer`, and uses the default `TVIVideoConstraints`.
 *
 *  @param capturer A `TVIVideoCapturer` which will provide the content for this Track.
 *
 *  @return A Track which is ready to be shared with Participants in a Room, or `nil` if an error occurs.
 */
+ (nullable instancetype)trackWithCapturer:(nonnull id<TVIVideoCapturer>)capturer;

/**
 *  @brief Creates a `TVILocalVideoTrack` with a `TVIVideoCapturer`, `TVIVideoConstraints` and an enabled setting.
 *
 *  @discussion This method allows you to provide specific `TVIVideoConstraints`, and produce a disabled Track if you wish.
 *
 *  @param capturer A `TVIVideoCapturer` which will provide the content for this Track.
 *  @param enabled Determines if the Track is enabled at creation time.
 *  @param constraints A `TVIVideoConstraints` which specifies requirements for video capture.
 *  @param name The Track name.
 *
 *  @return A Track which is ready to be shared with Participants in a Room, or `nil` if an error occurs.
 */
+ (nullable instancetype)trackWithCapturer:(nonnull id<TVIVideoCapturer>)capturer
                                   enabled:(BOOL)enabled
                               constraints:(nullable TVIVideoConstraints *)constraints
                                      name:(nullable NSString *)name;

@end
