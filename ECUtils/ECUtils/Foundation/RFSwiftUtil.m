//
//  RFSwiftUtil.m
//  ECUtils
//
//  Created by kiri on 2/4/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFSwiftUtil.h"

@implementation RFSwiftUtil

+ (Class)swiftClassFromString:(NSString *)className
{
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSString *classStringName = [NSString stringWithFormat:@"%@.%@", appName, className];
    return NSClassFromString(classStringName);
}

@end
