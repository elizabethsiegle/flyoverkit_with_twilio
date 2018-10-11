//
//  TVIEncodingParameters.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * `TVIEncodingParameters` defines audio and video encoding parameters. 
 * Maximum bitrate is specified as Transport Independent Application Specific
 * Maximum (TIAS) bitrate [RFC3890](https://tools.ietf.org/html/rfc3890) in bits per second (bps) excluding
 * IP/UDP/TCP headers. These encoding parameters are applied for each PeerConnection. For peer-to-peer
 * Rooms, there is a separate PeerConnection for each participant, i.e., if you set maximum video bitrate to 1 Mbps
 * and you have two `TVIRemoteParticipant`s in the Room, the Client sends up to 2 Mbps. For group Rooms, there is a single
 * PeerConnection to Twilio's Media Server. If you are publishing multiple video tracks (e.g., video and screen
 * share), each tracks receives the maximum bitrate specified, i.e., if you set maximum video bitrate to 1 Mbps and you
 * publish both video and screen share, client sends out 2 Mbps. You may update encoding parameters any time using
 * `[TVILocalParticipant setEncodingParameters:]`.
 */
@interface TVIEncodingParameters : NSObject

/**
 *  @brief Initializes a `TVIEncodingParameters` object.
 *
 *  @param maxAudioBitrate The maximum audio send bitrate in bits per second.
 *  @param maxVideoBitrate The maximum video send bitrate in bits per second.
 *
 *  @return A `TVIEncodingParameters` instance.
 */
- (_Nonnull instancetype)initWithAudioBitrate:(NSUInteger)maxAudioBitrate videoBitrate:(NSUInteger)maxVideoBitrate;

/** 
 *  @brief Maximum audio send bitrate in bits per second.
 *
 *  @discussion Zero indicates the WebRTC default value, which is codec dependent.
 *  The maximum bitrate for [Opus](http://opus-codec.org/) is 510 kbps.
 */
@property (nonatomic, assign, readonly) NSUInteger maxAudioBitrate;

/** 
 *  @brief Maximum video send bitrate in bits per second. 
 *
 *  @discussion Zero indicates the WebRTC default value, which is 2 Mbps.
 */
@property (nonatomic, assign, readonly) NSUInteger maxVideoBitrate;

@end
