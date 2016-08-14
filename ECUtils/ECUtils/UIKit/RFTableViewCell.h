//
//  RFTableViewCell.h
//  ECUtils
//
//  Created by kiri on 15/1/2.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFRow.h"
#import "RFTableViewCellDynamicHeight.h"

typedef NS_ENUM(NSInteger, RFTableViewCellBackgroundStyle) {
    RFTableViewCellBackgroundStyleNone,
    RFTableViewCellBackgroundStyleDark,
    RFTableViewCellBackgroundStyleLight,
};

@interface RFTableViewCell : UITableViewCell

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) RFRow *row;

@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic) RFTableViewCellBackgroundStyle backgroundStyle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (void)prepareWithRow:(RFRow *)row;
- (CGFloat)contentHeightAfterLayout;

@end
