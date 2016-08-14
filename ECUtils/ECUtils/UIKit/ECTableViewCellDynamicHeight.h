//
//  ECTableViewCellDynamicHeight.h
//  ECUtils
//
//  Created by kiri on 15/5/11.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECTableViewCellDynamicHeight <NSObject>

- (CGFloat)contentHeightAfterLayout;

@end
