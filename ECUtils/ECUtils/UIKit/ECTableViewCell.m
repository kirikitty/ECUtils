//
//  ECTableViewCell.m
//  ECUtils
//
//  Created by kiri on 15/1/2.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECTableViewCell.h"
#import "ECApplication.h"
#import "UIView+Utils.h"

@implementation ECTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont fontWithSize:self.textLabel.font.pointSize];
        self.detailTextLabel.font = [UIFont fontWithSize:self.detailTextLabel.font.pointSize];
        UIColor *titleColor = [UIColor titleColor];
        if (titleColor) {
            self.textLabel.textColor = titleColor;
        }
        UIColor *subtitleColor = [UIColor subtitleColor];
        if (subtitleColor) {
            self.detailTextLabel.textColor = subtitleColor;
        }
    }
    return self;
}

- (void)prepareWithRow:(ECRow *)row
{
    self.tag = row.tag;
}

- (CGFloat)contentHeightAfterLayout
{
    if (self.bottomConstraint) {
        return [self.bottomConstraint.secondItem bottom] + self.bottomConstraint.constant;
    }
    return self.tableView.separatorStyle == UITableViewCellSeparatorStyleNone ? 44.f : 43.f;
}

- (void)setBackgroundStyle:(ECTableViewCellBackgroundStyle)backgroundStyle
{
    if (_backgroundStyle != backgroundStyle) {
        _backgroundStyle = backgroundStyle;
        
        [self updateBackgroundStyle];
    }
}

- (void)updateBackgroundStyle
{
    switch (self.backgroundStyle) {
        case ECTableViewCellBackgroundStyleDark:
        {
            self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
            self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:.1f];
            break;
        }
        case ECTableViewCellBackgroundStyleLight:
        {
            self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
            self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:.1f];
            break;
        }
        default:
        {
            self.selectedBackgroundView = nil;
            break;
        }
    }
}

@end
