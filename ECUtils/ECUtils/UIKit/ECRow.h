//
//  ECRow.h
//  ECUtils
//
//  Created by kiri on 15/4/6.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECViewObject.h"

typedef NS_ENUM(NSUInteger, ECRowSource) {
    ECRowSourceNib,
    ECRowSourceCreating,
};

extern const UITableViewCellAccessoryType ECRowAccessoryTypeNotDetermined;
extern const UITableViewCellSelectionStyle ECRowSelectionStyleNotDetermined;

/**
 *  The model of table view row.
 */
@interface ECRow : ECViewObject

@property (strong, nonatomic) NSString *reuseIdentifier;
@property (nonatomic) ECRowSource source;
@property (nonatomic) BOOL dynamicHeight;
@property (nonatomic) UITableViewCellStyle style;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data nibName:(NSString *)nibName;
+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data className:(NSString *)className;

+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data className:(NSString *)className userInfo:(id)userInfo style:(UITableViewCellStyle)style;
+ (instancetype)rowWithTag:(NSInteger)tag data:(id)data nibName:(NSString *)nibName userInfo:(id)userInfo;

+ (NSMutableArray *)rowsWithTag:(NSInteger)tag datas:(NSArray *)datas nibName:(NSString *)nibName;

@end

@interface ECSimpleRow : ECRow

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *detailText;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageId;

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText nibName:(NSString *)nibName;
+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text image:(UIImage *)image nibName:(NSString *)nibName;
+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text imageId:(NSString *)imageId nibName:(NSString *)nibName;
+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText image:(UIImage *)image nibName:(NSString *)nibName;

@end

@interface ECNativeRow : ECSimpleRow

+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text;
+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text detailText:(NSString *)detailText;
+ (instancetype)rowWithTag:(NSInteger)tag text:(NSString *)text image:(UIImage *)image;

@end