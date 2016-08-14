//
//  ECSidebar.h
//  ECUtils
//
//  Created by kiri on 14-5-26.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECSidebar <NSObject>

@optional
- (void)sidebarWillAppear:(BOOL)animated;
- (void)sidebarDidAppear:(BOOL)animated;
- (void)sidebarWillDisappear:(BOOL)animated;
- (void)sidebarDidDisappear:(BOOL)animated;

@end
