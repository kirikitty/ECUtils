//
//  ECSection.h
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECViewObject.h"
#import "ECRow.h"

/**
 *  The model of table view section.
 */
@interface ECSection : ECViewObject

@property (strong, nonatomic) NSString *header;
@property (strong, nonatomic) NSString *footer;
@property (strong, nonatomic) NSArray *rows;

+ (ECSection *)sectionWithTag:(NSInteger)tag rows:(NSArray *)rows;
+ (ECSection *)sectionWithTag:(NSInteger)tag header:(NSString *)header footer:(NSString *)footer rows:(NSArray *)rows;

+ (ECSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName;
+ (ECSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas className:(NSString *)className;

- (ECSection *)addRow:(ECRow *)row;
- (ECSection *)insertRow:(ECRow *)row atIndex:(NSInteger)index;
- (ECSection *)removeRowAtIndex:(NSInteger)index;

@end
