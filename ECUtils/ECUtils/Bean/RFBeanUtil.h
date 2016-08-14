//
//  RFBeanUtil.h
//  ECUtils
//
//  Created by kiri on 15/6/14.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFBeanProperty.h"
#import "RFBeanPropertyAnnotation.h"

@interface RFBeanUtil : NSObject

/*!
 * shallow copy. Pointer & union is also copied. 
 * @note object that conforms protocol NSCopying or NSMutableCopying will be copied.
 */
+ (id)copyObject:(id)object;
+ (id)copyObject:(id)object withZone:(NSZone *)zone;

// properties. SEL will parse to NSString. Pointer & union will be lost.
+ (NSMutableDictionary *)propertiesFromObject:(id)object;
+ (id)objectFromProperties:(NSDictionary *)properties class:(Class)cls;
+ (void)setProperties:(NSDictionary *)properties toObject:(id)object class:(Class)cls;

+ (NSMutableDictionary *)propertiesFromObject:(id)object class:(Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id value, RFBeanProperty *property))preprocessor;
+ (void)setProperties:(NSDictionary *)properties toObject:(id)object class:(Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id value, RFBeanProperty *property))preprocessor;
+ (id)objectFromProperties:(NSDictionary *)properties class:(Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id value, RFBeanProperty *property))preprocessor;

@end
