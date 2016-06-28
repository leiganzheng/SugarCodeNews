//
//  QNTools.h
//  QooccNews
//
//  Created by yangxi on 14-3-14.
//  Copyright (c) 2014年 王顺强. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//字号类型
typedef NS_ENUM(NSInteger, ContentFontSize) {
    ContentFontSizeSmall = 0,
    ContentFontSizeMedium,
    ContentFontSizeLarge,
};

#define kNoDataPromptDebugMode 0

#if kNoDataPromptDebugMode
#define kNoDataErrorMessage @"查询结果为空 debug模式"
#else
#define kNoDataErrorMessage @"网络异常"
#endif

typedef enum {
    kHintImageTypeNone = 0,
    kHintImageTypeSuccess,
    kHintImageTypeSad,
    kHintImageTypeFail,
} HintImageType;

@interface QNTools : NSObject

// 组合图片下载地址
+ (NSURL*)combineImageUrl:(NSString*)imgName type:(int)prefixType;

//返回居中的按比例缩放的缩略图
+(UIImage *)image:(UIImage *)image centerInWidth:(CGFloat)tWidth centerInHeight:(CGFloat)tHeight;


/** 公共格式化日期
 
 @param dateStr 需要格式化的日期
 */
+ (NSString *)commonFormatterDateString:(NSString *)dateStr;

//新闻内容的字号名称
+(NSString *)textForFontSize:(ContentFontSize)fontSize;

/**
 新闻内容的字体大小类型
 */
+(NSInteger)contentFontSize;

/** 新闻内容的字体大小根据字体类似
 
 @param fontSize 字号类型
 */
+ (CGFloat)pFontSize:(ContentFontSize)fontSize;

/** 给图片上色
 
 @param name 图片名称
 @param name 颜色
 */
+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;


/** 配置imageView的image
 */
//+ (void)configCellImgaeView:(SKListImageView *)imageView imageName:(NSString *)imageName;


/** 缓存图片大小
 */
+(NSString *)pictureCacheSize;

/** 缓存图片大小
 */
+(NSString *)pictureCacheSize:(NSUInteger)cacheSize;

/*
 * 最小比例压缩，按当前的image的size 与 （max,maxH)的最小比例
 * 如：image的size为 640 和 1136，maxW和maxH为 320 和 400, 那么压缩后的图片尺寸为320，568
 */
+(UIImage *)image:(UIImage *)image maxWidth:(CGFloat)maxW maxHeight:(CGFloat)maxH;

//默认图片，背景颜色拉伸
+ (UIImage *)noPicImage:(CGSize)size;

//点击下载的默认图片
+ (UIImage *)needDownloadDefaultPicImage:(CGSize)size;

//利用正则表达式解析URL
+ (NSString *)parseUrlParameter:(NSString *)key urlQueue:(NSString *)urlQueue;

//图片的白天/夜间模式
+ (UIImage *)imageForNightMode:(BOOL)nightMode prefixImgName:(NSString *)prefixImgName;

//检测是否开了wifi
+ (BOOL)checkWifiAbility;

//图片方向纠正
+ (UIImage *)imageFixOrientation:(UIImage *)srcImg;

@end
