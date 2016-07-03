//
//  FDateItem.h
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    eFDateItemDefault,           // 默认
    eFDateItemSelected,          // 选中
    eFDateItemDisabled,			 // 不可选
}eFDateItemChoiceStatus;

typedef enum
{
    eFDateItemOptionDefault = 0,		  // 默认
    eFDateItemOptionHoliday = 1<<1,       // 休假
    eFDateItemOptionLowest  = 1<<2,       // 最低价
}eFDateItemOptionStatus;


@interface FDateItem : NSObject

@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger weekday;
@property (nonatomic, assign) NSInteger price;

@property (nonatomic, strong) NSString  *holidayText;
@property (nonatomic, assign) eFDateItemChoiceStatus choiceStatus;
@property (nonatomic, assign) eFDateItemOptionStatus optionStatus;


- (BOOL)isEqualDate:(NSDate *)date;

- (NSString *)getMDD;
- (NSString *)getYYYYMMDD;

@end
