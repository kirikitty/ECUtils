//
//  ECCUtil.h
//  ECUtils
//
//  Created by kiri on 15/5/15.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void ec_dispatch_sync_main(dispatch_block_t block);

extern NSString *ECDocumentDirectory(void);
extern NSString *ECCachesDirectory(void);

typedef void(^ECNoParamsBlock)(void);

extern Class ECSwiftClassFromString(NSString *className);

@interface ECCUtil : NSObject

@end
