//
//  FlightNetTask.h
//  Flight
//
//  Created by caiyangjieto on 16/6/12.
//  Copyright © 2016年 just. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightNetTask : NSObject

/**
 *
 *  @param service
 *  @param param
 *  @param haveCache  表示本次请求是否需要在缓存中查找
 *
 *  @return 生成的NetToolDownLoader是否成功
 */
+ (BOOL)postSearch:(NSString *)service
          forParam:(NSObject *)param
          forCache:(BOOL)haveCache
         withDelgt:(id<NetworkPtc>)delegate
        withResult:(Class)result
       withCusInfo:(id)customInfo;


+ (void)cancelNetRequestsWithTarget:(id)target;
+ (void)cancelNetRequestsWithSearch:(NSString *)service;

@end
