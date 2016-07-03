//
//  FCityVCListDataSource.m
//  Flight
//
//  Created by qitmac000224 on 15/7/8.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//

#import "FCityVCListVM.h"
#import "FUserCityRecord.h"

@interface FCityVCListVM ()

@property (nonatomic, assign) FCityHotType              fCityHotType;               // 热门城市类型
@property (nonatomic, assign) NSInteger                 btnCount;                   // 热门城市类型

@property (nonatomic, strong) NSString                  *curCityName;               // 当前选中城市

@property (nonatomic, strong) NSMutableArray            *arrayDomesticCity;         // 缓存国内所有城市列表数据
@property (nonatomic, strong) NSMutableArray            *arrayInterCity;            // 缓存国际所有城市列表数据
@property (nonatomic, strong) NSArray                   *arrayDomesticDepart;       // 缓存国内出发热门列表数据
@property (nonatomic, strong) NSArray                   *arrayDomesticArrival;      // 缓存国内到达热门列表数据
@property (nonatomic, strong) NSArray                   *arrayInterDepart;          // 缓存国际出发热门列表数据
@property (nonatomic, strong) NSArray                   *arrayInterArrival;         // 缓存国际到达热门列表数据

@end

@implementation FCityVCListVM

- (id)initWithHotType:(FCityHotType)fCityHotType cityName:(NSString *)curCityName tagCount:(NSInteger)tagCount
{
    if (self = [super init])
    {
        _fCityHotType = fCityHotType;
        _btnCount = tagCount;
        _curCityName = curCityName;
        
        _arrayDomesticCity = [NSMutableArray array];
        _arrayInterCity = [NSMutableArray array];
    }
    
    return self;
}

- (void)loadDomesticDataToCache
{
    [[FDBManager getInstance] openFlightDB:nil];
    NSArray *arrayCity = [[FDBManager getInstance] selectDomesticCity];
    _arrayDomesticCity = [self getCityInfoCellArray:arrayCity isInter:NO];
    [[FDBManager getInstance] closeFlightDB];
}

- (void)loadInterDataToCache
{
    [[FDBManager getInstance] openFlightDB:nil];
    NSArray *arrayCity = [[FDBManager getInstance] selectInternationalCity];
    _arrayInterCity = [self getCityInfoCellArray:arrayCity isInter:YES];
    [[FDBManager getInstance] closeFlightDB];
}

- (FCityVCModel *)getCityListTableData:(FCityVCTabType)fCityVCTabType
{
    FCityVCModel *data = [[FCityVCModel alloc] init];
    
    switch (fCityVCTabType)
    {
        case FCityVCTabTypeDomesticCity:
        {
            if (IsArrEmpty(_arrayDomesticCity))
                return nil;
            
            data.arrayCityCellData = _arrayDomesticCity;
        }
            break;
        case FCityVCTabTypeInternationalCity:
        {
            if (IsArrEmpty(_arrayInterCity))
                return nil;
            
            data.arrayCityCellData = _arrayInterCity;
        }
            break;
    }
    
    //GPS
    if (_fCityVCSectionType == FCityVCSectionAllCity || (_fCityVCSectionType & FCityVCSectionGPS)!= 0)
    {
        [data.arrayIndexName addObject:@"定位"];
        [data.arraySectionName addObject:@"定位"];
        [data.arraySectionLogo addObject:kCustomerFontLocation];
        [data.arraySectionCount addObject:@1];
        [data.arrayDefCellData addObject:@1];//占位，无意义的数据
    }
    
    // 历史城市
    if (_fCityVCSectionType == FCityVCSectionAllCity || (_fCityVCSectionType & FCityVCSectionHistory)!= 0)
    {
        NSArray *arrayHistory = [self getHistoryCityArray:fCityVCTabType];
        if(!IsArrEmpty(arrayHistory))
        {
            [data.arrayIndexName addObject:@"历史"];
            [data.arraySectionName addObject:@"历史"];
            [data.arraySectionLogo addObject:kCustomerFontHistory];
            NSArray *array = [self getHistoryCityCellArray:arrayHistory];
            [data.arraySectionCount addObject:@([array count])];
            [data.arrayTagCellData addObject:array];
        }
    }
    
    // 热门城市
    if (_fCityVCSectionType == FCityVCSectionAllCity || (_fCityVCSectionType & FCityVCSectionHotCity)!= 0)
    {
        NSArray *arrayHotCity = [self getHotCityArray:fCityVCTabType];
        if(!IsArrEmpty(arrayHotCity))
        {
            [data.arrayIndexName addObject:@"热门"];
            [data.arraySectionName addObject:@"热门"];
            [data.arraySectionLogo addObject:kCustomerFontHotCity];
            NSArray *array = [self getHotCityCellArray:arrayHotCity];
            [data.arraySectionCount addObject:@([array count])];
            [data.arrayTagCellData addObject:array];
        }
    }
    
    // 城市列表
    if (_fCityVCSectionType == FCityVCSectionAllCity || (_fCityVCSectionType & FCityVCSectionNormalCity)!= 0)
    {
        for (NSArray *section in data.arrayCityCellData)
        {
            FCityCellInfo *city = [section objectAtIndexSafe:0];
            NSString *sectionTitle = city.sectionTitle;
            
            NSString *number = @"^[A-Z]";
            NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
            if ([numberPre evaluateWithObject:sectionTitle])
            {
                [data.arrayIndexName addObject:sectionTitle];
                [data.arraySectionName addObject:sectionTitle];
                [data.arraySectionCount addObject:@([section count])];
            }
        }
    }
    
    return data;
}

#pragma mark - 普通城市列表

- (NSMutableArray *)getCityInfoCellArray:(NSArray *)array isInter:(BOOL)isInter
{
    NSMutableArray *resultList = [NSMutableArray array];
    
    NSString *preSection = @"";
    NSMutableArray *result;
    for (FCityPhysicalMark *item in array)
    {
        FCityCellInfo *cityInfo = [self setupCityInfoItem:item isInter:isInter];
        NSString *nowSection = cityInfo.sectionTitle;
        if ([preSection isEqualToString:nowSection])
        {
            [result addObject:cityInfo];
        }
        else
        {
            preSection = nowSection;
            result = [NSMutableArray array];
            [result addObject:cityInfo];
            [resultList addObject:result];
        }
    }
    
    return resultList;
}

#pragma mark - 热门城市

- (NSArray *)getHotCityArray:(FCityVCTabType)fCityVCTabType
{
    switch (fCityVCTabType)
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

- (NSMutableArray *)getHotCityCellArray:(NSArray *)array
{
#warning caiyangjieto
    NSMutableArray *resultList = [NSMutableArray array];
    NSMutableArray *result;
    
    for (NSInteger i = 0; i < [array count]; i++)
    {
        NSInteger remainder = i % _btnCount;
        
        if (remainder == 0)
        {
            result = [NSMutableArray array];
            [resultList addObject:result];
        }
        
        NSString *cityText = [array objectAtIndexSafe:i];
        
        FCityTagInfo *cityInfo = [[FCityTagInfo alloc] init];
        [cityInfo setDisplayText:cityText];
        [cityInfo setSearchName:cityText];
        [cityInfo setIsSelected:[self checkSelectMark:cityText]];
        [cityInfo setIndexLine:remainder];
        
        [result addObject:cityInfo];
    }
    
    return resultList;
}

#pragma mark - 历史城市

- (NSArray *)getHistoryCityArray:(FCityVCTabType)fCityVCTabType
{
    switch (fCityVCTabType)
    {
        case FCityVCTabTypeDomesticCity:
        {
            return [FUserCityRecord getInlandCityRecordArray];
        }
            break;
        case FCityVCTabTypeInternationalCity:
        {
            return [FUserCityRecord getOutlandCityRecordArray];
        }
            break;
    }
}

- (NSArray *)getHistoryCityCellArray:(NSArray *)array
{
    NSMutableArray *resultList = [NSMutableArray array];
    NSMutableArray *result;
    
    for (NSInteger i = 0; i < [array count]; i++)
    {
        NSInteger remainder = i % _btnCount;
        
        if (remainder == 0)
        {
            result = [NSMutableArray array];
            [resultList addObject:result];
        }
        
        NSString *cityText = [array objectAtIndexSafe:i];
        
        FCityTagInfo *cityInfo = [[FCityTagInfo alloc] init];
        [cityInfo setDisplayText:cityText];
        [cityInfo setSearchName:cityText];
        [cityInfo setIsSelected:[self checkSelectMark:cityText]];
        [cityInfo setIndexLine:remainder];
        
        [result addObject:cityInfo];
    }
    
    return resultList;
}

// 保存国内历史城市
- (void)saveInHistory:(FCitySelectItemInfo *)fCitySelectItemInfo
{
    NSMutableArray *arrayFHistoryCity = [FUserCityRecord getInlandCityRecordArray];
    [self saveHistory:fCitySelectItemInfo historyArray:arrayFHistoryCity];
    [FUserCityRecord setInlandCityRecordArray:arrayFHistoryCity];
    [FUserCityRecord saveUserCityRecord];
}

// 保存国际历史城市
- (void)saveOutHistory:(FCitySelectItemInfo *)fCitySelectItemInfo
{
    NSMutableArray *arrayFHistoryCity = [FUserCityRecord getOutlandCityRecordArray];
    [self saveHistory:fCitySelectItemInfo historyArray:arrayFHistoryCity];
    [FUserCityRecord setOutlandCityRecordArray:arrayFHistoryCity];
    [FUserCityRecord saveUserCityRecord];
}

- (void)saveHistory:(FCitySelectItemInfo *)fCitySelectItemInfo historyArray:(NSMutableArray *)arrayFHistoryCity
{
    NSString *cityName = [fCitySelectItemInfo searchName];
    
    // 不在历史城市数组中
    if(![arrayFHistoryCity containsObject:cityName symbal:@"##"])
    {
        [arrayFHistoryCity insertObjectSafe:cityName atIndex:0];
        if([arrayFHistoryCity count] > _btnCount*2)
        {
            [arrayFHistoryCity removeLastObject];
        }
    }
    // 在历史城市中
    else
    {
        NSInteger index = [arrayFHistoryCity indexOfStringArray:cityName];
        [arrayFHistoryCity removeObjectAtIndex:index];
        [arrayFHistoryCity insertObject:cityName atIndex:0];
    }
}

#pragma mark - 辅助函数

- (FCityCellInfo *)setupCityInfoItem:(FCityPhysicalMark *)item isInter:(BOOL)isInter
{
    FCityCellInfo *cityInfo = [[FCityCellInfo alloc] init];
    [cityInfo setDisplayText:item.cityNameCN];
    [cityInfo setSearchName:item.searchCity];
    [cityInfo setSectionTitle:item.sectionTitle];
    [cityInfo setRecommendCity:item.recommendCity];
    [cityInfo setAirportCode:item.airportCodeLower];
    [cityInfo setCountry:item.country];
    
    BOOL isSelected = [self checkSelectMark:item.searchCity];
    [cityInfo setIsSelected:isSelected];
    
    if (isInter)
    {
       NSString *cityText = [[NSString alloc] initWithFormat:@"%@   %@",item.cityCode,item.country];
        [cityInfo setDisplaySubText:cityText];
    }
    
    return cityInfo;
}

- (BOOL)checkSelectMark:(NSString *)cityName
{
    return [_curCityName isEqualToString:cityName]?YES:NO;
}

@end
