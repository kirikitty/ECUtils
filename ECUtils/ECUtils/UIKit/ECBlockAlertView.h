//
//  ECBlockAlertView.h
//  ECUtils
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ECAlertViewBlock)(void);

/*! An alert view delegate by block */
@interface ECBlockAlertView : UIAlertView

- (ECAlertViewBlock)blockForOk;
- (void)setBlockForOk:(ECAlertViewBlock)blockForOk;

- (ECAlertViewBlock)blockForCancel;
- (void)setBlockForCancel:(ECAlertViewBlock)blockForCancel;

- (ECAlertViewBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(ECAlertViewBlock)block atButtonIndex:(NSInteger)buttonIndex;


@end
