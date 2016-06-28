//
//  HTMLFormatConverter.m
//  QooccNews
//
//  Created by LiuYu on 14-9-26.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import "HTMLFormatConverter.h"
#import "QN_DefaultImg.h"
#import "SDImageCache+NSDataToDisk.h"
#import "NewsDetailURLProtocol.h"
#import "CyToolDefine.h"
#import "QNTools.h"
@interface HTMLFormatConverter ()

@end


@implementation HTMLFormatConverter {
    BOOL _revertImageIsFinished; // 完成Revert图片
}
@synthesize imageURLs = _imageURLs;

#pragma mark - Getter
- (NSMutableArray *)imageURLs
{
    if (!_imageURLs) _imageURLs = [NSMutableArray array];
    return _imageURLs;
}

#pragma mark - 将webView中的img标签默认图，转换成实际的图
/**
 *  将webView中的img标签默认图，转换成实际的图
 *  注意：
 *  1. 必须设置 self.imageDefault；
 *  2. 该webView加载的是 经过htmlFormatConver: 处理的html流；
 *  3. 在webView的回掉 - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
        中掉用此方法；
 */
- (BOOL)revertImageForWebView:(UIWebView *)webView
{
    if (_revertImageIsFinished || (webView == nil)) return NO;
    
//    BOOL allowRequest = [QNTools checkWifiAbility] || [kUserDefaults boolForKey:kStorePictureLoadSwitchKey];
//    for (int i = 0; i < self.imageURLs.count; i++) {
//        NSData *imageData = [[SDImageCache sharedImageCache] dataFromDiskCacheForKey:self.imageURLs[i]];
//        NSString *extension = ((NSString *)self.imageURLs[i]).pathExtension;
//        if (imageData && imageData.length > 10) {
//            NSString *revertImageJS = [NSString stringWithFormat:@"iBase.Id('%@%d').src = 'data:image/%@;base64,%@';", kImageTagIdPrefix, (i + 1), extension, [imageData base64Encoding]];
//            [webView stringByEvaluatingJavaScriptFromString:revertImageJS];
//        }
//        else {
//            if (allowRequest) {
//                NSString *revertImageJS = [NSString stringWithFormat:@"iBase.Id('%@%d').src = '%@';", kImageTagIdPrefix, (i + 1), self.imageURLs[i]];
//                [webView stringByEvaluatingJavaScriptFromString:revertImageJS];
//            }
//        }
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewsDetailLoadImageFinish object:nil];
//    _revertImageIsFinished = YES;
    return YES;
}

#pragma mark - HTML 格式化转换
/**
 *  HTML 格式化转换
 *      1. 修改文本字体大小（根据应用内的设置）
 *      2. 修改文本颜色 （根据应用内的设置）
 *      3. 增加图片的慢加载
 *
 *  @param content HTML内容
 *  @return 返回转换后的内容
 */
- (NSString *)htmlFormatConver:(NSString *)content
{
    // 清空之前的数据
    [self.imageURLs removeAllObjects];
    _revertImageIsFinished = NO;
    
    // 输入太短，或不存在
    if (!content || content.length < 4) { return @""; }
    
    // 格式化扫描器
    NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    NSScanner *scanner = [[NSScanner alloc] initWithString:content];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setCaseSensitive:YES];
    
    // 输出结果保存
    NSMutableString *result = [NSMutableString string];
    NSString *str = nil;
    NSString *tagName = nil;
    
    // 获取文本颜色的二进制
    NSString *fontColor = nil;
    if (self.textColor) {
        CGFloat red = 0, green = 0, blue = 0;
        [self.textColor getRed:&red green:&green blue:&blue alpha:nil];
        fontColor = [NSString stringWithFormat:@"#%x%x%x", (unsigned int)(red*255), (unsigned int)(green*255), (unsigned int)(blue*255)];
    }
    
    BOOL beginNewsText = NO; // 遇到 div 标签，并且 id == @"newsText" 才开始解析图片
    
    // 开始遍历标签，并且格式化标签
    do {
        // 扫描到标签的开始符号，并把 "<" 之前的所有内容全部添加到结果中
        if ([scanner scanUpToString:@"<" intoString:&str]) {
            [result appendString:str];
            str = nil;
        }
        
        // 扫描停在一个标签/意见或空白
        if ([scanner scanString:@"<" intoString:&str]) {
            // 注释标签，过滤
            if ([scanner scanString:@"!--" intoString:NULL]) {
                [scanner scanUpToString:@"-->" intoString:NULL];
                [scanner scanString:@"-->" intoString:NULL];
            }
            else {
                [result appendString:str];
                
                // 结束标签
                if ([scanner scanString:@"/" intoString:&str]) {
                    [result appendString:str];
                }
                // 开始标签
                else if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
                    tagName = [tagName lowercaseString];
                    // 找到标签的 样式
                    if ([scanner scanString:@">" intoString:&str] || [scanner scanUpToString:@">" intoString:&str]) {
                        
                        // 找到图片标签
                        if (beginNewsText && ([tagName isEqual:@"img"] || ([tagName isEqual:@"input"] && [self isTagWithTagName:@"image" forInput:str]))) {
//很奇怪以下三行代码会删除img父节点的样式，弄不懂有什么用意－－－－－－by GuJinyou
                            [scanner scanString:@">" intoString:NULL];

                            // 是以 "</**>" 结束，而不是以 "/>" 结束的标签
                            if (![str hasSuffix:@"/"]) {
                                [scanner scanUpToString:@">" intoString:NULL];
                                [scanner scanString:@">" intoString:NULL];
                            }
                            
                            [result setString:[result substringToIndex:(result.length - 1)]];
                            
                            [self imgTagFormatConver:str forResult:result];
                        }
                        // head 标签增加本地js
                        else if([tagName isEqualToString:@"head"]){
                            [result appendString:tagName];
                            [result appendString:str];
                            [result appendString:@"<script src=\"FadeOutInJS.js\"></script>"];
                        }
                        // div 标签增加文字的大小和颜色配置
                        else if ([tagName isEqualToString:@"div"]){
//                            [result appendString:tagName];
//                            NSString *divId = [self valueOfName:@"id" inTag:str];
//                            if (divId.isNotEmpty && [divId isEqualToString:@"newsText"]) {
//                                [result appendFormat:@" style=\"font-size:%fpt;line-height:1.45em;margin-left:15px;margin-right:15px;font-family: STHeiti,Arial;text-align:justify;color:%@;\" ", self.fontSize, fontColor];
//                                beginNewsText = YES;
//                            }
//                            [result appendString:str];
                        }
                        // link 标签，需要增加css样式
                        else if ([tagName isEqualToString:@"link"]) {
                            [result appendString:tagName];
                            
                            NSString *linkId = [self valueOfName:@"id" inTag:str];
                            NSString *linkHref = [self valueOfName:@"href" inTag:str];
                            
//                            if (linkId.isNotEmpty && [linkId isEqualToString:@"newsLink"] && linkHref.isNotEmpty) {
//                                str = [str stringByReplacingOccurrencesOfString:linkHref withString:(kIsShowModeNight ? @"news_night.css" : @"news.css")];
//                            }
                            
                            [result appendString:str];
                        }
                        // 其他标签不做修改，直接原样添加即可
                        else {
                            [result appendString:tagName];
                            [result appendString:str];
                        }
                    } // ([scanner scanString:@">" intoString:&str] || [scanner scanUpToString:@">" intoString:&str])
                } // if ([scanner scanString:@"/" intoString:&str]) else if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName])
            } // if ([scanner scanString:@"!--" intoString:NULL]) else
        } // if ([scanner scanString:@"<" intoString:&str])
        
    } while (![scanner isAtEnd]);  // do
    
    return result;
}

// 获取标签里的属性
- (NSString *)valueOfName:(NSString *)name inTag:(NSString *)tagContent
{
//    if (tagContent.isNotEmpty && name.isNotEmpty) {
//        NSString *pattern = [NSString stringWithFormat:@"\\s+[^>]*?%@\\s*=\\s*(\'|\")(.*?)\\1[^>]*?\\/?\\s*", name];
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
//        
//        if (regex != nil) {
//            NSTextCheckingResult *firstMatch = [regex firstMatchInString:tagContent options:0 range:NSMakeRange(0, [tagContent length])];
//            
//            if (firstMatch && firstMatch.numberOfRanges == 3) {
//                NSRange resultRange = [firstMatch rangeAtIndex:2];
//                
//                // 从urlString当中截取数据
//                NSString *result = [tagContent substringWithRange:resultRange];
//                
//                if ([name isEqualToString:@"width"] || [name isEqualToString:@"height"]) {
//                    result = [result lowercaseString];
//                    return [result stringByReplacingOccurrencesOfString:@"px" withString:@""];
//                }
//                
//                //输出结果
//                return result;
//            }
//        }
//    }
    
    return nil;
}

// 判断input内容是否为 tagName 标签
- (BOOL)isTagWithTagName:(NSString *)tagName forInput:(NSString *)input
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:input];
    [scanner setCharactersToBeSkipped:nil];
    [scanner setCaseSensitive:YES];
    
    NSString *type = nil;
    if ([scanner scanUpToString:@"type" intoString:NULL]) {
        [scanner scanUpToString:@"\"" intoString:NULL];
        [scanner scanString:@"\"" intoString:NULL];
        [scanner scanUpToString:@"\"" intoString:&type];
        // 删除前面和后面的空格和换行符
//        type = [[type stringByTrimmingLeadingWhitespaceAndNewlineCharacters] stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    }
    
    return [type isEqualToString:tagName];
}

// 格式化img标签, 全部转换成本地的默认图片
// 将格式化的结果添加到 result中去，将格式化的图片增加到imageURLs中
- (void)imgTagFormatConver:(NSString *)tagContent forResult:(NSMutableString *)result;
{
//    if (tagContent.isNotEmpty && result) {
//        NSString *imgSrc = [self valueOfName:@"src" inTag:tagContent];
//        NSString *imgWidth = [self valueOfName:@"width" inTag:tagContent];
//        NSString *imgHeight = [self valueOfName:@"height" inTag:tagContent];
//      
//        if (imgSrc) {
//            [self.imageURLs addObject:imgSrc];
//            NSInteger idIndex = self.imageURLs.count;
//            
//            NSString *styles = kIsShowModeNight ? @"filter:alpha(opacity=60); -moz-opacity:0.6; -khtml-opacity: 0.6; opacity: 0.6;" : @"";
//
//            UIScreen *screen = [UIScreen mainScreen];
//            //css 样式会控制显示左右两边15
//            NSInteger width = CGRectGetWidth(screen.bounds)-30, height = 163; // 所有图片都改成290的宽, 163的高
//            //如果img 标签中设置了宽高，以标签中的高度为准
//            if (imgHeight.isNotEmpty && imgWidth.isNotEmpty) {
//                NSInteger widthInner = [imgWidth integerValue];
//                NSInteger heightInner = [imgHeight integerValue];
//                if (widthInner > 0 && heightInner > 0) {
//                    height = 1.0*width*heightInner/widthInner;
//                }
//            }
//            
//            // 获取默认图片
//            QN_DefaultImg *defaultImgModel = [QN_DefaultImg newsDetailDefaultImageWithImageSize:CGSizeMake(width, height)];
//            NSData        *imageData = UIImageJPEGRepresentation(defaultImgModel.defaultImg, 1);
//            NSString      *imageDataString = [imageData base64Encoding];
//            
//            // 如果标签中没有高度，则不写死高度（如果图片太长，会出现跳动）
//            if (imgHeight) {
//                [result appendFormat:@"<center><img id='%@%@' src='data:image/jpg;base64,%@' imgUrlSrc='%@' style='%@ max-width:%@px;' width='%@' height='%@' onclick='imgClickCallback(this)'/></center>", kImageTagIdPrefix, @(idIndex), imageDataString, imgSrc, styles, @(width), @(width), @(height)];
//            }
//            else {
//                [result appendFormat:@"<center><img id='%@%@' src='data:image/jpg;base64,%@' imgUrlSrc='%@' style='%@ max-width:%@px;' width='%@' onclick='imgClickCallback(this)'/></center>", kImageTagIdPrefix, @(idIndex), imageDataString, imgSrc, styles, @(width), @(width)];
//            }
//        }
//    }
}

@end
