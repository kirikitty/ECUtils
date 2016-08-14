//
//  RFBeanProtocol.h
//  ECUtils
//
//  Created by kiri on 15/6/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface RFBeanProtocol : NSObject

@property (strong, nonatomic) Protocol *protocol;
@property (strong, nonatomic) NSString *name;

- (instancetype)initWithProtocol:(Protocol *)protocol;

@end
