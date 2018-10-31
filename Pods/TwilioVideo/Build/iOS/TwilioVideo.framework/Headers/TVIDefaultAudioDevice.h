//
//  TVIDefaultAudioDevice.h
//  TwilioVideo
//
//  Copyright © 2017 Twilio, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "TVIAudioDevice.h"

static NSTimeInterval const kTVIDefaultAudioDeviceIOBufferDurationSimulator = 0.02;
static double const kTVIDefaultAudioDeviceSampleRateSimulator = 48000;

/**
 *  `TVIAVAudioSessionConfigurationBlock` allows you to configure AVAudioSession.
 */
typedef void (^TVIAVAudioSessionConfigurationBlock)(void);

/**
 *  `kDefaultAVAudioSessionConfigurationBlock` configures AVAudioSession with the default values for a bidirectional
 *  VOIP audio call.
 */
static TVIAVAudioSessionConfigurationBlock _Nonnull kDefaultAVAudioSessionConfigurationBlock = ^() {
    AVAudioSession *session = [AVAudioSession sharedInstance];

    NSError *error = nil;
    if (@available(iOS 10.0, *)) {
        if ([session respondsToSelector:@selector(setCategory:mode:options:error:)]) {
            if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                                 mode:AVAudioSessionModeVideoChat
                              options:AVAudioSessionCategoryOptionAllowBluetooth
                                error:&error]) {
                NSLog(@"AVAudioSession setCategory:options:mode:error: %@",error);
            }
        }
    } else {
        if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                      withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                            error:&error]) {
            NSLog(@"AVAudioSession setCategory:withOptions:error: %@",error);
        }

        if (![session setMode:AVAudioSessionModeVideoChat error:&error]) {
            NSLog(@"AVAudioSession setMode:error: %@",error);
        }
    }

#if TARGET_IPHONE_SIMULATOR
    // Workaround for issues using 48 khz / 10 msec on the simulator: https://bugs.chromium.org/p/webrtc/issues/detail?id=6644
    double sampleRate = kTVIDefaultAudioDeviceSampleRateSimulator;
    double ioBufferDuration = kTVIDefaultAudioDeviceIOBufferDurationSimulator;
#else
    // In WebRTC-67 a 20 msec duration is preferred with the default device.
    double sampleRate = 48000;
    double ioBufferDuration = 0.02;
#endif
    if (![session setPreferredSampleRate:sampleRate error:&error]) {
        NSLog(@"AVAudioSession setPreferredSampleRate:error: %@", error);
    }
    if (![session setPreferredIOBufferDuration:ioBufferDuration error:&error]) {
        NSLog(@"AVAudioSession setPreferredIOBufferDuration:error: %@", error);
    }

    // Make sure AVAudioSession is not activated while configuring the aggregatedIOPreference.

    if (@available(iOS 10.0, *)) {
        if ([[AVAudioSession sharedInstance] respondsToSelector: @selector(setAggregatedIOPreference:error:)]) {
            if (![session setAggregatedIOPreference:AVAudioSessionIOTypeAggregated error:&error]) {
                NSLog(@"AVAudioSession setAggregatedIOPreference:error: %@", error);
            }
        }
    }

    /*
     * You should not set `preferredInputNumberOfChannels` and `preferredOutputNumberOfChannels` until the
     * AVAudioSession is activated. Since this block will be called before and after activation, we first check the
     * maximum number of channels before setting our preferences. `TVIDefaultAudioDevice` configures an AudioUnit graph
     * which uses mono I/O, but adapts to the current sample rate.
     */
    if (session.maximumInputNumberOfChannels > 0 &&
        ![session setPreferredInputNumberOfChannels:1 error:&error]) {
        NSLog(@"AVAudioSession setPreferredInputNumberOfChannels:error: %@", error);
    }

    if (session.maximumOutputNumberOfChannels > 0 &&
        ![session setPreferredOutputNumberOfChannels:1 error:&error]) {
        NSLog(@"AVAudioSession setPreferredOutputNumberOfChannels:error: %@", error);
    }
};

/**
 *  `TVIDefaultAudioDevice` allows you to record and playback audio when you are connected to a Room.
 */
@interface TVIDefaultAudioDevice : NSObject <TVIAudioDevice>

/**
   @brief A block to configure the AVAudiosession.

   @discussion  If `TVIDefaultAudioDevice` is `enabled`, the SDK executes this block and activates the audio session while
   connecting to a Room, otherwise it is the developer's responsibility to execute the block. Please note that the getter of
   this property returns a wrapper block which internally executes the block you set. By default, the SDK returns a default
   wrapper block which executes `kDefaultAVAudioSessionConfigurationBlock` internally.

   The following example demonstrates changing the audio route from speaker to receiver:

      TVIDefaultAudioDevice *audioDevice = [TVIDefaultAudioDevice audioDevice];

      TwilioVideo.audioDevice = audioDevice;

      //...connect to a Room with audioDevice. By default the audio route will be configured to speaker.

      audioDevice.block =  ^ {
          // We will execute `kDefaultAVAudioSessionConfigurationBlock` first.
          kDefaultAVAudioSessionConfigurationBlock();

          // Overwrite the audio route
          AVAudioSession *session = [AVAudioSession sharedInstance];
          NSError *error = nil;
          if (![session setMode:AVAudioSessionModeVoiceChat error:&error]) {
              NSLog(@"AVAudiosession setMode %@",error);
          }

          if (![session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error]) {
              NSLog(@"AVAudiosession overrideOutputAudioPort %@",error);
          }
      };
      audioDevice.block();
 */
@property (nonatomic, copy, nonnull) TVIAVAudioSessionConfigurationBlock block;

/**
 *  @brief A boolean which enables playback and recording.
 *
 *  @discussion By default, the SDK initializes this property to YES. Setting it to NO forces the underlying CoreAudio
 *  graph to be stopped (if active), and prevents it from being started again. Setting the property to YES allows the
 *  audio graph to be started whenever there is audio to play or record in a Room.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Use `defaultAudioDevice`to create a `TVIDefaultAudioDevice`.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use `audioDevice` to create a `TVIDefaultAudioDevice`.")));

/**
 *  @brief Factory method to create an instance of `TVIDefaultAudioDevice`.
 */
+ (nonnull instancetype)audioDevice;

/**
   @brief Factory method with a block to create an instance of `TVIDefaultAudioDevice`.
   @param block The AVAudioSession configuration block.
   @return An instance of TVIDefaultAudioDevice.

   @discussion Use this factory method if you want to connect to a Room with your choice of audio session configuration.
 
   The following example demonstrates connecting to a Room using the AVAudioSessionCategoryPlayback category:

      TwilioVideo.audioDevice = [TVIDefaultAudioDevice audioDeviceWithBlock:^ {
        // We will execute `kDefaultAVAudioSessionConfigurationBlock` first.
        kDefaultAVAudioSessionConfigurationBlock();

        // Overwrite the category to `playback`
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                             mode:AVAudioSessionModeVideoChat
                          options:AVAudioSessionCategoryOptionAllowBluetooth
                            error:&error]) {
            NSLog(@"AVAudioSession setCategory:options:mode:error: %@",error);
        }
      }];

      TVIConnectOptions *connectOptions = [TVIConnectOptions optionsWithToken:token
                                                                      block:^(TVIConnectOptionsBuilder *builder) {
                                                                        builder.audioTracks = @[[TVILocalAudioTrack track]];
                                                                    }];

      TVIRoom *room = [TwilioVideo connectWithOptions:connectOptions];
 */
+ (nonnull instancetype)audioDeviceWithBlock:(TVIAVAudioSessionConfigurationBlock _Nonnull )block;

@end
