//
//  NSDate+Utils.m
//  ECUtils
//
//  Created by kiri on 15/5/8.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

- (NSDate *)dateByTrimmingTime
{
    NSDateFormatter *df = [[self class] formatterWithFormat:@"yyyy-MM-dd"];
    return [df dateFromString:[df stringFromDate:self]];
}

- (NSString *)stringWithTime:(BOOL)containsSeconds
{
    return containsSeconds ? [self stringWithFormat:@"HH:mm:ss"] : [self stringWithFormat:@"HH:mm"];
}

- (NSString *)stringWithDate
{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)stringWithDateTime
{
    return [self stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *df = [NSDate formatterWithFormat:format];
    if (df == nil) {
        df = [NSDateFormatter new];
        df.dateFormat = format;
    }
    return [df stringFromDate:self];
}

- (NSString *)stringWithFormat:(NSString *)format locale:(NSLocale *)locale
{
    NSDateFormatter *df = [NSDate formatterWithFormat:format];
    if (df == nil) {
        df = [NSDateFormatter new];
        df.dateFormat = format;
    }
    df.locale = locale ? locale : [NSLocale autoupdatingCurrentLocale];
    return [df stringFromDate:self];
}

- (NSString *)GMTString
{
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [NSDateFormatter new];
        df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss zzz";
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return [df stringFromDate:self];
}

- (NSString *)GMTStringWithCurrentTimeZone
{
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [NSDateFormatter new];
        df.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss zzz";
        df.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return [df stringFromDate:self];
}

- (NSInteger)day
{
    return [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitDay fromDate:self].day;
}

- (NSInteger)daysSinceDate:(NSDate *)date
{
    if (date == nil) {
        return 0;
    }
    
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *comp2 = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self];
    components.hour = comp2.hour;
    components.minute = comp2.minute;
    components.second = comp2.second;
    NSDate *dateToCompare = [cal dateFromComponents:components];
    return round(([self timeIntervalSinceReferenceDate] - [dateToCompare timeIntervalSinceReferenceDate]) / 86400);
}

+ (NSDate *)dateWithString:(NSString *)s format:(NSString *)format
{
    if (s.length == 0) {
        return nil;
    }
    
    return [[self formatterWithFormat:format] dateFromString:s];
}

+ (NSDateFormatter *)formatterWithFormat:(NSString *)format
{
    static NSMutableDictionary *dfs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dfs = [NSMutableDictionary dictionary];
    });
    
    NSDateFormatter *formatter = dfs[format];
    if (formatter) {
        return formatter;
    } else {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = format;
        if ([NSThread isMainThread]) {
            dfs[format] = df;
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dfs[format] = df;
            });
        }
        return df;
    }
}

- (int64_t)millisecondsSince1970
{
    return ((int64_t)[self timeIntervalSince1970]) * 1000;
}

+ (NSDate *)dateWithMillisecondsSince1970:(int64_t)milliseconds
{
    return [self dateWithTimeIntervalSince1970:milliseconds / 1000.0];
}

- (NSString *)feedTimeString
{
    NSTimeInterval interval = -[self timeIntervalSinceNow];
    if (interval < 60) {
        return @"刚刚";
    } else if (interval < 3600) {
        return [NSString stringWithFormat:@"%.0f分钟前", interval / 60];
    } else if (interval < 86400) {
        return [NSString stringWithFormat:@"%.0f小时前", interval / 3600];
    } else {
        NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
        NSDateComponents *components = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
        NSInteger currentYear = [cal components:NSCalendarUnitYear fromDate:[NSDate date]].year;
        if (components.year == currentYear) {
            return [self stringWithFormat:@"M月d日"];
        } else {
            return [self stringWithFormat:@"y年M月d日"];
        }
    }
}

- (NSString *)constellation
{
    NSDateComponents *comps = [[NSCalendar autoupdatingCurrentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSInteger m = comps.month;
    NSInteger d = comps.day;
    return [[self class] constellationWithMonth:m day:d];
}

+ (NSString *)constellationWithMonth:(NSInteger)m day:(NSInteger)d
{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    if (m < 1|| m > 12|| d < 1 || d > 31) {
        return nil;
    }
    
    if(m == 2 && d > 29) {
        return nil;
    } else if (m == 4 || m == 6 || m == 9 || m == 11) {
        if (d > 30) {
            return nil;
        }
    }
    return [NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
}

@end
