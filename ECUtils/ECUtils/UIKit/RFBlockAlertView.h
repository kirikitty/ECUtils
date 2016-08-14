//
//  RFBlockAlertView.h
//  ECUtils
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^RFAlertViewBlock)(void);

/*! An alert view delegate by block */
@interface RFBlockAlertView : UIAlertView

- (RFAlertViewBlock)blockForOk;
- (void)setBlockForOk:(RFAlertViewBlock)blockForOk;

- (RFAlertViewBlock)blockForCancel;
- (void)setBlockForCancel:(RFAlertViewBlock)blockForCancel;

- (RFAlertViewBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(RFAlertViewBlock)block atButtonIndex:(NSInteger)buttonIndex;


@end
