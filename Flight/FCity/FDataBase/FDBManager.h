//
//  FDBManager.h
//  Flight
//
//  Created by caiyangjietos on 15-5-19.
//  Copyright (c) 2015年 just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FCityPhysicalMark.h"
#import "FNationPhyscialMark.h"

typedef NS_ENUM(NSUInteger, TableType) {
    TableTypeCity = 1,//城市表
    TableTypeNation,//国家表
};

typedef NS_ENUM(NSUInteger, HotCityType) {
    HotCityTypeDomesticDepart,//国内出发热门
    HotCityTypeDomesticArrival,//国内到达热门
    HotCityTypeInternationalDepart,//国际出发热门
    HotCityTypeInternationalArrival,//国际到达热门
};

#define _FMDATABASEQUEUE_H_

#ifdef _FMDATABASEQUEUE_H_
@class FMDatabaseQueue;
#endif

@interface FDBManager : NSObject
{
    FMDatabase                         *dbObject;          // DB对象
    NSString                           *dbFullPath;        // DB文件的完整路径
#ifdef _FMDATABASEQUEUE_H_
    FMDatabaseQueue                    *queue;             // 多线程操作保护
#endif
}

/**
 * 函数说明：DB 操作唯一入口
 * 参数说明：N/A
 * 返回值：  FDBManager 唯一实例
 */
+ (FDBManager *)getInstance;

/**
 * 函数说明：根据账号打开对应的数据库DB文件,不存在则创建对应的DB文件
 * 参数说明：NSString*  账号id
 * 返回值：  N/A
 */
- (void)openFlightDB:(NSString *)accountId;

/**
 * 函数说明：根据账号删除对应的数据库DB文件
 * 参数说明：NSString*  账号id
 * 返回值：  N/A
 */
- (void)removeFlightDB:(NSString *)accountId;

/**
 * 函数说明：Close DB 操作唯一入口 退出程序时调用
 * 参数说明：N/A
 * 返回值：  N/A
 */
+ (void)closeFlightDB;

/**
 * 函数说明：关闭数据库
 * 参数说明：N/A
 * 返回值：  N/A
 */
- (void)closeFlightDB;

#pragma mark - 城市表查询
/**
 * 函数说明：返回大陆城市 港澳台
 */
- (NSArray *)selectDomesticCity;
/**
 * 函数说明：返回国际城市 港澳台
 */
- (NSArray *)selectInternationalCity;
/**
 * 函数说明：按照城市查询城市信息
 */
- (NSArray *)selectCityName:(NSString *)cityName;
/**
 * 函数说明：返回城市数组
 */
- (NSArray *)selectArrayWithSearchID:(NSString *)cityName;
/**
 * 函数说明：按照国家查询城市信息
 */
- (NSArray *)selectCityCountryName:(NSString *)countryName;

#pragma mark - 城市表更新
/**
 * 函数说明：插入一条城市
 */
- (void)insertCity:(FCityPhysicalMark *)mark;

/**
 * 函数说明：删除城市
 */
- (void)deleteCity:(NSNumber *)cityId;

/**
 * 函数说明：更新城市  不存在CID就会insert
 */
- (void)updateCity:(FCityPhysicalMark *)mark;

#pragma mark - 国家表
/**
 * 函数说明：按国家名查询所有国家信息
 */
- (NSArray *)selectNation:(NSString *)countryName;
/**
 * 函数说明：插入一条国家
 */
- (void)insertNation:(FNationPhyscialMark *)mark;

#pragma mark - 版本号
/**
 * 函数说明：设置本地城市列表数据库版本号
 */
- (void)setCityDBVersion:(NSString *)version;

/**
 * 函数说明：获取本地城市列表数据库版本号
 */
- (NSString *)getCityDBVersion;

/**
 * 函数说明：设置发布城市列表数据库App版本号
 */
- (void)setCityDBAppVersion:(NSString *)version;

/**
 * 函数说明：获取发布城市列表数据库App版本号
 */
- (NSString *)getCityDBAppVersion;
/**
 * 函数说明：保存本地城市列表数据库版本号
 */
- (void)saveCityDBVersion;


@end
