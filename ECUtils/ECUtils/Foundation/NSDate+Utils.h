//
//  NSDate+Utils.h
//  ECUtils
//
//  Created by kiri on 15/5/8.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSString *)stringWithTime:(BOOL)containsSeconds;
- (NSString *)stringWithDate;
- (NSString *)stringWithDateTime;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithFormat:(NSString *)format locale:(NSLocale *)locale;

- (NSString *)GMTString;
- (NSString *)GMTStringWithCurrentTimeZone;

- (NSInteger)day;
- (NSInteger)daysSinceDate:(NSDate *)date;
- (NSDate *)dateByTrimmingTime;

+ (NSDate *)dateWithString:(NSString *)s format:(NSString *)format;

- (int64_t)millisecondsSince1970;
+ (NSDate *)dateWithMillisecondsSince1970:(int64_t)milliseconds;

- (NSString *)feedTimeString;
- (NSString *)constellation;

+ (NSString *)constellationWithMonth:(NSInteger)month day:(NSInteger)day;

@end
