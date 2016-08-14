//
//  RFBeanProperty.h
//  ECUtils
//
//  Created by kiri on 14-9-11.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface RFBeanProperty : NSObject

@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) Class cls;
@property (strong, nonatomic) Protocol *protocol;

@property (strong, nonatomic) NSDictionary *attributes;
@property (nonatomic) char typeEncoding;

@property (strong, readonly, nonatomic) NSString *typeName;
@property (strong, readonly, nonatomic) NSString *className;
@property (strong, readonly, nonatomic) NSString *structName;
@property (readonly, nonatomic) NSInteger bitNumber;

@property (readonly) SEL customGetter;
@property (readonly) SEL customSetter;
@property (readonly, getter=isReadonly) BOOL readonly;
@property (readonly, getter=isCopy) BOOL copy;
@property (readonly, getter=isStrong) BOOL strong;
@property (readonly, getter=isWeak) BOOL weak;
@property (readonly, getter=isAssign) BOOL assign;
@property (readonly, getter=isDynamic) BOOL dynamic;
@property (readonly, getter=isNonatomic) BOOL nonatomic;

@property (readonly) SEL getter;
@property (readonly) SEL setter;

// need set from outer.
@property (strong, nonatomic) NSInvocation *getterInvocation;
@property (strong, nonatomic) NSInvocation *setterInvocation;

- (instancetype)initWithProperty:(objc_property_t)property;

@end
