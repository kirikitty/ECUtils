//
//  NSData+Utils.h
//  ECUtils
//
//  Created by kiri on 15/4/29.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Utils)

- (NSData *)MD5EncodedData;
- (NSData *)hmacSHA1EncodedDataWithKey:(NSData *)key;
- (NSString *)URLSafeBase64EncodedString;
- (NSString *)base64EncodedString;

/*!
 *  Hex string in lowercase.
 */
- (NSString *)stringRepresentation;

+ (NSMutableData *)dataWithHexString:(NSString *)hex;

@end
