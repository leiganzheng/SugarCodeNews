//
//  HttpTool.m
//  WBZhiHuDailyPaper
//
//  Created by caowenbo on 15/12/18.
//  Copyright © 2015年 曹文博. All rights reserved.
//

#import "HttpTool.h"
#import <UIKit+AFNetworking.h>
#import <AFHTTPSessionManager.h>
@implementation HttpTool

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure
{

    AFHTTPSessionManager   *mgr = [AFHTTPSessionManager manager];
    [mgr GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"responseObject:%@",error);

        if (failure) {
            failure(error);
        }

    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure
{
    
    AFHTTPSessionManager   *mgr = [AFHTTPSessionManager manager];
    [mgr POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        
    }];
}


@end
