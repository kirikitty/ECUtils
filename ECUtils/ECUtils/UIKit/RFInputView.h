//
//  RFInputView.h
//  ECUtils
//
//  Created by kiri on 15/5/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFInputView : UIView

- (void)show;
- (void)showInView:(UIView *)view;
- (void)dismiss;

// protected methods
- (UIView *)createKeyboardView;

@end
