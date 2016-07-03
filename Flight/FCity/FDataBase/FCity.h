//
//  FCity.h
//  Flight
//
//  Created by caiyangjieto on 16-5-20.
//  Copyright (c) 2014年 just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCitySelectItemInfo.h"

//顺序不能修改
typedef NS_ENUM(NSUInteger, FCityNationType) {
    FCityNULLType       = 0x00,//无法判断
    FCityDomesticType   = 0x01,//国内城市
    FCityInterType      = 0x10,//国际城市
    FCitySpecialType    = 0x11,//港澳台
};


@interface FCity : NSObject

// 检查城市类型
+ (FCityNationType)checkCityNationType:(NSString *)cityName;
+ (FCityNationType)checkCountryNationType:(NSString *)countryName;


+ (BOOL)checkInterCity:(NSString *)city;
+ (BOOL)checkDomesticCity:(NSString *)city;

+ (BOOL)checkInterLine:(NSString *)depCity arrCity:(NSString *)arrCity;

@end
