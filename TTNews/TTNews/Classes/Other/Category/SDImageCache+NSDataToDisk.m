//
//  SDImageCache+NSDataToDisk.m
//  QooccNews
//
//  Created by leiganzheng on 14/10/23.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import "SDImageCache+NSDataToDisk.h"
#import <CommonCrypto/CommonDigest.h>

static NSString  *diskCachePathSelf = nil;

@implementation SDImageCache (NSDataToDisk)

// 判断一个urlString的扩展名是否是Gif
+ (BOOL)isGifURLWithURLString:(NSString *)urlString {
    NSString *fileExtension = [[urlString pathExtension] uppercaseString];
    return [fileExtension isEqual:@"GIF"];
}

// 根据私有属性 diskCachePath 配置 共有属性
- (void)configDiskCachePath {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:@"default"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        diskCachePathSelf = [paths[0] stringByAppendingPathComponent:fullNamespace];
    });
}

/*!
 *  存储Gif的 data到文件中
 *
 *  @param imageData Gif data
 *  @param key       Gif url
 */
- (void)storeDataToDisk:(NSData *)data forKey:(NSString *)key {
    if (!data || !key) { return ; }
    
    [self configDiskCachePath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePathSelf]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePathSelf withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *filePath = [diskCachePathSelf stringByAppendingPathComponent:[self cachedFileNameForKeyOnlySelf:key]];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}

/*!
 *  获取本地缓存中的 Gif data，
 *
 *  @param key Gif url
 *
 *  @return 如果没有则返回nil
 */
- (NSData *)dataFromDiskCacheForKey:(NSString *)key {
    if (!key) { return nil; }
    
    [self configDiskCachePath];
    
    NSString *filePath = [diskCachePathSelf stringByAppendingPathComponent:[self cachedFileNameForKeyOnlySelf:key]];
    return [NSData dataWithContentsOfFile:filePath];
}

#pragma mark - Private
// 从 SDImageCache 中拷贝出来的，增加了 OnlySelf. (当 SDImageCache 有更新时，不一定要更新 此方法）
- (NSString *)cachedFileNameForKeyOnlySelf:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

@end
