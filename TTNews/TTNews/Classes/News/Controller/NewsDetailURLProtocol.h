//
//  NewsDetailURLProtocol.h
//  QooccNews
//
//  Created by LiuYu on 14/10/28.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import <Foundation/Foundation.h>

//图片加载完会抛该通知
extern NSString *NotificationNewsDetailLoadImageFinish;

/*!
 *  对WebView中的图片重新做缓存，缓存使用SDImageCache+NSDataToDisk 
 */

@interface NewsDetailURLProtocol : NSURLProtocol

@end
