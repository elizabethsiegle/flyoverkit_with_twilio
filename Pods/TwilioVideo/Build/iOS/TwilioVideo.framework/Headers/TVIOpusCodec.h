//
//  TVIOpusCodec.h
//  TwilioVideo
//
//  Copyright © 2018 Twilio, Inc. All rights reserved.
//

#import "TVIAudioCodec.h"

/**
 * @brief Lossy audio coding format.
 *
 * @see [Opus](https://en.wikipedia.org/wiki/Opus_(audio_format))
 */
@interface TVIOpusCodec : TVIAudioCodec

/**
 * Initialzes an instance of the `TVIOpusCodec` codec.
 */
- (null_unspecified instancetype)init;

@end
