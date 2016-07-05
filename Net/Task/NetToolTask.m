//
//  NetToolTask.m
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import "NetToolTask.h"
#import "NetToolCache.h"
#import "NetToolUtility.h"
#import "NetToolManager.h"


@implementation NetToolTask

+ (NetToolDownLoader *)postSearch:(NSString *)service
                         forParam:(NSString *)paramRequest
                         forCache:(BOOL)haveCache
                        withDelgt:(id<NetworkPtc>)delegate
                       withResult:(Class)result
                      withCusInfo:(id)customInfo;
{
 
    // 分配网络请求对象和代理
    NetToolDelegate *netToolDelegate = [[NetToolDelegate alloc] init];
    [netToolDelegate setNeedCache:haveCache];
    [netToolDelegate setService:service];
    [netToolDelegate setDelegate:delegate];
    [netToolDelegate setNetToolResult:[[result alloc] init]];
    [netToolDelegate setCustomInfo:customInfo];
    
    NSString *domain = [[service componentsSeparatedByString:@":"] objectAtIndex:0];
    
    NSMutableString *httpString = [[NSMutableString alloc] initWithFormat:@"http://%@",service];
    
    // 是否使用缓存
    if(haveCache)
    {
        NSString *key = [[NetToolCache getInstance] setupCacheKey:service];
        NSString *content = [[NetToolCache getInstance] getCacheWithKey:key];
        
        if (!IsStrEmpty(content))
        {
            //解析model
            NSDictionary* dict = [NSDictionary dictionaryWithJsonString:content];
            [netToolDelegate.netToolResult parseAllNetResult:dict];
            
            // 回调
            if([[netToolDelegate delegate] respondsToSelector:@selector(getSearchNetBack:forInfo:)])
            {
                [[netToolDelegate delegate] getSearchNetBack:netToolDelegate.netToolResult
                                                     forInfo:[netToolDelegate customInfo]];
            }
            return nil;
        }
    }
    
    //加密
    NSString *postString = paramRequest;//[NetToolUtility Encode:paramRequest key:@"null"];
    
    
    //=====================================================================
    //请求头
    //=====================================================================
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)[postData length]];
    
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:httpString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    [urlRequest setValue:domain forHTTPHeaderField:@"Host"];
    [urlRequest setHTTPMethod: @"POST"];
    [urlRequest setValue: postLength forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue: @"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody: postData];
    
    // 发送网络请求
    NetToolDownLoader *urlConnection = [[NetToolDownLoader alloc] initWithRequest:urlRequest];
    [[NetToolManager getInstance] addConnection:urlConnection andDelegate:netToolDelegate];
    
    return urlConnection;
}

+ (void)searchReturnData:(NetToolDelegate *)netToolDelegate result:(NSData *)result;
{
    id delegate = netToolDelegate.delegate;
    if (delegate && [delegate respondsToSelector:@selector(getSearchNetBack:forInfo:)])
    {
        //解压
        NSData *receivedData = result;//[result uncompressZippedData];
        NSString *responseText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        
        //解密
        //responseText = [NetToolUtility Decode:responseText key:@"null"];
        NSLog(@"result:%@",responseText);
        
        //缓存
        if (netToolDelegate.needCache)
        {
            NSString *key = [netToolDelegate service];
            key = [[NetToolCache getInstance] setupCacheKey:key];
            [[NetToolCache getInstance] setCache:responseText key:key];
        }
        
        //解析model
        NSDictionary* dict = [NSDictionary dictionaryWithJsonString:responseText];
        [netToolDelegate.netToolResult parseAllNetResult:dict];
        
        //回调
        [delegate getSearchNetBack:netToolDelegate.netToolResult forInfo:netToolDelegate.customInfo];
    }
    
    return ;
}


+ (void)cancelNetRequestsWithTarget:(id)target
{
    [[NetToolManager getInstance] removeTarget:target];
}

+ (void)cancelNetRequestsWithSearch:(NSString *)service
{
    [[NetToolManager getInstance] removeService:service];
}

+ (void)cancelNetRequestsWithDownLoader:(NetToolDownLoader *)downLoader
{
    [[NetToolManager getInstance] removeConnection:downLoader];
}

@end




