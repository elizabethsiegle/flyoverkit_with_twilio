//
//  TVIScreenCapturer.h
//  TwilioVideo
//
//  Copyright © 2016-2017 Twilio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TVIVideoCapturer.h"

/**
 *  `TVIScreenCapturer` captures from a `UIView` by using UIGraphics to draw its contents to an offscreen buffer.
 *  In iOS 12.0, Apple introduced the new A8 backing store and improved color management. However, at the same time,
 *  drawing the contents of a `UIView` became prohibitively expensive with some UIView and device combinations.
 *  For this reason we are deprecating this class on iOS 12.0 and above. If you wish to capture the entire screen (or a
 *  portion of it) then we recommend that you use ReplayKit with a custom `TVIVideoCapturer` instead.
 */
NS_DEPRECATED_IOS(8_1, 12_0, "Use ReplayKit with a custom TVIVideoCapturer instead.")
@interface TVIScreenCapturer : NSObject <TVIVideoCapturer>

/**
 *  @brief Indicates that screen capture is active.
 */
@property (atomic, assign, readonly, getter = isCapturing) BOOL capturing;

/**
 *  @brief Constructs a `TVIScreenCapturer` with a `UIView`.
 *
 *  @param view The `UIView` to capture content from.
 *
 *  @return An instance of `TVIScreenCapturer` if creation was successful, and `nil` otherwise.
 *
 *  @discussion `TVIScreenCapturer` captures the contents of a single view at 1x scale.
 *  Because this class depends on UIKit and CoreGraphics to snapshot content it does not function
 *  if the application is backgrounded. This class will not respond to `TVIVideoConstraints`.
 *  Instead, it will use the dimensions of the view to determine its capture size.
 */
- (null_unspecified instancetype)initWithView:(nonnull UIView *)view;

/**
 *  @brief Developers shouldn't initialize this class using `init`.
 *
 *  @discussion Initialize TVIScreenCapturer with a UIView.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Initialize TVIScreenCapturer with a UIView.")));

@end
