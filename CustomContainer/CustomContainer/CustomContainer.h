//
//  CustomContainer.h
//  CustomContainer
//
//  Created by zhaimengyang on 3/14/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kCustomContainerAnimationTypeCustomSegueDidBeginNotification;
extern NSString * const kCustomContainerAnimationTypeCustomSegueDidEndNotification;
extern NSString * const kCustomContainerSubClassShouldConfigureSegueNotification;

typedef void(^animationBlock)(UIViewController *fromVC, UIViewController *toVC, CGRect endedFrame);

typedef NS_ENUM(NSUInteger, CustomContainerTransitionViewControllersAnimationType) {
    CustomContainerTransitionViewControllersAnimationTypeCustomBlock,
    CustomContainerTransitionViewControllersAnimationTypeDefaultTransition,
    // __CustomSegue is NOT available__
    CustomContainerTransitionViewControllersAnimationTypeCustomSegue,
};


typedef NS_ENUM(NSUInteger, CustomContainerTransitionViewControllersAnimationOptions) {
    
    //    UIViewAnimationOptionCurveEaseInOut            = 0 << 16, // default
    //    UIViewAnimationOptionCurveEaseIn               = 1 << 16,
    //    UIViewAnimationOptionCurveEaseOut              = 2 << 16,
    //    UIViewAnimationOptionCurveLinear               = 3 << 16,
    //
    //    UIViewAnimationOptionTransitionNone            = 0 << 20, // default
    //    UIViewAnimationOptionTransitionFlipFromLeft    = 1 << 20,
    //    UIViewAnimationOptionTransitionFlipFromRight   = 2 << 20,
    //    UIViewAnimationOptionTransitionCurlUp          = 3 << 20,
    //    UIViewAnimationOptionTransitionCurlDown        = 4 << 20,
    //    UIViewAnimationOptionTransitionCrossDissolve   = 5 << 20,
    //    UIViewAnimationOptionTransitionFlipFromTop     = 6 << 20,
    //    UIViewAnimationOptionTransitionFlipFromBottom  = 7 << 20,
    
    CustomContainerTransitionViewControllersAnimationOptionCurveEaseInOut = 0 << 16, // default
    CustomContainerTransitionViewControllersAnimationOptionCurveEaseIn    = 1 << 16,
    CustomContainerTransitionViewControllersAnimationOptionCurveEaseOut   = 2 << 16,
    CustomContainerTransitionViewControllersAnimationOptionCurveLinear    = 3 << 16,
    
    CustomContainerTransitionViewControllersAnimationOptionTransitionFlipFromLeft   = 1 << 20,
    CustomContainerTransitionViewControllersAnimationOptionTransitionFlipFromRight  = 2 << 20,
    CustomContainerTransitionViewControllersAnimationOptionTransitionCurlUp         = 3 << 20, // default
    CustomContainerTransitionViewControllersAnimationOptionTransitionCurlDown       = 4 << 20,
    CustomContainerTransitionViewControllersAnimationOptionTransitionCrossDissolve  = 5 << 20,
    CustomContainerTransitionViewControllersAnimationOptionTransitionFlipFromTop    = 6 << 20,
    CustomContainerTransitionViewControllersAnimationOptionTransitionFlipFromBottom = 7 << 20,
    
    //    CustomContainerTransitionViewControllersAnimationDirectionUp,
    //    CustomContainerTransitionViewControllersAnimationDirectionDown,
    //    CustomContainerTransitionViewControllersAnimationDirectionLeft,
    //    CustomContainerTransitionViewControllersAnimationDirectionRight,
};


@protocol CustomContainerDataSource <NSObject>
- (NSTimeInterval)timeIntervalForAnimation;
@end



@interface CustomContainer : UIViewController

@property (nonatomic) NSArray *viewControllers;

- (void)setSelectedIndex:(NSUInteger)selectedIndex;
- (NSUInteger)selectedIndex;

+ (instancetype)customContainerWithViewControllers:(NSArray <__kindof UIViewController *>*)viewControllers;

@property (strong, nonatomic) UIColor *tintColorForBars;

@property (assign, nonatomic) BOOL doubleDirection;


@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) CustomContainerTransitionViewControllersAnimationType animationType;

/// CustomContainerTransitionViewControllersAnimationTypeCustomBlock
@property (copy, nonatomic) animationBlock animation;
@property (weak, nonatomic) id<CustomContainerDataSource> dataSource;

/// CustomContainerTransitionViewControllersAnimationTypeDefaultTransition
@property (assign, nonatomic) CustomContainerTransitionViewControllersAnimationOptions defaultOptions;
@property (assign, nonatomic) NSTimeInterval defaultTimeInterval;

/// CustomContainerTransitionViewControllersAnimationTypeCustomSegue
@property (strong, nonatomic) UIViewController *sourceVC;
@property (strong, nonatomic) UIViewController *destinationVC;
- (void)configureSegue;

@property (assign, nonatomic) BOOL hidesStatusBar;
@property (assign, nonatomic) BOOL hidesNavBar;

@property (nullable,nonatomic,copy) NSArray<UIBarButtonItem *> *navLeftBarButtonItems;
@property (nullable,nonatomic,copy) NSArray<UIBarButtonItem *> *navRightBarButtonItems;
@property (nullable, copy, nonatomic) NSString *navTitle;
@property (nullable, strong, nonatomic) UIView *navTitleView;

@end
