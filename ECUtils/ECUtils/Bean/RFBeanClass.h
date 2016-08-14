//
//  RFBeanClass.h
//  ECUtils
//
//  Created by kiri on 15/6/14.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFBeanProperty.h"
#import "RFBeanProtocol.h"

@interface RFBeanClass : NSObject

@property (strong, nonatomic) RFBeanClass *parent;
@property (strong, nonatomic) Class cls;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *properties;
@property (strong, nonatomic) NSArray *protocols;

- (instancetype)initWithClass:(Class)cls recursive:(BOOL)recursive;

@end
