//
//  ECViewUtil.m
//  ECUtils
//
//  Created by kiri on 15/1/13.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECViewUtil.h"

@implementation ECViewUtil

+ (CGFloat)pointWith6PlusPoint:(CGFloat)pt
{
    return pt * [UIScreen mainScreen].bounds.size.width / 414.f;
}

+ (CGFloat)pointWith6PlusPoint:(CGFloat)pt horizontalMargin:(CGFloat)hMargin
{
    return pt * ([UIScreen mainScreen].bounds.size.width - hMargin) / (414.f - hMargin);
}

+ (CGFloat)pointWith6Point:(CGFloat)pt
{
    return [self pointWith6Point:pt horizontalMargin:0];
}

+ (CGFloat)pointWith6Point:(CGFloat)pt horizontalMargin:(CGFloat)hMargin
{
    return pt * ([UIScreen mainScreen].bounds.size.width - hMargin) / (375.f - hMargin);
}

+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font horizontalMargin:(CGFloat)horizontalMargin
{
    return [self sizeWithString:s font:font maxWidth:([UIScreen mainScreen].bounds.size.width - horizontalMargin)];
}

+ (NSInteger)numberOfLinesWithString:(NSString *)s font:(UIFont *)font horizontalMargin:(CGFloat)horizontalMargin
{
    return [self numberOfLinesWithString:s font:font maxWidth:([UIScreen mainScreen].bounds.size.width - horizontalMargin)];
}

+ (NSInteger)numberOfLinesWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    CGSize size = [self sizeWithString:s font:font maxWidth:maxWidth];
    CGFloat lineHeight = [self sizeWithString:@"1壹j" font:font maxWidth:300].height;
    return roundf(size.height / lineHeight);
}

+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    return [s boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor darkTextColor]} context:nil].size;
}

+ (CGSize)sizeWithString:(NSString *)s font:(UIFont *)font maxWidth:(CGFloat)maxWidth numberOfLines:(NSInteger)numberOfLines
{
    CGSize size = [self sizeWithString:s font:font maxWidth:maxWidth];
    if (numberOfLines > 0) {
        CGFloat maxHeight = [self sizeWithString:@"1壹j" font:font maxWidth:300].height * numberOfLines;
        if (size.height > maxHeight) {
            size.height = maxHeight;
        }
    }
    return size;
}

+ (void)slopeView:(UIView *)view factor:(CGFloat)factor
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        // not compact with autolayout.
        return;
    }
    CGAffineTransform transform = CGAffineTransformMake(1, 0, -factor, 1, 0, 0);
    view.transform = transform;
}

+ (void)slopeTextView:(UIView *)textView
{
    [self slopeView:textView factor:.2f];
}

+ (UIView *)addBlurEffectWithView:(UIView *)view style:(UIBlurEffectStyle)style
{
    if (style == UIBlurEffectStyleExtraLight) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:view.bounds];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        toolbar.userInteractionEnabled = NO;
        [view insertSubview:toolbar atIndex:0];
        return toolbar;
    }
    if ([UIVisualEffectView class]) {
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        effectView.frame = view.bounds;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [view insertSubview:effectView atIndex:0];
        view.backgroundColor = [UIColor clearColor];
        return effectView;
    } else {
        view.backgroundColor = [UIColor colorWithWhite:1 alpha:.9f];
        return nil;
    }
}

@end

@implementation UIView (ECViewUtil)

- (void)addBlurEffectViewWithStyle:(UIBlurEffectStyle)style
{
    [ECViewUtil addBlurEffectWithView:self style:style];
}

@end
