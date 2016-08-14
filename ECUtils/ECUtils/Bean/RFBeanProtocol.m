//
//  RFBeanProtocol.m
//  ECUtils
//
//  Created by kiri on 15/6/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBeanProtocol.h"
#import <objc/runtime.h>

@implementation RFBeanProtocol

- (instancetype)initWithProtocol:(Protocol *)protocol
{
    if (self = [super init]) {
        self.protocol = protocol;
        self.name = [NSString stringWithUTF8String:protocol_getName(protocol)];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; name = %@; protocol = %@>", NSStringFromClass([self class]), self, self.name, self.protocol];
}

@end
