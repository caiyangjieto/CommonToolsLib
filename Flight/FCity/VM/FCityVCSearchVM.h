//
//  FCityVCSearchDataSource.h
//  Flight
//
//  Created by qitmac000224 on 15/7/8.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//
//  迁移时间 2015-10-23 15:00

#import <Foundation/Foundation.h>
#import "FCityVC.h"
#import "FCityVCModel.h"
#import "FDBManager.h"

@protocol FCityDataQueryDelgt <NSObject>

- (void)queryCityDataBack:(BOOL)isResult;                //搜索城市的回调
- (void)queryCountryDataBack:(BOOL)isResult;             //搜索国家的回调

@end

@interface FCityVCSearchVM : NSObject

@property (nonatomic, strong) NSMutableArray *arraySearchResult;            // 城市列表
@property (nonatomic, weak) id<FCityDataQueryDelgt> delegate;


- (id)initWithHotCityType:(FCityHotType)fCityHotType;

- (FCityVCModel *)getCityListTableData;

//搜索城市
- (void)startSearchSuggestCity:(NSString *)searchKeyText;

//搜索国家
- (void)startSearchSuggestCountry:(NSString *)countryName arrayHotCity:(NSArray *)citys;

@end
