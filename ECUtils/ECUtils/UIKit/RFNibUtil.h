//
//  RFNibUtil.h
//  ECUtils
//
//  Created by kiri on 2013-10-15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFNibUtil : NSObject

/**
 *  use this function only when nibname isEqual to class name
 */
+ (id)loadMainObjectFromNib:(NSString *)nibName;

+ (id)loadObjectWithClass:(Class)clazz fromNib:(NSString *)nibName;

@end
