//
//  NSFileManager+Utils.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "NSFileManager+Utils.h"

@implementation NSFileManager (Utils)

- (NSURL *)URLForDocumentDirectory
{
    return [self URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSURL *)URLForCachesDirectory
{
    return [self URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
}

@end
