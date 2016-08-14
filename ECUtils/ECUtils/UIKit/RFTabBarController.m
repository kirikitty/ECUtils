//
//  RFTabBarController.m
//  ECUtils
//
//  Created by kiri on 15/1/1.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFTabBarController.h"

@interface RFTabBarController ()

@end

@implementation RFTabBarController

- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    return self.selectedViewController.prefersStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.selectedViewController.preferredStatusBarUpdateAnimation;
}

@end
