//
//  RFToast.m
//  ECUtils
//
//  Created by kiri on 15/4/11.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFToast.h"
#import "ECApplication.h"
#import "UIView+Utils.h"

#define kToastWhite [[UIColor whiteColor] colorWithAlphaComponent:.98f]
#define kToastBlack [[UIColor titleColor] colorWithAlphaComponent:.98f]

@interface RFToast ()

@property (strong, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIView *backgroundView;
@property (nonatomic) BOOL userInterfaceEnabled;
@property (nonatomic) BOOL showing;
@property (nonatomic) BOOL hiding;

@property (nonatomic) BOOL canShow;

@property (strong, nonatomic) UIView *maskView;

- (BOOL)shouldHideOnTap;

@end

@interface RFTextToast : RFToast

@property (weak, nonatomic) UILabel *textLabel;

- (instancetype)initWithText:(NSString *)text style:(RFToastStyle)style;

@end

@interface RFLoadingToast : RFToast

@property (weak, nonatomic) UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) UILabel *textLabel;
@property (nonatomic, readonly) CGSize minimumSize;

+ (instancetype)sharedInstance;

- (void)prepareWithText:(NSString *)text style:(RFToastStyle)style block:(BOOL)block;

@end

@implementation RFToast

- (instancetype)init
{
    if (self = [super init]) {
        self.userInterfaceEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = self.contentView.superview ? [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] : 0;
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGFloat top = (rect.origin.y - [self topBarHeight] - self.contentView.height) / 2;
    [UIView animateWithDuration:duration delay:0 options:curve << 16 animations:^{
        self.contentView.top = top;
    } completion:nil];
}

- (CGFloat)topBarHeight
{
    id root = [ECApplication sharedApplication].rootViewController;
    if ([root isKindOfClass:[UITabBarController class]]) {
        root = [(UITabBarController *)root selectedViewController];
    }
    
    if ([root isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = root;
        CGFloat h = [UIApplication sharedApplication].statusBarFrame.size.height;
        if (!nav.navigationBarHidden) {
            h += nav.navigationBar.height;
        }
        return h;
    }
    return 0;
}

- (void)show
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self show];
        });
        return;
    }
    
    self.canShow = YES;
    if (self.showing) {
        return;
    }
    
    self.showing = YES;
    UIWindow *window = [ECApplication sharedApplication].window;
    self.contentView.userInteractionEnabled = !self.userInterfaceEnabled;
    if (!self.userInterfaceEnabled) {
        [self createMaskView];
        [window addSubview:self.maskView];
    }
    
    CGRect rect = [ECApplication sharedApplication].keyboardFrame;
    CGFloat topBarHeight = [self topBarHeight];
    CGFloat visibleHeight = rect.origin.y - topBarHeight;
    CGFloat top = MAX(0, visibleHeight / 2 - self.contentView.height / 2) + topBarHeight;
    CGFloat left = (window.width - self.contentView.width) / 2;
    CGPoint origin = CGPointMake(left, top);
    
    BOOL updateFrame = YES;
    if (self.contentView.hidden || self.contentView.superview == nil) {
        self.contentView.alpha = 0;
        self.contentView.hidden = NO;
        self.contentView.origin = origin;
        updateFrame = NO;
    }
    
    if (self.contentView.superview == nil) {
        [window addSubview:self.contentView];
    }
        
    [self willShow];
    self.showing = NO;
    [UIView animateWithDuration:.35 animations:^{
        self.contentView.alpha = 1;
        self.maskView.alpha = 1;
        if (updateFrame) {
            self.contentView.origin = origin;
        }
    } completion:^(BOOL finished) {
        [self didShow];
    }];
}

- (void)hide
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hide];
        });
        return;
    }
    
    self.canShow = NO;
    if (self.hiding) {
        return;
    }
    
    self.hiding = YES;
    [self willHide];
    self.hiding = NO;
    [UIView animateWithDuration:.35 animations:^{
        self.contentView.alpha = 0;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        if (!self.canShow) {
            [self.contentView removeFromSuperview];
            [self.maskView removeFromSuperview];
        }
        [self didHide];
    }];
}

- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
        if (self.contentView == nil) {
            return nil;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:self.contentView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView insertSubview:view atIndex:0];
        _backgroundView = view;
    }
    return _backgroundView;
}

- (void)createMaskView
{
    if (self.maskView == nil) {
        self.maskView = [[UIView alloc] initWithFrame:[ECApplication sharedApplication].window.bounds];
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];
        self.maskView.alpha = 0;
        [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMask:)]];
    }
}

- (void)didTapMask:(UIGestureRecognizer *)mask
{
    if ([self shouldHideOnTap]) {
        [self hide];
    }
}

#pragma mark - For Override
- (BOOL)shouldHideOnTap
{
    return YES;
}

- (void)willShow
{
}

- (void)didShow
{
}

- (void)willHide
{
}

- (void)didHide
{
}

#pragma mark - Public Method
+ (void)showTextWithFormat:(NSString *)fmt, ...
{
    if (fmt.length == 0) {
        return;
    }
    
    va_list args;
    va_start(args, fmt);
    NSString *text = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    [self showText:text style:RFToastStyleLightContent];
}

+ (void)showText:(NSString *)text
{
    [self showText:text style:RFToastStyleLightContent];
}

+ (void)showText:(NSString *)text style:(RFToastStyle)style
{
    RFToast *toast = [[RFTextToast alloc] initWithText:text style:style];
    [toast show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast hide];
    });
}

+ (void)showLoadingWithText:(NSString *)text
{
    [self showLoadingWithText:text style:RFToastStyleLightContent];
}

+ (void)showLoadingWithText:(NSString *)text style:(RFToastStyle)style
{
    [self showLoadingWithText:text style:style block:YES];
}

+ (void)showLoadingWithText:(NSString *)text style:(RFToastStyle)style block:(BOOL)block
{
    RFLoadingToast *toast = [RFLoadingToast sharedInstance];
    [toast prepareWithText:text style:style block:block];
    [toast show];
}

+ (void)showLoading
{
    [self showLoadingWithText:nil style:RFToastStyleDefault];
}

+ (void)hideLoading
{
    [[RFLoadingToast sharedInstance] hide];
}

@end

@implementation RFTextToast

- (instancetype)initWithText:(NSString *)text style:(RFToastStyle)style
{
    if (self = [super init]) {
//        CGFloat maxWidth = 180.f;
        UIFont *font = [UIFont fontWithSize:15.f];
//        CGRect rect = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:NULL];
        CGRect rect = CGRectMake(0, 0, 180, 60);
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectInset(rect, -20.f, 0)];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectOffset(rect, 20.f, 0)];
        textLabel.font = font;
        textLabel.text = text;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 2;
        [contentView addSubview:textLabel];
        
        self.contentView = contentView;
        self.textLabel = textLabel;
        self.userInterfaceEnabled = NO;
        
        switch (style) {
            case RFToastStyleLightContent:
            {
                self.backgroundView.backgroundColor = kToastWhite;
                self.textLabel.textColor = kToastBlack;
                break;
            }
            default:
            {
                self.backgroundView.backgroundColor = kToastBlack;
                self.textLabel.textColor = kToastWhite;
                break;
            }
        }
    }
    return self;
}

@end

@implementation RFLoadingToast

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        UIView *contentView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.minimumSize}];
        contentView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.origin = CGPointMake((contentView.width - indicatorView.width) / 2, (contentView.height - indicatorView.height) / 2);
        [contentView addSubview:indicatorView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, indicatorView.bottom, contentView.width - 24.f, 0)];
        textLabel.font = [UIFont fontWithSize:15.f];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.numberOfLines = 0;
        [contentView addSubview:textLabel];
        
        self.contentView = contentView;
        self.indicatorView = indicatorView;
        self.textLabel = textLabel;
        self.userInterfaceEnabled = NO;
    }
    return self;
}

- (void)prepareWithText:(NSString *)text style:(RFToastStyle)style block:(BOOL)block
{
    self.userInterfaceEnabled = !block;
    switch (style) {
        case RFToastStyleLightContent:
        {
            self.backgroundView.backgroundColor = kToastWhite;
            self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            self.textLabel.textColor = kToastBlack;
            break;
        }
        default:
        {
            self.backgroundView.backgroundColor = kToastBlack;
            self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            self.textLabel.textColor = kToastWhite;
            break;
        }
    }
    
    if (text.length > 0) {
        self.indicatorView.color = nil;
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.textLabel.width, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.textLabel.font} context:NULL];
        self.contentView.size = CGSizeMake(self.minimumSize.width, self.minimumSize.height + rect.size.height);
        self.indicatorView.origin = CGPointMake((self.contentView.width - self.indicatorView.width) / 2, (self.minimumSize.height - self.indicatorView.height) / 2);
        self.textLabel.text = text;
        self.textLabel.frame = CGRectMake(self.textLabel.left, self.indicatorView.bottom + 5, self.textLabel.width, rect.size.height);
    } else {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.contentView.size = CGSizeMake(70, 40);
        self.indicatorView.origin = CGPointMake(25, 10);
        self.textLabel.text = nil;
    }
}

- (BOOL)shouldHideOnTap
{
    return NO;
}

- (CGSize)minimumSize
{
    return CGSizeMake(164, 50);
}

- (void)willShow
{
    [super willShow];
    [self.indicatorView startAnimating];
}

@end
