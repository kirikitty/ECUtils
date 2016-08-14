//
//  ECCollectionViewCell.h
//  ECUtils
//
//  Created by kiri on 16/1/6.
//  Copyright © 2016年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECRow.h"

@interface ECCollectionViewCell : UICollectionViewCell

@property (strong, readonly, nonatomic) ECRow *row;

- (void)prepareWithRow:(ECRow *)row;

@end
