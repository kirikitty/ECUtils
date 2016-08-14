//
//  RFJSONObject.h
//  ECUtils
//
//  Created by kiri on 15/6/27.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJSONPropertyAnnotation.h"

@protocol RFJSONObject <NSObject>

@optional
#pragma mark - global control
- (instancetype)initWithJSONValue:(NSDictionary *)value;
- (NSMutableDictionary *)JSONValue;

#pragma mark - fragment control
/*!
 * It's a dictionary of {propertyName, annotation}.
 * @see RFJSONPropertyAnnotation
 */
- (NSDictionary *)JSONPropertyAnnotations;

#pragma mark - callbacks
- (BOOL)shouldStartEncodingJSONValue;
- (void)didEncodeWithJSONValue:(NSMutableDictionary *)value;

/*!
 * It has no effect with - initWithJSONValue:
 */
- (BOOL)shouldStartDecodingWithJSONValue:(NSDictionary *)value;
- (void)didDecodeWithJSONValue:(NSDictionary *)value;

@end
