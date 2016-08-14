//
//  ECViewController.m
//  ECUtils
//
//  Created by kiri on 2014-12-24.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "ECViewController.h"
#import "ECLog.h"
#import "ECApplication.h"
#import "NSNull+Protection.h"
#import "ECNibUtil.h"
#import "ECBlockActionSheet.h"
#import "ECBlockImagePickerViewController.h"

typedef NS_ENUM(NSInteger, ECViewControllerState) {
    ECViewControllerStateNone = 0,
    ECViewControllerStateWillAppear,
    ECViewControllerStateDidAppear,
    ECViewControllerStateWillDisappear,
    ECViewControllerStateDidDisappear,
};

@interface ECViewController ()
{
    NSTimeInterval _timeIntervalForLogger;
}

@property (nonatomic) ECViewControllerState state;

@property (strong, nonatomic) UIImageView *navbarHairlineImageView;

@property (nonatomic) BOOL firstDidAppear;
@property (nonatomic) BOOL firstWillAppear;
@property (nonatomic) BOOL firstDidLayoutSubviews;

// store in navigation view controller.
@property (strong, nonatomic) NSMutableDictionary *userInfo;

@end

@implementation ECViewController

@synthesize backgroundImage = _backgroundImage;

+ (instancetype)controllerFromNib
{
    NSString *nibName = [NSStringFromClass(self) componentsSeparatedByString:@"."].lastObject;
    return [ECNibUtil loadMainObjectFromNib:nibName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _navigationBarHidden = NO;
    _tabBarHidden = YES;
    _navigationBackActionEnabled = YES;
    _navigationBarBottomLineHidden = NO;
    
    self.navigationItem.backBarButtonItem.title = @"";
    
    self.state = ECViewControllerStateNone;
    ECLogDebug(@"%@", NSStringFromClass([self class]));
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Appears
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.state == ECViewControllerStateWillAppear || self.state == ECViewControllerStateDidAppear) {
        return;
    }
    self.state = ECViewControllerStateWillAppear;
    
    if (self.parentViewController == self.navigationController) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        if (self.navigationBarTintColor) {
            self.navigationController.navigationBar.barTintColor = self.navigationBarTintColor;
        } else {
            self.navigationController.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
        }
        if (self.navigationBarButtonTintColor) {
            self.navigationController.navigationBar.tintColor = self.navigationBarButtonTintColor;
        } else {
            self.navigationController.navigationBar.tintColor = [UINavigationBar appearance].tintColor;
        }
        
        if (self.navigationController.navigationBarHidden != self.isNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:self.isNavigationBarHidden animated:animated];
        }
        if (self.tabBarController.tabBar.hidden != self.isTabBarHidden) {
            self.tabBarController.tabBar.hidden = self.isTabBarHidden;
        }
        
        [self refreshNavbarHairLine];
        
        [[ECApplication sharedApplication] refreshStatusBar];
    }
    
    if (!self.firstWillAppear) {
        self.firstWillAppear = YES;
        [self viewWillFirstAppear:animated];
    }
    
    _timeIntervalForLogger = [NSDate timeIntervalSinceReferenceDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.navigationController && self.navigationController == self.parentViewController) {
        if (self.isNavigationBackActionEnabled) {
            self.navigationController.interactivePopGestureRecognizer.enabled = self == self.navigationController.viewControllers.firstObject ? NO : YES;
        } else {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    if (self.state == ECViewControllerStateDidAppear) {
        return;
    }
    self.state = ECViewControllerStateDidAppear;
    
    if (!self.firstDidAppear) {
        self.firstDidAppear = YES;
        [self viewDidFirstAppear:animated];
    }
    
//    [[ECApplication sharedApplication] refreshStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.state == ECViewControllerStateNone || self.state == ECViewControllerStateDidDisappear || self.state == ECViewControllerStateWillDisappear) {
        return;
    }
    
    self.state = ECViewControllerStateWillDisappear;
    _timeIntervalForLogger = [NSDate timeIntervalSinceReferenceDate] - _timeIntervalForLogger;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.state == ECViewControllerStateNone || self.state == ECViewControllerStateDidDisappear) {
        return;
    }
    self.state = ECViewControllerStateDidDisappear;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.firstDidLayoutSubviews) {
        self.firstDidLayoutSubviews = YES;
        [self viewDidFirstLayoutSubviews];
    }
}

#pragma mark - NavigationItem Actions
- (IBAction)backButtonDidClick:(id)sender {
    [self backButtonDidClick:sender animated:YES];
}

- (void)backButtonDidClick:(id)sender animated:(BOOL)animated
{
    if (self.navigationController.viewControllers.firstObject == self || self.navigationController == nil) {
        id shownSideViewController = [ECApplication sharedApplication].shownSideViewController;
        if (shownSideViewController != nil && (shownSideViewController == self.navigationController || shownSideViewController == self)) {
            [[ECApplication sharedApplication] hideSideViewController];
            return;
        }
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:animated completion:nil];
        }
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void)closeButtonDidClick:(id)sender
{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)homeButtonDidClick:(id)sender {
    if (self.presentingViewController) {
        UIWindow *window = self.view.window;
        window.userInteractionEnabled = NO;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            window.userInteractionEnabled = YES;
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)leftSidebarButtonDidClick:(id)sender
{
    [[ECApplication sharedApplication] setLeftSidebarHidden:![ECApplication sharedApplication].isLeftSidebarHidden animated:YES];
}

- (IBAction)rightSidebarButtonDidClick:(id)sender
{
    [[ECApplication sharedApplication] setRightSidebarHidden:![ECApplication sharedApplication].isRightSidebarHidden animated:YES];
}

- (BOOL)isViewAppeared
{
    return self.state == ECViewControllerStateDidAppear;
}

- (void)setNavigationBackActionEnabled:(BOOL)navigationBackActionEnabled
{
    if (_navigationBackActionEnabled != navigationBackActionEnabled) {
        _navigationBackActionEnabled = navigationBackActionEnabled;
        self.navigationItem.hidesBackButton = !navigationBackActionEnabled;
        self.navigationController.interactivePopGestureRecognizer.enabled = navigationBackActionEnabled;
    }
}

#pragma mark - Styles
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [ECApplication sharedApplication].statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [ECApplication sharedApplication].statusBarAnimation;
}

#pragma mark - Hair Line
- (UIImageView *)findHairlineImageViewBelowView:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewBelowView:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - For Override
- (void)viewWillFirstAppear:(BOOL)animated
{
    if (self.tapToEndEditing) {
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleEndEditingTap:)]];
    }
}

- (void)viewDidFirstAppear:(BOOL)animated
{
}

- (void)viewDidFirstLayoutSubviews
{
}

#pragma mark - End Editing
- (void)_handleEndEditingTap:(UITapGestureRecognizer *)gr
{
    [self.view endEditing:YES];
}

#pragma mark - Utils

- (UIImageView *)navbarHairlineImageView
{
    if (_navbarHairlineImageView == nil) {
        _navbarHairlineImageView = [self findHairlineImageViewBelowView:self.navigationController.navigationBar];
    }
    return _navbarHairlineImageView;
}

- (void)refreshNavbarHairLine
{
    self.navbarHairlineImageView.hidden = self.navigationBarBottomLineHidden;
}

#pragma mark - Rotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

@end
