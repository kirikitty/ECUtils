//
//  RFBeanProperty.m
//  ECUtils
//
//  Created by kiri on 14-9-11.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import "RFBeanProperty.h"

@interface RFBeanProperty ()

@property (strong, nonatomic) NSString *typeName;
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *structName;
@property (nonatomic) NSInteger bitNumber;

@end

@implementation RFBeanProperty

- (NSString *)description
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@: %p; @property ", NSStringFromClass([self class]), self];
    NSMutableArray *attrs = [NSMutableArray array];
    if (self.isStrong) {
        [attrs addObject:@"strong"];
    }
    if (self.isWeak) {
        [attrs addObject:@"weak"];
    }
    if (self.isCopy) {
        [attrs addObject:@"copy"];
    }
    if (self.isAssign) {
        [attrs addObject:@"assign"];
    }
    if (self.isReadonly) {
        [attrs addObject:@"readonly"];
    }
    if (self.isNonatomic) {
        [attrs addObject:@"nonatomic"];
    }
    if (self.customGetter) {
        [attrs addObject:[@"getter=" stringByAppendingString:NSStringFromSelector(self.customGetter)]];
    }
    if (self.customSetter) {
        [attrs addObject:[@"setter=" stringByAppendingString:NSStringFromSelector(self.customSetter)]];
    }
    if (attrs.count > 0) {
        [s appendFormat:@"(%@) ", [attrs componentsJoinedByString:@", "]];
    }
    
    if (self.typeName) {
        [s appendString:self.typeName];
    }
    if (![self.typeName hasSuffix:@"*"]) {
        [s appendString:@" "];
    }
    [s appendString:self.name];
    
    if (self.isDynamic) {
        [s appendString:@"; dynamic"];
    }
    [s appendString:@">"];
    return s;
}

- (NSString *)fetchTypeNameWithTypeEncoding:(char)typeEncoding
{
    switch (typeEncoding) {
        case _C_CLASS:
            return @"Class";
        case _C_SEL:
            return @"SEL";
        case _C_CHR:
            return @"char";
        case _C_UCHR:
            return @"unsigned char";
        case _C_SHT:
            return @"short";
        case _C_USHT:
            return @"unsigned short";
        case _C_INT:
            return @"int";
        case _C_UINT:
            return @"unsigned int";
        case _C_LNG:
            return @"long";
        case _C_ULNG:
            return @"unsigned long";
        case _C_LNG_LNG:
            return @"long long";
        case _C_ULNG_LNG:
            return @"unsigned long long";
        case _C_FLT:
            return @"float";
        case _C_DBL:
            return @"double";
        case _C_BFLD:
            return @"bit: ";
        case _C_BOOL:
            return @"BOOL";
        case _C_VOID:
            return @"void";
        case _C_CHARPTR:
            return @"char *";
        default:
            return @"";
    }
}

- (BOOL)isReadonly
{
    return self.attributes[@"R"] != nil;
}

- (BOOL)isCopy
{
    return self.attributes[@"C"] != nil;
}

- (BOOL)isStrong
{
    return self.attributes[@"&"] != nil;
}

- (BOOL)isWeak
{
    return self.attributes[@"W"] != nil;
}

- (BOOL)isNonatomic
{
    return self.attributes[@"N"] != nil;
}

- (BOOL)isDynamic
{
    return self.attributes[@"D"] != nil;
}

- (BOOL)isAssign
{
    return self.typeEncoding == _C_ID && !self.isDynamic && !self.isStrong && !self.isCopy && !self.isWeak;
}

- (SEL)customGetter
{
    NSString *getter = self.attributes[@"G"];
    if (getter) {
        return NSSelectorFromString(getter);
    }
    return nil;
}

- (SEL)customSetter
{
    NSString *setter = self.attributes[@"S"];
    if (setter) {
        return NSSelectorFromString(setter);
    }
    return nil;
}

- (SEL)getter
{
    SEL selector = self.customGetter;
    if (selector == NULL) {
        selector = NSSelectorFromString(self.name);
    }
    return selector;
}

- (SEL)setter
{
    SEL selector = self.customSetter;
    if (selector == NULL) {
        selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [self.name substringToIndex:1].uppercaseString, [self.name substringFromIndex:1]]);
    }
    return selector;
}

- (instancetype)initWithProperty:(objc_property_t)p
{
    if (self = [super init]) {
        self.name = [NSString stringWithUTF8String:property_getName(p)];
        
        unsigned int attrCount;
        objc_property_attribute_t *rawAttributes = property_copyAttributeList(p, &attrCount);
        
        if (rawAttributes != NULL) {
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            for (int j = 0; j < attrCount; j++) {
                objc_property_attribute_t attr = rawAttributes[j];
                attributes[[NSString stringWithUTF8String:attr.name]] = [NSString stringWithUTF8String:attr.value];
            }
            self.attributes = attributes;
            NSString *type = attributes[@"T"];
            if (type.length > 0) {
                [self processTypeWithTypeEncoding:type.UTF8String[0] type:type];
            }
            
            free(rawAttributes);
            rawAttributes = NULL;
        }
    }
    return self;
}

- (void)processTypeWithTypeEncoding:(char)typeEncoding type:(NSString *)type
{
    self.typeEncoding = typeEncoding;
    switch (typeEncoding) {
        case _C_ID:
        {
            NSTextCheckingResult *result = [self.idRegex firstMatchInString:type options:0 range:NSMakeRange(0, type.length)];
            if (result.numberOfRanges > 1 && result.range.length > 0) {
                NSString *className = [type substringWithRange:[result rangeAtIndex:1]];
                self.cls = NSClassFromString(className);
                self.className = className;
                self.typeName = [NSString stringWithFormat:@"%@ *", className];
            } else {
                self.typeName = @"id";
            }
            
            NSTextCheckingResult *protocolResult = [self.protocolRegex firstMatchInString:type options:0 range:NSMakeRange(0, type.length)];
            if (protocolResult.numberOfRanges > 1 && protocolResult.range.length > 0) {
                NSString *protocolName = [type substringWithRange:[protocolResult rangeAtIndex:1]];
                self.protocol = NSProtocolFromString(protocolName);
                self.typeName = [self.typeName stringByAppendingFormat:@"<%@>", protocolName];
            }
            break;
        }
        case _C_STRUCT_B:
        case _C_UNION_B:
        {
            NSRegularExpression *regex = typeEncoding == _C_STRUCT_B ? self.structRegex : self.unionRegex;
            NSTextCheckingResult *result = [regex firstMatchInString:type options:0 range:NSMakeRange(0, type.length)];
            if (result.numberOfRanges > 1 && result.range.length > 0) {
                self.structName = [type substringWithRange:[result rangeAtIndex:1]];
                self.typeName = self.structName;
            } else {
                self.typeName = @"undefined";
            }
            break;
        }
        case _C_PTR:
        {
            NSString *realType = [type stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"^"]];
            NSInteger ptrNumber = type.length - realType.length;
            
            NSMutableString *typeName = [NSMutableString string];
            if (realType.length > 0) {
                char ptrType = realType.UTF8String[0];
                switch (ptrType) {
                    case _C_ID:
                    {
                        NSTextCheckingResult *result = [self.idRegex firstMatchInString:type options:0 range:NSMakeRange(0, type.length)];
                        if (result.numberOfRanges > 1 && result.range.length > 0) {
                            NSString *className = [type substringWithRange:[result rangeAtIndex:1]];
                            [typeName appendFormat:@"%@ *", className];
                        } else {
                            [typeName appendString:@"id"];
                        }
                        
                        NSTextCheckingResult *protocolResult = [self.protocolRegex firstMatchInString:type options:0 range:NSMakeRange(0, type.length)];
                        if (protocolResult.numberOfRanges > 1 && protocolResult.range.length > 0) {
                            NSString *protocolName = [type substringWithRange:[protocolResult rangeAtIndex:1]];
                            [typeName appendFormat:@"<%@>", protocolName];
                        }
                        break;
                    }
                    case _C_STRUCT_B:
                    case _C_UNION_B:
                    {
                        NSRegularExpression *regex = ptrType == _C_STRUCT_B ? self.structRegex : self.unionRegex;
                        NSTextCheckingResult *result = [regex firstMatchInString:realType options:0 range:NSMakeRange(0, realType.length)];
                        if (result.numberOfRanges > 1 && result.range.length > 0) {
                            [typeName appendString:[realType substringWithRange:[result rangeAtIndex:1]]];
                        }
                        break;
                    }
                    default:
                    {
                        [typeName appendString:[self fetchTypeNameWithTypeEncoding:ptrType]];
                        break;
                    }
                }
            }
            
            if (typeName.length == 0) {
                [typeName appendString:@"void"];
            }
            
            if (![typeName hasPrefix:@"*"]) {
                [typeName appendString:@" "];
            }
            
            for (int i = 0; i < ptrNumber; i++) {
                [typeName appendString:@"*"];
            }
            self.typeName = typeName;
            break;
        }
            // There isn't bitfield property.
//        case _C_BFLD:
//        {
//            self.bitNumber = type.length > 1 ? [[type substringFromIndex:1] integerValue] : 0;
//            self.typeName = [NSString stringWithFormat:@"b:%@", @(self.bitNumber)];
//            break;
//        }
        default:
        {
            self.typeName = [self fetchTypeNameWithTypeEncoding:typeEncoding];
            break;
        }
    }
}

- (NSRegularExpression *)idRegex
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^@\\\"(\\w+)\\\"" options:0 error:nil];
    });
    return regex;
}

- (NSRegularExpression *)protocolRegex
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^@\\\"<(\\w+)>\\\"" options:0 error:nil];
    });
    return regex;
}

- (NSRegularExpression *)structRegex
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^\\{(\\w*)" options:0 error:nil];
    });
    return regex;
}

- (NSRegularExpression *)unionRegex
{
    static NSRegularExpression *regex = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regex = [NSRegularExpression regularExpressionWithPattern:@"^\\((\\w*)" options:0 error:nil];
    });
    return regex;
}

@end
