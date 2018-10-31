//
//  TVILocalParticipant.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import "TVIParticipant.h"

@protocol TVILocalParticipantDelegate;

@class TVIEncodingParameters;

@class TVILocalAudioTrackPublication;
@class TVILocalDataTrackPublication;
@class TVILocalVideoTrackPublication;

@class TVILocalAudioTrack;
@class TVILocalDataTrack;
@class TVILocalVideoTrack;

/**
 *  `TVILocalParticipant` represents your Participant in a Room which you are connected to.
 */
@interface TVILocalParticipant : TVIParticipant

/**
 *  @brief The Local Participant's delegate. Set this property to be notified about Participant events such as tracks being
 *  published.
 */
@property (atomic, weak, nullable) id<TVILocalParticipantDelegate> delegate;

/**
 * @brief A collection of `TVILocalAudioTrackPublication` objects.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVILocalAudioTrackPublication *> *localAudioTracks;

/**
 * @brief A collection of `TVILocalDataTrackPublication` objects.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVILocalDataTrackPublication *> *localDataTracks;

/**
 * @brief A collection of `TVILocalVideoTrackPublication` objects.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVILocalVideoTrackPublication *> *localVideoTracks;

/**
 *  @brief Publishes the audio track to the Room.
 *
 *  @param track The `TVILocalAudioTrack` to publish.
 *
 *  @return `YES` if the track was published successfully, `NO` otherwise.
 */
- (BOOL)publishAudioTrack:(nonnull TVILocalAudioTrack *)track;

/**
 *  @brief Publishes the data track to the Room.
 *
 *  @param track The `TVILocalDataTrack` to publish.
 *
 *  @return `YES` if the track was published successfully, `NO` otherwise.
 */
- (BOOL)publishDataTrack:(nonnull TVILocalDataTrack *)track;

/**
 *  @brief Publishes the video track to the Room.
 *
 *  @param track The `TVILocalVideoTrack` to publish.
 *
 *  @return `YES` if the track was published successfully, `NO` otherwise.
 */
- (BOOL)publishVideoTrack:(nonnull TVILocalVideoTrack *)track;

/**
 *  @brief Unpublishes the audio track from the Room.
 *
 *  @param track The `TVILocalAudioTrack` to unpublish.
 *
 *  @return `YES` if the track was unpublished successfully, `NO` otherwise.
 */
- (BOOL)unpublishAudioTrack:(nonnull TVILocalAudioTrack *)track;

/**
 *  @brief Unpublishes the data track from the Room.
 *
 *  @param track The `TVILocalDataTrack` to unpublish.
 *
 *  @return `YES` if the track was unpublished successfully, `NO` otherwise.
 */
- (BOOL)unpublishDataTrack:(nonnull TVILocalDataTrack *)track;

/**
 *  @brief Unpublishes the video track from the Room.
 *
 *  @param track The `TVILocalVideoTrack` to unpublish.
 *
 *  @return `YES` if the track was unpublished successfully, `NO` otherwise.
 */
- (BOOL)unpublishVideoTrack:(nonnull TVILocalVideoTrack *)track;

/**
 *  @brief Updates the `TVIEncodingParameters` used to share media in the Room.
 *
 *  @param encodingParameters The `TVIEncodingParameters` to use or `nil` for the default values.
 */
- (void)setEncodingParameters:(nullable TVIEncodingParameters *)encodingParameters;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Use `TwilioVideo` connectWith* methods to join a `TVIRoom` and query its `localParticipant` property.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use TwilioVideo connectWith* methods to join a TVIRoom and query its `localParticipant` property.")));

@end

/**
 *  `TVILocalParticipantDelegate` provides callbacks when important events happen to a `TVILocalParticipant`.
 */
@protocol TVILocalParticipantDelegate <NSObject>

@optional

/**
 * @brief Delegate method called when the Local Participant successfully publishes an audio track.
 *
 * @param participant The local participant.
 * @param publishedAudioTrack The `TVILocalAudioTrackPublication` object.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant publishedAudioTrack:(nonnull TVILocalAudioTrackPublication *)publishedAudioTrack;


/**
 * @brief Delegate method called when the publication of an audio track fails.
 *
 * @param participant The local participant.
 * @param audioTrack The audio track that failed publication.
 * @param error An `NSError` object describing the reason for the failure.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant
failedToPublishAudioTrack:(nonnull TVILocalAudioTrack *)audioTrack
               withError:(nonnull NSError *)error;

/**
 * @brief Delegate method called when the Local Participant successfully publishes a data track.
 *
 * @param participant The local participant.
 * @param publishedDataTrack The `TVILocalDataTrackPublication` object.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant publishedDataTrack:(nonnull TVILocalDataTrackPublication *)publishedDataTrack;

/**
 * @brief Delegate method called when the publication of a data track fails.
 *
 * @param participant The local participant.
 * @param dataTrack The data track that failed publication.
 * @param error An `NSError` object describing the reason for the failure.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant
failedToPublishDataTrack:(nonnull TVILocalDataTrack *)dataTrack
               withError:(nonnull NSError *)error;

/**
 * @brief Delegate method called when the Local Participant successfully publishes a video track.
 *
 * @param participant The local participant.
 * @param publishedVideoTrack The `TVILocalVideoTrackPublication` object.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant publishedVideoTrack:(nonnull TVILocalVideoTrackPublication *)publishedVideoTrack;

/**
 * @brief Delegate method called when the publication of a video track fails.
 *
 * @param participant The local participant.
 * @param videoTrack The video track that failed publication.
 * @param error An `NSError` object describing the reason for the failure.
 */
- (void)localParticipant:(nonnull TVILocalParticipant *)participant
failedToPublishVideoTrack:(nonnull TVILocalVideoTrack *)videoTrack
               withError:(nonnull NSError *)error;

@end
