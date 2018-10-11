//
//  TVIRemoteVideoTrack.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TVIVideoTrack.h"

/**
 * `TVIRemoteVideoTrack` represents a remote video track.
 */
@interface TVIRemoteVideoTrack : TVIVideoTrack

/**
 *  @brief The sid of the remote video track.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *sid;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Tracks cannot be created explicitly.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Tracks cannot be created explicitly.")));

@end
