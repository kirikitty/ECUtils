//
//  RFBlockAction.m
//  ECUtils
//
//  Created by kiri on 15/6/1.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBlockAction.h"

@implementation RFBlockAction

- (instancetype)initWithIdentifier:(NSString *)identifier block:(void (^)(void))block userInfo:(id)userInfo
{
    if (self = [super init]) {
        self.identifier = identifier;
        self.userInfo = userInfo;
        self.block = block;
    }
    return self;
}

+ (instancetype)blockActionWithBlock:(void (^)(void))block
{
    return [[self alloc] initWithIdentifier:[[NSUUID UUID] UUIDString] block:block userInfo:nil];
}

@end
