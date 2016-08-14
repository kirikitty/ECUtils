//
//  ECViewController.h
//  ECUtils
//
//  Created by kiri on 2014-12-24.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECViewController : UIViewController

@property (nonatomic, getter = isNavigationBarHidden) BOOL navigationBarHidden;
@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;
@property (strong, nonatomic) UIColor *navigationBarTintColor;
@property (strong, nonatomic) UIColor *navigationBarButtonTintColor;
@property (nonatomic) BOOL navigationBarBottomLineHidden;
@property (nonatomic) BOOL tapToEndEditing;
@property (nonatomic, getter = isNavigationBackActionEnabled) BOOL navigationBackActionEnabled;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImage *backgroundImage;

- (BOOL)isViewAppeared;

+ (instancetype)controllerFromNib;

#pragma mark - NavigationItem Actions
- (IBAction)backButtonDidClick:(id)sender;
- (IBAction)homeButtonDidClick:(id)sender;
- (IBAction)closeButtonDidClick:(id)sender;
- (IBAction)leftSidebarButtonDidClick:(id)sender;
- (IBAction)rightSidebarButtonDidClick:(id)sender;

- (void)backButtonDidClick:(id)sender animated:(BOOL)animated;

#pragma mark - For Override
- (void)viewDidFirstAppear:(BOOL)animated;
- (void)viewWillFirstAppear:(BOOL)animated;
- (void)viewDidFirstLayoutSubviews;

- (UIImageView *)findHairlineImageViewBelowView:(UIView *)view;
- (void)refreshNavbarHairLine;

@end