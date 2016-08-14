//
//  RFSection.h
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFViewObject.h"
#import "RFRow.h"

/**
 *  The model of table view section.
 */
@interface RFSection : RFViewObject

@property (strong, nonatomic) NSString *header;
@property (strong, nonatomic) NSString *footer;
@property (strong, nonatomic) NSArray *rows;

+ (RFSection *)sectionWithTag:(NSInteger)tag rows:(NSArray *)rows;
+ (RFSection *)sectionWithTag:(NSInteger)tag header:(NSString *)header footer:(NSString *)footer rows:(NSArray *)rows;

+ (RFSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName;
+ (RFSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas className:(NSString *)className;

- (RFSection *)addRow:(RFRow *)row;
- (RFSection *)insertRow:(RFRow *)row atIndex:(NSInteger)index;
- (RFSection *)removeRowAtIndex:(NSInteger)index;

@end
