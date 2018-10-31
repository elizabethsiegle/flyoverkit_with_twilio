//
//  TVILocalDataTrackPublication.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import "TVIDataTrackPublication.h"

@class TVILocalDataTrack;

/**
 * `TVILocalDataTrackPublication` contains the mapping between a published `TVILocalDataTrack` and its server generated `sid`.
 */
@interface TVILocalDataTrackPublication : TVIDataTrackPublication

/**
 *  @brief The local data track associated with track publication.
 */
@property (nonatomic, strong, readonly, nullable) TVILocalDataTrack *localTrack;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Track publications cannot be created explicitly
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Track publications cannot be created explicitly.")));

@end
