//
//  FCity.m
//  Flight
//
//  Created by HongPu on 14-5-20.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "FCity.h"
#import "FDBManager.h"

@implementation FCity

+ (FCityNationType)checkCityNationType:(NSString *)cityName
{
    if (IsStrEmpty(cityName))
    {
        return FCityNULLType;
    }
    
    [[FDBManager getInstance] openFlightDB:nil];
    NSArray *arrayCitys = [[FDBManager getInstance] selectArrayWithSearchID:cityName];
    [[FDBManager getInstance] closeFlightDB];
    
    //searchCity 是唯一存在
    FCityPhysicalMark *city = [arrayCitys objectAtIndexSafe:0];
    NSString *country = [city country];
    
    if (IsStrEmpty(country))
    {
        return FCityNULLType;
    }
    
    return [self checkCountryNationType:country];
}

+ (FCityNationType)checkCountryNationType:(NSString *)countryName
{
    if (IsStrEmpty(countryName))
    {
        return FCityNULLType;
    }
    
    if ([countryName isEqualToString:@"中国"])
    {
        return FCityDomesticType;
    }
    else if ([countryName hasPrefix:@"中国"])
    {
        return FCitySpecialType;
    }
    
    return FCityInterType;
}

+ (BOOL)checkInterCity:(NSString *)city
{
    FCityNationType cityType = [self checkCityNationType:city];
    
    // 国际城市和国际国内共有城市都算国际  兼容无法的情况算国际
    BOOL isInterCity = (cityType == FCityInterType) || (cityType == FCitySpecialType) || (cityType == FCityNULLType);
    return isInterCity;
}

+ (BOOL)checkDomesticCity:(NSString *)city
{
    FCityNationType cityType = [self checkCityNationType:city];
    
    BOOL isDomesticCity = (cityType == FCityDomesticType) || (cityType == FCitySpecialType);
    return isDomesticCity;
}

// 检查是否是国际航线
+ (BOOL)checkInterLine:(NSString *)depCity arrCity:(NSString *)arrCity
{
    // 只要有一个城市是国际城市，就算该航线为国际航线
    BOOL isInterLine = [self checkInterCity:depCity] || [self checkInterCity:arrCity];
    
    return isInterLine;
}


@end
