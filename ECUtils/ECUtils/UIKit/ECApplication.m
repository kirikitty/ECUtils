//
//  ECApplication.m
//  ECUtils
//
//  Created by kiri on 14-6-30.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECApplication.h"
#import "ECRootViewController.h"
#import "ECNibUtil.h"
#import "NSDate+Utils.h"

#define kUserDefaultsLastEnterBackgroundTime @"kUserDefaultsLastEnterBackgroundTime"

NSString *const ECApplicationDidReceiveRemotePushNotificaiton = @"ECApplicationDidReceiveRemotePushNotificaiton";
NSString *const ECApplicationDidReceiveLocalPushNotificaiton = @"ECApplicationDidReceiveLocalPushNotificaiton";

void RFCrashHandler(NSException *e);

@interface ECApplication ()

@property (strong, nonatomic) UIWebView *phoneCallView;
@property (strong, nonatomic) NSDate *launchTime;
@property (strong, nonatomic) NSDate *lastActiveTime;
@property (strong, nonatomic) NSDate *lastDeactiveTime;
@property (strong, nonatomic) NSNotification *lastKeyboardNotification;
@property (strong, nonatomic) NSMutableDictionary *cache;
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSMutableArray *listeners;

@property (strong, nonatomic) NSMutableArray *dailyObservers;
@property (strong, nonatomic) NSDate *lastDateForDayChange;

@end

@implementation ECApplication

+ (ECApplication *)sharedApplication
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        _cache = [NSMutableDictionary dictionary];
        _listeners = [NSMutableArray array];
        _dailyObservers = [NSMutableArray array];
        _lastDateForDayChange = [NSDate date];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        // default theme
        _statusBarStyle = UIStatusBarStyleDefault;
        _statusBarAnimation = UIStatusBarAnimationSlide;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Application Delegate
- (void)startWithLaunchOptions:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    self.launchTime = [NSDate date];
    self.lastActiveTime = self.launchTime;
    self.lastDeactiveTime = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastEnterBackgroundTime];
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    delegate.window = [UIWindow new];
    
    delegate.window.rootViewController = [[ECRootViewController alloc] init];
    [self prepareTheme];
    
    [delegate.window makeKeyAndVisible];
    delegate.window.frame = [[UIScreen mainScreen] bounds];
    delegate.window.backgroundColor = [UIColor whiteColor];
    
    if (launchOptions.count == 0) {
        self.launchType = ECApplicationLaunchTypeNormal;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        self.launchType = ECApplicationLaunchTypeRemoteNotification;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] != nil) {
        self.launchType = ECApplicationLaunchTypeLocalNotification;
    } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil) {
        self.launchType = ECApplicationLaunchTypeOpenURL;
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    self.lastActiveTime = [NSDate date];
    self.lastActiveType = ECApplicationLaunchTypeNormal;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    self.lastDeactiveTime = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastDeactiveTime forKey:kUserDefaultsLastEnterBackgroundTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self startBackgroundTaskWithTimeout:30.0];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.listeners makeObjectsPerformSelector:@selector(stopListen)];
}

- (void)applicationDidBecomeActive:(NSNotification *)notifcation
{
}

#pragma mark - Remote Notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (fabs([[ECApplication sharedApplication].lastActiveTime timeIntervalSinceNow]) < 0.5) {
        self.lastActiveType = ECApplicationLaunchTypeRemoteNotification;
        self.lastActiveOptions = @{UIApplicationLaunchOptionsRemoteNotificationKey: userInfo};
        [[NSNotificationCenter defaultCenter] postNotificationName:ECApplicationDidReceiveRemotePushNotificaiton object:self];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (fabs([[ECApplication sharedApplication].lastActiveTime timeIntervalSinceNow]) < 0.5) {
        self.lastActiveType = ECApplicationLaunchTypeLocalNotification;
        self.lastActiveOptions = @{UIApplicationLaunchOptionsLocalNotificationKey: notification};
        [[NSNotificationCenter defaultCenter] postNotificationName:ECApplicationDidReceiveLocalPushNotificaiton object:self];
    }
}

#pragma mark - Application Root
- (UIWindow *)window
{
    return [UIApplication sharedApplication].delegate.window;
}

- (ECRootViewController *)appRootViewController
{
    ECRootViewController *root = (ECRootViewController *)self.window.rootViewController;
    return [root isKindOfClass:[ECRootViewController class]] ? root : nil;
}

- (id)rootViewController
{
    ECRootViewController *root = [self appRootViewController];
    return root ? root.rootViewController : self.window.rootViewController;
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self setRootViewController:controller animated:NO];
}

- (void)setRootViewController:(UIViewController *)controller animated:(BOOL)animated
{
    ECRootViewController *root = [self appRootViewController];
    if (root) {
        [root setRootViewController:controller animated:animated];
    } else {
        self.window.rootViewController = controller;
    }
}

#pragma mark - StatusBar
- (void)setStatusBarHidden:(BOOL)hidden style:(UIStatusBarStyle)style withAnimation:(UIStatusBarAnimation)animation animationDuration:(NSTimeInterval)animationDuration
{
    [[self appRootViewController] setStatusBarHidden:hidden style:style withAnimation:animation animationDuration:animationDuration];
}

- (void)resetStatusBarWithAnimated:(BOOL)animated animationDuration:(NSTimeInterval)animationDuration
{
    [[self appRootViewController] resetStatusBarWithAnimated:animated animationDuration:animationDuration];
}

- (void)refreshStatusBar
{
    [[self appRootViewController] setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Sidebar
- (void)setLeftSidebarTransform:(CGAffineTransform)leftSidebarTransform
{
    if (!CGAffineTransformEqualToTransform(_leftSidebarTransform, leftSidebarTransform)) {
        _leftSidebarTransform = leftSidebarTransform;
        [self appRootViewController].leftSidebarTransform = leftSidebarTransform;
    }
}

- (void)setLeftSidebarWidth:(CGFloat)leftSidebarWidth
{
    if (_leftSidebarWidth != leftSidebarWidth) {
        _leftSidebarWidth = leftSidebarWidth;
        [self appRootViewController].leftSidebarWidth = leftSidebarWidth;
    }
}

- (void)setLeftSidebarViewController:(UIViewController *)leftSidebarViewController
{
    [[self appRootViewController] setLeftSidebarViewController:leftSidebarViewController];
}

- (void)setLeftSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [[self appRootViewController] setLeftSidebarHidden:hidden animated:animated];
}

- (BOOL)isLeftSidebarHidden
{
    return [self appRootViewController].leftSidebarHidden;
}

- (UIViewController *)leftSidebarViewController
{
    return [[self appRootViewController] leftSidebarViewController];
}

- (void)setRightSidebarViewController:(UIViewController *)rightSidebarViewController
{
    [[self appRootViewController] setRightSidebarViewController:rightSidebarViewController];
}

- (void)setRightSidebarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [[self appRootViewController] setRightSidebarHidden:hidden animated:animated];
}

- (BOOL)isRightSidebarHidden
{
    return [self appRootViewController].rightSidebarHidden;
}

- (UIViewController *)rightSidebarViewController
{
    return [[self appRootViewController] rightSidebarViewController];
}

- (UIViewController *)shownSideViewController
{
    return [[self appRootViewController] shownSideViewController];
}

- (void)showSideViewController:(UIViewController *)viewController fromPosition:(ECSideViewPosition)position
{
    [[self appRootViewController] showSideViewController:viewController fromPosition:position];
}

- (void)hideSideViewController
{
    [[self appRootViewController] hideSideViewController];
}

#pragma mark - Utils
- (void)setDeviceOrientation:(UIDeviceOrientation)orientation
{
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

- (BOOL)openURL:(NSURL *)url
{
    return [[UIApplication sharedApplication] openURL:url];
}

- (void)callPhoneNumber:(NSString *)phoneNumber
{
    NSString *phone = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (phone.length == 0) {
        return;
    }
    
    if (self.phoneCallView == nil) {
        self.phoneCallView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [self.phoneCallView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]]]];
}

- (NSString *)version
{
    if (_version == nil) {
        _version = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    }
    return _version;
}

- (BOOL)openRateURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", self.appId];
    return [self openURL:[NSURL URLWithString:urlString]];
}

- (BOOL)openAppURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8", self.appId];
    return [self openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - Keyboard
- (void)keyboardDidChangeFrame:(NSNotification *)notif
{
    self.lastKeyboardNotification = notif;
}

- (CGRect)keyboardFrame
{
    if (self.lastKeyboardNotification) {
        return [self.lastKeyboardNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    } else {
        CGRect rect = CGRectZero;
        rect.origin.y = self.window.bounds.size.height;
        return rect;
    }
}

#pragma mark - Theme
- (void)prepareTheme
{
    if (!CGAffineTransformIsIdentity(self.leftSidebarTransform)) {
        [self appRootViewController].leftSidebarTransform = self.leftSidebarTransform;
    }
    if (self.leftSidebarWidth > 0) {
        [self appRootViewController].leftSidebarWidth = self.leftSidebarWidth;
    }
}

#pragma mark - Listener
- (void)addListener:(id<ECApplicationListener>)listener
{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self addListener:listener];
        });
        return;
    }
    
    if (![self.listeners containsObject:listener]) {
        [self.listeners addObject:listener];
        [listener startListen];
    }
}

- (void)removeListener:(id<ECApplicationListener>)listener
{
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self removeListener:listener];
        });
        return;
    }
    
    if ([self.listeners containsObject:listener]) {
        [listener stopListen];
        [self.listeners removeObject:listener];
    }
}

- (void)startBackgroundTaskWithTimeout:(NSTimeInterval)timeout
{
    __block UIBackgroundTaskIdentifier identifier;
    identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (identifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:identifier];
            identifier = UIBackgroundTaskInvalid;
        }
    }];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (identifier != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:identifier];
                identifier = UIBackgroundTaskInvalid;
            }
        });
    });
}

@end

@implementation UIFont (ECApplication)

+ (UIFont *)fontWithSize:(CGFloat)size
{
    UIFont *font = nil;
    NSString *fontName = [ECApplication sharedApplication].fontName;
    if (fontName.length > 0) {
        font = [self fontWithName:fontName size:size];
    }
    return font ? font : [self systemFontOfSize:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size
{
    UIFont *font = nil;
    NSString *fontName = [ECApplication sharedApplication].boldFontName;
    if (fontName.length > 0) {
        font = [self fontWithName:fontName size:size];
    }
    return font ? font : [self boldSystemFontOfSize:size];
}

@end

@implementation UIColor (ECApplication)

+ (UIColor *)barTintColor
{
    return [ECApplication sharedApplication].barTintColor;
}

+ (UIColor *)barTextColor
{
    return [ECApplication sharedApplication].barTextColor;
}

+ (UIColor *)tintColor
{
    return [ECApplication sharedApplication].tintColor;
}

+ (UIColor *)titleColor
{
    return [ECApplication sharedApplication].titleColor;
}

+ (UIColor *)subtitleColor
{
    return [ECApplication sharedApplication].subtitleColor;
}

@end