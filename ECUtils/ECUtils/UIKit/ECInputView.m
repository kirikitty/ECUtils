
//
//  ECInputView.m
//  ECUtils
//
//  Created by kiri on 15/5/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECInputView.h"
#import "UIView+Utils.h"
#import "ECApplication.h"

@interface ECInputView ()

@property (weak, nonatomic) UIView *maskView;
@property (weak, nonatomic) UIView *keyboardView;
@property (weak, nonatomic) NSLayoutConstraint *keyboardBottomConstraint;

@end

@implementation ECInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMask:)]];
        maskView.alpha = 0;
        [self addSubview:maskView];
        self.maskView = maskView;
        
        [self loadKeyboardView];
    }
    return self;
}

- (void)loadKeyboardView
{
    UIView *keyboardView = self.createKeyboardView;
    keyboardView.top = self.height;
    if (keyboardView) {
        [self addSubview:keyboardView];
        self.keyboardView = keyboardView;
        self.keyboardView.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[keyboardView]-(0)-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(keyboardView)]];
        NSLayoutConstraint *keyboardBottomConstraint = [NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:keyboardView.height];
        [constraints addObject:keyboardBottomConstraint];
        [self addConstraints:constraints];
        self.keyboardBottomConstraint = keyboardBottomConstraint;
        
        NSLayoutConstraint *heightConstraints = [NSLayoutConstraint constraintWithItem:keyboardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:keyboardView.height];
        [keyboardView addConstraint:heightConstraints];
    }
}

- (void)didTapMask:(UITapGestureRecognizer *)gr
{
    [self dismiss];
}

- (void)show
{
    [self showInView:[ECApplication sharedApplication].window];
}

- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    [view addSubview:self];
    
    self.keyboardBottomConstraint.constant = 0;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 1;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss
{
    self.keyboardBottomConstraint.constant = self.keyboardView.height;
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIView *)createKeyboardView
{
    return nil;
}

@end
