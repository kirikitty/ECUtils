//
//  RFBlockActionSheet.h
//  ECUtils
//
//  Created by kiri on 2/4/15.
//  Copyright (c) 2015 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RFActionSheetBlock)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface RFBlockActionSheet : UIActionSheet

- (NSInteger)addButtonWithTitle:(NSString *)title action:(RFActionSheetBlock)action;    // returns index of button. 0 based.

- (RFActionSheetBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(RFActionSheetBlock)block atButtonIndex:(NSInteger)buttonIndex;

@end
