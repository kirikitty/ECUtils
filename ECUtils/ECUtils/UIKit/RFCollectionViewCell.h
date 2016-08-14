//
//  RFCollectionViewCell.h
//  ECUtils
//
//  Created by kiri on 16/1/6.
//  Copyright © 2016年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFRow.h"

@interface RFCollectionViewCell : UICollectionViewCell

@property (strong, readonly, nonatomic) RFRow *row;

- (void)prepareWithRow:(RFRow *)row;

@end
