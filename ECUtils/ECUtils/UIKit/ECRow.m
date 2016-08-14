//
//  ECRow.m
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECRow.h"

const UITableViewCellAccessoryType ECRowAccessoryTypeNotDetermined = -1;
const UITableViewCellSelectionStyle ECRowSelectionStyleNotDetermined = -1;

@implementation ECRow

- (instancetype)initWithTag:(NSInteger)tag data:(id)data userInfo:(id)userInfo
{
    if (self = [super initWithTag:tag data:data userInfo:userInfo]) {
        self.accessoryType = ECRowAccessoryTypeNotDetermined;
        self.selectionStyle = ECRowSelectionStyleNotDetermined;
        self.dynamicHeight = YES;
    }
    return self;
}

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data nibName:(NSString *)nibName
{
    return [self rowWithTag:tag data:data nibName:nibName userInfo:nil];
}

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data nibName:(NSString *)nibName userInfo:(id)userInfo
{
    ECRow *row = [[self alloc] initWithTag:tag data:data userInfo:userInfo];
    row.reuseIdentifier = nibName;
    row.source = ECRowSourceNib;
    return row;
}

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data className:(NSString *)className
{
    return [self rowWithTag:tag data:data className:className userInfo:nil style:UITableViewCellStyleDefault];
}

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data className:(NSString *)className userInfo:(id)userInfo style:(UITableViewCellStyle)style
{
    ECRow *row = [[self alloc] initWithTag:tag data:data userInfo:userInfo];
    row.reuseIdentifier = className;
    row.style = style;
    row.source = ECRowSourceCreating;
    return row;
}

+ (NSMutableArray *)rowsWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName
{
    NSMutableArray *rows = [NSMutableArray array];
    [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [rows addObject:[self rowWithTag:tag data:obj nibName:nibName]];
    }];
    return rows;
}

@end

@implementation ECSimpleRow

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText nibName:(NSString *)nibName
{
    return [self rowWithTag:tag text:text detailText:detailText image:nil nibName:nibName];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text image:(UIImage *)image nibName:(NSString *)nibName
{
    return [self rowWithTag:tag text:text detailText:nil image:image nibName:nibName];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text imageId:(NSString *)imageId nibName:(NSString *)nibName
{
    ECNativeRow *row = [self rowWithTag:tag data:text nibName:nibName];
    row.text = text;
    row.imageId = imageId;
    return row;
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText image:(UIImage *)image nibName:(NSString *)nibName
{
    ECNativeRow *row = [self rowWithTag:tag data:text nibName:nibName userInfo:detailText];
    row.text = text;
    row.detailText = detailText;
    row.image = image;
    return row;
}

@end

@implementation ECNativeRow

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text
{
    return [self rowWithTag:tag text:text detailText:nil style:UITableViewCellStyleDefault];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText
{
    return [self rowWithTag:tag text:text detailText:detailText style:UITableViewCellStyleValue1];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText style:(UITableViewCellStyle)style
{
    return [self rowWithTag:tag text:text detailText:detailText image:nil style:style];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text image:(UIImage *)image
{
    return [self rowWithTag:tag text:text detailText:nil image:image style:UITableViewCellStyleDefault];
}

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText image:(UIImage *)image style:(UITableViewCellStyle)style
{
    ECNativeRow *row = [self rowWithTag:tag data:text className:@"ECTableViewCell" userInfo:detailText style:style];
    row.text = text;
    row.detailText = detailText;
    row.image = image;
    return row;
}


@end
