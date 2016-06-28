//
//  QN_DefaultImg.h
//  QooccNews
//
//  Created by 王顺强 on 14-6-18.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface QN_DefaultImg : NSObject

@property (nonatomic,strong) UIImage *defaultImg;
@property (nonatomic,assign) BOOL tapToDownload;

//新闻明细默认图片
+ (QN_DefaultImg *)newsDetailDefaultImageWithImageSize:(CGSize)imgSize;

@end
