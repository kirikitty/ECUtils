//
//  ECCUtil.m
//  ECUtils
//
//  Created by kiri on 15/5/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECCUtil.h"

void ec_dispatch_sync_main(dispatch_block_t block) {
    if (block == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NSString *ECDocumentDirectory() {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

NSString *ECCachesDirectory() {
//    return [RFDocumentDirectory() stringByAppendingPathComponent:@"Caches"];
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}

Class ECSwiftClassFromString(NSString *className) {
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSString *classStringName = [NSString stringWithFormat:@"%@.%@", appName, className];
    return NSClassFromString(classStringName);
}

@implementation ECCUtil

@end
