//
//  RFTableViewCellDynamicHeight.h
//  ECUtils
//
//  Created by kiri on 15/5/11.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RFTableViewCellDynamicHeight <NSObject>

- (CGFloat)contentHeightAfterLayout;

@end
