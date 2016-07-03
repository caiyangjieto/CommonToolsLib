//
//  HUserLocationResult.h
//  QunariPhone
//
//  Created by bruce on 12-12-13.
//  Copyright (c) 2012年 Qunar.com. All rights reserved.
//

//  迁移时间 2015-10-23 15:00
//  为适应解耦需要，从CommonBusiness拷贝而来

@interface FAddressDetail : NSObject

@property (nonatomic, strong, readonly, getter = city) NSString *city;                      // 城市
@property (nonatomic, strong, readonly, getter = cityUrl) NSString *cityUrl;                // 城市Url
@property (nonatomic, strong, readonly, getter = cityName) NSString *cityName;              // 城市名称
@property (nonatomic, strong, readonly, getter = cityCode) NSNumber *cityCode;              // 城市编号
@property (nonatomic, strong, readonly, getter = district) NSString *district;              // 区
@property (nonatomic, strong, readonly, getter = province) NSString *province;              // 省
@property (nonatomic, strong, readonly, getter = street) NSString *street;                  // 街道
@property (nonatomic, strong, readonly, getter = streetNumber) NSString *streetNumber;      // 街道号
@property (nonatomic, strong, readonly, getter = parentCityUrl) NSString *parentCityUrl;    // 父级城市 可能为空
@property (nonatomic, strong, readonly, getter = parentCityName) NSString *parentCityName;  // 父级城市 可能为空

@end

@interface FUserLocationResult : NetToolResult

@property (nonatomic, strong, readonly, getter = address) NSString *address;                // 地址
@property (nonatomic, strong, readonly, getter = addressDetail) FAddressDetail *addrDetail;  // 地址信息
@property (nonatomic, strong, readonly, getter = business) NSString *business;              // 商圈
@property (nonatomic, strong, readonly, getter = arraySurround) NSArray *surrPoi;           // 周边

@end



