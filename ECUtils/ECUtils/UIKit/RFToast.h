//
//  RFToast.h
//  ECUtils
//
//  Created by kiri on 15/4/11.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RFToastStyle) {
    RFToastStyleDefault,
    RFToastStyleLightContent,
};

@interface RFToast : NSObject

+ (void)showTextWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1,2);

+ (void)showText:(NSString *)text;
+ (void)showLoadingWithText:(NSString *)text;
+ (void)showLoading;
+ (void)hideLoading;

+ (void)showText:(NSString *)text style:(RFToastStyle)style;
+ (void)showLoadingWithText:(NSString *)text style:(RFToastStyle)style;

@end
