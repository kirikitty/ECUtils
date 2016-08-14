//
//  NSString+Utils.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ECPinyinUtil.h"
#import "NSDate+Utils.h"
#import "NSData+Utils.h"

@implementation NSString (Utils)

- (NSData *)UTF8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - URL Coding
- (NSString *)stringByURLEncoding
{
    __autoreleasing NSString *urlEncoded = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR("!*'\"();:@&=+$,/?%#[]% "), kCFStringEncodingUTF8);
    return urlEncoded;
}

- (NSString *)stringByURLDecoding
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - MD5 Encode
- (NSString *)MD5EncodedString
{
    return self.UTF8Data.MD5EncodedData.stringRepresentation;
}

#pragma mark - Base64
- (NSString *)base64EncodedString
{
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)URLSafeBase64EncodedString
{
    NSString *s = [self base64EncodedString];
    s = [s stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    s = [s stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return s;
}

#pragma mark - Utils
- (NSString *)stringByRemovingBlankCharacters
{
    return [self stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)stringByReplacingUnicodeCharacters
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:nil];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

- (BOOL)containsEmoji
{
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (NSString *)trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringByTrimmingToLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding
{
    if ([self lengthOfBytesUsingEncoding:encoding] <= length) {
        return self;
    }
    
    NSMutableString *s = [NSMutableString stringWithString:self];
    [self enumerateSubstringsInRange:NSMakeRange(0, s.length) options:NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [s deleteCharactersInRange:NSMakeRange(s.length - substringRange.length, substringRange.length)];
        *stop = [s lengthOfBytesUsingEncoding:encoding] <= length;
    }];
    return s;
}

#pragma mark - Creation
+ (NSString *)UUIDString
{
    if ([NSUUID class]) {
        return [[NSUUID UUID] UUIDString];
    } else {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *result = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
        CFRelease(uuid);
        return result;
    }
}

+ (NSString *)stringWithDiskSize:(int64_t)size maximumFractionDigits:(NSInteger)maximumFractionDigits
{
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lliB", size];
    } else if (size < 1024 * 1024) {
        NSInteger fraction = MIN(maximumFractionDigits, 3);
        NSString *format = [NSString stringWithFormat:@"%%.%@fKB", @(fraction)];
        return [NSString stringWithFormat:format, size / 1024.0];
    } else if (size < 1024 * 1024 * 1024) {
        NSInteger fraction = MIN(maximumFractionDigits, 6);
        NSString *format = [NSString stringWithFormat:@"%%.%@fMB", @(fraction)];
        return [NSString stringWithFormat:format, size / 1024.0 / 1024.0];
    } else {
        NSInteger fraction = MIN(maximumFractionDigits, 9);
        NSString *format = [NSString stringWithFormat:@"%%.%@fGB", @(fraction)];
        return [NSString stringWithFormat:format, size / 1024.0 / 1024.0 / 1024.0];
    }
}

+ (NSString *)stringWithPlayTime:(NSTimeInterval)playTime prefix:(NSString *)prefix
{
    return [self stringWithPlayTime:playTime prefix:prefix zeroPadding:YES];
}

+ (NSString *)stringWithDistance:(NSInteger)meters
{
    if (meters < 1) {
        return [NSString stringWithFormat:@"1米以内"];
    } else if (meters < 1000) {
        return [NSString stringWithFormat:@"%@米以内", @(meters)];
    } else if (meters < 10000) {
        return [NSString stringWithFormat:@"%.2f千米以内", meters / 1000.0];
    } else {
        return [NSString stringWithFormat:@"%.0f千米以内", meters / 1000.0];
    }
}

+ (NSString *)stringWithPlayTime:(NSTimeInterval)playTime prefix:(NSString *)prefix zeroPadding:(BOOL)zeroPadding
{
    if (isnan(playTime)) {
        return @"--:--";
    }
    
    if (fabs(playTime) < 1) {
        return zeroPadding ? @"00:00" : @"0:00";
    }
    
    int time = fabs(playTime);
    int hours = time / 3600;
    int left = time % 3600;
    int minutes = left / 60;
    int seconds = left % 60;
    if (prefix == nil) {
        prefix = playTime < 0 ? @"-" : @"";
    }
    
    if (zeroPadding) {
        return hours > 0 ? [NSString stringWithFormat:@"%@%02d:%02d:%02d", prefix, hours, minutes, seconds] : [NSString stringWithFormat:@"%@%02d:%02d", prefix, minutes, seconds];
    } else {
        return hours > 0 ? [NSString stringWithFormat:@"%@%d:%02d:%02d", prefix, hours, minutes, seconds] : [NSString stringWithFormat:@"%@%d:%02d", prefix, minutes, seconds];
    }
}

+ (NSString *)hexStringWithData:(NSData *)data
{
    const char *p = data.bytes;
    NSInteger length = data.length;
    
    NSMutableString *output = [NSMutableString string];
    for(NSInteger i = 0; i < length; i++) {
        [output appendFormat:@"%02x",p[i]];
    }
    return output;
}

#pragma mark - Pinyin
- (NSString *)pinyin
{
    NSMutableData *data = [NSMutableData data];
    char buffer[80];
    for (int i = 0; i < [self length]; i++) {
        unichar c = [self characterAtIndex:i];
        int len;
        BOOL isPinyin = [ECPinyinUtil unichar2Py:c out:buffer outlen:&len];
        if (!isPinyin) {
            NSString *tmp = [NSString stringWithCharacters:&c length:1];
            [data appendData:[tmp dataUsingEncoding:NSUTF8StringEncoding]];
            continue;
        }
        
        int length = -1;
        int offset = 0;
        char initial = tolower([ECPinyinUtil firstLetterWithCharacter:c]);
        for (int j = 0; j < len; j++) {
            if (buffer[j] == '|') {
                if (buffer[offset] != initial) {
                    offset = j + 1;
                } else {
                    length = j - offset;
                    break;
                }
            }
        }
        if (length < offset) {
            length = len - offset;
        }
        if (length > 0) {
            buffer[offset] = toupper(buffer[offset]);
            [data appendBytes:buffer + offset length:length];
        }
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)pinyinFirstLetters:(BOOL)isAll
{
    if (self.length == 0) {
        return nil;
    }
    
    unichar chResult[self.length];
    for (int i = 0; i < self.length; i++) {
        unichar letter = [self characterAtIndex:i];
        chResult[i] = [ECPinyinUtil firstLetterWithCharacter:letter];
        if (!isAll) {
            break;
        }
    }
    return [NSString stringWithCharacters:chResult length:isAll ? self.length : 1];
}

- (BOOL)isPinyinMatch:(NSString *)aString
{
    return [[aString pinyin] rangeOfString:[self pinyin] options:NSCaseInsensitiveSearch].location != NSNotFound;
}

#pragma mark - Validation
- (BOOL)isValidMobilePhone
{
    return [self rangeOfString:@"^1\\d{10}$" options:NSRegularExpressionSearch].location != NSNotFound;
}

- (BOOL)isValidEmail
{
    return [self rangeOfString:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$" options:NSRegularExpressionSearch].location != NSNotFound;
}

- (BOOL)isValidURL {
    NSUInteger length = [self length];
    if (length > 0) {
        NSError *error = nil;
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        if (dataDetector && !error) {
            NSRange range = NSMakeRange(0, length);
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:self options:0 range:range];
            if (linkRange.length > 0 && NSEqualRanges(range, linkRange)) {
                return YES;
            }
        } else {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    return NO;
}

- (BOOL)hasText
{
    if (![self isKindOfClass:[NSString class]]) {
        return NO;
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

#pragma mark - File System
- (NSString *)relativeFilePath
{
    if (self.length == 0) {
        return nil;
    }
    
    NSString *path = self;
    if ([path hasPrefix:@"/private/"]) {
        path = [path substringFromIndex:@"/private".length];
    }
    NSString *home = NSHomeDirectory();
    NSString *appId = home.lastPathComponent;
    NSString *appRoot = [home substringToIndex:home.length - appId.length];
    if (path.length < appRoot.length) {
        return nil;
    }
    
    NSString *tmp = [path substringFromIndex:appRoot.length];
    NSInteger sepIndex = [tmp rangeOfString:@"/"].location;
    if (sepIndex == NSNotFound) {
        return nil;
    }
    
    return [tmp substringFromIndex:sepIndex];
}

@end

@implementation NSMutableString (Utils)

- (void)appendPathComponent:(NSString *)component
{
    BOOL b1 = [self hasSuffix:@"/"];
    BOOL b2 = [component hasPrefix:@"/"];
    if (b1 && b2 ) {
        [self appendString:[component substringFromIndex:1]];
    } else if (b1 || b2) {
        [self appendString:component];
    } else {
        [self appendString:@"/"];
        [self appendString:component];
    }
}

@end
