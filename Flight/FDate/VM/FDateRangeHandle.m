//
//  FDateRangeHandle.m
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateRangeHandle.h"

@implementation FDateRangeHandle

- (void)handleMinDate:(NSDate *)minVDate maxDate:(NSDate *)maxDate
{
    _arrayDate = [NSMutableArray new];
    _dictDate = [NSMutableDictionary new];
    
    
    NSInteger startYear = [minVDate year];
    NSInteger startMonth = [minVDate month];
    
    //开始第一天的周几 以后累加
    NSInteger weekday = [[NSDate dateWithYear:startYear month:startMonth] weekday];
    
    //相差月份
    NSInteger intervalMonthInYears = ([maxDate year] - startYear)*12;
    NSInteger intervalMonth = [maxDate month] - startMonth + intervalMonthInYears;
    
    for (NSInteger index = startMonth; index <= (startMonth+intervalMonth); index++)
    {
        NSInteger year = startYear + index/13;//年份进位
        NSInteger month = index/13 + index%13;//月份进位
        
        NSInteger daysInMonth = [self getDaysInYear:year month:month];
        for (NSInteger day = 1; day <= daysInMonth; day++)
        {
            weekday = weekday/8 + weekday%8;//星期进位
            
            FDateItem *fDateItem = [[FDateItem alloc] init];
            [fDateItem setYear:year];
            [fDateItem setMonth:month];
            [fDateItem setDay:day];
            [fDateItem setWeekday:weekday];
            
            weekday++;
            
            [_arrayDate addObject:fDateItem];
            [_dictDate setObject:fDateItem forKey:[fDateItem getYYYYMMDD]];
        }
    }
}

- (NSInteger)getDaysInYear:(NSInteger)year month:(NSInteger)month
{
    NSDate *date = [NSDate dateWithYear:year month:month];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = NSMakeRange(0, 0);
    
//    if (kiOS8Later){
        range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
//    }else{
//        range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
//    }
    
    return range.length;
}

@end
