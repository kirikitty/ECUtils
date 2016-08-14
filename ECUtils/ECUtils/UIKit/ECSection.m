//
//  ECSection.m
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECSection.h"

@implementation ECSection

+ (ECSection *)sectionWithTag:(NSInteger)tag rows:(NSArray *)rows
{
    return [self sectionWithTag:tag header:nil footer:nil rows:rows];
}

+ (ECSection *)sectionWithTag:(NSInteger)tag header:(NSString *)header footer:(NSString *)footer rows:(NSArray *)rows
{
    ECSection *section = [[self alloc] initWithTag:tag data:nil userInfo:nil];
    section.header = header;
    section.footer = footer;
    section.rows = rows;
    return section;
}

+ (ECSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName
{
    NSMutableArray *rows = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[ECRow rowWithTag:tag data:obj nibName:nibName]];
    }];
    return [self sectionWithTag:tag rows:rows];
}

+ (ECSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas className:(NSString *)className
{
    NSMutableArray *rows = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[ECRow rowWithTag:tag data:obj className:className]];
    }];
    return [self sectionWithTag:tag rows:rows];
}

- (ECSection *)addRow:(ECRow *)row
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows addObject:row];
    self.rows = rows;
    return self;
}

- (ECSection *)insertRow:(ECRow *)row atIndex:(NSInteger)index
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows insertObject:row atIndex:index];
    self.rows = rows;
    return self;
}

- (ECSection *)removeRowAtIndex:(NSInteger)index
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows removeObjectAtIndex:index];
    self.rows = rows;
    return self;
}

@end
