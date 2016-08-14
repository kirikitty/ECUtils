//
//  RFBeanClass.m
//  ECUtils
//
//  Created by kiri on 15/6/14.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBeanClass.h"

@implementation RFBeanClass

- (instancetype)initWithClass:(Class)cls recursive:(BOOL)recursive
{
    if (self = [super init]) {
        self.cls = cls;
        self.name = NSStringFromClass(cls);
        [self fetchProperties];
        [self fetchProtocols];
        
        if (recursive) {
            Class superCls = class_getSuperclass(cls);
            if (superCls) {
                self.parent = [[self.class alloc] initWithClass:superCls recursive:recursive];
            }
        }
    }
    return self;
}

- (void)fetchProperties
{
    unsigned int count;
    objc_property_t *rawProperties = class_copyPropertyList(self.cls, &count);
    if (rawProperties == NULL) {
        self.properties = @[];
        return;
    }
    
    NSMutableArray *properties = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    for (int i = 0; i < count; i++) {
        objc_property_t p = rawProperties[i];
        NSString *pname = [NSString stringWithUTF8String:property_getName(p)];
        if ([names containsObject:pname]) {
            continue;
        }
        
        [names addObject:pname];
        RFBeanProperty *property = [[RFBeanProperty alloc] initWithProperty:p];
        if (property) {
            switch (property.typeEncoding) {
                case _C_ATOM:
                case _C_BFLD:
                case _C_UNION_B:
                case _C_UNDEF:
                case _C_VECTOR:
                    break;
                default:
                {
                    if (property.getter) {
                        NSMethodSignature *signature = [self.cls instanceMethodSignatureForSelector:property.getter];
                        if (signature) {
                            property.getterInvocation = [NSInvocation invocationWithMethodSignature:signature];
                        }
                    }
                    if (!property.isReadonly && property.setter) {
                        NSMethodSignature *signature = [self.cls instanceMethodSignatureForSelector:property.setter];
                        if (signature) {
                            property.setterInvocation = [NSInvocation invocationWithMethodSignature:signature];
                        }
                    }
                    break;
                }
            }
            [properties addObject:property];
        }
    }
    self.properties = properties;
    
    free(rawProperties);
    rawProperties = NULL;
}

- (void)fetchProtocols
{
    unsigned int count;
    Protocol * __unsafe_unretained* rawProtocols = class_copyProtocolList(self.cls, &count);
    if (rawProtocols == NULL) {
        self.protocols = @[];
        return;
    }
    
    NSMutableArray *protocols = [NSMutableArray array];
    NSMutableSet *names = [NSMutableSet set];
    for (int i = 0; i < count; i++) {
        Protocol *p = rawProtocols[i];
        NSString *pname = [NSString stringWithUTF8String:protocol_getName(p)];
        if ([names containsObject:pname]) {
            continue;
        }
        
        [names addObject:pname];
        RFBeanProtocol *protocol = [[RFBeanProtocol alloc] initWithProtocol:p];
        if (protocol) {
            [protocols addObject:protocol];
        }
    }
    self.protocols = protocols;
    
    free(rawProtocols);
    rawProtocols = NULL;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; class = %@; properties = %@; protocols = %@; parent = %@>", NSStringFromClass([self class]), self, self.cls, self.properties, self.protocols, self.parent];
}

@end
