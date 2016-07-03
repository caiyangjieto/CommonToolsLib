//
//  FDateVM.m
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateVM.h"
#import "FDateRangeHandle.h"
#import "FDatePriceResult.h"

typedef enum {
    FDateCompareSmall = 0,
    FDateCompareRange,
    FDateCompareLarge
}FDateCompareStatus;

@interface FDateVM ()

@property (nonatomic, strong) FDateRangeHandle       *fDateRangeHandle;
@property (nonatomic, strong) NSMutableDictionary    *dictionaryPrice;
@property (nonatomic, assign) FDateCompareStatus     fDateCompareStatus;

@end

@implementation FDateVM

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _fDateRangeHandle = [[FDateRangeHandle alloc] init];
        
    }
    return self;
}

- (void)setArrayPrices:(NSArray *)arrayPrices
{
    _arrayPrices = arrayPrices;
    _dictionaryPrice = [NSMutableDictionary new];
    
    for (FDatePriceItem *item in arrayPrices)
    {
        [_dictionaryPrice setObject:item.price forKey:item.date];
    }
}

- (void)setupDateDataModel
{
    [_fDateRangeHandle handleMinDate:[_dateLogic minValidDate] maxDate:[_dateLogic maxValidDate]];
    
    _arrayTitleText = [NSMutableArray new];
    _arraySectonData = [NSMutableArray new];
    
    
    NSMutableArray *arraySection = nil;
    NSInteger preMonth = 0;
    for (FDateItem *fDateItem in [_fDateRangeHandle arrayDate])
    {
        if ([fDateItem month] != preMonth)
        {
            preMonth = [fDateItem month];
            
            arraySection = [NSMutableArray new];
            [_arraySectonData addObject:arraySection];
            
            NSString *sectionTitle = [[NSString alloc] initWithFormat:@"%ld年%ld月",(long)[fDateItem year],(long)[fDateItem month]];
            [_arrayTitleText addObject:sectionTitle];
        }
        
        [self appendItem:fDateItem array:arraySection];
    }
}

- (void)appendItem:(FDateItem *)fDateItem array:(NSMutableArray *)arrayCells
{
    NSMutableArray *cellModel = [arrayCells lastObject];
    if ([cellModel count]%7 == 0)
    {
        cellModel = [NSMutableArray new];
        [arrayCells addObject:cellModel];
        
        for (NSInteger index = 1; index < fDateItem.weekday; index++) {
            [cellModel addObject:[[FDateItem alloc] init]];
        }
    }
    
    //价格
    NSNumber *price = [_dictionaryPrice objectForKey:[fDateItem getYYYYMMDD]];
    [fDateItem setPrice:[price integerValue]];
    
    //选中状态
    if ([fDateItem isEqualDate:_dateLogic.minSelectDate])
    {
        _indexSecton = [_arraySectonData indexOfObject:arrayCells];
        [fDateItem setChoiceStatus:eFDateItemSelected];
    }
    else if ([fDateItem isEqualDate:_dateLogic.minValidDate])
    {
        [fDateItem setChoiceStatus:eFDateItemDefault];
        _fDateCompareStatus = FDateCompareRange;
    }
    else if ([fDateItem isEqualDate:_dateLogic.maxValidDate])
    {
        [fDateItem setChoiceStatus:eFDateItemDefault];
        _fDateCompareStatus = FDateCompareLarge;
    }
    else if (_fDateCompareStatus == FDateCompareRange)
    {
        [fDateItem setChoiceStatus:eFDateItemDefault];
    }
    else
    {
        [fDateItem setChoiceStatus:eFDateItemDisabled];
    }
    
    [cellModel addObject:fDateItem];
}

@end




