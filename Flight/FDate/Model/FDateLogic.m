//
//  FDateLogic.m
//  Flight
//
//  Created by qitmac000224 on 16/6/14.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateLogic.h"

@implementation FDateLogic

- (NSDate *)minValidDate
{
    if (_minValidDate == nil) {
        _minValidDate = [NSDate adjustToday];
    }
    return _minValidDate;
}

- (NSDate *)maxValidDate
{
    if (_maxValidDate == nil) {
        _maxValidDate = [[NSDate adjustToday] dateByAddingMonths:kFSearchBackDateMaxMonthRange];
    }
    return _maxValidDate;
}

- (NSDate *)minSelectDate
{
    if (_minSelectDate == nil) {
        _minSelectDate = [[NSDate adjustToday] dateByAddingDays:kFSearchDepartMinInterval];
    }
    return _minSelectDate;
}

- (NSDate *)maxSelectDate
{
    if (_maxSelectDate == nil) {
        _maxSelectDate = [[NSDate adjustToday] dateByAddingDays:kFSearchDepartBackInterval];
    }
    return _maxSelectDate;
}

@end
