//
//  ECResourceLoader.h
//  ECUtils
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECResourceLoader : NSObject

/*!
 *  Return URL for resource located in ~/Documents/Resource/. If not exist, search and copy from main bundle.
 *  @discussion This method is more effective than URLForResourceWithRelativePath:, but can't has subdirectory.
 *  @param name The name of file.
 *  @param ext The extension of file.
 *  @return The specified URL for resource located in ~/Documents/Resource/.
 */
+ (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext;

/*!
 *  Return URL for resource located in ~/Documents/Resource/. If not exist, search and copy from main bundle.
 *  @param relativePath The file path relative to ~/Documents/Resource/.
 *  @return The specified URL for resource located in ~/Documents/Resource/.
 */
+ (NSURL *)URLForResourceWithRelativePath:(NSString *)relativePath;

+ (NSURL *)resourceDirectoryURL;

@end