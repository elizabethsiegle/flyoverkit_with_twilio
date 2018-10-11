//
//  TVIRemoteParticipant.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVIParticipant.h"

@protocol TVIRemoteParticipantDelegate;
@class TVIRemoteAudioTrackPublication;
@class TVIRemoteDataTrackPublication;
@class TVIRemoteVideoTrackPublication;
@class TVIRemoteAudioTrack;
@class TVIRemoteDataTrack;
@class TVIRemoteVideoTrack;


/**
 *  `TVIRemoteParticipant` represents a remote Participant in a Room which you are connected to.
 */
@interface TVIRemoteParticipant : TVIParticipant

/**
 *  @brief Indicates if the Participant is connected to the Room.
 */
@property (nonatomic, assign, readonly, getter=isConnected) BOOL connected;

/**
 *  @brief The Remote Participant's delegate. Set this property to be notified about Participant events such as tracks being
 *  added or removed.
 */
@property (atomic, weak, nullable) id<TVIRemoteParticipantDelegate> delegate;

/**
 *  @brief The collection of Remote Audio Tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIRemoteAudioTrackPublication *> *remoteAudioTracks;

/**
 *  @brief The collection of Remote Video Tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIRemoteVideoTrackPublication *> *remoteVideoTracks;

/**
 *  @brief The collection of Remote Data Tracks.
 */
@property (nonatomic, copy, readonly, nonnull) NSArray<TVIRemoteDataTrackPublication *> *remoteDataTracks;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Use `TwilioVideo` connectWith* methods to join a `TVIRoom` with `TVIRemoteParticipant` instances.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use TwilioVideo connectWith* methods to join a TVIRoom with TVIRemoteParticipant instances.")));

@end


/**
 *  `TVIRemoteParticipantDelegate` provides callbacks when important changes to a `TVIRemoteParticipant` occur.
 */
@protocol TVIRemoteParticipantDelegate <NSObject>

@optional

/**
 * @brief Delegate method called when the Participant publishes a video track.
 *
 * @param participant The remote Participant.
 * @param publication The remote video track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant publishedVideoTrack:(nonnull TVIRemoteVideoTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant unpublishes a video track.
 *
 * @param participant The remote Participant.
 * @param publication The remote video track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant unpublishedVideoTrack:(nonnull TVIRemoteVideoTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant publishes an audio track.
 *
 * @param participant The remote Participant.
 * @param publication The remote audio track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant publishedAudioTrack:(nonnull TVIRemoteAudioTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant unpublishes an audio track.
 *
 * @param participant The remote Participant.
 * @param publication The remote audio track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant unpublishedAudioTrack:(nonnull TVIRemoteAudioTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant publishes a data track.
 *
 * @param participant The remote Participant.
 * @param publication The remote data track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant publishedDataTrack:(nonnull TVIRemoteDataTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant unpublishes a data track.
 *
 * @param participant The remote Participant.
 * @param publication The remote data track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant unpublishedDataTrack:(nonnull TVIRemoteDataTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant enables a video track.
 *
 * @param participant The remote Participant.
 * @param publication The remote video track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant enabledVideoTrack:(nonnull TVIRemoteVideoTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant disables a video track.
 *
 * @param participant The remote Participant.
 * @param publication The remote video track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant disabledVideoTrack:(nonnull TVIRemoteVideoTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant enables an audio track.
 *
 * @param participant The remote Participant.
 * @param publication The remote audio track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant enabledAudioTrack:(nonnull TVIRemoteAudioTrackPublication *)publication;

/**
 * @brief Delegate method called when the Participant disables an audio track.
 *
 * @param participant The remote Participant.
 * @param publication The remote audio track publication.
 */
- (void)remoteParticipant:(nonnull TVIRemoteParticipant *)participant disabledAudioTrack:(nonnull TVIRemoteAudioTrackPublication *)publication;

/**
 * @brief Delegate method called when the local Participant has succesfully subscribed to the Participant's remote video track.
 *
 * @param videoTrack The remote video track.
 * @param publication The remote video track publication.
 * @param participant The remote Participant.
 */
- (void)subscribedToVideoTrack:(nonnull TVIRemoteVideoTrack *)videoTrack
                   publication:(nonnull TVIRemoteVideoTrackPublication *)publication
                forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has failed to subscribe to the Participant's remote video track publication.
 *
 * @param publication The remote video track publication.
 * @param error The error which indicates why the subscription failed.
 * @param participant The remote Participant.
 */
- (void)failedToSubscribeToVideoTrack:(nonnull TVIRemoteVideoTrackPublication *)publication
                                error:(nonnull NSError *)error
                       forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has succesfully unsubscribed from the Participant's remote video track.
 *
 * @param videoTrack The remote video track.
 * @param publication The remote video track publication.
 * @param participant The remote Participant.
 */
- (void)unsubscribedFromVideoTrack:(nonnull TVIRemoteVideoTrack *)videoTrack
                       publication:(nonnull TVIRemoteVideoTrackPublication *)publication
                    forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has succesfully subscribed to the Participant's remote audio track.
 *
 * @param audioTrack The remote audio track.
 * @param publication The remote audio track publication.
 * @param participant The remote Participant.
 */
- (void)subscribedToAudioTrack:(nonnull TVIRemoteAudioTrack *)audioTrack
                   publication:(nonnull TVIRemoteAudioTrackPublication *)publication
                forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has failed to subscribe to the Participant's remote audio track publication.
 *
 * @param publication The remote audio track publication.
 * @param error The error which indicates why the subscription failed.
 * @param participant The remote Participant.
 */
- (void)failedToSubscribeToAudioTrack:(nonnull TVIRemoteAudioTrackPublication *)publication
                                error:(nonnull NSError *)error
                       forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has succesfully unsubscribed from the Participant's remote audio track.
 *
 * @param audioTrack The remote audio track.
 * @param publication The remote audio track publication.
 * @param participant The remote Participant.
 */
- (void)unsubscribedFromAudioTrack:(nonnull TVIRemoteAudioTrack *)audioTrack
                       publication:(nonnull TVIRemoteAudioTrackPublication *)publication
                    forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has succesfully subscribed to the Participant's remote data track.
 *
 * @param dataTrack The remote data track.
 * @param publication The remote data track publication.
 * @param participant The remote Participant.
 */
- (void)subscribedToDataTrack:(nonnull TVIRemoteDataTrack *)dataTrack
                  publication:(nonnull TVIRemoteDataTrackPublication *)publication
               forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has failed to subscribe to the Participant's remote data track publication.
 *
 * @param publication The remote data track publication.
 * @param error The error which indicates why the subscription failed.
 * @param participant The remote Participant.
 */
- (void)failedToSubscribeToDataTrack:(nonnull TVIRemoteDataTrackPublication *)publication
                               error:(nonnull NSError *)error
                      forParticipant:(nonnull TVIRemoteParticipant *)participant;

/**
 * @brief Delegate method called when the local Participant has succesfully unsubscribed from the Participant's remote data track.
 *
 * @param dataTrack The remote data track.
 * @param publication The remote data track publication.
 * @param participant The remote Participant.
 */
- (void)unsubscribedFromDataTrack:(nonnull TVIRemoteDataTrack *)dataTrack
                      publication:(nonnull TVIRemoteDataTrackPublication *)publication
                   forParticipant:(nonnull TVIRemoteParticipant *)participant;

@end
