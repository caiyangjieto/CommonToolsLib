//
//  FCityListVCData.m
//  Flight
//
//  Created by qitmac000224 on 15/7/13.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//

#import "FCityVCModel.h"

@implementation FCityVCModel

- (id)init
{
    if (self = [super init])
    {
        [self setArrayIndexName:[[NSMutableArray alloc] init]];
        [self setArraySectionName:[[NSMutableArray alloc] init]];
        [self setArraySectionLogo:[[NSMutableArray alloc] init]];
        [self setArraySectionCount:[[NSMutableArray alloc] init]];
        [self setArrayDefCellData:[[NSMutableArray alloc] init]];
        [self setArrayTagCellData:[[NSMutableArray alloc] init]];
        [self setArrayCityCellData:[[NSMutableArray alloc] init]];
        
        return self;
    }
    
    return nil;
}

@end


@implementation FCityCellInfo

@end