//
//  RFBlockAlertView.m
//  ECUtils
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBlockAlertView.h"

@interface RFBlockAlertView ()  <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *buttonBlocks;
@property (nonatomic, weak) id<UIAlertViewDelegate> otherDelegate;

@end

@implementation RFBlockAlertView

-(void)show
{
    self.otherDelegate = self.delegate;
    self.delegate = self;
    [super show];
}

- (void)setBlockForOk:(RFAlertViewBlock)blockForOk
{
    [self setBlock:blockForOk atButtonIndex:1];
}

- (RFAlertViewBlock)blockForOk
{
    return [[self buttonBlocks] objectForKey:@1];
}

- (void)setBlockForCancel:(RFAlertViewBlock)blockForCancel
{
    [self setBlock:blockForCancel atButtonIndex:0];
}

- (RFAlertViewBlock)blockForCancel
{
    return [self.buttonBlocks objectForKey:@0];
}

- (void)setBlock:(RFAlertViewBlock)block atButtonIndex:(NSInteger)buttonIndex
{
    if (!self.buttonBlocks) {
        self.buttonBlocks = [NSMutableDictionary dictionary];
    }
    
    if (block) {
        RFAlertViewBlock temp = [block copy];
        [self.buttonBlocks setObject:temp forKey:[NSNumber numberWithInteger:buttonIndex]];
    }
}

- (RFAlertViewBlock)blockAtButtonIndex:(NSInteger)buttonIndex
{
    return [self.buttonBlocks objectForKey:[NSNumber numberWithInteger:buttonIndex]];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    RFAlertViewBlock block = [self blockAtButtonIndex:buttonIndex];
    if (block) {
        block();
    }
    
    if ([self.otherDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.otherDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (self.title == nil) {
        self.title = @"";
    }
    if ([self.otherDelegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.otherDelegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if ([self.otherDelegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.otherDelegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.otherDelegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.otherDelegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [self.otherDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (self.cancelButtonIndex != 0) {
        return NO;
    }
    if ([self.otherDelegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
        return [self.otherDelegate alertViewShouldEnableFirstOtherButton:alertView];
    }
    return YES;
}

@end
