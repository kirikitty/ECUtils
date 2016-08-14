//
//  NSData+Utils.m
//  ECUtils
//
//  Created by kiri on 15/4/29.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "NSData+Utils.h"
#import "NSString+Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Utils)

- (NSData *)MD5EncodedData
{
    if(self.length == 0) {
        return nil;
    }
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
    
    // Convert MD5 value in the buffer to NSData
    return [NSData dataWithBytes:md5Buffer length:sizeof(md5Buffer)];
}

- (NSData *)hmacSHA1EncodedDataWithKey:(NSData *)key
{
    if(self.length == 0 || key.length == 0) {
        return nil;
    }
    
    unsigned char output[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, key.bytes, key.length, self.bytes, self.length, output);
    return [NSData dataWithBytes:output length:sizeof(output)];
}

- (NSString *)base64EncodedString
{
    return [self base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)URLSafeBase64EncodedString
{
    NSString *s = self.base64EncodedString;
    s = [s stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    s = [s stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return s;
}

- (NSString *)stringRepresentation
{
    const uint8_t *p = self.bytes;
    NSInteger length = self.length;
    
    NSMutableString *output = [NSMutableString string];
    for(NSInteger i = 0; i < length; i++) {
        uint8_t byte = p[i];
        [output appendFormat:@"%02x", byte];
    }
    return output;
}

+ (NSMutableData *)dataWithHexString:(NSString *)hex
{
    NSMutableData *data = [NSMutableData data];
    for (NSInteger idx = 0; idx + 2 <= hex.length; idx+= 2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString *subHex = [hex substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:subHex];
        unsigned int intValue;
        if ([scanner scanHexInt:&intValue]) {
            [data appendBytes:&intValue length:1];
        }
    }
    return data;
}

@end
