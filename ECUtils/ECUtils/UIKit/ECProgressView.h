//
//  ECProgressView.h
//  ECUtils
//
//  Created by kiri on 14-5-28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface ECProgressView : UIControl

@property (nonatomic) CGFloat progress;
@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *trackTintColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGLineCap lineCapStyle;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated maxDuration:(NSTimeInterval)maxDuration completion:(void (^)(void))completion;
- (void)stopAnimating;

// for subclass override
- (NSArray *)observableKeypaths;

@end
