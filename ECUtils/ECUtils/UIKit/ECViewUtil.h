//
//  ECViewUtil.h
//  ECUtils
//
//  Created by kiri on 15/1/13.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECViewUtil : NSObject

+ (CGFloat)pointWith6PlusPoint:(CGFloat)pt;
+ (CGFloat)pointWith6PlusPoint:(CGFloat)pt horizontalMargin:(CGFloat)hMargin;

+ (CGFloat)pointWith6Point:(CGFloat)pt;
+ (CGFloat)pointWith6Point:(CGFloat)pt horizontalMargin:(CGFloat)hMargin;

+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font horizontalMargin:(CGFloat)horizontalMargin;
+ (NSInteger)numberOfLinesWithString:(NSString *)s font:(UIFont *)font horizontalMargin:(CGFloat)horizontalMargin;
+ (NSInteger)numberOfLinesWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth;

+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth;
+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth numberOfLines:(NSInteger)numberOfLines;

/*!
 *  factor is the 'c' in (x' = ax + cy + tx).
 */
+ (void)slopeView:(UIView *)view factor:(CGFloat)factor;
+ (void)slopeTextView:(UIView *)textView;

+ (UIView *)addBlurEffectWithView:(UIView *)view style:(UIBlurEffectStyle)style;

@end

@interface UIView (ECViewUtil)

- (void)addBlurEffectViewWithStyle:(UIBlurEffectStyle)style;

@end
