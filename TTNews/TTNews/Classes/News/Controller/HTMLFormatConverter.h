//
//  HTMLFormatConverter.h
//  QooccNews
//
//  Created by LiuYu on 14-9-26.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kHtmlImageDefaultIdBase     @"img_default_"
// img标签，src前缀
#define kImageTagIdPrefix           @"image_wait_load_"
// 图片URL前缀，可用于识别是否是图片link被点击
#define kHtmlImageCacheUrlPrefix    @"http://cache.image.url.qoocc.com/"
// 头部图片URL前缀，可用于识别是否是头部图片link被点击
#define kHtmlUserHeadUrlPrefix      @"http://www.qoocc.com/header"

/**
 *  HTML 格式化转换器
 */
@interface HTMLFormatConverter : NSObject

@property (nonatomic, readonly) NSMutableArray *imageURLs;    // 格式化后的所有img标签中的src地址

@property (nonatomic, assign) CGFloat fontSize;         // 文字字体大小
@property (nonatomic, strong) UIColor *textColor;       // 文字字体颜色

/**
 *  HTML 格式化转换
 *      1. 修改文本字体大小（根据应用内的设置）
 *      2. 修改文本颜色 （根据应用内的设置）
 *      3. 增加图片的慢加载
 *
 *  @param content HTML内容
 *  @return 返回转换后的内容
 */
- (NSString *)htmlFormatConver:(NSString *)content;

/**
 *  将webView中的img标签默认图，转换成实际的图
 *  注意：
 *  1. 该webView加载的是 经过htmlFormatConver: 处理的html流；
 *  2. 在webView的回掉 - (void)webViewDidFinishLoad:(UIWebView *)webView; 中掉用此方法；
 */
- (BOOL)revertImageForWebView:(UIWebView *)webView;

@end
