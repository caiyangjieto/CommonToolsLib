//
//  FDateItem.m
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateItem.h"

@implementation FDateItem

- (BOOL)isEqualDate:(NSDate *)date
{
    if (self.year == date.year &&
        self.month == date.month &&
        self.day == date.day )
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)getMDD
{
    return [[NSString alloc] initWithFormat:@"%ld-%ld",_month,_day];
}

- (NSString *)getYYYYMMDD
{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"%ld",(long)_year];
    
    if (_month < 10) {
        [string appendFormat:@"-0%ld",(long)_month];
    }else{
        [string appendFormat:@"-%ld",(long)_month];
    }
    
    if (_day < 10) {
        [string appendFormat:@"-0%ld",(long)_day];
    }else{
        [string appendFormat:@"-%ld",(long)_day];
    }
    
    return string;
}

@end
