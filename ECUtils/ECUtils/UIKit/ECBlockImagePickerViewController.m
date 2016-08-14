//
//  ECBlockImagePickerViewController.m
//  ECUtils
//
//  Created by kiri on 2013-11-18.
//  Copyright (c) 2013年 kiri. All rights reserved.
//

#import "ECBlockImagePickerViewController.h"

@interface ECBlockImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ECBlockImagePickerViewController

- (id)init
{
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        self.completion(weakSelf, NO, info);
    } else {
        if (picker.presentingViewController) {
            UIViewController *vc = picker.presentingViewController;
            [picker dismissViewControllerAnimated:YES completion:^{
                if ([vc respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [vc setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.completion) {
        __weak typeof(self) weakSelf = self;
        self.completion(weakSelf, YES, nil);
    } else {
        if (picker.presentingViewController) {
            UIViewController *vc = picker.presentingViewController;
            [picker dismissViewControllerAnimated:YES completion:^{
                if ([vc respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [vc setNeedsStatusBarAppearanceUpdate];
                }
            }];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSString *classStr = NSStringFromClass([self class]);
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 && [classStr isEqualToString:@"PLUICameraViewController"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (self.topViewController && [NSStringFromClass(self.topViewController.class) hasPrefix:@"TN"]) {
        return self.topViewController.prefersStatusBarHidden;
    }
    
    NSString *classStr = NSStringFromClass([self class]);
    if ([classStr isEqualToString:@"PLUICameraViewController"]) {
        return YES;
    }
    
    return NO;
}

@end