//
//  CustomContainer.m
//  CustomContainer
//
//  Created by zhaimengyang on 3/14/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import "CustomContainer.h"

@interface CustomContainer () <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopLayoutConstraint;


@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *leftScreenEdgePan;
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *rightScreenEdgePan;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) UIViewController *currentViewController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItem;

@property (assign, nonatomic) BOOL goesRoundNext;
@property (assign, nonatomic) BOOL goesRoundPrevious;

@property (assign, nonatomic) BOOL isTransitioning;

@end


NSString * const kCustomContainerAnimationTypeCustomSegueDidBeginNotification = @"kCustomContainerAnimationTypeCustomSegueDidBeginNotification";
NSString * const kCustomContainerAnimationTypeCustomSegueDidEndNotification = @"kCustomContainerAnimationTypeCustomSegueDidEndNotification";
NSString * const kCustomContainerSubClassShouldConfigureSegueNotification = @"kCustomContainerSubClassShouldConfigureSegueNotification";


@implementation CustomContainer

static const CGFloat navBarHeight = 44;

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        //
////        self.viewControllers = self.viewControllers;
//        self.tintColorForBars = [UIColor cyanColor];
//        self.doubleDirection = YES;
//        self.animated = YES;
//        self.defaultOptions = CustomContainerTransitionViewControllersAnimationOptionCurveEaseInOut | CustomContainerTransitionViewControllersAnimationOptionTransitionCurlUp;
//        self.defaultTimeInterval = 0.6;
//        self.selectedIndex = 0;
//        self.hidesStatusBar = NO;
//        self.hidesNavBar = YES;
//        self.navItem.leftItemsSupplementBackButton = NO;
//        
//        [self addObserver:self forKeyPath:@"navLeftBarButtonItems" options:NSKeyValueObservingOptionNew context:NULL];
//        [self addObserver:self forKeyPath:@"navRightBarButtonItems" options:NSKeyValueObservingOptionNew context:NULL];
//        [self addObserver:self forKeyPath:@"navTitle" options:NSKeyValueObservingOptionNew context:NULL];
//        [self addObserver:self forKeyPath:@"navTitleView" options:NSKeyValueObservingOptionNew context:NULL];
//        [self addObserver:self forKeyPath:@"hidesNavBar" options:NSKeyValueObservingOptionNew context:NULL];
//        //
//    }
//    return self;
//}

+ (instancetype)customContainerWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CustomContainer" bundle:[NSBundle mainBundle]];
    CustomContainer *container = (CustomContainer *)[storyBoard instantiateViewControllerWithIdentifier:@"CustomContainer"];
    container.viewControllers = viewControllers;
    container.tintColorForBars = [UIColor cyanColor];
    container.doubleDirection = YES;
    container.animated = YES;
    container.defaultOptions = CustomContainerTransitionViewControllersAnimationOptionCurveEaseInOut | CustomContainerTransitionViewControllersAnimationOptionTransitionCurlUp;
    container.defaultTimeInterval = 0.6;
    container.selectedIndex = 0;
    container.hidesStatusBar = NO;
    container.hidesNavBar = YES;
    container.navItem.leftItemsSupplementBackButton = NO;
    
    [container addObserver:container forKeyPath:@"navLeftBarButtonItems" options:NSKeyValueObservingOptionNew context:NULL];
    [container addObserver:container forKeyPath:@"navRightBarButtonItems" options:NSKeyValueObservingOptionNew context:NULL];
    [container addObserver:container forKeyPath:@"navTitle" options:NSKeyValueObservingOptionNew context:NULL];
    [container addObserver:container forKeyPath:@"navTitleView" options:NSKeyValueObservingOptionNew context:NULL];
    [container addObserver:container forKeyPath:@"hidesNavBar" options:NSKeyValueObservingOptionNew context:NULL];
    
    return container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = self.tintColorForBars;
    self.navBar.barTintColor = self.tintColorForBars;
    self.toolbar.barTintColor = self.tintColorForBars;
    
    self.currentIndex = 0;
    NSLog(@"%@", NSStringFromCGRect(self.navBar.frame));
    NSLog(@"%f", CGRectGetMaxY(self.navBar.frame));
    
    [self refreshNavBar];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"navLeftBarButtonItems"]
        ||[keyPath isEqualToString:@"navRightBarButtonItems"]
        || [keyPath isEqualToString:@"navTitle"]
        || [keyPath isEqualToString:@"navTitleView"]) {
        [self refreshNavBar];
    }
    
    if ([keyPath isEqualToString:@"hidesNavBar"]) {
        [self appeared];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self appeared];
    
    if (self.viewControllers && self.viewControllers.count != 0) {
        self.currentViewController = self.viewControllers[0];
        [self switchViewFromViewController:nil toViewController:self.currentViewController animated:NO];
    }
    
    [self refreshToolbarItemStatus];
}

- (void)appeared {
    if (self.hidesNavBar) {
        CGRect frame = self.navBar.frame;
        frame.size.height = 0;
        self.navBar.frame = frame;
        self.containerViewTopLayoutConstraint.constant = -navBarHeight;
    } else {
        CGRect frame = self.navBar.frame;
        frame.size.height = navBarHeight;
        self.navBar.frame = frame;
        self.containerViewTopLayoutConstraint.constant = 0;
    }
}

- (IBAction)switchViewController:(UIBarButtonItem *)sender {
    NSLog(@"%@", sender.title);
    if (self.isTransitioning) {
        return;
    }
    
    self.isTransitioning = YES;
    
//    NSLog(@"%@", sender.title);
    NSUInteger total = self.viewControllers.count;
    
    UIViewController *toVC = nil;
    
    if ([sender.title isEqualToString:@"next"]) {
        if (self.goesRoundNext) {
            toVC = self.viewControllers[0];
            self.currentIndex = 0;
        } else {
            self.currentIndex++;
            toVC = self.viewControllers[self.currentIndex];
        }
    }
    if ([sender.title isEqualToString:@"previous"]) {
        if (self.goesRoundPrevious) {
            toVC = self.viewControllers[total - 1];
            self.currentIndex = total - 1;
        } else {
            self.currentIndex--;
            toVC = self.viewControllers[self.currentIndex];
        }
    }
    
    if (toVC) {
        self.nextItem.enabled = NO;
        self.previousItem.enabled = NO;
        self.sourceVC = self.currentViewController;
        self.destinationVC = toVC;
        [self switchViewFromViewController:self.currentViewController toViewController:toVC animated:self.animated];
        self.currentViewController = toVC;
        
    }
    
    [self refreshToolbarItemStatus];
}

- (void)refreshNavBar {
    [self.navItem setLeftBarButtonItems:self.navLeftBarButtonItems];
    [self.navItem setRightBarButtonItems:self.navRightBarButtonItems];
    [self.navItem setTitle:self.navTitle];
    [self.navItem setTitleView:self.navTitleView];
    
    self.navBar.items = nil;
    [self.navBar pushNavigationItem:self.navItem animated:NO];
}

- (void)refreshToolbarItemStatus {
    self.nextItem.enabled = NO;
    self.previousItem.enabled = NO;
    self.goesRoundNext = NO;
    self.goesRoundPrevious = NO;
    
    NSUInteger total = self.viewControllers.count;
    if (total <= 1) {
        return;
    }
    
    BOOL isInRange;
    
    NSInteger nextIndex = self.currentIndex + 1;
    isInRange = nextIndex <= total - 1;
    if (isInRange) {
        self.nextItem.enabled = YES;
    } else {
        if (self.doubleDirection) {
            self.nextItem.enabled = YES;
            self.goesRoundNext = YES;
        }
    }
    
    NSInteger previousIndex = self.currentIndex - 1;
    isInRange = previousIndex >= 0;
    if (isInRange) {
        self.previousItem.enabled = YES;
    } else {
        if (self.doubleDirection) {
            self.previousItem.enabled = YES;
            self.goesRoundPrevious = YES;
        }
    }
}

- (void)switchViewFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC animated:(BOOL)animated {
    if (!animated) {
        if (fromVC) {
            [fromVC willMoveToParentViewController:nil];
            [fromVC.view removeFromSuperview];
            [fromVC removeFromParentViewController];
        }
        if (toVC) {
            [self addChildViewController:toVC];
            toVC.view.frame = self.containerView.bounds;
            [self.containerView addSubview:toVC.view];
            [toVC didMoveToParentViewController:self];
        }
        self.isTransitioning = NO;
        return;
    }
    
    self.leftScreenEdgePan.enabled = NO;
    self.rightScreenEdgePan.enabled = NO;
    
    [fromVC willMoveToParentViewController:nil];
    [self addChildViewController:toVC];
    
    switch (self.animationType) {
        case CustomContainerTransitionViewControllersAnimationTypeCustomBlock:
            [self animateCustomBlockFromViewController:fromVC toViewController:toVC];
            break;
        case CustomContainerTransitionViewControllersAnimationTypeDefaultTransition:
            [self animateDefaultTransitionFromViewController:fromVC toViewController:toVC];
            break;
        case CustomContainerTransitionViewControllersAnimationTypeCustomSegue: {
            [[NSNotificationCenter defaultCenter]addObserver:self
                                                    selector:@selector(animationCustomSegueDidBeginFromViewController:toViewController:)
                                                        name:kCustomContainerAnimationTypeCustomSegueDidBeginNotification
                                                      object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self
                                                    selector:@selector(animationCustomSegueDidEndFromViewController:toViewController:)
                                                        name:kCustomContainerAnimationTypeCustomSegueDidEndNotification
                                                   object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:kCustomContainerSubClassShouldConfigureSegueNotification object:self];
        }
            break;
            
        default:
            break;
    }
}

- (void)animateCustomBlockFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(timeIntervalForAnimation)]) {
        [self.containerView addSubview:toVC.view];
        
        NSTimeInterval duration = [self.dataSource timeIntervalForAnimation];
        self.animation(fromVC, toVC, self.containerView.bounds);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [fromVC.view removeFromSuperview];
            [fromVC removeFromParentViewController];
            [toVC didMoveToParentViewController:self];
            
            self.leftScreenEdgePan.enabled = YES;
            self.rightScreenEdgePan.enabled = YES;
            
            self.isTransitioning = NO;
        });
    }
}

- (void)animateDefaultTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    [self transitionFromViewController:fromVC
                      toViewController:toVC duration:self.defaultTimeInterval
                               options:UIViewAnimationOptionLayoutSubviews | self.defaultOptions
                            animations:nil
                            completion:^(BOOL finished) {
                                if (fromVC) {
                                    [fromVC.view removeFromSuperview];
                                    [fromVC removeFromParentViewController];
                                }
                                if (toVC) {
                                    toVC.view.frame = self.containerView.bounds;
                                    [self.containerView addSubview:toVC.view];
                                    [toVC didMoveToParentViewController:self];
                                }
                                self.leftScreenEdgePan.enabled = YES;
                                self.rightScreenEdgePan.enabled = YES;
                                
                                self.isTransitioning = NO;
                            }];
}

- (void)configureSegue {
    return;
}

- (void)animationCustomSegueDidBeginFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (fromVC) {
//        [fromVC willMoveToParentViewController:nil];
        [fromVC.view removeFromSuperview];
    }
//    if (toVC) {
//        [self addChildViewController:toVC];
//    }
}

- (void)animationCustomSegueDidEndFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (fromVC) {
        [fromVC removeFromParentViewController];
    }
    if (toVC) {
        toVC.view.frame = self.containerView.bounds;
        [self.containerView addSubview:toVC.view];
        [toVC didMoveToParentViewController:self];
    }
    self.leftScreenEdgePan.enabled = YES;
    self.rightScreenEdgePan.enabled = YES;
    
    self.isTransitioning = NO;
}

- (IBAction)screenEdgePan:(UIScreenEdgePanGestureRecognizer *)sender {
    NSLog(@"%ld",(long)sender.state);
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.toolbarBottomLayoutConstraint.constant == 0) {
            self.toolbarBottomLayoutConstraint.constant = -self.toolbar.frame.size.height;
        } else {
            self.toolbarBottomLayoutConstraint.constant = 0;
        }
        self.leftScreenEdgePan.enabled = NO;
        self.rightScreenEdgePan.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.leftScreenEdgePan.enabled = YES;
            self.rightScreenEdgePan.enabled = YES;
        }];
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.hidesStatusBar;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (self.currentIndex == selectedIndex) {
        return;
    }
    self.currentIndex = selectedIndex;
    UIViewController *toVC = self.viewControllers[self.currentIndex];
    if (toVC) {
        self.nextItem.enabled = NO;
        self.previousItem.enabled = NO;
        [self switchViewFromViewController:self.currentViewController toViewController:toVC animated:self.animated];
        self.currentViewController = toVC;
    }
    
    [self refreshToolbarItemStatus];
}

- (NSUInteger)selectedIndex {
    return self.currentIndex;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"navLeftBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navRightBarButtonItems"];
    [self removeObserver:self forKeyPath:@"navTitle"];
    [self removeObserver:self forKeyPath:@"navTitleView"];
    [self removeObserver:self forKeyPath:@"hidesNavBar"];
    
    if (self.animationType == CustomContainerTransitionViewControllersAnimationTypeCustomSegue) {
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

@end
