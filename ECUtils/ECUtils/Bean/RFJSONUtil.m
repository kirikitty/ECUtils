//
//  RFJSONUtil.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "RFJSONUtil.h"
#import "RFBeanUtil.h"
#import "ECLog.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define ECHasOption(opts, opt) (((opts) & (opt)) == (opt))

@interface RFJSONUtil ()

+ (NSString *)classNameKey;
+ (NSString *)valueKey;

@end

@implementation RFJSONUtil

#pragma mark - Work with String
+ (id)objectFromString:(NSString *)jsonString
{
    return [self objectFromString:jsonString class:nil options:0];
}

+ (id)objectFromString:(NSString *)jsonString class:(Class)aClass
{
    return [self objectFromString:jsonString class:aClass options:0];
}

+ (id)objectFromString:(NSString *)jsonString class:(Class)aClass options:(RFJSONReadingOptions)options
{
    if ([jsonString isKindOfClass:[NSDictionary class]] || [jsonString isKindOfClass:[NSArray class]]) {
        return [self objectWithJSONValue:jsonString class:aClass];
    }
    return [self objectFromData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] class:aClass options:options];
}

+ (NSString *)stringFromObject:(id)object
{
    return [self stringFromObject:object options:0];
}

+ (NSString *)stringFromObject:(id)object options:(RFJSONWritingOptions)options
{
    NSData *data = [self dataFromObject:object options:options];
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark - Work with Data
+ (id)objectFromData:(NSData *)jsonData
{
    return [self objectFromData:jsonData class:nil options:0];
}

+ (id)objectFromData:(NSData *)jsonData class:(Class)aClass
{
    return [self objectFromData:jsonData class:aClass options:0];
}

+ (id)objectFromData:(NSData *)jsonData class:(Class)aClass options:(RFJSONReadingOptions)options
{
    if (jsonData == nil) {
        return nil;
    }
    
    NSJSONReadingOptions opts = 0;
    if (ECHasOption(options, RFJSONReadingMutableContainers)) {
        opts |= NSJSONReadingMutableContainers;
    }
    if (ECHasOption(options, RFJSONReadingMutableLeaves)) {
        opts |= NSJSONReadingMutableLeaves;
    }
    if (ECHasOption(options, RFJSONReadingAllowFragments)) {
        opts |= NSJSONReadingAllowFragments;
    }
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:opts error:&error];
    if (jsonData.length > 0 && json == nil) {
        ECLogDebug(@"json error = %@, string = %@", error, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    }
    return json ? [self objectWithJSONValue:json class:aClass] : nil;
}

+ (NSData *)dataFromObject:(id)object
{
    return [self dataFromObject:object options:0];
}

+ (NSData *)dataFromObject:(id)object options:(RFJSONWritingOptions)options
{
    id json = [self JSONValueWithObject:object options:options];
    if (json && [NSJSONSerialization isValidJSONObject:json]) {
        NSJSONWritingOptions opts = 0;
        if(ECHasOption(options, RFJSONWritingPrettyPrinted)) {
            opts |= NSJSONWritingPrettyPrinted;
        }
        return [NSJSONSerialization dataWithJSONObject:json options:opts error:nil];
    }
    return nil;
}


#pragma mark - Work with JSONValue
+ (id)JSONValueWithObject:(id)object
{
    return [self JSONValueWithObject:object options:0];
}

+ (id)objectWithJSONValue:(id)value
{
    return [self objectWithJSONValue:value class:NULL];
}

+ (id)JSONValueWithObject:(id)object options:(RFJSONWritingOptions)options
{
    id (^completion)(id result) = ^id(id result) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            if (ECHasOption(options, RFJSONWritingIncludeClassName)) {
                NSMutableDictionary *map = [result mutableCopy];
                map[self.classNameKey] = class_isMetaClass(object_getClass(object)) ? @"Class" : NSStringFromClass([object class]);
                return map;
            }
        }
        return result;
    };
    
    // Already valid, return.
    if ([NSJSONSerialization isValidJSONObject:object]) {
        return completion(object);
    }
    
    // Change set & ordered set to array, not support other collections.
    if ([object isKindOfClass:[NSSet class]]) {
        object = [object allObjects];
    } else if ([object isKindOfClass:[NSOrderedSet class]]) {
        object = [object array];
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        // Parse array recursively.
        NSMutableArray *result = [NSMutableArray array];
        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id value = [self JSONValueWithObject:obj options:options];
            if (value) {
                [result addObject:value];
            }
        }];
        return result;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        // Parse dictionary recursively.
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]]) {
                id value = [self JSONValueWithObject:obj options:options];
                if (value) {
                    result[key] = value;
                }
            }
        }];
        return completion(result);
    } else {
        // Filter simple object (json fragment).
        if ([self isJSONFragment:object]) {
            // these are json fragment.
            return object;
        } else {
            id result = nil;
            if ([object isKindOfClass:[NSDate class]]) {    // date to NSNumber of milliseconds.
                result = @((int64_t)[object timeIntervalSince1970] * 1000L);
            } else if ([object isKindOfClass:[NSData class]]) { // data to base64 string
                result = [object base64EncodedStringWithOptions:0];
            } else if (class_isMetaClass(object_getClass(object))) {
                result = NSStringFromClass(object);
            } else {  // Objects parsed to json using NSCoding
                NSArray *classes = self.supportedNSCodingClasses;
                for (Class cls in classes) {
                    if ([object isKindOfClass:cls]) {
                        result = [[self safeArchiveObject:object] base64EncodedStringWithOptions:0];
                        break;
                    }
                }
            }
            if (result) {
                if (ECHasOption(options, RFJSONWritingIncludeClassName)) {
                    return completion(@{self.valueKey: result});
                }
                return result;
            }
        }
        
        // parse object.
        
        // Check skip or not.
        if ([object respondsToSelector:@selector(shouldStartEncodingJSONValue)] && ![object shouldStartEncodingJSONValue]) {
            return nil;
        }
        
        // Start encoding.
        if ([object respondsToSelector:@selector(JSONValue)]) {
            return completion([object JSONValue]);
        }
        
        NSDictionary *annotations = nil;
        if ([object respondsToSelector:@selector(JSONPropertyAnnotations)]) {
            annotations = [object JSONPropertyAnnotations];
        }
        NSMutableDictionary *properties = [RFBeanUtil propertiesFromObject:object class:nil recursive:YES annotations:annotations preprocessor:^id(id value, RFBeanProperty *property) {
            // parse basic property directly.
            if (value == nil) {
                return nil;
            }
            
            if (property.typeEncoding == _C_CLASS) {
                return [value isKindOfClass:[NSString class]] ? value : NSStringFromClass(value);
            } else if (property.typeEncoding == _C_SEL) {
                return value;
            }
            
            if ([self isJSONFragment:value]) {
                return value;
            } else if ([value isKindOfClass:[NSDate class]]) {
                return @((int64_t)[value timeIntervalSince1970] * 1000L);
            } else if ([value isKindOfClass:[NSData class]]) {
                return [value base64EncodedStringWithOptions:0];
            } else if ([value isKindOfClass:[NSValue class]]) {
                NSString *structName = property.structName;
                if (structName) {
                    NSValue *structVal = value;
                    if ([structName isEqualToString:@"CGPoint"]) {
                        return NSStringFromCGPoint(structVal.CGPointValue);
                    } else if ([structName isEqualToString:@"CGSize"]) {
                        return NSStringFromCGSize(structVal.CGSizeValue);
                    } else if ([structName isEqualToString:@"CGRect"]) {
                        return NSStringFromCGRect(structVal.CGRectValue);
                    } else if ([structName isEqualToString:@"UIEdgeInsets"]) {
                        return NSStringFromUIEdgeInsets(structVal.UIEdgeInsetsValue);
                    } else if ([structName isEqualToString:@"NSRange"]) {
                        return NSStringFromRange(structVal.rangeValue);
                    } else if ([structName isEqualToString:@"CGAffineTransform"]) {
                        return NSStringFromCGAffineTransform(structVal.CGAffineTransformValue);
                    } else if ([structName isEqualToString:@"UIOffset"]) {
                        return NSStringFromUIOffset(structVal.UIOffsetValue);
                    }
                }
                return [[self safeArchiveObject:value] base64EncodedStringWithOptions:0];
            } else {
                NSArray *classes = self.supportedNSCodingClasses;
                for (Class cls in classes) {
                    if ([value isKindOfClass:cls]) {
                        return [[self safeArchiveObject:value] base64EncodedStringWithOptions:0];
                    }
                }
            }
            return [self JSONValueWithObject:value options:options];
        }];
        
        // encoding finished.
        if ([object respondsToSelector:@selector(didEncodeWithJSONValue:)]) {
            [object didEncodeWithJSONValue:properties];
        }
        return completion(properties);
    }
}

+ (id)objectWithJSONValue:(id)value class:(__unsafe_unretained Class)aClass
{
    if (![NSJSONSerialization isValidJSONObject:value]) {
        // parse json fragment
        if ([value isKindOfClass:[NSNumber class]]) {
            if (aClass == NULL || [aClass isSubclassOfClass:[NSNumber class]]) {
                return value;
            } else if ([aClass isSubclassOfClass:[NSDate class]]) {
                return [NSDate dateWithTimeIntervalSince1970:[value longLongValue] / 1000.0];
            }
        } else if ([value isKindOfClass:[NSString class]]) {
            if (aClass == NULL || [aClass isSubclassOfClass:[NSString class]]) {
                return value;
            } else if ([aClass isSubclassOfClass:[NSData class]]) {
                return [[NSData alloc] initWithBase64EncodedString:value options:0];
            } else if (aClass != NULL) {
                NSArray *classes = self.supportedNSCodingClasses;
                for (Class cls in classes) {
                    if ([aClass isSubclassOfClass:cls]) {
                        NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:0];
                        return [self safeUnarchiveObject:data];
                    }
                }
                
                // maybe value is jsonString
                return [self objectFromString:value class:aClass];
            }
        } else if ([value isKindOfClass:[NSNull class]]) {
            if (aClass == NULL || [aClass isSubclassOfClass:[NSNull class]]) {
                return value;
            }
        }
        return nil;
    }
    
    if ([value isKindOfClass:[NSArray class]]) {
        // parse array recursively
        NSMutableArray *result = [NSMutableArray array];
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id temp = [self objectWithJSONValue:obj class:aClass];
            if (temp) {
                [result addObject:temp];
            }
        }];
        return result;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        // detect actual class.
        Class cls = aClass;
        
        // internal class preffered.
        NSString *internalClassName = value[self.classNameKey];
        if ([internalClassName isEqualToString:@"Class"]) {
            return NSClassFromString(value[self.valueKey]);
        } else if (internalClassName.length > 0) {
            Class test = NSClassFromString(internalClassName);
            if (test) {
                cls = test;
            }
        }
        
        // parse basic object
        if (cls != nil) {
            if ([cls isSubclassOfClass:[NSDate class]]) {
                id obj = value[self.valueKey];
                if ([obj isKindOfClass:[NSNumber class]]) {
                    return [NSDate dateWithTimeIntervalSince1970:[obj longLongValue] / 1000.0];
                }
                return nil;
            }
            
            BOOL isNSCoding = NO;
            NSArray *classes = self.supportedNSCodingClasses;
            for (Class c in classes) {
                if ([cls isSubclassOfClass:c]) {
                    isNSCoding = YES;
                    break;
                }
            }
            if (isNSCoding || [cls isSubclassOfClass:[NSData class]]) {
                id obj = value[self.valueKey];
                if ([obj isKindOfClass:[NSString class]]) {
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:obj options:0];
                    if (isNSCoding) {
                        return [self safeUnarchiveObject:data];
                    } else {
                        return data;
                    }
                }
                return nil;
            }
        }
        
        // parse raw dictionary.
        if (cls == nil || [cls isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *result = [NSMutableDictionary dictionary];
            [value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqualToString:self.classNameKey]) {
                    return;
                }
                
                id temp = [self objectWithJSONValue:obj class:[aClass isSubclassOfClass:[NSDictionary class]] ? NULL : aClass];
                if (temp) {
                    result[key] = temp;
                }
            }];
            return result;
        }
        
        // parse object
        
        // Start decoding.
        // direct decode.
        if ([cls instancesRespondToSelector:@selector(initWithJSONValue:)]) {
            id object = [[cls alloc] initWithJSONValue:value];
            if ([object respondsToSelector:@selector(shouldStartDecodingWithJSONValue:)] && ![object shouldStartDecodingWithJSONValue:value]) {
                return nil;
            }
            return object;
        }
        
        // check skip or not.
        id object = [cls new];
        if ([object respondsToSelector:@selector(shouldStartDecodingWithJSONValue:)] && ![object shouldStartDecodingWithJSONValue:value]) {
            return nil;
        }
        
        NSDictionary *annotations = nil;
        if ([object respondsToSelector:@selector(JSONPropertyAnnotations)]) {
            annotations = [object JSONPropertyAnnotations];
        }
        [RFBeanUtil setProperties:value toObject:object class:cls recursive:YES annotations:annotations preprocessor:^id(id obj, RFBeanProperty *property) {
            // nil.
            if (property.name.length == 0 || [obj isKindOfClass:[NSNull class]]) {
                return nil;
            }
            
            id (^structVal)(NSString *s, NSString *structName) = ^id(NSString *s, NSString *structName) {
                if ([structName isEqualToString:@"CGPoint"]) {
                    return [NSValue valueWithCGPoint:CGPointFromString(s)];
                } else if ([structName isEqualToString:@"CGSize"]) {
                    return [NSValue valueWithCGSize:CGSizeFromString(s)];
                } else if ([structName isEqualToString:@"CGRect"]) {
                    return [NSValue valueWithCGRect:CGRectFromString(s)];
                } else if ([structName isEqualToString:@"UIEdgeInsets"]) {
                    return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsFromString(s)];
                } else if ([structName isEqualToString:@"NSRange"]) {
                    return [NSValue valueWithRange:NSRangeFromString(s)];
                } else if ([structName isEqualToString:@"CGAffineTransform"]) {
                    return [NSValue valueWithCGAffineTransform:CGAffineTransformFromString(s)];
                } else if ([structName isEqualToString:@"UIOffset"]) {
                    return [NSValue valueWithUIOffset:UIOffsetFromString(s)];
                }
                return nil;
            };
            
            // object
            Class pclass = property.cls;
            if (pclass) {
                RFJSONPropertyAnnotation *annotation = annotations[property.name];
                if ([pclass isSubclassOfClass:[NSArray class]] || [pclass isSubclassOfClass:[NSSet class]] || [pclass isSubclassOfClass:[NSOrderedSet class]]) {
                    // parse array.
                    if ([obj isKindOfClass:[NSString class]]) {
                        obj = [self objectFromString:obj];
                    }
                    if ([obj isKindOfClass:[NSData class]]) {
                        obj = [self objectFromData:obj];
                    }
                    if (![obj isKindOfClass:[NSArray class]]) {
                        return nil;
                    }
                    
                    NSMutableArray *array = [NSMutableArray array];
                    [obj enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
                        id temp = [self objectWithJSONValue:obj2 class:annotation.classInArray];
                        if (temp) {
                            [array addObject:temp];
                        }
                    }];
                    if ([pclass isSubclassOfClass:[NSSet class]]) {
                        return [NSMutableSet setWithArray:array];
                    } else if ([pclass isSubclassOfClass:[NSOrderedSet class]]) {
                        return [NSMutableOrderedSet orderedSetWithArray:array];
                    } else {
                        return array;
                    }
                } else if ([pclass isSubclassOfClass:[NSDictionary class]]) {
                    // parse dictionary.
                    if ([obj isKindOfClass:[NSString class]]) {
                        obj = [self objectFromString:obj];
                    }
                    if ([obj isKindOfClass:[NSData class]]) {
                        obj = [self objectFromData:obj];
                    }
                    if (![obj isKindOfClass:[NSDictionary class]]) {
                        return nil;
                    }
                    
                    NSMutableDictionary *map = [NSMutableDictionary dictionary];
                    [obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj2, BOOL *stop) {
                        id temp = [self objectWithJSONValue:obj2 class:annotation.classInDictionary];
                        if (temp) {
                            map[key] = temp;
                        }
                    }];
                    return map;
                } else if ([pclass isSubclassOfClass:[NSString class]] || [pclass isSubclassOfClass:[NSNumber class]] || [pclass isSubclassOfClass:[NSNull class]]) {
                    return [obj isKindOfClass:pclass] ? obj : nil;
                } else if ([pclass isSubclassOfClass:[NSValue class]] && [obj isKindOfClass:[NSString class]] && [obj hasPrefix:@"{"] && [obj hasSuffix:@"}"]) {
                    return structVal(obj, property.structName);
                } else {
                    return [self objectWithJSONValue:obj class:pclass];
                }
            } else if (property.typeEncoding == _C_ID) {
                return [self objectWithJSONValue:obj class:nil];
            }
            
            // struct
            NSString *structName = property.structName;
            if (structName) {
                if ([obj isKindOfClass:[NSString class]]) {
                    if ([obj hasPrefix:@"{"] && [obj hasSuffix:@"}"]) {
                        return structVal(obj, structName);
                    } else {
                        return [self objectWithJSONValue:obj class:[NSValue class]];
                    }
                }
                return nil;
            }
            
            // class & selector
            if (property.typeEncoding == _C_CLASS || property.typeEncoding == _C_SEL) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    obj = [obj objectForKey:self.valueKey];
                }
                return [obj isKindOfClass:[NSString class]] ? property.typeEncoding == _C_CLASS ? NSClassFromString(obj) : obj : nil;
            }
            
            // char, int, long, bool, etc...
            return [obj isKindOfClass:[NSNumber class]] ? obj : nil;
        }];
        
        // finish decoding.
        if ([object respondsToSelector:@selector(didDecodeWithJSONValue:)]) {
            [object didDecodeWithJSONValue:value];
        }
        return object;
    }
    return nil;
}

+ (NSData *)safeArchiveObject:(id)object
{
    if (object == nil) {
        return nil;
    }
    
    @try {
        return [NSKeyedArchiver archivedDataWithRootObject:object];
    }
    @catch (NSException *exception) {
        NSLog(@"archiveObject: %@\n\texception: %@", object, exception);
    }
    return nil;
}

+ (id)safeUnarchiveObject:(NSData *)data
{
    if (![data isKindOfClass:[NSData class]] || data.length == 0) {
        return nil;
    }
    
    @try {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException *exception) {
        NSLog(@"unarchiveObject: %@\n\texception: %@", data, exception);
    }
    return nil;
}

+ (id)copyObject:(id)object
{
    return [self objectFromData:[self dataFromObject:object options:RFJSONWritingIncludeClassName]];
}

#pragma mark - Private
+ (BOOL)isJSONFragment:(id)object
{
    return [object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSNull class]];
}

+ (NSArray *)supportedNSCodingClasses
{
    return @[[NSValue class], [NSURL class], [NSURLRequest class], [NSURLResponse class], [NSAttributedString class], [NSExpression class], [NSLocale class], [NSTimeZone class], [NSUUID class], [CLLocation class], [CLPlacemark class], [CLRegion class], [CLHeading class]];
}

+ (NSString *)classNameKey
{
    return @"__class";
}

+ (NSString *)valueKey
{
    return @"__value";
}

@end
