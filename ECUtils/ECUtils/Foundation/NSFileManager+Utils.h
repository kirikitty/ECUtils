//
//  NSFileManager+Utils.h
//  ECUtils
//
//  Created by kiri on 14/12/28.
//  Copyright (c) 2014年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Utils)

- (NSURL *)URLForDocumentDirectory;
- (NSURL *)URLForCachesDirectory;

@end
