//
//  NewsDetailURLProtocol.m
//  QooccNews
//
//  Created by LiuYu on 14/10/28.
//  Copyright (c) 2014年 巨细科技. All rights reserved.
//

#import "NewsDetailURLProtocol.h"
#import "SDImageCache+NSDataToDisk.h"

#define kLogURLProtocol(...) ;//NSLog(__VA_ARGS__)
#define kKeyHasProcess @"HasProcess"

NSString *NotificationNewsDetailLoadImageFinish = @"NotificationNewsDetailLoadImageFinish";

@interface NewsDetailURLProtocol () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *datas;

@end


@implementation NewsDetailURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // 目前只处理 jpg png gif 三种图片
    NSString *urlString = request.URL.absoluteString;
    NSString *extension = [urlString.pathExtension lowercaseString];
    if ([extension isEqual:@"jpg"] || [extension isEqual:@"png"] || [extension isEqual:@"gif"]) {
        if ([request valueForHTTPHeaderField:kKeyHasProcess] == nil) {
            kLogURLProtocol(@"加载URL:%@", urlString);
            return YES;
        }
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    kLogURLProtocol(@"创建了一个NSURLProtocal");
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (NSMutableData *)datas {
    if (!_datas) {
        _datas = [NSMutableData data];
    }
    return _datas;
}

- (void)startLoading {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:self.request.URL
                                                                          cachePolicy:self.request.cachePolicy
                                                                      timeoutInterval:self.request.timeoutInterval];
    [mutableURLRequest setAllHTTPHeaderFields:[self.request allHTTPHeaderFields]];

    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
    [mutableURLRequest setValue:@"Liu" forHTTPHeaderField:kKeyHasProcess];
    self.datas = nil;
    self.connection = [NSURLConnection connectionWithRequest:mutableURLRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    // Thanks to Nick Dowell https://gist.github.com/1885821
    if (response != nil) {
        NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:request.URL
                                                                              cachePolicy:request.cachePolicy
                                                                          timeoutInterval:request.timeoutInterval];
        [mutableURLRequest setAllHTTPHeaderFields:[request allHTTPHeaderFields]];
        
        // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
        [mutableURLRequest setValue:nil forHTTPHeaderField:kKeyHasProcess];
        if (self.connection == connection) {
            [self.client URLProtocol:self wasRedirectedToRequest:mutableURLRequest redirectResponse:response];
        }
        return mutableURLRequest;
    }
    else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.connection == connection) {
        [self.datas appendData:data];
    }
    
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.connection == connection) {
        kLogURLProtocol(@"缓存数据 key:%@, value leng:%d", connection.currentRequest.URL.absoluteString, self.datas.length);
        [[SDImageCache sharedImageCache] storeDataToDisk:self.datas forKey:connection.currentRequest.URL.absoluteString];
    }
    
    [self.client URLProtocolDidFinishLoading:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewsDetailLoadImageFinish object:nil];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

@end
