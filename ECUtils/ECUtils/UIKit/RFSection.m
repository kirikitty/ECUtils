//
//  RFSection.m
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFSection.h"

@implementation RFSection

+ (RFSection *)sectionWithTag:(NSInteger)tag rows:(NSArray *)rows
{
    return [self sectionWithTag:tag header:nil footer:nil rows:rows];
}

+ (RFSection *)sectionWithTag:(NSInteger)tag header:(NSString *)header footer:(NSString *)footer rows:(NSArray *)rows
{
    RFSection *section = [[self alloc] initWithTag:tag data:nil userInfo:nil];
    section.header = header;
    section.footer = footer;
    section.rows = rows;
    return section;
}

+ (RFSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName
{
    NSMutableArray *rows = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[RFRow rowWithTag:tag data:obj nibName:nibName]];
    }];
    return [self sectionWithTag:tag rows:rows];
}

+ (RFSection *)sectionWithTag:(NSInteger)tag datas:(NSArray *)datas className:(NSString *)className
{
    NSMutableArray *rows = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[RFRow rowWithTag:tag data:obj className:className]];
    }];
    return [self sectionWithTag:tag rows:rows];
}

- (RFSection *)addRow:(RFRow *)row
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows addObject:row];
    self.rows = rows;
    return self;
}

- (RFSection *)insertRow:(RFRow *)row atIndex:(NSInteger)index
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows insertObject:row atIndex:index];
    self.rows = rows;
    return self;
}

- (RFSection *)removeRowAtIndex:(NSInteger)index
{
    NSMutableArray *rows = self.rows ? [self.rows mutableCopy] : [NSMutableArray array];
    [rows removeObjectAtIndex:index];
    self.rows = rows;
    return self;
}

@end
