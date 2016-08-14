//
//  ECCollectionViewCell.m
//  ECUtils
//
//  Created by kiri on 16/1/6.
//  Copyright © 2016年 kiri. All rights reserved.
//

#import "ECCollectionViewCell.h"

@interface ECCollectionViewCell ()

@property (strong, nonatomic) ECRow *row;

@end

@implementation ECCollectionViewCell

- (void)prepareWithRow:(ECRow *)row
{
    self.row = row;
}

@end
