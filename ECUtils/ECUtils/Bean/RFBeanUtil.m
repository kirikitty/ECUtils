//
//  RFBeanUtil.m
//  ECUtils
//
//  Created by kiri on 15/6/14.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBeanUtil.h"
#import "RFBeanClass.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface RFBeanUtil ()

// manager some cache.
+ (RFBeanUtil *)sharedInstance;

@property (strong, nonatomic) NSMutableDictionary *classCache;
@property (strong, nonatomic) NSMutableDictionary *parserCache;

@end

@implementation RFBeanUtil

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _classCache = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (RFBeanClass *)beanClassWithClass:(Class)class
{
    if (class == nil) {
        return nil;
    }
    
    if (![NSThread isMainThread]) {
        __block RFBeanClass *obj = nil;
        dispatch_sync(dispatch_get_main_queue(), ^{
            obj = [self beanClassWithClass:class];
        });
        return obj;
    }
    
    NSString *key = NSStringFromClass(class);
    RFBeanClass *obj = self.sharedInstance.classCache[key];
    if (obj == nil) {
        obj = [[RFBeanClass alloc] initWithClass:class recursive:NO];
        Class superClass = class_getSuperclass(class);
        if (superClass) {
            obj.parent = [self beanClassWithClass:superClass];
        }
        self.sharedInstance.classCache[key] = obj;
    }
    return obj;
}

+ (id)copyObject:(id)object
{
    return [self copyObject:object withZone:nil];
}

+ (id)copyObject:(id)object withZone:(NSZone *)zone
{
    if (object == nil) {
        return nil;
    }
    
    Class class = [object class];
    if (class) {
        id result = [[class allocWithZone:zone] init];
        RFBeanClass *beanClass = [self beanClassWithClass:class];
        if (beanClass.properties.count > 0) {
            [beanClass.properties enumerateObjectsUsingBlock:^(RFBeanProperty *property, NSUInteger idx, BOOL *stop) {
                if (property.isReadonly) {
                    return;
                }
                
                if (property.typeEncoding == _C_STRUCT_B) {
                    // why struct can't use selector...
                    [result setValue:[object valueForKey:property.name] forKey:property.name];
                } else if (property.typeEncoding == _C_ID) {
                    id value = [object performSelector:property.getter];
                    if ([value conformsToProtocol:@protocol(NSMutableCopying)]) {
                        value = [value mutableCopy];
                    } else if ([object conformsToProtocol:@protocol(NSCopying)]) {
                        value = [value copy];
                    }
                    [result performSelector:property.setter withObject:value];
                } else {
                    [result performSelector:property.setter withObject:[object performSelector:property.getter]];
                }
            }];
        }
        return result;
    }
    return nil;
}

#pragma mark - Properties
+ (NSMutableDictionary *)propertiesFromObject:(id)object
{
    return [self propertiesFromObject:object class:nil recursive:NO annotations:nil preprocessor:nil];
}

+ (NSMutableDictionary *)propertiesFromObject:(id)object class:(Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id, RFBeanProperty *))preprocessor
{
    if (object == nil) {
        return nil;
    }
    
    if (class_isMetaClass(object_getClass(object))) {
        return nil;
    }
    
    if (cls == nil) {
        cls = [object class];
    }
    
    if (cls == nil) {
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    RFBeanClass *class = [self beanClassWithClass:cls];
    if (class.parent.cls == nil) {
        return properties;
    }
    
    if (recursive && class.parent) {
        NSDictionary *p = [self propertiesFromObject:object class:class.parent.cls recursive:recursive annotations:annotations preprocessor:preprocessor];
        if (p) {
            [properties addEntriesFromDictionary:p];
        }
    }
    
    if (class.properties.count > 0) {
        [class.properties enumerateObjectsUsingBlock:^(RFBeanProperty *property, NSUInteger idx, BOOL *stop) {
            if (property.isReadonly) {
                return;
            }
            
            NSString *key = property.name;
            RFBeanPropertyAnnotation *annotation = annotations[key];
            if (annotation) {
                if (annotation.ignore) {
                    return;
                }
                if (annotation.name) {
                    key = annotation.name;
                }
            }
            
            __weak typeof(object) wobj = object;
            id value = nil;
            if (annotation.getter) {
                value = annotation.getter(wobj);
            } else {
                value = [self propertyWithObject:object meta:property];
                if (preprocessor) {
                    value = preprocessor(value, property);
                }
            }
            if (value) {
                [properties setObject:value forKey:key];
            }
        }];
    }
    return properties;
}

+ (id)objectFromProperties:(NSDictionary *)properties class:(Class)cls
{
    return [self objectFromProperties:properties class:cls recursive:NO annotations:nil preprocessor:nil];
}

+ (id)objectFromProperties:(NSDictionary *)properties class:(Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id, RFBeanProperty *))preprocessor
{
    if (cls == nil) {
        return nil;
    }
    
    id result = cls.new;
    [self setProperties:properties toObject:result class:cls recursive:recursive annotations:annotations preprocessor:preprocessor];
    return result;
}

+ (void)setProperties:(NSDictionary *)properties toObject:(id)object class:(Class)cls
{
    [self setProperties:properties toObject:object class:cls recursive:NO annotations:nil preprocessor:nil];
}

+ (void)setProperties:(NSDictionary *)properties toObject:(id)object class:(__unsafe_unretained Class)cls recursive:(BOOL)recursive annotations:(NSDictionary *)annotations preprocessor:(id (^)(id, RFBeanProperty *))preprocessor
{
    if (object == nil) {
        return;
    }
    
    if (cls == nil) {
        cls = [object class];
    }
    
    if (cls == nil) {
        return;
    }
    
    id result = object;
    RFBeanClass *beanClass = [self beanClassWithClass:cls];
    if (beanClass.parent == nil) {
        // cls is root
        return;
    }
    
    if (recursive && beanClass.parent) {
        [self setProperties:properties toObject:object class:beanClass.parent.cls recursive:recursive annotations:annotations preprocessor:preprocessor];
    }
    if (beanClass.properties.count > 0) {
        [beanClass.properties enumerateObjectsUsingBlock:^(RFBeanProperty *property, NSUInteger idx, BOOL *stop) {
            if (property.isReadonly) {
                return;
            }
            
            NSString *key = property.name;
            RFBeanPropertyAnnotation *annotation = annotations[key];
            if (annotation) {
                if (annotation.ignore) {
                    return;
                }
                if (annotation.name) {
                    key = annotation.name;
                }
            }
            
            id value = properties[key];
            if (annotation.setter) {
                __weak typeof(result) wobj = result;
                annotation.setter(wobj, value);
            } else {
                if (preprocessor) {
                    value = preprocessor(value, property);
                }
                [self setPropertyWithObject:result value:value meta:property];
            }
        }];
    }
}

+ (id)propertyWithObject:(id)object meta:(RFBeanProperty *)meta
{
    switch (meta.typeEncoding) {
        case _C_ID:
        case _C_CLASS:
            return [object performSelector:meta.getter];
        case _C_CHR:
        case _C_UCHR:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        case _C_UINT:
        case _C_LNG:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_FLT:
        case _C_DBL:
        case _C_BOOL:
        case _C_STRUCT_B:
            return [object valueForKey:meta.name];
        case _C_SEL:
        {
            void *selector = (__bridge void *)([object performSelector:meta.getter]);
            return selector == NULL ? nil : NSStringFromSelector((SEL)selector);
        }
        default:
            return nil;
    }
}

+ (void)setPropertyWithObject:(id)object value:(id)value meta:(RFBeanProperty *)meta
{
    switch (meta.typeEncoding) {
        case _C_ID:
        case _C_CLASS:
        {
            [object performSelector:meta.setter withObject:value];
            break;
        }
        case _C_CHR:
        case _C_UCHR:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        case _C_UINT:
        case _C_LNG:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_FLT:
        case _C_DBL:
        case _C_BOOL:
        {
            if (value == nil) {
                value = @0;
            }
        }
        case _C_STRUCT_B:
        {
            if (value != nil) {
                [object setValue:value forKey:meta.name];
            }
            break;
        }
        case _C_SEL:
        {
            void *selector = (void *)(value ? NSSelectorFromString(value) : NULL);
            [object performSelector:meta.setter withObject:(__bridge id)(selector)];
            break;
        }
        default:
            break;
    }
}

@end

#pragma clang diagnostic pop
