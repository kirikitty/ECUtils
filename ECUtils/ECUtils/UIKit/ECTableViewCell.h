//
//  ECTableViewCell.h
//  ECUtils
//
//  Created by kiri on 15/1/2.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECRow.h"
#import "ECTableViewCellDynamicHeight.h"

typedef NS_ENUM(NSInteger, ECTableViewCellBackgroundStyle) {
    ECTableViewCellBackgroundStyleNone,
    ECTableViewCellBackgroundStyleDark,
    ECTableViewCellBackgroundStyleLight,
};

@interface ECTableViewCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) ECRow *row;

@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic) ECTableViewCellBackgroundStyle backgroundStyle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (void)prepareWithRow:(ECRow *)row;
- (CGFloat)contentHeightAfterLayout;

@end
