//
//  RFPureCUtil.m
//  ECUtils
//
//  Created by kiri on 15/5/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFPureCUtil.h"

void rf_dispatch_sync_main(dispatch_block_t block) {
    if (block == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NSString *RFDocumentDirectory() {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

NSString *RFCachesDirectory() {
    return [RFDocumentDirectory() stringByAppendingPathComponent:@"Caches"];
//    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
}

@implementation RFPureCUtil

@end
