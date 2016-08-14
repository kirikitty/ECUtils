//
//  ECBlockActionSheet.h
//  ECUtils
//
//  Created by kiri on 2/4/15.
//  Copyright (c) 2015 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ECActionSheetBlock)(UIActionSheet *actionSheet, NSInteger buttonIndex);

@interface ECBlockActionSheet : UIActionSheet

- (NSInteger)addButtonWithTitle:(NSString *)title action:(ECActionSheetBlock)action;    // returns index of button. 0 based.

- (ECActionSheetBlock)blockAtButtonIndex:(NSInteger)buttonIndex;
- (void)setBlock:(ECActionSheetBlock)block atButtonIndex:(NSInteger)buttonIndex;

@end
