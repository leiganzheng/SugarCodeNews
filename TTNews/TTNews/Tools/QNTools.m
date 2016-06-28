//
//  QNTools.m
//  QooccNews
//
//  Created by yangxi on 14-3-14.
//  Copyright (c) 2014年 王顺强. All rights reserved.
//
#import "QNTools.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "SDImageCache.h"
#import "CyToolDefine.h"

#define kDFMBSize       1024 * 1024
#define kDFKBSize       1024
#define kDFGBSize       1024 * 1024 * 1024

@implementation QNTools



// 组合图片下载地址
+ (NSURL*)combineImageUrl:(NSString*)imgName type:(int)prefixType
{
    NSURL *url = nil;
//    if (imgName.isNotEmpty) {
//        url = [NSURL URLWithString:imgName];
//    }
    
    return url;
}

//返回居中的缩略图(通过匹配可用空间的长度和宽度来填充图像。每个像素都被使用，但是图像将水平或垂直裁剪)
+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) viewsize
{
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(viewsize);
    float dwidth = (viewsize.width - size.width) / 2.0f;
    float dheight = (viewsize.height - size.height) / 2.0f;
    
    CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
    [image drawInRect:rect];
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}

//返回居中的按比例缩放的缩略图
+(UIImage *)image:(UIImage *)image centerInWidth:(CGFloat)tWidth centerInHeight:(CGFloat)tHeight
{
    CGFloat tUnit = (image.size.width / tWidth < image.size.height / tHeight) ? (image.size.width / tWidth) : (image.size.height / tHeight);
    CGSize size = CGSizeMake(tUnit * tWidth, tUnit * tHeight);
    
    return [QNTools image:image centerInSize:size];
}


+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    // load the image
    
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    CGSize size = CGSizeMake(img.size.width * 2, img.size.height * 2);
    UIGraphicsBeginImageContext(size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    //    CGContextClipToMask(context, rect, img.CGImage);
    //    CGContextAddRect(context, rect);
    //    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


//+ (void)configCellImgaeView:(__weak SKListImageView *)imageView imageName:(NSString *)imageName
//{
//    NSURL *url = [QNTools combineImageUrl:imageName type:kImgPrefixTypeNews];
//    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:kHomeThumbDefaultImage] options:SDWebImageRetryFailed | SDWebImageLowPriority];
//}



//缓存图片大小
+(NSString *)pictureCacheSize
{
    long long size = [[SDImageCache sharedImageCache] getSize];
    
    if (size > kDFGBSize) {
        float unit = kDFGBSize;
        float retF = size / unit;
        return [NSString stringWithFormat:@"%.1fGB",retF];
    }
    else if(size > kDFMBSize){
        float unit = kDFMBSize;
        float retF = size / unit;
        return [NSString stringWithFormat:@"%.1fMB",retF];
    }
    else if(size > kDFKBSize){
        float unit = kDFKBSize;
        float retF = size / unit;
        return [NSString stringWithFormat:@"%.1fKB",retF];
    }
    
    return @"0KB";
}

//缓存图片大小
+(NSString *)pictureCacheSize:(NSUInteger)cacheSize
{
    if (cacheSize > kDFGBSize) {
        float unit = kDFGBSize;
        float retF = cacheSize / unit;
        return [NSString stringWithFormat:@"%.1fGB",retF];
    }
    else if(cacheSize > kDFMBSize){
        float unit = kDFMBSize;
        float retF = cacheSize / unit;
        return [NSString stringWithFormat:@"%.1fMB",retF];
    }
    else if(cacheSize > kDFKBSize){
        float unit = kDFKBSize;
        float retF = cacheSize / unit;
        return [NSString stringWithFormat:@"%.1fKB",retF];
    }
    
    return @"0KB";
}


/*
 * 最小比例压缩，按当前的image的size 与 （max,maxH)的最小比例
 * 如：image的size为 640 和 1136，maxW和maxH为 320 和 400, 那么压缩后的图片尺寸为320，568
 */
+(UIImage *)image:(UIImage *)image maxWidth:(CGFloat)maxW maxHeight:(CGFloat)maxH
{
    CGFloat scaleX = maxW / image.size.width;
    CGFloat scaleY = maxH / image.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scale, scale);
    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
}


//默认图片
+ (UIImage *)noPicImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform myTr = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, myTr);
    
    CGRect imgRect = CGRectMake(0, 0, size.width, size.height);
    //背景颜色值
    CGContextSetFillColorWithColor(context, [kCyColorFromHex(0xefefef) CGColor]);
    CGContextFillRect(context, imgRect);
    
    CGFloat noPicW = 156, noPicH = 88;
    CGRect noPicRect = CGRectMake(imgRect.origin.x + (imgRect.size.width - noPicW) / 2, imgRect.origin.y + (imgRect.size.height - noPicH) / 2, noPicW, noPicH);
    
    CGContextDrawImage(context, noPicRect, [UIImage imageNamed:@"html_default_img"].CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//点击下载默认图片
+ (UIImage *)needDownloadDefaultPicImage:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform myTr = CGAffineTransformMake(1, 0, 0, -1, 0, size.height);
    CGContextConcatCTM(context, myTr);
    
    CGRect imgRect = CGRectMake(0, 0, size.width, size.height);
    //背景颜色值
    CGContextSetFillColorWithColor(context, [kCyColorFromHex(0xefefef) CGColor]);
    CGContextFillRect(context, imgRect);
    
    CGFloat noPicW = 156, noPicH = 88;
    CGRect noPicRect = CGRectMake(imgRect.origin.x + (imgRect.size.width - noPicW) / 2, imgRect.origin.y + (imgRect.size.height - noPicH) / 2, noPicW, noPicH);
    
    CGContextDrawImage(context, noPicRect, [UIImage imageNamed:@"html_default_img_download"].CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

//利用正则表达式解析URL
+ (NSString *)parseUrlParameter:(NSString *)key urlQueue:(NSString *)urlQueue
{
    if (!urlQueue || !key) {
        return nil;
    }
    
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",key];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:urlQueue
                                      options:0
                                        range:NSMakeRange(0, [urlQueue length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [urlQueue substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return nil;
}

//图片的白天/夜间模式
+ (UIImage *)imageForNightMode:(BOOL)nightMode prefixImgName:(NSString *)prefixImgName
{
    if (prefixImgName) {
        NSString *dayOrNight = nightMode ? @"night" : @"day";
        NSString *imgName = [NSString stringWithFormat:@"%@_%@",prefixImgName,dayOrNight];
        return [UIImage imageNamed:imgName];
    }
    
    return nil;
}

//检测是否开了wifi
+ (BOOL)checkWifiAbility
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable) && [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi;
}

//图片方向纠正
+ (UIImage *)imageFixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp)
        return srcImg;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//AM 0:00-6:00 三小时更新一次 AM 6：00-12：00 每小时更新一次 PM 12：00-24：00 每两小时更新一次
+ (BOOL)needRefreshNow:(NSDate *)lastUpdate{
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh"];
    NSString *hour = [df stringFromDate:date];
    NSInteger ihour = [hour intValue];
    NSTimeInterval timeinterval = 60*60;;
    if (ihour<6) {
        timeinterval = 3*60*60;
    }else if (ihour<12){
        timeinterval = 60*60;
    }else if (ihour<24){
        timeinterval = 2*60*60;
    }
    NSTimeInterval delTime = [date timeIntervalSinceDate:lastUpdate];
    return delTime>timeinterval;
}
//保存和读取新闻阅读记录
+ (void)saveWebContentOffset:(CGPoint)offset withStringFlag:(NSString *)flag andUserID:(NSString *)userID
{
    NSDictionary *dic = @{@"x": [NSString stringWithFormat:@"%f",offset.x],@"y":[NSString stringWithFormat:@"%f",offset.y]};
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:[NSString stringWithFormat:@"%@-webView-%@",userID,flag]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (CGPoint)getWebContentOffsetWithFlag:(NSString *)flag andWithUserID:(NSString *)userID{
    NSString *webViewName = [NSString stringWithFormat:@"%@-webView-%@",userID,flag];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:webViewName];
    if (dic) {
        NSString *x = dic[@"x"];
        NSString *y = dic[@"y"];
        return CGPointMake(x.floatValue, y.floatValue);
    }
    return CGPointMake(0, 0);
}

//频道名字
+ (NSString *)channelName:(NSString *)channel{
//    NSArray *nameArray = @[@"社会民生",@"八卦爆料",@"生活百科",@"科技",@"房产",@"家居",@"教育",@"母婴",@"金融",@"医药",@"纺织",@"食品",@"旅游酒店",@"家电",@"通讯",@"电商",@"健康",@"农业",@"汽车",@"军事"];
//    NSArray *channelType = [self channels];
//    NSUInteger index = [channelType indexOfObject:channel];
//    if (index!=NSNotFound) {
//        return nameArray[index];
//    }
    return nil;
}
//频道背景
+ (UIImage *)channelBgIcon:(NSString *)channel{
//    NSArray *normalImageArray = @[@"b_5_icon",@"b_6_icon",@"b_7_icon",@"b_8_icon",@"b_10_icon",@"b_9_icon",@"b_11_icon",@"b_23_icon",@"b_12_icon",@"b_13_icon",@"b_14_icon",@"b_15_icon",@"b_16_icon",@"b_17_icon",@"b_18_icon",@"b_21_icon",@"b_22_icon",@"b_19_icon",@"b_20_icon",@"b_24_icon"];
//    NSArray *channelType = [self channels];
//    NSUInteger index = [channelType indexOfObject:channel];
//    if (index!=NSNotFound) {
//        return [UIImage imageNamed:normalImageArray[index]];
//    }
    return nil;
}

+ (UIImage *)singleLineImage:(CGSize)size Color:(UIColor *)color{
    static UIImage *singleLineImage = nil;
    if (singleLineImage == nil) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 0.0);
//        [[UIColor colorWithWhite:222.0/255.0 alpha:1] setFill];
        [color setFill];
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
        singleLineImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return [singleLineImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 1.0)];
}

+ (UIImage *)imageWithSize:(CGSize)size Color:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0, 1.0), NO, 0.0);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}




@end
