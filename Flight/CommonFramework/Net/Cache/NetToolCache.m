//
//  NetToolCache.m
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import "NetToolCache.h"

@interface NetToolCache ()

@property(nonatomic,strong) NSCache *dictContentCache;      //内容缓存
@property(nonatomic,strong) NSCache *dictTimeIntervalCache; //时间戳缓存

@end

@implementation NetToolCache

+ (NetToolCache *)getInstance
{
    static NetToolCache *sharedNetToolCacheInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetToolCacheInstance = [[super allocWithZone:NULL] init];
        sharedNetToolCacheInstance.dictContentCache = [[NSCache alloc] init];
        sharedNetToolCacheInstance.dictTimeIntervalCache = [[NSCache alloc] init];
        
        sharedNetToolCacheInstance.cacheTimeInterval = 5 * 60 * 1.0 ;
        
    });
    
    return sharedNetToolCacheInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 对外接口
- (NSString *)setupCacheKey:(NSString *)server
{
    return server;
}

- (NSString *)getCacheWithKey:(NSString *)key
{
    NSDate *timeInterval = [_dictTimeIntervalCache objectForKey:key];
    NSTimeInterval old = [timeInterval timeIntervalSince1970];
    NSTimeInterval new = [[NSDate date] timeIntervalSince1970];
    
    BOOL isAvaild = (new-old-_cacheTimeInterval)>0? NO:YES ;
    
    return isAvaild? [_dictContentCache objectForKey:key] : nil ;
}

- (void)setCache:(NSString *)content key:(NSString *)key
{
    [_dictContentCache setObject:content forKey:key];
    [_dictTimeIntervalCache setObject:[NSDate date] forKey:key];
}

#pragma mark - 辅助函数



@end
