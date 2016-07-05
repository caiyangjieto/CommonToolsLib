//
//  NetToolDownLoader.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetToolDownLoader : NSObject

@property (readonly, nonatomic, strong) NSURLRequest *request;

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest;

- (void)start;
- (void)cancel;

@end
