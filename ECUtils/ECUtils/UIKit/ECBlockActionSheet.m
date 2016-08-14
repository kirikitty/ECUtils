//
//  ECBlockActionSheet.m
//  ECUtils
//
//  Created by kiri on 2/4/15.
//  Copyright (c) 2015 kiri. All rights reserved.
//

#import "ECBlockActionSheet.h"

@interface ECBlockActionSheet () <UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *buttonBlocks;
@property (nonatomic, weak) id<UIActionSheetDelegate> otherDelegate;

@end

@implementation ECBlockActionSheet

- (void)prepareForShowing
{
    if (self.delegate != self) {
        self.otherDelegate = self.delegate;
        self.delegate = self;
    }
}

- (void)dealloc
{
    self.delegate = nil;
}

#pragma mark - Showing
- (void)showInView:(UIView *)view
{
    [self prepareForShowing];
    [super showInView:view];
}

- (void)showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
    [self prepareForShowing];
    [super showFromBarButtonItem:item animated:animated];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
{
    [self prepareForShowing];
    [super showFromRect:rect inView:view animated:animated];
}

- (void)showFromTabBar:(UITabBar *)view
{
    [self prepareForShowing];
    [super showFromTabBar:view];
}

- (void)showFromToolbar:(UIToolbar *)view
{
    [self prepareForShowing];
    [super showFromToolbar:view];
}

#pragma mark - Block
- (void)setBlock:(ECActionSheetBlock)block atButtonIndex:(NSInteger)buttonIndex
{
    if (!self.buttonBlocks) {
        self.buttonBlocks = [NSMutableDictionary dictionary];
    }
    
    ECActionSheetBlock p = [block copy];
    [self.buttonBlocks setObject:p forKey:@(buttonIndex)];
}

- (ECActionSheetBlock)blockAtButtonIndex:(NSInteger)buttonIndex
{
    return self.buttonBlocks[@(buttonIndex)];
}

#pragma mark - delegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ECActionSheetBlock block = [self blockAtButtonIndex:buttonIndex];
    if (block) {
        block = [block copy];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __weak typeof(actionSheet) weakRef = actionSheet;
            block(weakRef, buttonIndex);
        });
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
    }
    
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if ([self.otherDelegate respondsToSelector:@selector(actionSheetCancel:)]) {
        [self.otherDelegate actionSheetCancel:actionSheet];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet  // before animation and showing view
{
    if ([self.otherDelegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.otherDelegate willPresentActionSheet:actionSheet];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet  // after animation
{
    if ([self.otherDelegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.otherDelegate didPresentActionSheet:actionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex // before animation and hiding view
{
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:willDismissWithButtonIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet willDismissWithButtonIndex:buttonIndex];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{
    if ([self.otherDelegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
        [self.otherDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }
}

#pragma mark - Utils
- (NSInteger)addButtonWithTitle:(NSString *)title action:(ECActionSheetBlock)action
{
    NSInteger index = [super addButtonWithTitle:title];
    [self setBlock:action atButtonIndex:index];
    return index;
}

@end
