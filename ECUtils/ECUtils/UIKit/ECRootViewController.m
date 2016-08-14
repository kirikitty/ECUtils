//
//  ECRootViewController.m
//  ECUtils
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECRootViewController.h"
#import "ECSidebar.h"
#import "UIView+Utils.h"
#import "ECApplication.h"

@interface ECRootViewController ()
{
    BOOL sidebarAnimating;
}

@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *statusBarMaskView;

@property (nonatomic) NSInteger forcedStatusBarStyle;
@property (nonatomic) NSInteger forcedStatusBarHidden;
@property (nonatomic) NSInteger forcedStatusBarAnimation;

@property (nonatomic) ECSideViewPosition shownSideViewPosition;
@property (nonatomic, weak) UIViewController *shownSideViewController;

@end

@implementation ECRootViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self privateInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self privateInit];
}

- (void)privateInit
{
    _leftSidebarHidden = YES;
    _rightSidebarHidden = YES;
    _leftSidebarTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.7, 0.7), CGAffineTransformMakeTranslation(180, 0));
    _rightSidebarTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.7, 0.7), CGAffineTransformMakeTranslation(-180, 0));
    _forcedStatusBarHidden = ECApplicationStatusBarHiddenNone;
    _forcedStatusBarStyle = ECApplicationStatusBarStyleNone;
    _forcedStatusBarAnimation = ECApplicationStatusBarAnimationNone;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration
{
    self.forcedStatusBarHidden = hidden;
    self.forcedStatusBarStyle = style;
    self.forcedStatusBarAnimation = animation;
    
    if (animation == UIStatusBarAnimationNone) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    }
}

- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration
{
    self.forcedStatusBarHidden = ECApplicationStatusBarHiddenNone;
    self.forcedStatusBarStyle = ECApplicationStatusBarStyleNone;
    self.forcedStatusBarAnimation = ECApplicationStatusBarAnimationNone;
    
    if (animated) {
        [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    } else {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.forcedStatusBarStyle == ECApplicationStatusBarStyleNone) {
        UIStatusBarStyle defaultStyle = [ECApplication sharedApplication].statusBarStyle;
        if ([super respondsToSelector:@selector(preferredStatusBarStyle)]) {
            if (!self.leftSidebarHidden && self.leftSidebarViewController) {
                return self.leftSidebarViewController.preferredStatusBarStyle;
            }
            if (!self.rightSidebarHidden && self.rightSidebarViewController) {
                return self.rightSidebarViewController.preferredStatusBarStyle;
            }
            return (self.presentedViewController && !self.presentedViewController.isBeingDismissed) ? self.presentedViewController.preferredStatusBarStyle : self.rootViewController ? self.rootViewController.preferredStatusBarStyle : defaultStyle;
        } else {
            return defaultStyle;
        }
    } else {
        return self.forcedStatusBarStyle;
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (self.forcedStatusBarHidden == ECApplicationStatusBarHiddenNone) {
        if ([super respondsToSelector:@selector(prefersStatusBarHidden)]) {
            if (!self.leftSidebarHidden) {
                return self.leftSidebarViewController.prefersStatusBarHidden;
            }
            return (self.presentedViewController && !self.presentedViewController.isBeingDismissed) ? self.presentedViewController.prefersStatusBarHidden : self.rootViewController ? self.rootViewController.prefersStatusBarHidden : NO;
        } else {
            return NO;
        }
    } else {
        return self.forcedStatusBarHidden;
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    if (self.forcedStatusBarAnimation == ECApplicationStatusBarAnimationNone) {
        UIStatusBarAnimation defaultAnimation = [ECApplication sharedApplication].statusBarAnimation;
        if ([super respondsToSelector:@selector(preferredStatusBarUpdateAnimation)]) {
            return (self.presentedViewController && !self.presentedViewController.isBeingDismissed) ? self.presentedViewController.preferredStatusBarUpdateAnimation : self.rootViewController ? self.rootViewController.preferredStatusBarUpdateAnimation : defaultAnimation;
        } else {
            return defaultAnimation;
        }
    } else {
        return self.forcedStatusBarAnimation;
    }
}

- (void)setNeedsStatusBarAppearanceUpdate
{
    if ([super respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [super setNeedsStatusBarAppearanceUpdate];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:self.preferredStatusBarUpdateAnimation != UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarHidden:self.prefersStatusBarHidden withAnimation:self.preferredStatusBarUpdateAnimation];
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (_rootViewController != rootViewController) {
        // clear window
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window.rootViewController != self) {
            window.rootViewController = self;
        }
        self.view.frame = window.bounds;
        
        // change root
        UIViewController *currentRoot = _rootViewController;
        UIViewController *newRoot = rootViewController;
        
        _rootViewController = rootViewController;
        if (newRoot) {
            [self addChildViewController:newRoot];
            
            UIView *newView = newRoot.view;
            newView.frame = self.view.bounds;
            if (currentRoot) {
                newView.transform = currentRoot.view.transform;
            }
            if (currentRoot) {
                if (animated) {
                    window.userInteractionEnabled = NO;
                    [self.view insertSubview:newView belowSubview:currentRoot.view];
                    self.forcedStatusBarAnimation = UIStatusBarAnimationFade;
                    newView.alpha = 0;
                    [UIView animateWithDuration:.35 animations:^{
                        currentRoot.view.alpha = 0.f;
                        newRoot.view.alpha = 1.f;
                        [self setNeedsStatusBarAppearanceUpdate];
                    } completion:^(BOOL finished) {
                        [currentRoot.view removeFromSuperview];
                        [currentRoot removeFromParentViewController];
                        window.userInteractionEnabled = YES;
                        self.forcedStatusBarAnimation = ECApplicationStatusBarAnimationNone;
                    }];
                } else {
                    [currentRoot.view removeFromSuperview];
                    [currentRoot removeFromParentViewController];
                    [self.view addSubview:newView];
                }
            } else {
                [self.view addSubview:newView];
            }
        }
    }
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    [self setRootViewController:rootViewController animated:NO];
}

- (void)addChildViewController:(UIViewController *)childController
{
    [super addChildViewController:childController];
    childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self adjustChildPostion:childController];
}

- (void)updateStatusBarStyle
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 7) {
        [[UIApplication sharedApplication] setStatusBarStyle:self.preferredStatusBarStyle animated:YES];
    } else {
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }
}

- (void)adjustAllChildrenPostion
{
    for (UIViewController *vc in self.childViewControllers) {
        [self adjustChildPostion:vc];
    }
}

- (void)adjustChildPostion:(UIViewController *)childController
{
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.rootViewController == nil) {
        return UIInterfaceOrientationPortrait;
    }
    return self.rootViewController.preferredInterfaceOrientationForPresentation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.rootViewController == nil) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return self.rootViewController.supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate
{
    if (self.rootViewController == nil) {
        return NO;
    }
    return self.rootViewController.shouldAutorotate;
}

#pragma mark - Sidebars
- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    if (_leftSidebarViewController != leftSidebarViewController) {
        if (_leftSidebarViewController) {
            [_leftSidebarViewController.view removeFromSuperview];
            [_leftSidebarViewController removeFromParentViewController];
        }
        
        _leftSidebarViewController = leftSidebarViewController;
        [self addChildViewController:leftSidebarViewController];
        [self.view insertSubview:leftSidebarViewController.view atIndex:0];
        leftSidebarViewController.view.hidden = self.leftSidebarHidden;
    }
}

- (void)setLeftSidebarHidden:(BOOL)leftSidebarHidden
{
    [self setLeftSidebarHidden:leftSidebarHidden animated:NO];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setLeftSidebarHidden:hidden animated:animated maskStatusBar:NO];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated maskStatusBar:(BOOL)maskStatusBar
{
    if (self.leftSidebarViewController == nil) {
        return;
    }
    
    if (hidden == _leftSidebarHidden) {
        return;
    }
    
    if (sidebarAnimating) {
        return;
    }
    
    sidebarAnimating = YES;
    if (self.rightSidebarViewController.view.superview == self.view) {
        [self.view sendSubviewToBack:self.rightSidebarViewController.view];
    }
    
    void (^preparation)(void) = nil;
    void (^animation)(void) = nil;
    void (^completion)(void) = nil;
    
    void (^commonPreparation)(void) = ^{
        if (hidden) {
            if ([self.leftSidebarViewController respondsToSelector:@selector(sidebarWillDisappear:)]) {
                [(id<ECSidebar>)self.leftSidebarViewController sidebarWillDisappear:animated];
            }
            //            self.rootViewController.view.layer.cornerRadius = 0.f;
            //            self.rootViewController.view.layer.masksToBounds = NO;
        } else {
            if ([self.leftSidebarViewController respondsToSelector:@selector(sidebarWillAppear:)]) {
                [(id<ECSidebar>)self.leftSidebarViewController sidebarWillAppear:animated];
            }
            //            self.rootViewController.view.layer.cornerRadius = 4.f;
            //            self.rootViewController.view.layer.masksToBounds = YES;
        }
    };
    
    void (^commonCompletion)(void) = ^{
        sidebarAnimating = NO;
        _leftSidebarHidden = hidden;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        if (!hidden && [self.leftSidebarViewController respondsToSelector:@selector(sidebarDidAppear:)]) {
            [(id<ECSidebar>)self.leftSidebarViewController sidebarDidAppear:animated];
        } else if (hidden && [self.leftSidebarViewController respondsToSelector:@selector(sidebarDidDisappear:)]) {
            [(id<ECSidebar>)self.leftSidebarViewController sidebarDidDisappear:animated];
        }
    };
    
    if (hidden) {
        animation = ^{
            self.maskView.alpha = 0.f;
            CGAffineTransform trans = CGAffineTransformIdentity;
            self.maskView.transform = trans;
            self.rootViewController.view.transform = trans;
        };
        
        completion = ^{
            self.maskView.hidden = YES;
            self.leftSidebarViewController.view.hidden = YES;
        };
    } else {
        preparation = ^{
            if (maskStatusBar) {
                self.statusBarMaskView.backgroundColor = self.leftSidebarViewController.view.backgroundColor;
            }
            self.maskView.alpha = 0.f;
            self.maskView.hidden = NO;
            self.leftSidebarViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.maskView];
        };
        
        animation = ^{
            self.maskView.alpha = 1.f;
            CGAffineTransform trans = self.leftSidebarTransform;
            self.maskView.transform = trans;
            self.rootViewController.view.transform = trans;
        };
    }
    
    commonPreparation();
    
    if (preparation != nil) {
        preparation();
    }
    
    if (animated && animation) {
        CGFloat dampingRatio = hidden ? 1 : .8f;
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:dampingRatio initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            commonCompletion();
            
            if (completion) {
                completion();
            }
        }];
    } else {
        if (animation) {
            animation();
        }
        
        commonCompletion();
        
        if (completion) {
            completion();
        }
    }
}

- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    if (_rightSidebarViewController != rightSidebarViewController) {
        if (_rightSidebarViewController) {
            [_rightSidebarViewController.view removeFromSuperview];
            [_rightSidebarViewController removeFromParentViewController];
        }
        
        _rightSidebarViewController = rightSidebarViewController;
        
        [self addChildViewController:_rightSidebarViewController];
        [self.view insertSubview:_rightSidebarViewController.view atIndex:0];
        _rightSidebarViewController.view.hidden = self.rightSidebarHidden;
    }
}

- (void)setRightSidebarHidden:(BOOL)rightSidebarHidden
{
    [self setRightSidebarHidden:rightSidebarHidden animated:NO];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setRightSidebarHidden:hidden animated:animated maskStatusBar:NO];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated maskStatusBar:(BOOL)maskStatusBar
{
    if (self.rightSidebarViewController == nil) {
        return;
    }
    
    if (hidden == _rightSidebarHidden) {
        return;
    }
    
    if (sidebarAnimating) {
        return;
    }
    
    sidebarAnimating = YES;
    
    if (self.leftSidebarViewController.view.superview == self.view) {
        [self.view sendSubviewToBack:self.leftSidebarViewController.view];
    }
    
    void (^preparation)(void) = nil;
    void (^animation)(void) = nil;
    void (^completion)(void) = nil;
    
    void (^commonPreparation)(void) = ^{
        if (!hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarWillAppear:)]) {
            [(id<ECSidebar>)self.rightSidebarViewController sidebarWillAppear:animated];
        } else if (hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarWillDisappear:)]) {
            [(id<ECSidebar>)self.rightSidebarViewController sidebarWillDisappear:animated];
        }
    };
    
    void (^commonCompletion)(void) = ^{
        sidebarAnimating = NO;
        _rightSidebarHidden = hidden;
        
        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
            [self setNeedsStatusBarAppearanceUpdate];
        }
        
        if (!hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarDidAppear:)]) {
            [(id<ECSidebar>)self.rightSidebarViewController sidebarDidAppear:animated];
        } else if (hidden && [self.rightSidebarViewController respondsToSelector:@selector(sidebarDidDisappear:)]) {
            [(id<ECSidebar>)self.rightSidebarViewController sidebarDidDisappear:animated];
        }
    };
    
    if (hidden) {
        animation = ^{
            self.maskView.alpha = 0.f;
            self.maskView.transform = CGAffineTransformIdentity;
            self.rootViewController.view.transform = CGAffineTransformIdentity;
        };
        
        completion = ^{
            self.maskView.hidden = YES;
            self.rightSidebarViewController.view.hidden = YES;
        };
    } else {
        preparation = ^{
            if (maskStatusBar) {
                self.statusBarMaskView.backgroundColor = self.rightSidebarViewController.view.backgroundColor;
            }
            self.maskView.alpha = 0.f;
            self.maskView.hidden = NO;
            self.rightSidebarViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.maskView];
        };
        
        animation = ^{
            self.maskView.alpha = 1.f;
            self.maskView.transform = self.rightSidebarTransform;
            self.rootViewController.view.transform = self.rightSidebarTransform;
        };
    }
    
    commonPreparation();
    
    if (preparation != nil) {
        preparation();
    }
    
    if (animated && animation) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            commonCompletion();
            
            if (completion) {
                completion();
            }
        }];
    } else {
        if (animation) {
            animation();
        }
        
        commonCompletion();
        
        if (completion) {
            completion();
        }
    }
}

- (IBAction)didTapMaskView:(id)sender {
    [self setLeftSidebarHidden:YES animated:YES];
    [self setRightSidebarHidden:YES animated:YES];
}

- (void)showSideViewController:(UIViewController *)viewController fromPosition:(ECSideViewPosition)position
{
    if (viewController == self.shownSideViewController) {
        return;
    }
    
    [self addChildViewController:viewController];
    CGFloat moveDistance = position == ECSideViewPositionLeft ? viewController.view.width : - viewController.view.width;
    viewController.view.left = position == ECSideViewPositionLeft ? -viewController.view.width : self.view.width;
    [self.view addSubview:viewController.view];
    
    BOOL isMove = self.shownSideViewController == nil;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewController.view.left = 0;
        if (isMove) {
            self.rootViewController.view.left += moveDistance;
            self.leftSidebarViewController.view.left += moveDistance / 2;
            self.rightSidebarViewController.view.left += moveDistance / 2;
        }
        if (self.shownSideViewController) {
            self.shownSideViewController.view.left += moveDistance;
        }
    } completion:^(BOOL finished) {
        if (self.shownSideViewController) {
            [self hideSideViewControllerAnimated:NO];
        }
        
        self.shownSideViewController = viewController;
        self.shownSideViewPosition = position;
    }];
}

- (void)hideSideViewController
{
    [self hideSideViewControllerAnimated:YES];
}

- (void)hideSideViewControllerAnimated:(BOOL)animated
{
    if (self.shownSideViewController == nil) {
        return;
    }
    
    void (^animation)(void) = ^{
        self.shownSideViewController.view.left = self.shownSideViewPosition == ECSideViewPositionLeft ? -self.shownSideViewController.view.width : self.view.width;
        CGFloat moveDistance = self.shownSideViewPosition == ECSideViewPositionLeft ? -self.shownSideViewController.view.width : self.shownSideViewController.view.width;
        
        self.rootViewController.view.left += moveDistance;
        self.leftSidebarViewController.view.left += moveDistance / 2;
        self.rightSidebarViewController.view.left += moveDistance / 2;
    };
    
    void (^completion)(void) = ^{
        [self.shownSideViewController.view removeFromSuperview];
        [self.shownSideViewController removeFromParentViewController];
        self.shownSideViewController = nil;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:animation completion:^(BOOL finished) {
            completion();
        }];
    } else {
        animation();
        completion();
    }
}

@end
