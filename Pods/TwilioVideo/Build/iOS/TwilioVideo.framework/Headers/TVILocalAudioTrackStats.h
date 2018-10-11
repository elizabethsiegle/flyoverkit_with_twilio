//
//  TVILocalAudioTrackStats.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TVILocalTrackStats.h"

/**
 * `TVILocalAudioTrackStats` represents stats about a local audio track.
 */
@interface TVILocalAudioTrackStats : TVILocalTrackStats

/**
 * @brief Audio input level.
 */
@property (nonatomic, assign, readonly) NSUInteger audioLevel;

/**
 * @brief Packet jitter measured in milliseconds.
 */
@property (nonatomic, assign, readonly) NSUInteger jitter;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Local audio track stats cannot be created explicitly.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("TVILocalAudioTrackStats cannot be created explicitly.")));

@end
