//
//  NetToolDownLoader.m
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import "NetToolDownLoader.h"
#import "AFURLConnectionOperation.h"
#import "NetToolManager.h"

@interface NetToolDownLoader ()

@property(nonatomic,strong) AFURLConnectionOperation *operation;

@end

@implementation NetToolDownLoader

// 初始化函数
- (instancetype)initWithRequest:(NSURLRequest *)urlRequest
{
    if((self = [super init]) != nil)
    {
        _operation = [[AFURLConnectionOperation alloc] initWithRequest:urlRequest];
        _request = urlRequest;
        return self;
    }
    
    return nil;
}

- (void)start
{
    @WeakObj(self)
    _operation.completionBlock = ^ {
        @StrongObj(self)
        if (!selfStrong)
            return ;
        
        [selfStrong dealResponseData:selfStrong.operation.responseData];
    };
    [_operation start];
}

- (void)cancel
{
    [_operation cancel];
}

- (void)dealResponseData:(NSData *)data
{
    [[NetToolManager getInstance] finishConnection:self result:data];
}

@end
