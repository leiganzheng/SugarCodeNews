//
//  SDImageCache+NSDataToDisk.h
//  QooccNews
//
//  Created by LiuYu on 14/10/23.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import "SDImageCache.h"

/*!
 *  增加直接对Data的存储和读取方法，使用 SDImageCache 的缓存目录
 */
@interface SDImageCache (NSDataToDisk)

// 判断一个urlString的扩展名是否是Gif
+ (BOOL)isGifURLWithURLString:(NSString *)urlString;

/*!
 *  存储Gif的 data到文件中
 *
 *  @param imageData Gif data
 *  @param key       Gif url
 */
- (void)storeDataToDisk:(NSData *)data forKey:(NSString *)key;

/*!
 *  获取本地缓存中的 Gif data，
 *
 *  @param key Gif url
 *
 *  @return 如果没有则返回nil
 */
- (NSData *)dataFromDiskCacheForKey:(NSString *)key;

@end
