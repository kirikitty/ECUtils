//
//  NSString+Utils.h
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSGB2312StringEncoding (CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000))

@interface NSString (Utils)

- (NSData *)UTF8Data;

#pragma mark - URL Coding
- (NSString *)stringByURLEncoding;
- (NSString *)stringByURLDecoding;

#pragma mark - MD5 Encode
- (NSString *)MD5EncodedString;

#pragma mark - Base64 Encode
- (NSString *)base64EncodedString;
- (NSString *)URLSafeBase64EncodedString;

#pragma mark - Pinyin
- (NSString *)pinyin;
- (NSString *)pinyinFirstLetters:(BOOL)isAll;
- (BOOL)isPinyinMatch:(NSString *)anotherString;

#pragma mark - Utils
- (NSString *)stringByRemovingBlankCharacters;
- (NSString *)stringByReplacingUnicodeCharacters;

- (BOOL)containsEmoji;

- (NSString *)trimmedString;
- (NSString *)stringByTrimmingToLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding;

#pragma mark - Creation
+ (NSString *)UUIDString;
+ (NSString *)stringWithDiskSize:(int64_t)size maximumFractionDigits:(NSInteger)maximumFractionDigits;
+ (NSString *)stringWithPlayTime:(NSTimeInterval)playTime prefix:(NSString *)prefix;

+ (NSString *)stringWithDistance:(NSInteger)meters;

#pragma mark - Validation
- (BOOL)isValidEmail;
- (BOOL)isValidMobilePhone;
- (BOOL)isValidURL;

- (BOOL)hasText;

#pragma mark - File System
- (NSString *)relativeFilePath;

@end

@interface NSMutableString (Utils)

- (void)appendPathComponent:(NSString *)component;

@end
