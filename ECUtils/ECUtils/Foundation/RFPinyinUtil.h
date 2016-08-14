//
//  RFPinyinUtil.h
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFPinyinUtil : NSObject

+ (unichar)firstLetterWithCharacter:(unichar)c;
+ (BOOL)unichar2Py:(unichar)c out:(char *)out outlen:(int *)outlen;
+ (char)pycharWithBuffer:(const char *)buffer bufferLen:(int)bufferLen;
+ (BOOL)isHanziUnicodeCharacter:(unichar)c;
+ (BOOL)isHanziGBKCharacter:(unichar)c;

@end
