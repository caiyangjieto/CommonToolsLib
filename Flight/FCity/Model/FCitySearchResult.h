//
//  FCitySearchResult.h
//  Flight
//
//  Created by caiyangjieto on 16-5-20.
//  Copyright (c) 2014年 just. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSearchCity;
@class FSearchCountry;

@interface FCitySearchResult : NetToolResult

@property (nonatomic, strong, readonly, getter = cities)   NSArray QiniskyArray(cities,FSearchCity);  // 匹配到的城市列表
@property (nonatomic, strong, readonly, getter = countrys) FSearchCountry *country;                   // 匹配到的城市列表

@end


@interface FSearchCity : NSObject

@property (nonatomic, strong, readonly, getter = displayName)   NSString *displayname;          // 显示值
@property (nonatomic, strong, readonly, getter = realName)      NSString *nameZh;               // 实际值
@property (nonatomic, strong, readonly, getter = country)       NSString *country;              // 国家
@property (nonatomic, strong, readonly, getter = isInter)       NSNumber *cityLabel;            // 是否是国际航线

@end

@interface FSearchCountry : NSObject

@property (nonatomic, strong, readonly, getter = countryName)   NSString *nameZh;               // 实际值
@property (nonatomic, strong, readonly, getter = cities)        NSArray QiniskyArray(cities,FSearchCity); // 所属国家推荐城市

@end