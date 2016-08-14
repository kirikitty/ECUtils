//
//  NSDictionary+Utils.h
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSNull+Protection.h"

@interface NSDictionary (Utils)

- (double)doubleForKey:(id)aKey;
- (float)floatForKey:(id)aKey;
- (int)intForKey:(id)aKey;
- (NSInteger)integerForKey:(id)aKey;
- (long long)longLongForKey:(id)aKey;
- (BOOL)boolForKey:(id)aKey;

@end

@interface NSMutableDictionary (Utils)

- (void)setDouble:(double)value forKey:(id<NSCopying>)aKey;
- (void)setFloat:(float)value forKey:(id<NSCopying>)aKey;
- (void)setInt:(int)value forKey:(id<NSCopying>)aKey;
- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)aKey;
- (void)setLongLong:(long long)value forKey:(id<NSCopying>)aKey;
- (void)setBool:(BOOL)value forKey:(id<NSCopying>)aKey;

@end
