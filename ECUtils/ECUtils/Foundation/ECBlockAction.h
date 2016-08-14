//
//  ECBlockAction.h
//  ECUtils
//
//  Created by kiri on 15/6/1.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECBlockAction : NSObject

@property (weak, nonatomic) id target;

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) id userInfo;
@property (copy, nonatomic) void (^block)(void);

- (instancetype)initWithIdentifier:(NSString *)identifier block:(void (^)(void))block userInfo:(id)userInfo;
+ (instancetype)blockActionWithBlock:(void (^)(void))block;

@end
