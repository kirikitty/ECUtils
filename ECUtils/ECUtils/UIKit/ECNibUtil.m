//
//  ECNibUtil.m
//  ECUtils
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECNibUtil.h"
#import "ECLog.h"
#import "ECCUtil.h"

@implementation ECNibUtil

+ (id)loadMainObjectFromNib:(NSString *)nibName
{
    Class clazz = NSClassFromString(nibName);
    if (clazz == NULL) {
        clazz = ECSwiftClassFromString(nibName);
    }
    if (clazz) {
        return [self loadObjectWithClass:clazz fromNib:nibName];
    }
    return nil;
}

+ (id)loadObjectWithClass:(Class)clazz fromNib:(NSString *)nibName
{
    NSArray *objList = nil;
    NSException *ex1, *ex2 = nil;
    @try {
        objList = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    }
    @catch (NSException *exception) {
        ex1 = exception;
    }
    if (objList.count == 0) {
        ECLogError(@"exception in main bundle: %@\n\texception in toolbox bundle: %@", ex1, ex2);
        return nil;
    }
    
    id tmpObj = nil;
    for (id obj in objList) {
        if ([obj isMemberOfClass:clazz]) {
            return obj;
        } else if ([obj isKindOfClass:clazz]) {
            tmpObj = obj;
        }
    }
    return tmpObj;
}

@end
