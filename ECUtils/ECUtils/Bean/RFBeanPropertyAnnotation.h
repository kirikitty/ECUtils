//
//  RFBeanPropertyAnnotation.h
//  ECUtils
//
//  Created by kiri on 15/6/27.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFBeanPropertyAnnotation : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL ignore;
@property (copy, nonatomic) id (^getter)(id object);
@property (copy, nonatomic) void (^setter)(id object, id value);

@end
