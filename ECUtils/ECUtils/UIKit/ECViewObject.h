//
//  ECViewObject.h
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  It's the root of view object.
 */
@interface ECViewObject : NSObject

@property (nonatomic) NSInteger tag;
@property (strong, nonatomic) id data;
@property (strong, nonatomic) id userInfo;

/**
 *  Designated initializer.
 */
- (instancetype)initWithTag:(NSInteger)tag data:(id)data userInfo:(id)userInfo;

@end
