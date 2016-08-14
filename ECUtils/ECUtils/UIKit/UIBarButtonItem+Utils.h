//
//  UIBarButtonItem+Utils.h
//  ECUtils
//
//  Created by kiri on 15/5/8.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Utils)

+ (instancetype)fixedSpaceItemWithWidth:(CGFloat)width;
+ (instancetype)flexibleSpaceItem;

@end
