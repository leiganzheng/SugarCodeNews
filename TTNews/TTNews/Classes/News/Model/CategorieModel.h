//
//  CategorieModel.h
//  TTNews
//
//  Created by AlanWoo on 16/6/20.
//  Copyright © 2016年 瑞文戴尔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>
@interface CategorieModel : JSONModel
@property (nonatomic,strong) NSString<Optional> *cat_ID;
@property (nonatomic,strong) NSString<Optional> *cat_name;
@end
