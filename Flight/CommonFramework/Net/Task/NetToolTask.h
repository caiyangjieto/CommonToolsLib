//
//  NetToolTask.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetToolDelegate.h"
#import "NetToolDownLoader.h"

@interface NetToolTask : NSObject

/**
 *
 *  @param service
 *  @param param
 *  @param haveCache  表示本次请求是否需要在缓存中查找
 *
 *  @return 生成的NetToolDownLoader对象 如果是缓存就为nil
 */
+ (NetToolDownLoader *)postSearch:(NSString *)service
                         forParam:(NSString *)paramRequest
                         forCache:(BOOL)haveCache
                        withDelgt:(id<NetworkPtc>)delegate
                       withResult:(Class)result
                      withCusInfo:(id)customInfo;


+ (void)searchReturnData:(NetToolDelegate *)netToolDelegate result:(NSData *)result;


+ (void)cancelNetRequestsWithTarget:(id)target;
+ (void)cancelNetRequestsWithSearch:(NSString *)service;
+ (void)cancelNetRequestsWithDownLoader:(NetToolDownLoader *)downLoader;


@end





