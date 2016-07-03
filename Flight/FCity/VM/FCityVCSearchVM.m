//
//  FCityVCSearchDataSource.m
//  Flight
//
//  Created by qitmac000224 on 15/7/8.
//  Copyright (c) 2015年 just. All rights reserved.
//

#import "FCityVCSearchVM.h"
#import "FCitySearchResult.h"
#import "FUserCityRecord.h"

@interface FCityVCSearchVM ()

@property (nonatomic, assign) FCityHotType              fCityHotType;                  // 热门城市类型

@property (nonatomic, strong) NSString                  *countryName;                  // 国家名
@property (nonatomic, strong) NSMutableArray            *arrayCountrySearchResult;     // 国家搜索城市结果
@property (nonatomic, strong) NSMutableArray            *arrayCountryHotSearchResult;  // 国家搜索热门城市

@property (nonatomic, strong) NSArray                   *arrayDomesticDepart;           // 缓存国内出发热门列表数据
@property (nonatomic, strong) NSArray                   *arrayDomesticArrival;          // 缓存国内到达热门列表数据
@property (nonatomic, strong) NSArray                   *arrayInterDepart;              // 缓存国际出发热门列表数据
@property (nonatomic, strong) NSArray                   *arrayInterArrival;             // 缓存国际到达热门列表数据

@end

@implementation FCityVCSearchVM

- (id)initWithHotCityType:(FCityHotType)fCityHotType
{
    if (self = [super init])
    {
        _fCityHotType = fCityHotType;
    }
    
    return self;
}

- (FCityVCModel *)getCityListTableData
{
    FCityVCModel *data = [[FCityVCModel alloc] init];
    
    // 城市搜索结果
    if (!IsArrEmpty(_arraySearchResult))
    {
        FCityCellInfo *city = [_arraySearchResult objectAtIndexSafe:0];
        NSString *sectionTitle = city.isDataFromNet?@"您要找的是不是：":@"";
        
        [data.arrayIndexName addObject:@"#"];
        [data.arraySectionName addObject:sectionTitle];
        [data.arraySectionCount addObject:@([_arraySearchResult count])];
        [data.arrayCityCellData addObject:_arraySearchResult];
    }
    //只做提示的section
    if(!IsStrEmpty(_countryName) &&
       (!IsArrEmpty(_arrayCountrySearchResult) || !IsArrEmpty(_arrayCountryHotSearchResult)))
    {
        NSString *sectionTitle = [[NSString alloc] initWithFormat:@"*以下为%@对应城市", _countryName];
        
        [data.arraySectionName addObject:sectionTitle];
        [data.arraySectionCount addObject:@0];
        [data.arrayCityCellData addObject:@0];
    }
    
    // 热门城市搜索结果
    if(!IsArrEmpty(_arrayCountryHotSearchResult))
    {
        [data.arrayIndexName addObject:@"热门"];
        [data.arraySectionName addObject:@"热门城市"];
        [data.arraySectionCount addObject:@([_arrayCountryHotSearchResult count])];
        [data.arrayCityCellData addObject:_arrayCountryHotSearchResult];
    }
    
    // 城市列表
    for (NSArray *section in _arrayCountrySearchResult)
    {
        FCityCellInfo *city = [section objectAtIndexSafe:0];
        [data.arrayIndexName addObject:city.sectionTitle];
        [data.arraySectionName addObject:city.sectionTitle];
        [data.arraySectionCount addObject:@([section count])];
        [data.arrayCityCellData addObject:section];
    }
    
    // 大于十个才有索引
    if([data.arrayIndexName count] <= 10)
        data.arrayIndexName = nil;
    
    // 空cell
    if(IsArrEmpty(_arraySearchResult) &&
       IsArrEmpty(_arrayCountryHotSearchResult) &&
       IsArrEmpty(_arrayCountrySearchResult))
    {
        [data.arraySectionCount addObject:@1];
    }
    
    return data;
}

// 发起搜索关键字提示的请求
- (void)startSearchSuggestCity:(NSString *)searchKeyText
{
    @WeakObj(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 分配新的结果
        NSMutableArray *arraySearchResultThread = [[NSMutableArray alloc] init];
        
        selfWeak.countryName = nil;
        
        // 过滤掉空格
        NSString *searchTextTmp = [searchKeyText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        BOOL needSearchNetwork = NO;
        
        if(!IsStrEmpty(searchTextTmp))
        {
            @autoreleasepool
            {
                NSString *keywordLowCase = [searchTextTmp lowercaseString];
                
                // 获取国家名
                NSArray *array = [[FDBManager getInstance] selectNation:keywordLowCase];
                if (!IsArrEmpty(array))
                {
                    selfWeak.countryName = [[array objectAtIndexSafe:0] nameCN];
                }
                
                // 按城市名搜索
                [selfWeak searchCityName:keywordLowCase cityResult:arraySearchResultThread];
                
                // 去除超过个数范围
                if ([arraySearchResultThread count] >kHCityResultMaxNumber )
                {
                    [arraySearchResultThread removeObjectsInRange:NSMakeRange(kHCityResultMaxNumber, [arraySearchResultThread count]-kHCityResultMaxNumber)];
                }
                
                // 判断是否搜索网络
                if(IsArrEmpty(arraySearchResultThread))
                {
                    needSearchNetwork = YES;
                }
            }
        }
        
        // 不需要搜索网络，直接刷新
//        if(needSearchNetwork == NO)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 赋值搜索到得数据
                selfWeak.arraySearchResult = [arraySearchResultThread mutableCopy];
                selfWeak.arrayCountrySearchResult = nil;
                selfWeak.arrayCountryHotSearchResult = nil;
                
                if (selfWeak.delegate && [selfWeak.delegate respondsToSelector:@selector(queryCityDataBack:)])
                {
                    [selfWeak.delegate queryCityDataBack:YES];
                }
                
            });
        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if (selfWeak.delegate && [selfWeak.delegate respondsToSelector:@selector(queryCityDataBack:)])
//                {
//                    [selfWeak.delegate queryCityDataBack:NO];
//                }
//            });
//        }
    });
}

// 仅搜索国家
- (void)startSearchSuggestCountry:(NSString *)countryName arrayHotCity:(NSArray *)citys
{
    @WeakObj(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 分配新的结果
        NSMutableArray *arrayCountrySearchResultThread = [[NSMutableArray alloc] init];
        NSMutableArray *arrayCountryHotSearchResultThread = [[NSMutableArray alloc] init];
        
        // 过滤掉空格
        NSString *searchTextTmp = [countryName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if(!IsStrEmpty(searchTextTmp))
        {
            @autoreleasepool
            {
                selfWeak.countryName = [searchTextTmp lowercaseString];
                
                // 按照国家名搜索
                if (!IsStrEmpty(selfWeak.countryName))
                    [selfWeak searchCountryCity:selfWeak.countryName countryResult:arrayCountrySearchResultThread];
                
                // 匹配到国家，搜索本地热门城市
                if (!IsStrEmpty(selfWeak.countryName) && !IsArrEmpty(arrayCountrySearchResultThread))
                {
                    [selfWeak searchCountryHotCity:selfWeak.countryName hotResult:arrayCountryHotSearchResultThread];
                    
                    //网络返回的热门城市
                    if (IsArrEmpty(arrayCountryHotSearchResultThread))
                    {
                        [selfWeak setupHotCityArray:citys hotResult:arrayCountryHotSearchResultThread];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 赋值搜索出来的数据
            selfWeak.arrayCountrySearchResult = [arrayCountrySearchResultThread mutableCopy];
            selfWeak.arrayCountryHotSearchResult = [arrayCountryHotSearchResultThread mutableCopy];
            
            if (selfWeak.delegate && [selfWeak.delegate respondsToSelector:@selector(queryCountryDataBack:)])
            {
                [selfWeak.delegate queryCountryDataBack:YES];
            }
            
        });
    });
}

- (void)setArraySearchResult:(NSMutableArray *)arraySearchResult
{
    //一旦外部设置搜索结果，意味着从头开始
    _arraySearchResult = arraySearchResult;
    _arrayCountrySearchResult = nil;
    _arrayCountryHotSearchResult = nil;
}

#pragma mark - 搜索函数

// 按城市名搜索
- (void)searchCityName:(NSString *)cityName cityResult:(NSMutableArray *)arraySearchResult
{
    NSArray *array = [[FDBManager getInstance] selectCityName:cityName];
    
    for (FCityPhysicalMark *mark in array)
    {
        FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
        [self setupCityDesc:fCityCellInfo cityName:cityName cityFItem:mark];
        [arraySearchResult addObjectSafe:fCityCellInfo];
    }
}

// 按国家名搜索
- (void)searchCountryCity:(NSString *)countryName countryResult:(NSMutableArray *)arrayCountrySearchResultThread
{
    NSArray *array = [[FDBManager getInstance] selectCityCountryName:countryName];
    
    NSString *preSection = @"";
    NSMutableArray *result;
    for (FCityPhysicalMark *mark in array)
    {
        FCityCellInfo *fCityCellInfo = [self setupCityCellResult:mark];
        
        NSString *nowSection = fCityCellInfo.sectionTitle;
        if ([preSection isEqualToString:nowSection])
        {
            [result addObject:fCityCellInfo];
        }
        else
        {
            preSection = nowSection;
            result = [NSMutableArray array];
            [result addObject:fCityCellInfo];
            [arrayCountrySearchResultThread addObject:result];
        }
    }
}

// 搜索热门城市
- (void)searchCountryHotCity:(NSString *)countryName hotResult:(NSMutableArray *)arrayCountryHotSearchResultThread
{
#warning caiyangjieto
    // 国内
    NSArray *arrayInHotCity = [self getHotCityArray:FCityVCTabTypeDomesticCity];
    for(NSDictionary *mark in arrayInHotCity)
    {
        NSString *hotCountryName = nil;//[FStorageManager fHotCityCountry:mark];
        if ([countryName isEqualToString:hotCountryName])
        {
            NSString *hotCityName = nil;//[FStorageManager fHotCityName:mark];
            
            FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
            [fCityCellInfo setDisplayText:hotCityName];
            [fCityCellInfo setSearchName:hotCityName];
            [fCityCellInfo setSectionTitle:@"热门"];
            [fCityCellInfo setCountry:hotCountryName];
            
            [arrayCountryHotSearchResultThread addObject:fCityCellInfo];
        }
    }
    
    // 国际
    NSArray *arrayOutHotCity = [self getHotCityArray:FCityVCTabTypeInternationalCity];
    for(NSDictionary *mark in arrayOutHotCity)
    {
        NSString *hotCountryName = nil;//[FStorageManager fHotCityCountry:mark];
        if ([countryName isEqualToString:hotCountryName])
        {
            NSString *hotCityName = nil;//[FStorageManager fHotCityName:mark];
            
            FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
            [fCityCellInfo setDisplayText:hotCityName];
            [fCityCellInfo setSearchName:hotCityName];
            [fCityCellInfo setSectionTitle:@"热门"];
            [fCityCellInfo setCountry:hotCountryName];
            
            [arrayCountryHotSearchResultThread addObject:fCityCellInfo];
        }
    }
}

//网络返回的热门城市推荐
- (void)setupHotCityArray:(NSArray *)citys hotResult:(NSMutableArray *)arrayCountryHotSearchResultThread
{
    for (FSearchCity *city in citys)
    {
        FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
        [fCityCellInfo setDisplayText:city.displayname];
        [fCityCellInfo setSearchName:city.nameZh];
        [fCityCellInfo setSectionTitle:@"热门"];
        [fCityCellInfo setCountry:city.country];
        
        [arrayCountryHotSearchResultThread addObject:fCityCellInfo];
    }
}

- (void)setupCityDesc:(FCityCellInfo *)fCityCell cityName:(NSString *)cityName cityFItem:(FCityPhysicalMark *)cityFItem
{
    NSMutableString *describle = [[NSMutableString alloc] initWithString:@""];
    
    NSString *country = [cityFItem country];
    if ([FCity checkCountryNationType:country] > FCityDomesticType)
    {
        NSString *cityCode = [cityFItem cityCode];
        if (!IsStrEmpty(cityCode)){
            [describle appendFormat:@"%@   ", [cityCode uppercaseString]];
        }
        
        if (!IsStrEmpty(country)){
            [describle appendFormat:@"%@   ", country];
        }
    }
    
    
    if ([[cityFItem cityCode] hasPrefix:[cityName uppercaseString]] ||
        [[cityFItem cityCode] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem cityCode]];
    }
    else if ([[cityFItem airportCodeLower] containsString:[cityName uppercaseString]]  ||
             [[cityFItem airportCodeLower] containsString:[cityName lowercaseString]])
    {
        NSArray *arrayAirportCode = [[cityFItem airportCodeLower] componentsSeparatedByString:@"/"];
        for(NSString *airportCode in arrayAirportCode)
        {
            if([airportCode  containsString:[cityName uppercaseString]] ||
               [airportCode  containsString:[cityName lowercaseString]] )
            {
                [describle appendFormat:@"(%@)", [airportCode uppercaseString]];
            }
        }
    }
    else if ([[cityFItem searchCity] hasPrefix:[cityName uppercaseString]] ||
             [[cityFItem searchCity] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem searchCity]];
    }
    else if ([[cityFItem cityNameCN] hasPrefix:[cityName uppercaseString]] ||
             [[cityFItem cityNameCN] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem cityNameCN]];
    }
    else if([[cityFItem cityNameJP] hasPrefix:[cityName uppercaseString]] ||
            [[cityFItem cityNameJP] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem cityNameJP]];
    }
    else if([[cityFItem cityNamePY] hasPrefix:[cityName uppercaseString]] ||
            [[cityFItem cityNamePY] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem cityNamePY]];
    }
    else if([[cityFItem cityNameEN] hasPrefix:[cityName uppercaseString]] ||
            [[cityFItem cityNameEN] hasPrefix:[cityName lowercaseString]])
    {
        [describle appendFormat:@"(%@)", [cityFItem cityNameEN]];
    }
    
    
    [fCityCell setDisplayText:[cityFItem cityNameCN]];
    [fCityCell setDisplaySubText:describle];
    [fCityCell setSearchName:[cityFItem searchCity]];
    [fCityCell setCountry:country];
}

- (FCityCellInfo *)setupCityCellResult:(FCityPhysicalMark *)item
{
    FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
    [fCityCellInfo setDisplayText:item.cityNameCN];
    [fCityCellInfo setDisplaySubText:[item.cityCode uppercaseString]];
    [fCityCellInfo setSearchName:item.searchCity];
    [fCityCellInfo setAirportCode:item.airportCodeLower];
    [fCityCellInfo setSectionTitle:[item sectionTitle]];
    [fCityCellInfo setCountry:item.country];
    return fCityCellInfo;
}

#pragma mark - 获取数据源

- (NSArray *)getHotCityArray:(FCityVCTabType)tabType;
{
    switch (tabType)
    {
        case FCityVCTabTypeDomesticCity:
        {
            if(_fCityHotType == eFCityHotDeptType)
            {
                if(!_arrayDomesticDepart)
                    _arrayDomesticDepart = [FUserCityRecord getHotCityInlandDepCityArray];
                return _arrayDomesticDepart;
            }
            else if(_fCityHotType == eFCityHotArrivalType)
            {
                if(!_arrayDomesticArrival)
                    _arrayDomesticArrival = [FUserCityRecord getHotCityInlandArrCityArray];
                return _arrayDomesticArrival;
            }
        }
            break;
        case FCityVCTabTypeInternationalCity:
        {
            if(_fCityHotType == eFCityHotDeptType)
            {
                if(!_arrayInterDepart)
                    _arrayInterDepart = [FUserCityRecord getHotCityOutlandDepCityArray];
                return _arrayInterDepart;
            }
            else if(_fCityHotType == eFCityHotArrivalType)
            {
                if(!_arrayInterArrival)
                    _arrayInterArrival = [FUserCityRecord getHotCityOutlandArrCityArray];
                return _arrayInterArrival;
            }
        }
            break;
    }
    
    return nil;
}

@end
