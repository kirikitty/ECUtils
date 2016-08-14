//
//  ECToast.h
//  ECUtils
//
//  Created by kiri on 15/4/11.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ECToastStyle) {
    ECToastStyleDefault,
    ECToastStyleLightContent,
};

@interface ECToast : NSObject

+ (void)showTextWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);

+ (void)showText:(NSString *)text;
+ (void)showLoadingWithText:(NSString *)text;
+ (void)showLoading;
+ (void)hideLoading;

+ (void)showText:(NSString *)text style:(ECToastStyle)style;
+ (void)showLoadingWithText:(NSString *)text style:(ECToastStyle)style;

@end
