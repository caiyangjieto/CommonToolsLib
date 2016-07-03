//
//  NetToolCache.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetToolCache : NSObject

@property (nonatomic, assign) NSTimeInterval   cacheTimeInterval;           // 缓存时间 默认5分钟

+ (NetToolCache *)getInstance;

- (NSString *)setupCacheKey:(NSString *)server;

- (NSString *)getCacheWithKey:(NSString *)key;
- (void)setCache:(NSString *)content key:(NSString *)key;

@end
