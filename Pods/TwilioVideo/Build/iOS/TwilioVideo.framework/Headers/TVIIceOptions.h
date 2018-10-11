//
//  TVIIceOptions.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  `TVIIceTransportPolicy` specifies which ICE transports to allow.
 */
typedef NS_ENUM(NSUInteger, TVIIceTransportPolicy) {
    /**
     *  All transports will be used.
     */
    TVIIceTransportPolicyAll = 0,
    /**
     *  Only TURN relay transports will be used.
     */
    TVIIceTransportPolicyRelay = 1
};

/**
 *  `TVIIceServer` is a single STUN or TURN server.
 */
@interface TVIIceServer : NSObject

/**
 *  @brief The URL string for the ICE server.
 *
 *  @discussion Your server URL must begin with either the stun: or turn: scheme.
 *  For example, a STUN server could be defined as <stun:stun.company.com:port>.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *urlString;

/**
 *  @brief The user name. Required for TURN servers.
 */
@property (nullable, nonatomic, readonly, copy) NSString *username;

/**
 *  @brief The password. Required for TURN servers.
 */
@property (nullable, nonatomic, readonly, copy) NSString *password;

/**
 *  Creates a `TVIIceServer`.
 *
 *  @param serverURLString The URL for your STUN or TURN server.
 *
 *  @return A `TVIIceServer` object.
 */
- (null_unspecified instancetype)initWithURLString:(nonnull NSString *)serverURLString;

/**
 *  Creates a `TVIIceServer`.
 *
 *  @param serverURLString The URL for your STUN or TURN server.
 *  @param username The username credential for your server.
 *  @param password The password credential for your server.
 *
 *  @return A `TVIIceServer` object.
 */
- (null_unspecified instancetype)initWithURLString:(nonnull NSString *)serverURLString
                                          username:(nullable NSString *)username
                                          password:(nullable NSString *)password;

/**
 *  @brief Developers should initialize with a parameterized initializer.
 *
 *  @discussion `TVIIceServer` cannot be created without supplying parameters.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("TVIIceServer must be created with a parameterized initializer.")));

@end

/**
 *  @brief `TVIIceOptionsBuilder` constructs `TVIIceOptions`.
 *
 *  @discussion If you provide a `transportPolicy` but do not provide any ICE Servers, then the servers will automatically
 *  be fetched for you based upon how the Room was created. For Client created Rooms the default Room settings
 *  are used, while settings are provided on a per-Room basis when creating Rooms using the REST API.
 */
@interface TVIIceOptionsBuilder : NSObject

/**
 *  @brief An array of `TVIIceServer` objects to be used during connection establishment.
 */
@property (nonatomic, strong, nullable) NSArray<TVIIceServer *> *servers;

/**
 *  @brief The transport policy to use. Defaults to `TVIIceTransportPolicyAll`.
 */
@property (nonatomic, assign) TVIIceTransportPolicy transportPolicy;

/**
 *  @brief Whether to abort if ICE servers time out.
 *
 *  @discussion If fetching ICE servers times out (due to a restrictive network or a slow network proxy), then, by default,
 *  the Video SDK will fallback to using hard-coded STUN servers and continue connecting to the Room.
 *  Setting this property to true will instead abort with error 53500, "Unable to acquire configuration".
 *  Defaults to 'NO'.
 */
@property (nonatomic, assign) BOOL abortOnIceServersTimeout;

/**
 *  @brief The timeout to wait (before aborting) when acquiring ICE servers. Defaults to 3 seconds.
 */
@property (nonatomic, assign) NSTimeInterval iceServersTimeout;

- (null_unspecified instancetype)init __attribute__((unavailable("Use a TVIIceOptionsBuilderBlock instead.")));

@end

/**
 *  @brief `TVIIceOptionsBuilderBlock` is a block to configure ICE options.
 *
 *  @param builder The builder
 */
typedef void (^TVIIceOptionsBuilderBlock)(TVIIceOptionsBuilder * _Nonnull builder);

/**
 *  @brief `TVIIceOptions` specifies custom media connectivity configurations.
 *
 *  @discussion Media connections are established using the ICE (Interactive Connectivity Establishment) protocol.
 *  These options allow you to customize how data flows to and from participants, and which protocols to use.
 *  You may also provide your own ICE servers, overriding the defaults.
 *  https://www.twilio.com/stun-turn
 */
@interface TVIIceOptions : NSObject

/**
 *  @brief An array of `TVIIceServer` objects to be used during connection establishment.
 */
@property (nonatomic, copy, nonnull, readonly) NSArray<TVIIceServer *> *servers;

/**
 *  @brief The transport policy to use. Defaults to `TVIIceTransportPolicyAll`.
 */
@property (nonatomic, assign, readonly) TVIIceTransportPolicy transportPolicy;

/**
 *  @brief Whether to abort if ICE servers time out.
 *
 *  @discussion If fetching ICE servers times out (due to a restrictive network or a slow network proxy), then, by default,
 *  the Video SDK will fallback to using hard-coded STUN servers and continue connecting to the Room.
 *  Setting this property to true will instead abort with error 53500, "Unable to acquire configuration".
 *  Defaults to 'NO'.
 */
@property (nonatomic, assign, readonly) BOOL abortOnIceServersTimeout;

/**
 *  @brief The timeout to wait (before aborting) when acquiring ICE servers. Defaults to 3 seconds.
 */
@property (nonatomic, assign, readonly) NSTimeInterval iceServersTimeout;

/**
 *  @brief Creates a default `TVIIceOptions` instance.
 *
 *  @return An instance of `TVIIceOptions`.
 */
+ (_Null_unspecified instancetype)options;

/**
 *  @brief Creates a `TVIIceOptions` instance using a builder block that you specify.
 *
 *  @param block A `TVIIceOptionsBuilderBlock` which sets specific options on the builder.
 *
 *  @return A `TVIIceOptions` instance created using options set in the builder block.
 */
+ (nonnull instancetype)optionsWithBlock:(nonnull TVIIceOptionsBuilderBlock)block;

@end
