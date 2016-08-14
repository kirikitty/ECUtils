//
//  NSTimer+Block.h
//  ECUtils
//
//  Created by kiri on 2013-10-21.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RFBlockTimerRepeatCountInfinite NSIntegerMax

/*!
 *  The timer block to execute.
 *  @param timer The timer.
 *  @return Whether invalidating current timer.
 */
typedef BOOL (^RFTimerBlock)(NSTimer *timer);

@interface NSTimer (Block)

/*!
 *  @abstract Creates and returns a new RFBlockTimer object initialized with the specified block.
 *  @discussion You must add the new timer to a run loop, using addTimer:forMode:. Then, after seconds have elapsed, the timer fires, executing block. (If the timer is configured to repeat, there is no need to subsequently re-add the timer to the run loop.)
 *  @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block The block as timer handler.
 *  @param userInfo Custom user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
 *  @param repeatCount How many times to repeat block execution.
 *  @param completion Be called when timer completed all task. The param in block indicates whether task canceled by block. Always call this block in mainQueue.
 *  @return A new NSTimer object, configured according to the specified parameters.
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(RFTimerBlock)block userInfo:(NSDictionary *)userInfo repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL canceled))completion;

/*!
 *  @abstract Creates and returns a new RFBlockTimer object and schedules it on the current run loop in the default mode.
 *  @discussion After seconds seconds have elapsed, the timer fires, executing block.
 *  @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block The block as timer handler.
 *  @param userInfo The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
 *  @param repeatCount How many times to repeat block execution.
 *  @param completion Be called when timer completed all task. The param in block indicates whether task canceled by block. Always call this block in mainQueue.
 *  @return A new NSTimer object, configured according to the specified parameters.
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(RFTimerBlock)block userInfo:(NSDictionary *)userInfo repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL canceled))completion;

/*!
 *  @abstract Creates and returns a new RFBlockTimer object initialized with the specified block.
 *  @discussion You must add the new timer to a run loop, using addTimer:forMode:. Then, after seconds have elapsed, the timer fires, executing block. (If the timer is configured to repeat, there is no need to subsequently re-add the timer to the run loop.)
 *  @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block The block as timer handler.
 *  @param userInfo The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
 *  @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block userInfo:(NSDictionary *)userInfo repeats:(BOOL)repeats;

/*!
 *  @abstract Creates and returns a new RFBlockTimer object and schedules it on the current run loop in the default mode.
 *  @discussion After seconds seconds have elapsed, the timer fires, executing block.
 *  @param seconds The number of seconds between firings of the timer. If seconds is less than or equal to 0.0, this method chooses the nonnegative value of 0.1 milliseconds instead.
 *  @param block The block as timer handler.
 *  @param userInfo The user info for the timer. The timer maintains a strong reference to this object until it (the timer) is invalidated. This parameter may be nil.
 *  @param repeats If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block userInfo:(NSDictionary *)userInfo repeats:(BOOL)repeats;

@end
