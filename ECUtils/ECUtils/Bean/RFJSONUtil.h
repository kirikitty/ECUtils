//
//  RFJSONUtil.h
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJSONObject.h"

typedef NS_OPTIONS(NSUInteger, RFJSONReadingOptions) {
    RFJSONReadingMutableContainers = 1UL << 0,
    RFJSONReadingMutableLeaves = 1UL << 1,
    RFJSONReadingAllowFragments = 1UL << 2,
};

typedef NS_OPTIONS(NSUInteger, RFJSONWritingOptions) {
    RFJSONWritingPrettyPrinted = 1UL << 0,
    RFJSONWritingIncludeClassName = 1UL << 16,
};

@interface RFJSONUtil : NSObject

#pragma mark - Work with String
+ (id)objectFromString:(NSString *)jsonString;
+ (id)objectFromString:(NSString *)jsonString class:(Class)aClass;
+ (id)objectFromString:(NSString *)jsonString class:(Class)aClass options:(RFJSONReadingOptions)options;

+ (NSString *)stringFromObject:(id)object;
+ (NSString *)stringFromObject:(id)object options:(RFJSONWritingOptions)options;

#pragma mark - Work with Data
+ (id)objectFromData:(NSData *)jsonData;
+ (id)objectFromData:(NSData *)jsonData class:(Class)aClass;
+ (id)objectFromData:(NSData *)jsonData class:(Class)aClass options:(RFJSONReadingOptions)options;

+ (NSData *)dataFromObject:(id)object;
+ (NSData *)dataFromObject:(id)object options:(RFJSONWritingOptions)options;

#pragma mark - Work with JSONValue
+ (id)JSONValueWithObject:(id)object;
+ (id)JSONValueWithObject:(id)object options:(RFJSONWritingOptions)options;

+ (id)objectWithJSONValue:(id)value;
+ (id)objectWithJSONValue:(id)jsonValue class:(Class)aClass;

#pragma mark - Copy
/// Copy object deeply.
+ (id)copyObject:(id)object;

@end
