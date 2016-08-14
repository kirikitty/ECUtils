//
//  ECProgressView.m
//  ECUtils
//
//  Created by kiri on 14-5-28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "ECProgressView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <math.h>
#import "NSTimer+Block.h"

@interface ECProgressView ()

@property (nonatomic, weak) NSTimer *animationTimer;

@end

@implementation ECProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineCapStyle = kCGLineCapRound;
        [self _privateInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _privateInit];
}

- (void)_privateInit
{
    [self registerForKVO];
}

- (void)dealloc
{
    [self unregisterFromKVO];
}

- (void)drawRect:(CGRect)rect
{
    // override by subclass
}

#pragma mark - KVO
- (void)registerForKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths {
	return [NSArray arrayWithObjects:@"progressTintColor", @"progressTintColor", @"lineWidth", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self setProgress:progress animated:animated maxDuration:1.0 completion:nil];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated maxDuration:(NSTimeInterval)maxDuration completion:(void (^)(void))completion
{
    progress = MIN(1.0, MAX(0.0, progress));
    if (_progress != progress) {
        BOOL animating = [self.animationTimer isValid];
        if (animating) {
            [self.animationTimer invalidate];
            self.animationTimer = nil;
        }
        if (animated) {
            BOOL plus = _progress < progress;
            CGFloat step = 0.02 / maxDuration;
            __weak typeof(self) wself = self;
            self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 block:^BOOL(NSTimer *timer) {
                if (plus) {
                    _progress += MIN(step, progress - _progress);
                } else {
                    _progress -= MIN(step, _progress - progress);
                }
                [wself setNeedsDisplay];
                return (plus && _progress >= progress) || (!plus && _progress <= progress);
            } userInfo:nil repeatCount:RFBlockTimerRepeatCountInfinite completion:^(BOOL canceled) {
                if (completion) {
                    completion();
                }
                [wself sendActionsForControlEvents:UIControlEventValueChanged];
            }];
        } else {
            _progress = progress;
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            if (completion) {
                completion();
            }
        }
    }
}

- (void)stopAnimating
{
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (UIColor *)trackTintColor
{
    if (_trackTintColor) {
        return _trackTintColor;
    }
    return [[[self class] appearance] trackTintColor];
}

- (UIColor *)progressTintColor
{
    if (_progressTintColor) {
        return _progressTintColor;
    }
    return [[[self class] appearance] progressTintColor];
}

@end
