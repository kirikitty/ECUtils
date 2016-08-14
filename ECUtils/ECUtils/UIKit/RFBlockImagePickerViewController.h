//
//  RFBlockImagePickerViewController.h
//  ECUtils
//
//  Created by kiri on 2013-11-18.
//  Copyright (c) 2013年 kiri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFBlockImagePickerViewController : UIImagePickerController

@property (nonatomic, copy) void (^completion)(RFBlockImagePickerViewController *picker, BOOL isCancel, NSDictionary *mediaInfo);

@end