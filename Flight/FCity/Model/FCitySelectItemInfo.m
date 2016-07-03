//
//  FCitySelectItemInfo.m
//  Flight
//
//  Created by qitmac000010 on 14/11/11.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "FCitySelectItemInfo.h"

@implementation FCitySelectItemInfo

- (FCitySelectItemInfo *)initWithFCityCellInfo:(FCityCellInfo *)fCityItem
{
    if((self = [super init]) != nil)
    {
        _country = [fCityItem country];
        _sectionTitle = [fCityItem sectionTitle];
        //_recommendCity = [fCityItem recommendCity];
        
        // SearchName
        _searchName = [fCityItem searchName];
        _displayName = [fCityItem displayText];
        
        return self;
    }
    
    return nil;
}

@end
