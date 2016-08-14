//
//  ECResourceLoader.m
//  ECUtils
//
//  Created by kiri on 2013-10-16.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "ECResourceLoader.h"

@implementation ECResourceLoader

+ (int)originResourceVersionForKey:(NSString *)key
{
    static NSDictionary *appMeta = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appMeta = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ResourceVersion" withExtension:@"plist"]];
    });
    
    NSNumber *ver = [appMeta objectForKey:key];
    return [ver intValue];
}

+ (NSMutableDictionary *)resourceVersion
{
    static NSMutableDictionary *meta = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        meta = [NSMutableDictionary dictionaryWithContentsOfURL:[[self resourceDirectoryURL] URLByAppendingPathComponent:@"ResourceVersion.plist"]];
        if (!meta) {
            meta = [NSMutableDictionary dictionary];
        }
    });
    return meta;
}

+ (void)saveResourceVersion
{
    [[self resourceVersion] writeToURL:[[self resourceDirectoryURL] URLByAppendingPathComponent:@"ResourceVersion.plist"] atomically:YES];
}

+ (NSURL *)resourceDirectoryURL
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:@"Resources" isDirectory:YES];
    BOOL dir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&dir] || !dir) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil]) {
            return nil;
        }
    }
    return url;
}

+ (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dir = [self resourceDirectoryURL];
    if (dir == nil) {
        return nil;
    }
    
    NSString *key = [name stringByAppendingPathExtension:ext];
    BOOL needUpdate = NO;
    if ([self originResourceVersionForKey:key] > [[[self resourceVersion] objectForKey:key] intValue]) {
        needUpdate = YES;
    }
    
    NSURL *url = [[dir URLByAppendingPathComponent:name] URLByAppendingPathExtension:ext];
    if (!needUpdate && [fm fileExistsAtPath:url.path]) {
        return url;
    }
    
    NSURL *srcURL = [[NSBundle mainBundle] URLForResource:name withExtension:ext];
    if (srcURL) {
        if ([fm fileExistsAtPath:url.path]) {
            [fm removeItemAtURL:url error:nil];
        }
        if ([fm copyItemAtURL:srcURL toURL:url error:nil]) {
            [[self resourceVersion] setObject:[NSNumber numberWithInt:[self originResourceVersionForKey:key]] forKey:key];
            [self saveResourceVersion];
            return url;
        } else {
            return srcURL;
        }
    }
    return nil;
}

+ (NSURL *)URLForResourceWithRelativePath:(NSString *)relativePath
{
    NSString *ext = [relativePath pathExtension];
    NSString *name = [relativePath stringByDeletingPathExtension];
    NSString *relativeDir = [name stringByDeletingLastPathComponent];
    name = [name lastPathComponent];
    
    NSString *dirPath = [self resourceDirectoryURL].path;
    if (dirPath == nil) {
        return nil;
    }
    
    dirPath = [dirPath stringByAppendingPathComponent:relativeDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dir = [NSURL fileURLWithPath:dirPath isDirectory:YES];
    if (![fm fileExistsAtPath:dir.path]) {
        [fm createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *key = [name stringByAppendingPathExtension:ext];
    BOOL needUpdate = NO;
    if ([self originResourceVersionForKey:key] > [[[self resourceVersion] objectForKey:key] intValue]) {
        needUpdate = YES;
    }
    
    NSURL *url = [[dir URLByAppendingPathComponent:name] URLByAppendingPathExtension:ext];
    if (!needUpdate && [fm fileExistsAtPath:url.path]) {
        return url;
    }
    
    NSURL *srcURL = [[NSBundle mainBundle] URLForResource:name withExtension:ext];
    if (srcURL) {
        if ([fm copyItemAtURL:srcURL toURL:url error:nil]) {
            [[self resourceVersion] setObject:[NSNumber numberWithInt:[self originResourceVersionForKey:key]] forKey:key];
            [self saveResourceVersion];
            return url;
        } else {
            return srcURL;
        }
    }
    return nil;
}

@end
