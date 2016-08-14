//
//  NSNull+Protection.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "NSNull+Protection.h"

@implementation NSNull (Protection)

- (char)charValue
{
    return 0;
}

- (unsigned char)unsignedCharValue
{
    return 0;
}

- (short)shortValue
{
    return 0;
}

- (unsigned short)unsignedShortValue
{
    return 0;
}

- (int)intValue
{
    return 0;
}

- (unsigned int)unsignedIntValue
{
    return 0;
}

- (long)longValue
{
    return [@0 longValue];
}

- (unsigned long)unsignedLongValue
{
    return [@0 unsignedLongValue];
}

- (long long)longLongValue
{
    return 0L;
}

- (unsigned long long)unsignedLongLongValue
{
    return 0L;
}

- (float)floatValue
{
    return 0.f;
}

- (double)doubleValue
{
    return 0.0;
}

- (BOOL)boolValue
{
    return NO;
}

- (NSInteger)integerValue
{
    return 0;
}

- (NSUInteger)unsignedIntegerValue
{
    return 0;
}

- (NSString *)stringValue
{
    return nil;
}

- (void *)pointerValue
{
    return NULL;
}

- (NSRange)rangeValue
{
    return NSMakeRange(0, 0);
}

- (CGPoint)CGPointValue
{
    return CGPointZero;
}

- (CGSize)CGSizeValue
{
    return CGSizeZero;
}

- (CGRect)CGRectValue
{
    return CGRectZero;
}

- (CGAffineTransform)CGAffineTransformValue
{
    return CGAffineTransformIdentity;
}

- (UIEdgeInsets)UIEdgeInsetsValue
{
    return UIEdgeInsetsZero;
}

- (UIOffset)UIOffsetValue
{
    return UIOffsetZero;
}

- (NSComparisonResult)compare:(id)otherObject
{
    if (otherObject == nil || [otherObject isKindOfClass:[NSNull class]]) {
        return NSOrderedSame;
    }
    return NSOrderedAscending;
}

- (BOOL)isEqualToNumber:(id)otherObject
{
    return [self compare:otherObject] == NSOrderedSame;
}

- (BOOL)isEqualToString:(id)otherObject
{
    return [self compare:otherObject] == NSOrderedSame;
}

- (NSUInteger)count
{
    return 0;
}

- (NSUInteger)length
{
    return 0;
}

@end
