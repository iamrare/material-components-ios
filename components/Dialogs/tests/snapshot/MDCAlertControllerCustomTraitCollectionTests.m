// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MDCAvailability.h"
#import "MDCButton.h"
#import "MDCAlertController.h"
#import "UIFont+MaterialScalable.h"
#import "UIColor+MaterialDynamic.h"

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "../../src/private/MDCDialogShadowedView.h"
#import "MDCAlertController+ButtonForAction.h"
#import "MDCFontScaler.h"
#import "MDCSnapshotTestCase.h"
#import "UIView+MDCSnapshot.h"

static NSDictionary<UIContentSizeCategory, NSNumber *> *CustomScalingCurve() {
  static NSDictionary<UIContentSizeCategory, NSNumber *> *scalingCurve;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    scalingCurve = @{
      UIContentSizeCategoryExtraSmall : @99,
      UIContentSizeCategorySmall : @98,
      UIContentSizeCategoryMedium : @97,
      UIContentSizeCategoryLarge : @96,
      UIContentSizeCategoryExtraLarge : @95,
      UIContentSizeCategoryExtraExtraLarge : @94,
      UIContentSizeCategoryExtraExtraExtraLarge : @93,
      UIContentSizeCategoryAccessibilityMedium : @92,
      UIContentSizeCategoryAccessibilityLarge : @91,
      UIContentSizeCategoryAccessibilityExtraLarge : @90,
      UIContentSizeCategoryAccessibilityExtraExtraLarge : @89,
      UIContentSizeCategoryAccessibilityExtraExtraExtraLarge : @88
    };
  });
  return scalingCurve;
}

/** A test fake window that allows overriding its @c traitCollection. */
@interface MDCAlertControllerCustomTraitCollectionTestsWindowFake : UIWindow

/** Set to override the value of @c traitCollection. */
@property(nonatomic, strong) UITraitCollection *traitCollectionOverride;

@end

@implementation MDCAlertControllerCustomTraitCollectionTestsWindowFake

- (UITraitCollection *)traitCollection {
  return self.traitCollectionOverride ?: [super traitCollection];
}

@end

/**
 A @c MDCAlertController test fake to override the @c traitCollection to test for dynamic type.
 */
@interface AlertControllerCustomTraitCollectionSnapshotTestFake : MDCAlertController
@property(nonatomic, strong) UITraitCollection *traitCollectionOverride;
@end

@implementation AlertControllerCustomTraitCollectionSnapshotTestFake

- (UITraitCollection *)traitCollection {
  return self.traitCollectionOverride ?: [super traitCollection];
}

@end

/** An @c MDCDialogShadowedView test fake to override the @c traitCollection to test. */
@interface ShadowViewCustomTraitCollectionSnapshotTestFake : MDCDialogShadowedView
@property(nonatomic, strong) UITraitCollection *traitCollectionOverride;
@end

@implementation ShadowViewCustomTraitCollectionSnapshotTestFake

- (UITraitCollection *)traitCollection {
  return self.traitCollectionOverride ?: [super traitCollection];
}

@end

@interface MDCAlertControllerCustomTraitCollectionTests : MDCSnapshotTestCase
@property(nonatomic, strong, nullable)
    AlertControllerCustomTraitCollectionSnapshotTestFake *alertController;
@end

@implementation MDCAlertControllerCustomTraitCollectionTests

- (void)setUp {
  [super setUp];

  // Uncomment below to recreate all the goldens (or add the following line to the specific
  // test you wish to recreate the golden for).
  //  self.recordMode = YES;

  self.alertController = [[AlertControllerCustomTraitCollectionSnapshotTestFake alloc] init];
  self.alertController.title = @"Material";
  self.alertController.message =
      @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt "
      @"ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation "
      @"ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in "
      @"reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur "
      @"sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id "
      @"est laborum.";
  MDCAlertAction *fakeAction = [MDCAlertAction actionWithTitle:@"Foo"
                                                       handler:^(MDCAlertAction *action){
                                                       }];
  [self.alertController addAction:fakeAction];
  MDCFontScaler *titleFontScaler = [MDCFontScaler scalerForMaterialTextStyle:MDCTextStyleSubtitle1];
  UIFont *titleFont = [UIFont fontWithName:@"Zapfino" size:14];
  titleFont = [titleFontScaler scaledFontWithFont:titleFont];
  titleFont = [titleFont mdc_scaledFontAtDefaultSize];
  self.alertController.titleFont = titleFont;
  MDCFontScaler *messageFontScaler = [MDCFontScaler scalerForMaterialTextStyle:MDCTextStyleBody2];
  UIFont *messageFont = [UIFont fontWithName:@"Zapfino" size:14];
  messageFont = [messageFontScaler scaledFontWithFont:messageFont];
  messageFont = [messageFont mdc_scaledFontAtDefaultSize];
  self.alertController.messageFont = messageFont;
  MDCFontScaler *buttonFontScaler = [MDCFontScaler scalerForMaterialTextStyle:MDCTextStyleButton];
  UIFont *buttonFont = [UIFont fontWithName:@"Zapfino" size:14];
  buttonFont = [buttonFontScaler scaledFontWithFont:buttonFont];
  buttonFont = [buttonFont mdc_scaledFontAtDefaultSize];
  for (MDCAlertAction *action in self.alertController.actions) {
    [[self.alertController buttonForAction:action] setTitleFont:buttonFont
                                                       forState:UIControlStateNormal];
  }
  self.alertController.view.bounds = CGRectMake(0, 0, 300, 300);
}

- (void)tearDown {
  self.alertController = nil;

  [super tearDown];
}

- (void)generateSnapshotAndVerifyForView:(UIView *)view {
  [view layoutIfNeeded];
  UIView *snapshotView = [view mdc_addToBackgroundView];
  [self snapshotVerifyView:snapshotView];
}

/** Used to set the @c UIContentSizeCategory on an @c MDCAlertController. */
- (void)setAlertControllerContentSizeCategory:(UIContentSizeCategory)sizeCategory {
  UITraitCollection *traitCollection = [[UITraitCollection alloc] init];
  traitCollection =
      [UITraitCollection traitCollectionWithPreferredContentSizeCategory:sizeCategory];

  self.alertController.traitCollectionOverride = traitCollection;
}

#pragma mark - Dynamic Type

/**
 Tests the original MDCTypography behavior for Dynamic Type.

 @note The output depends on the host simulator and is equal to
       @c testSystemFontScaledWhenScaledFontUnavailableForContentSizeAXXXL as a result.
 */
- (void)testSystemFontScaledWhenScaledFontUnavailableForContentSizeExtraSmall {
  // Given

  UIFont *originalFont = [UIFont fontWithName:@"Zapfino" size:20];
  UIFontMetrics *fontMetrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline];
  self.alertController.messageFont = [fontMetrics scaledFontForFont:originalFont];
  self.alertController.titleFont = [fontMetrics scaledFontForFont:originalFont];
  for (MDCAlertAction *action in self.alertController.actions) {
    [[self.alertController buttonForAction:action] setTitleFont:originalFont
                                                       forState:UIControlStateNormal];
  }
  [self setAlertControllerContentSizeCategory:UIContentSizeCategoryExtraSmall];

  // When
  [self.alertController loadViewIfNeeded];
  self.alertController.adjustsFontForContentSizeCategory = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.alertController.view];
}

/**
 Tests the original MDCTypography behavior for Dynamic Type.

 @note The output depends on the host simulator and is equal to
       @c testSystemFontScaledWhenScaledFontUnavailableForContentSizeExtraSmall as a result.
 */
- (void)testSystemFontScaledWhenScaledFontUnavailableForContentSizeAXXXL {
  // Given

  // Although the font is initialized with point size 1, the MDCTypography behavior will select
  // a fixed point size for the font at the current UIContentSizeCategory (of the host app),
  // which is not 1.
  UIFont *originalFont = [UIFont fontWithName:@"Zapfino" size:20];
  UIFontMetrics *fontMetrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline];
  self.alertController.messageFont = [fontMetrics scaledFontForFont:originalFont];
  self.alertController.titleFont = [fontMetrics scaledFontForFont:originalFont];
  for (MDCAlertAction *action in self.alertController.actions) {
    [[self.alertController buttonForAction:action] setTitleFont:originalFont
                                                       forState:UIControlStateNormal];
  }
  [self
      setAlertControllerContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

  // When
  [self.alertController loadViewIfNeeded];
  self.alertController.adjustsFontForContentSizeCategory = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.alertController.view];
}

/** Tests behavior when a font generated from a FontScaler is provided. */
- (void)testFontScalerFontScaledForContentSizeExtraSmall {
  // Given
  UIFont *originalFont = [UIFont fontWithName:@"Zapfino" size:20];
  UIFontMetrics *fontMetrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline];
  self.alertController.messageFont = [fontMetrics scaledFontForFont:originalFont];
  self.alertController.titleFont = [fontMetrics scaledFontForFont:originalFont];
  for (MDCAlertAction *action in self.alertController.actions) {
    [[self.alertController buttonForAction:action] setTitleFont:originalFont
                                                       forState:UIControlStateNormal];
  }
  [self setAlertControllerContentSizeCategory:UIContentSizeCategoryExtraSmall];

  // When
  [self.alertController loadViewIfNeeded];
  self.alertController.adjustsFontForContentSizeCategory = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.alertController.view];
}

/** Tests behavior when a font generated from a FontScaler is provided. */
- (void)testFontScalerFontScaledForContentSizeAXXXL {
  // Given
  UIFont *originalFont = [UIFont fontWithName:@"Zapfino" size:1];
  // Simulates a font scaler by providing scaling curve dictionary.
  originalFont.mdc_scalingCurve = CustomScalingCurve();
  self.alertController.messageFont = originalFont;
  self.alertController.titleFont = originalFont;
  for (MDCAlertAction *action in self.alertController.actions) {
    [[self.alertController buttonForAction:action] setTitleFont:originalFont
                                                       forState:UIControlStateNormal];
  }
  [self
      setAlertControllerContentSizeCategory:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

  // When
  [self.alertController loadViewIfNeeded];
  self.alertController.adjustsFontForContentSizeCategory = YES;

  // Then
  [self generateSnapshotAndVerifyForView:self.alertController.view];
}

/**
 Test that @c adjustsFontForContentSizeCategory will scale an appropriate font to a larger
 size when the preferred content size category increases.
 */
- (void)testAdjustsFontForContentSizeUpscalesUIFontMetricsFontsForSizeCategoryAXXXL {
  // Given
  UIFontMetrics *bodyMetrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleBody];
  UITraitCollection *extraSmallTraits = [UITraitCollection
      traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryExtraSmall];

  UIFont *titleFont = [UIFont fontWithName:@"Zapfino" size:20];
  XCTAssertNotNil(titleFont);
  titleFont = [bodyMetrics scaledFontForFont:titleFont
               compatibleWithTraitCollection:extraSmallTraits];
  self.alertController.titleFont = titleFont;

  UIFont *messageFont = [UIFont fontWithName:@"Zapfino" size:15];
  messageFont = [bodyMetrics scaledFontForFont:messageFont
                 compatibleWithTraitCollection:extraSmallTraits];
  self.alertController.messageFont = messageFont;

  UIFont *buttonFont = [UIFont fontWithName:@"Zapfino" size:20];
  buttonFont = [bodyMetrics scaledFontForFont:buttonFont
                compatibleWithTraitCollection:extraSmallTraits];
  for (MDCAlertAction *action in self.alertController.actions) {
    MDCButton *button = [self.alertController buttonForAction:action];
    button.titleLabel.font = buttonFont;
  }

  self.alertController.adjustsFontForContentSizeCategory = YES;
  [self.alertController loadViewIfNeeded];

  // The initial size is calculated without constraints, so start the view bounds there.
  CGSize alertSize = self.alertController.preferredContentSize;
  self.alertController.view.bounds = CGRectMake(0, 0, alertSize.width, alertSize.height);

  // Create a window so the Alert's view can inherit the trait environment.
  MDCAlertControllerCustomTraitCollectionTestsWindowFake *window =
      [[MDCAlertControllerCustomTraitCollectionTestsWindowFake alloc] init];
  [window makeKeyWindow];
  window.hidden = NO;
  [window addSubview:self.alertController.view];

  // When
  window.traitCollectionOverride =
      [UITraitCollection traitCollectionWithPreferredContentSizeCategory:
                             UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];
  [window traitCollectionDidChange:nil];
  // Recalculates the preferredContentSize of the AlertController.
  [self.alertController.view layoutIfNeeded];
  alertSize = self.alertController.preferredContentSize;
  window.bounds = CGRectMake(0, 0, alertSize.width, alertSize.height);
  self.alertController.view.frame = window.bounds;

  // Then
  // Can't add a UIWindow to a UIView, so just screenshot the window directly.
  [window layoutIfNeeded];
  [self snapshotVerifyView:window];
}

/**
 Test that @c adjustsFontForContentSizeCategory will scale an appropriate font to a
 smaller size when the preferred content size category decreases.
 */
- (void)testAdjustsFontForContentSizeDownscalesUIFontMetricsFontsForSizeCategoryXS {
  // Given
  UIFontMetrics *bodyMetrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleBody];
  UITraitCollection *aXXXLTraits =
      [UITraitCollection traitCollectionWithPreferredContentSizeCategory:
                             UIContentSizeCategoryAccessibilityExtraExtraExtraLarge];

  UIFont *titleFont = [UIFont fontWithName:@"Zapfino" size:20];
  XCTAssertNotNil(titleFont);
  titleFont = [bodyMetrics scaledFontForFont:titleFont compatibleWithTraitCollection:aXXXLTraits];
  self.alertController.titleFont = titleFont;

  UIFont *messageFont = [UIFont fontWithName:@"Zapfino" size:15];
  messageFont = [bodyMetrics scaledFontForFont:messageFont
                 compatibleWithTraitCollection:aXXXLTraits];
  self.alertController.messageFont = messageFont;

  UIFont *buttonFont = [UIFont fontWithName:@"Zapfino" size:20];
  buttonFont = [bodyMetrics scaledFontForFont:buttonFont compatibleWithTraitCollection:aXXXLTraits];
  for (MDCAlertAction *action in self.alertController.actions) {
    MDCButton *button = [self.alertController buttonForAction:action];
    button.titleLabel.font = buttonFont;
  }

  self.alertController.adjustsFontForContentSizeCategory = YES;
  [self.alertController loadViewIfNeeded];

  // The initial size is calculated without constraints, so start the view bounds there.
  CGSize alertSize = self.alertController.preferredContentSize;
  self.alertController.view.bounds = CGRectMake(0, 0, alertSize.width, alertSize.height);

  // Create a window so the Alert's view can inherit the trait environment.
  MDCAlertControllerCustomTraitCollectionTestsWindowFake *window =
      [[MDCAlertControllerCustomTraitCollectionTestsWindowFake alloc] init];
  [window makeKeyWindow];
  window.hidden = NO;
  [window addSubview:self.alertController.view];

  // When
  window.traitCollectionOverride = [UITraitCollection
      traitCollectionWithPreferredContentSizeCategory:UIContentSizeCategoryExtraSmall];
  [window traitCollectionDidChange:nil];
  // Recalculates the preferredContentSize of the AlertController.
  [self.alertController.view layoutIfNeeded];
  alertSize = self.alertController.preferredContentSize;
  window.bounds = CGRectMake(0, 0, alertSize.width, alertSize.height);
  self.alertController.view.frame = window.bounds;

  // Then
  // Can't add a UIWindow to a UIView, so just screenshot the window directly.
  [window layoutIfNeeded];
  [self snapshotVerifyView:window];
}

#pragma mark - Dynamic Color

- (void)testDynamicColorSupport {
#if MDC_AVAILABLE_SDK_IOS(13_0)
  if (@available(iOS 13.0, *)) {
    // Given
    UIColor *titleColor = [UIColor colorWithUserInterfaceStyleDarkColor:UIColor.greenColor
                                                           defaultColor:UIColor.blackColor];
    UIColor *messageColor = [UIColor colorWithUserInterfaceStyleDarkColor:UIColor.purpleColor
                                                             defaultColor:UIColor.blackColor];
    UIColor *backgroundColor = [UIColor colorWithUserInterfaceStyleDarkColor:UIColor.blueColor
                                                                defaultColor:UIColor.blackColor];
    self.alertController.titleColor = titleColor;
    self.alertController.messageColor = messageColor;
    self.alertController.backgroundColor = backgroundColor;

    // When
    self.alertController.traitCollectionOverride =
        [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];

    // Then
    UIView *snapshotView = [self.alertController.view
        mdc_addToBackgroundViewWithInsets:UIEdgeInsetsMake(50, 50, 50, 50)];
    [self snapshotVerifyViewForIOS13:snapshotView];
  }
#endif  // MDC_AVAILABLE_SDK_IOS(13_0)
}

- (void)testDynamicColorSupportForTrackingView {
#if MDC_AVAILABLE_SDK_IOS(13_0)
  if (@available(iOS 13.0, *)) {
    // Given
    UIColor *shadowColor = [UIColor colorWithUserInterfaceStyleDarkColor:UIColor.greenColor
                                                            defaultColor:UIColor.blackColor];
    ShadowViewCustomTraitCollectionSnapshotTestFake *trackingView =
        [[ShadowViewCustomTraitCollectionSnapshotTestFake alloc] init];
    trackingView.frame = CGRectMake(0, 0, 100, 200);
    trackingView.shadowColor = shadowColor;
    trackingView.backgroundColor = UIColor.whiteColor;

    // When
    trackingView.traitCollectionOverride =
        [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
    [trackingView layoutIfNeeded];

    // Then
    UIView *snapshotView =
        [trackingView mdc_addToBackgroundViewWithInsets:UIEdgeInsetsMake(50, 50, 50, 50)];
    [self snapshotVerifyViewForIOS13:snapshotView];
  }
#endif  // MDC_AVAILABLE_SDK_IOS(13_0)
}

@end
