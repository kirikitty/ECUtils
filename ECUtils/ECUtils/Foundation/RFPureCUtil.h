//
//  RFPureCUtil.h
//  ECUtils
//
//  Created by kiri on 15/5/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void rf_dispatch_sync_main(dispatch_block_t block);

extern NSString *RFDocumentDirectory(void);
extern NSString *RFCachesDirectory(void);

typedef void(^RFNoParamsBlock)(void);

@interface RFPureCUtil : NSObject

@end
