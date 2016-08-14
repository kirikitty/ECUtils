//
//  RFJSONPropertyAnnotation.h
//  ECUtils
//
//  Created by kiri on 15/6/27.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFBeanPropertyAnnotation.h"

@interface RFJSONPropertyAnnotation : RFBeanPropertyAnnotation

@property (strong, nonatomic) Class classInArray;
@property (strong, nonatomic) Class classInDictionary;

@end
