//
//  ECPinyinUtil.m
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "ECPinyinUtil.h"
#import "ECPinyinTable.h"

@implementation ECPinyinUtil

+ (unichar)firstLetterWithCharacter:(unichar)c
{
    int pinyinIndex = c - HANZI_START;
    if (pinyinIndex >= 0 && pinyinIndex < HANZI_COUNT) {
        return _pinyin_initial_table_[pinyinIndex];
    }
    return c;
}

+ (BOOL)unichar2Py:(unichar)c out:(char *)out outlen:(int *)outlen
{
    if ([self isHanziUnicodeCharacter:c]) {
        const char *ch = _pinyin_table_[c - HANZI_START];
        *outlen = (int)strlen(ch);
        memcpy(out, ch, *outlen);
        return YES;
    } else {
        if (c < 0x1 << 8) {
            out[0] = c;
            *outlen = 1;
        } else {
            memcpy(out, &c, 2);
            *outlen = 2;
        }
        return YES;
    }
}

+ (char)pycharWithBuffer:(const char *)buffer bufferLen:(int)bufferLen
{
    char pychar;
    if (bufferLen < 2) {
        return -1;
    }
    int tmp = (buffer[0] & 0xFF) << 8 | (buffer[1] & 0xFF);
    
    if(tmp >= 45217 && tmp <= 45252) pychar = 'A';
    else if(tmp >= 45253 && tmp <= 45760) pychar = 'B';
    else if(tmp >= 45761 && tmp <= 46317) pychar = 'C';
    else if(tmp >= 46318 && tmp <= 46825) pychar = 'D';
    else if(tmp >= 46826 && tmp <= 47009) pychar = 'E';
    else if(tmp >= 47010 && tmp <= 47296) pychar = 'F';
    else if(tmp >= 47297 && tmp <= 47613) pychar = 'G';
    else if(tmp >= 47614 && tmp <= 48118) pychar = 'H';
    else if(tmp >= 48119 && tmp <= 49061) pychar = 'J';
    else if(tmp >= 49062 && tmp <= 49323) pychar = 'K';
    else if(tmp >= 49324 && tmp <= 49895) pychar = 'L';
    else if(tmp >= 49896 && tmp <= 50370) pychar = 'M';
    else if(tmp >= 50371 && tmp <= 50613) pychar = 'N';
    else if(tmp >= 50614 && tmp <= 50621) pychar = 'O';
    else if(tmp >= 50622 && tmp <= 50905) pychar = 'P';
    else if(tmp >= 50906 && tmp <= 51386) pychar = 'Q';
    else if(tmp >= 51387 && tmp <= 51445) pychar = 'R';
    else if(tmp >= 51446 && tmp <= 52217) pychar = 'S';
    else if(tmp >= 52218 && tmp <= 52697) pychar = 'T';
    else if(tmp >= 52698 && tmp <= 52979) pychar = 'W';
    else if(tmp >= 52980 && tmp <= 53640) pychar = 'X';
    else if(tmp >= 53689 && tmp <= 54480) pychar = 'Y';
    else if(tmp >= 54481 && tmp <= 55289) pychar = 'Z';
    else pychar = -1;
    
    return pychar;
}

+ (BOOL)isHanziUnicodeCharacter:(unichar)c {
    return (c > HANZI_START - 1 && c < HANZI_START + HANZI_COUNT);
}

+ (BOOL)isHanziGBKCharacter:(unichar)c {
    return (c > 45216 && c < 55290);
}

@end
