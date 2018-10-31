//
//  TVILocalVideoTrackPublication.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TVIVideoTrackPublication.h"

@class TVILocalVideoTrack;

/**
 * `TVILocalVideoTrackPublication` contains the mapping between a published `TVILocalVideoTrack` and its server generated `sid`.
 */
@interface TVILocalVideoTrackPublication : TVIVideoTrackPublication

/**
 *  @brief The local video track associated with track publication.
 */
@property (nonatomic, strong, readonly, nullable) TVILocalVideoTrack *localTrack;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Track publications cannot be created explicitly
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Track publications cannot be created explicitly.")));

@end
