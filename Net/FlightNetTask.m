//
//  FlightNetTask.m
//  Flight
//
//  Created by caiyangjieto on 16/6/12.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FlightNetTask.h"
#import "NetToolTask.h"
#import "NetToolDownLoader.h"

@implementation FlightNetTask

+ (BOOL)postSearch:(NSString *)service
          forParam:(NSDictionary *)param
          forCache:(BOOL)haveCache
         withDelgt:(id<NetworkPtc>)delegate
        withResult:(Class)result
       withCusInfo:(id)customInfo;
{
    [NetToolTask postSearch:service forParam:[param jsonPrettyStringEncoded] forCache:haveCache withDelgt:delegate withResult:result withCusInfo:customInfo];
    
    return YES;
}

+ (void)cancelNetRequestsWithTarget:(id)target
{
    [NetToolTask cancelNetRequestsWithTarget:target];
}

+ (void)cancelNetRequestsWithSearch:(NSString *)service
{
    [NetToolTask cancelNetRequestsWithSearch:service];
}

@end
