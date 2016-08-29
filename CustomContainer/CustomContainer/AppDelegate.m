//
//  AppDelegate.m
//  CustomContainer
//
//  Created by zhaimengyang on 3/14/16.
//  Copyright © 2016 zhaimengyang. All rights reserved.
//

#import "AppDelegate.h"

#import "NavController.h"

#import "ViewController.h"

@interface AppDelegate () <CustomContainerDataSource>



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    UIViewController *red = [[UIViewController alloc]init];
    red.view.backgroundColor = [UIColor redColor];
    UIViewController *green = [[UIViewController alloc]init];
    green.view.backgroundColor = [UIColor greenColor];
    UIViewController *blue = [[UIViewController alloc]init];
    blue.view.backgroundColor = [UIColor blueColor];
    
    UIViewController *navRootVC = [[UIViewController alloc]init];
    navRootVC.view.backgroundColor = [UIColor yellowColor];
    navRootVC.title = @"hiahia";
    UISwitch *swi = [[UISwitch alloc]init];
    [swi addTarget:self action:@selector(changeNavBarHiddenStatus) forControlEvents:UIControlEventValueChanged];
    [navRootVC.view addSubview:swi];
    swi.center = navRootVC.view.center;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:navRootVC];
    
    CustomContainer *container = [CustomContainer customContainerWithViewControllers:@[red, green, blue, nav]];
    self.container = container;
    container.animated = YES;
    container.hidesNavBar = NO;
    
    container.navLeftBarButtonItems = @[[[UIBarButtonItem alloc]initWithTitle:@"帅到没朋友" style:UIBarButtonItemStylePlain target:self action:@selector(changeItem)]];
    container.navTitle = @"我好帅";
    
    container.animationType = CustomContainerTransitionViewControllersAnimationTypeCustomBlock;
    //container.animationType = CustomContainerTransitionViewControllersAnimationTypeCustomSegue;
    
    container.defaultTimeInterval = 2;
    container.defaultOptions = CustomContainerTransitionViewControllersAnimationOptionCurveEaseInOut |
                               CustomContainerTransitionViewControllersAnimationOptionTransitionCurlUp;
    
    container.dataSource = self;
    NSArray *VCs = [container viewControllers];
    container.animation = ^(UIViewController *fromVC, UIViewController *toVC, CGRect endedFrame) {
        fromVC.view.alpha = 1.0;
        toVC.view.alpha = 0.0;
        
        NSUInteger index = [VCs indexOfObject:toVC];
        switch (index) {
            case 0:
                toVC.view.frame = CGRectZero;
                break;
            case 1:
                toVC.view.frame = CGRectMake(self.window.frame.size.width, 0, 0, 0);
                break;
            case 2:
                toVC.view.frame = CGRectMake(0, self.window.frame.size.height, 0, 0);
                break;
            case 3:
                toVC.view.frame = CGRectMake(self.window.frame.size.width, self.window.frame.size.height, 0, 0);
                break;
            default:
                break;
        }
        
        [UIView animateWithDuration:0.6
                         animations:^{
                             fromVC.view.alpha = 0.0;
                             fromVC.view.frame = CGRectZero;
                             toVC.view.alpha = 1.0;
                             toVC.view.frame = endedFrame;
                             
//                             [fromVC.view setNeedsLayout];
//                             [toVC.view setNeedsLayout];
                             
                         } completion:nil];
    };
    
    self.window.rootViewController = container;
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSTimeInterval)timeIntervalForAnimation {
    return 0.6;
}

- (void)changeItem {
    self.container.navRightBarButtonItems = @[[[UIBarButtonItem alloc]initWithTitle:@"帅到没朋友" style:UIBarButtonItemStylePlain target:self action:@selector(changeItem)]];
    self.container.navTitle = @"帅死了";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"我帅过头了" message:@"真的" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.container.navTitle = @"帅得吊炸天";
    }];
    [alert addAction:action];
    [self.window.rootViewController presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.container.hidesNavBar = YES;
        });
    }];
}

- (void)changeNavBarHiddenStatus {
    self.container.hidesNavBar = !self.container.hidesNavBar;
    NSLog(@"%d", self.container.hidesNavBar);
    
//    UITableViewController *tvc = [[UITableViewController alloc]init];
//    [self.container presentViewController:tvc animated:YES completion:nil];
//    
//    UIViewController *demoVC = [[UIViewController alloc]init];
//    demoVC.view.backgroundColor = [UIColor orangeColor];
//    NavController *nav = [[NavController alloc]initWithRootViewController:demoVC];
//    [self.container presentViewController:nav animated:YES completion:nil];
    
    self.window.rootViewController = nil;
    ViewController *demoVC = [[ViewController alloc]init];
    demoVC.view.backgroundColor = [UIColor orangeColor];
    NavController *nav = [[NavController alloc]initWithRootViewController:demoVC];
    self.window.rootViewController = nav;
    
}

@end
