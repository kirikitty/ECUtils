//
//  RFLoadMoreCell.m
//  ECUtils
//
//  Created by kiri on 15/4/30.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFLoadMoreCell.h"

@interface RFLoadMoreCell ()

@end

@implementation RFLoadMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator = loadingIndicator;
        [self.contentView addSubview:loadingIndicator];
        
        NSMutableArray *constraints = [NSMutableArray array];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:loadingIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:loadingIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self.contentView addConstraints:constraints];
    }
    return self;
}

- (void)prepareWithRow:(RFRow *)row
{
    [self.loadingIndicator startAnimating];
}

@end
