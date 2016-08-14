//
//  RFCollectionViewCell.m
//  ECUtils
//
//  Created by kiri on 16/1/6.
//  Copyright © 2016年 kiri. All rights reserved.
//

#import "RFCollectionViewCell.h"

@interface RFCollectionViewCell ()

@property (strong, nonatomic) RFRow *row;

@end

@implementation RFCollectionViewCell

- (void)prepareWithRow:(RFRow *)row
{
    self.row = row;
}

@end
