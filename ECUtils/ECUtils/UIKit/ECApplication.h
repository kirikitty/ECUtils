//
//  ECApplication.h
//  ECUtils
//
//  Created by kiri on 14-6-30.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ECApplicationLaunchType) {
    ECApplicationLaunchTypeUnknown,
    ECApplicationLaunchTypeNormal,
    ECApplicationLaunchTypeRemoteNotification,
    ECApplicationLaunchTypeLocalNotification,
    ECApplicationLaunchTypeOpenURL,
};

enum {
    ECApplicationStatusBarHiddenNone = -1,
};

enum {
    ECApplicationStatusBarStyleNone = -1,
};

enum {
    ECApplicationStatusBarAnimationNone = -1,
};

enum {
    ECSideViewPositionLeft,
    ECSideViewPositionRight,
};
typedef NSUInteger ECSideViewPosition;

extern NSString *const ECApplicationDidReceiveRemotePushNotificaiton;
extern NSString *const ECApplicationDidReceiveLocalPushNotificaiton;

@protocol ECApplicationListener <NSObject>

- (void)startListen;
- (void)stopListen;

@end

@interface ECApplication : NSObject

+ (ECApplication *)sharedApplication;

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSDictionary *launchOptions;
@property (nonatomic) ECApplicationLaunchType launchType;
@property (strong, readonly, nonatomic) NSDate *launchTime;

@property (nonatomic) ECApplicationLaunchType lastActiveType;
@property (strong, nonatomic) NSDictionary *lastActiveOptions;
@property (strong, readonly, nonatomic) NSDate *lastActiveTime;
@property (strong, readonly, nonatomic) NSDate *lastDeactiveTime;

@property (strong, readonly, nonatomic) NSString *version;

// It's a global cache in memory.
@property (strong, readonly, nonatomic) NSMutableDictionary *cache;

- (void)startWithLaunchOptions:(NSDictionary *)launchOptions;

#pragma mark - Keyboard
@property (readonly) CGRect keyboardFrame;

#pragma mark - Theme
@property (nonatomic) UIStatusBarStyle statusBarStyle;
@property (nonatomic) UIStatusBarAnimation statusBarAnimation;

@property (nonatomic) NSString *fontName;
@property (nonatomic) NSString *boldFontName;

@property (strong, nonatomic) UIColor *barTintColor;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *barTextColor;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *subtitleColor;

#pragma mark - Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

#pragma mark - Sidebar
@property (nonatomic) CGAffineTransform leftSidebarTransform;
@property (nonatomic) CGFloat leftSidebarWidth;
@property (nonatomic) UIViewController *leftSidebarViewController;
- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)isLeftSidebarHidden;

@property (nonatomic) UIViewController *rightSidebarViewController;
- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated;
- (BOOL)isRightSidebarHidden;

- (UIViewController *)shownSideViewController;
- (void)showSideViewController:(UIViewController *)viewController fromPosition:(ECSideViewPosition)position;
- (void)hideSideViewController;

#pragma mark - Root
@property (nonatomic, readonly) UIWindow *window;

@property (nonatomic) UIViewController *rootViewController;
- (void)setRootViewController:(UIViewController *)controller animated:(BOOL)animated;

#pragma mark - Statusbar
- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration;
- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration;
- (void)refreshStatusBar;

#pragma mark - Utils
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation;
- (BOOL)openURL:(NSURL *)url;
- (void)callPhoneNumber:(NSString *)phoneNumber;

- (void)addListener:(id<ECApplicationListener>)listener;
- (void)removeListener:(id<ECApplicationListener>)listener;

- (BOOL)openRateURL;
- (BOOL)openAppURL;

- (void)startBackgroundTaskWithTimeout:(NSTimeInterval)timeout;

@end

@interface UIFont (ECApplication)

+ (UIFont *)fontWithSize:(CGFloat)size;
+ (UIFont *)boldFontWithSize:(CGFloat)size;

@end

@interface UIColor (ECApplication)

+ (UIColor *)barTintColor;
+ (UIColor *)tintColor;
+ (UIColor *)barTextColor;

+ (UIColor *)titleColor;
+ (UIColor *)subtitleColor;

@end
