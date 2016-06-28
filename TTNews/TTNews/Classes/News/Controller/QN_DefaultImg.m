//
//  QN_DefaultImg.m
//  QooccNews
//
//  Created by 王顺强 on 14-6-18.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import "QN_DefaultImg.h"
#import "Reachability.h"
#import "QNTools.h"

@implementation QN_DefaultImg

//新闻明细默认图片
+ (QN_DefaultImg *)newsDetailDefaultImageWithImageSize:(CGSize)imgSize
{
    Reachability *rTest = [Reachability reachabilityForInternetConnection];
//    NSNumber *loadPic = (NSNumber *)kGetUserSystemObject(kStorePictureLoadSwitchKey);
//    BOOL loadPicOn = loadPic ? [loadPic boolValue] : YES;
    BOOL loadPicOn = YES;
    //3G下 关闭了2/3G加载图片 的，需要手动点击才去下载
    BOOL userDefaultDownloadImg = [rTest currentReachabilityStatus] == ReachableViaWWAN && !loadPicOn;
    
    QN_DefaultImg *defaultImg = [[QN_DefaultImg alloc] init];
    defaultImg.defaultImg = userDefaultDownloadImg ? [QNTools needDownloadDefaultPicImage:imgSize] : [QNTools noPicImage:imgSize];
    defaultImg.tapToDownload = userDefaultDownloadImg;
    return defaultImg;

}

@end
