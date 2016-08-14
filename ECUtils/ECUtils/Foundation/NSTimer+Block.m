//
//  NSTimer+Block.m
//  ECUtils
//
//  Created by kiri on 2013-10-21.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "NSTimer+Block.h"

/*!
 *  A NSTimer that executes block.
 */
@interface RFBlockTimerHandler : NSObject

/*! How many times to repeat the block loop. */
@property (nonatomic) NSUInteger totalRepeatCount;

/*! How many times of the executed block loop. */
@property (nonatomic) NSUInteger currentRepeatCount;

@property (nonatomic, copy) RFTimerBlock block;

@property (nonatomic, copy) void (^blockWithoutBreak)(NSTimer *timer);

@property (nonatomic, copy) void (^completion)(BOOL finished);

@end

@implementation RFBlockTimerHandler

- (void)timerHandler:(NSTimer *)timer
{
    if (self.blockWithoutBreak) {
        __weak __typeof(timer) weakTimer = timer;
        self.blockWithoutBreak(weakTimer);
        return;
    }
    
    self.currentRepeatCount++;
    BOOL isBreak = (self.totalRepeatCount > 0 && self.totalRepeatCount != RFBlockTimerRepeatCountInfinite && self.currentRepeatCount >= self.totalRepeatCount);
    BOOL canceled = NO;
    if (self.block) {
        __weak __typeof(timer) weakTimer = timer;
        canceled = self.block(weakTimer);
        isBreak = isBreak || canceled;
    }
    
    if (isBreak) {
        [timer invalidate];
        if (self.completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.completion(canceled);
            }];
        }
    }
}

@end

@implementation NSTimer (Block)

- (RFBlockTimerHandler *)blockTimerHandler
{
    if ([self.userInfo isKindOfClass:[NSDictionary class]]) {
        return [self.userInfo objectForKey:@"__handler"];
    }
    return nil;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(RFTimerBlock)block userInfo:(NSDictionary *)userInfo repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL))completion
{
    RFBlockTimerHandler *fakeTimer = [[RFBlockTimerHandler alloc] init];
    fakeTimer.block = block;
    fakeTimer.blockWithoutBreak = nil;
    fakeTimer.currentRepeatCount = 0;
    fakeTimer.totalRepeatCount = repeatCount;
    fakeTimer.completion = completion;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [dict setObject:fakeTimer forKey:@"__handler"];
    NSTimer *timer = [self timerWithTimeInterval:seconds target:fakeTimer selector:@selector(timerHandler:) userInfo:dict repeats:repeatCount < 2 ? NO : YES];
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(RFTimerBlock)block userInfo:(NSDictionary *)userInfo repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL))completion
{
    RFBlockTimerHandler *fakeTimer = [[RFBlockTimerHandler alloc] init];
    fakeTimer.block = block;
    fakeTimer.blockWithoutBreak = nil;
    fakeTimer.currentRepeatCount = 0;
    fakeTimer.totalRepeatCount = repeatCount;
    fakeTimer.completion = completion;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [dict setObject:fakeTimer forKey:@"__handler"];
    NSTimer *timer = [self scheduledTimerWithTimeInterval:seconds target:fakeTimer selector:@selector(timerHandler:) userInfo:dict repeats:repeatCount < 2 ? NO : YES];
    return timer;
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *))block userInfo:(NSDictionary *)userInfo repeats:(BOOL)repeats
{
    RFBlockTimerHandler *fakeTimer = [[RFBlockTimerHandler alloc] init];
    fakeTimer.blockWithoutBreak = block;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [dict setObject:fakeTimer forKey:@"__handler"];
    NSTimer *timer = [self timerWithTimeInterval:seconds target:fakeTimer selector:@selector(timerHandler:) userInfo:dict repeats:repeats];
    return timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *))block userInfo:(NSDictionary *)userInfo repeats:(BOOL)repeats
{
    RFBlockTimerHandler *fakeTimer = [[RFBlockTimerHandler alloc] init];
    fakeTimer.blockWithoutBreak = block;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [dict setObject:fakeTimer forKey:@"__handler"];
    NSTimer *timer = [self scheduledTimerWithTimeInterval:seconds target:fakeTimer selector:@selector(timerHandler:) userInfo:dict repeats:repeats];
    return timer;
}

@end
