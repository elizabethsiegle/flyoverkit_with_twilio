//
//  TVIParticipant.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TVITrackPublication;
@class TVIAudioTrackPublication;
@class TVIVideoTrackPublication;
@class TVIDataTrackPublication;

/**
 *  `TVIParticipant` is the base class from which Local and Remote Participants are derived.
 */
@interface TVIParticipant : NSObject

/**
 *  @brief The Participant's identity.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *identity;

/**
 *  @brief The Participant's server identifier. This value uniquely identifies the Participant in a Room and is often 
 *  useful for debugging purposes.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sid;

/**
 *  @brief A collection of shared audio tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIAudioTrackPublication *> *audioTracks;

/**
 *  @brief A collection of shared video tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIVideoTrackPublication *> *videoTracks;

/**
 *  @brief A collection of shared data tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIDataTrackPublication *> *dataTracks;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion `TVIParticipant` cannot be created explicitly.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("TVIParticipant cannot be created explicitly.")));

/**
 *  @brief A utility method which finds a `TVITrackPublication` by its `sid`.
 *
 *  @param sid The track sid.
 *
 *  @return An instance of `TVITrackPublication` if found, otherwise `nil`.
 */
- (nullable TVITrackPublication *)getTrack:(nonnull NSString *)sid;

/**
 *  @brief A utility method which finds a `TVIAudioTrackPublication` by its `sid`.
 *
 *  @param sid The track sid.
 *
 *  @return An instance of `TVIAudioTrackPublication` if found, otherwise `nil`.
 */
- (nullable TVIAudioTrackPublication *)getAudioTrack:(nonnull NSString *)sid;

/**
 *  @brief A utility method which finds a `TVIVideoTrackPublication` by its `sid`.
 *
 *  @param sid The track sid.
 *
 *  @return An instance of `TVIVideoTrackPublication` if found, otherwise `nil`.
 */
- (nullable TVIVideoTrackPublication *)getVideoTrack:(nonnull NSString *)sid;

/**
 *  @brief A utility method which finds a `TVIDataTrackPublication` by its `sid`.
 *
 *  @param sid The track sid.
 *
 *  @return An instance of `TVIDataTrackPublication` if found, otherwise `nil`.
 */
- (nullable TVIDataTrackPublication *)getDataTrack:(nonnull NSString *)sid;

@end
