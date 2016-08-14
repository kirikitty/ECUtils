//
//  RFViewObject.m
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFViewObject.h"

@implementation RFViewObject

+ (instancetype)viewObjectWithTag:(NSInteger)tag data:(id)data
{
    return [self viewObjectWithTag:tag data:data userInfo:nil];
}

+ (instancetype)viewObjectWithTag:(NSInteger)tag data:(id)data userInfo:(id)userInfo
{
    return [[self alloc] initWithTag:tag data:data userInfo:userInfo];
}

- (instancetype)initWithTag:(NSInteger)tag data:(id)data userInfo:(id)userInfo
{
    if (self = [super init]) {
        _tag = tag;
        _data = data;
        _userInfo = userInfo;
    }
    return self;
}

@end
