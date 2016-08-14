//
//  NSDictionary+Utils.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

- (double)doubleForKey:(id)aKey
{
    return [[self objectForKey:aKey] doubleValue];
}

- (float)floatForKey:(id)aKey
{
    return [[self objectForKey:aKey] floatValue];
}

- (int)intForKey:(id)aKey
{
    return [[self objectForKey:aKey] intValue];
}

- (NSInteger)integerForKey:(id)aKey
{
    return [[self objectForKey:aKey] integerValue];
}

- (long long)longLongForKey:(id)aKey
{
    return [[self objectForKey:aKey] longLongValue];
}

- (BOOL)boolForKey:(id)aKey
{
    return [[self objectForKey:aKey] boolValue];
}

@end

@implementation NSMutableDictionary (Utils)

- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithDouble:value] forKey:aKey];
}

- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setInt:(int)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithInt:value] forKey:aKey];
}

- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithInteger:value] forKey:aKey];
}

- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithLongLong:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey
{
    [self setObject:[NSNumber numberWithBool:value] forKey:aKey];
}

@end

