//
//  UIBarButtonItem+Utils.m
//  ECUtils
//
//  Created by kiri on 15/5/8.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "UIBarButtonItem+Utils.h"

@implementation UIBarButtonItem (Utils)

+ (instancetype)fixedSpaceItemWithWidth:(CGFloat)width
{
    UIBarButtonItem *item = [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    item.width = width;
    return item;
}

+ (instancetype)flexibleSpaceItem
{
    return [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

@end
