//
//  UIView+Utils.m
//  ECUtils
//
//  Created by kiri on 2014-12-24.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (UIImage *)snapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIScrollView (Utils)

- (CGFloat)topInset
{
    return self.contentInset.top;
}

- (void)setTopInset:(CGFloat)topInset
{
    UIEdgeInsets insets = self.contentInset;
    insets.top = topInset;
    self.contentInset = insets;
}

- (CGFloat)bottomInset
{
    return self.contentInset.bottom;
}

- (void)setBottomInset:(CGFloat)bottomInset
{
    UIEdgeInsets insets = self.contentInset;
    insets.bottom = bottomInset;
    self.contentInset = insets;
}

- (CGFloat)topScrollIndicatorInset
{
    return self.scrollIndicatorInsets.top;
}

- (void)setTopScrollIndicatorInset:(CGFloat)topScrollIndicatorInset
{
    UIEdgeInsets insets = self.scrollIndicatorInsets;
    insets.top = topScrollIndicatorInset;
    self.scrollIndicatorInsets = insets;
}

- (CGFloat)bottomScrollIndicatorInset
{
    return self.scrollIndicatorInsets.bottom;
}

- (void)setBottomScrollIndicatorInset:(CGFloat)bottomScrollIndicatorInset
{
    UIEdgeInsets insets = self.scrollIndicatorInsets;
    insets.bottom = bottomScrollIndicatorInset;
    self.scrollIndicatorInsets = insets;
}

@end