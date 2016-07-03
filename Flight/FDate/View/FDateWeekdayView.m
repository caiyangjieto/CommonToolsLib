//
//  FDateWeekdayView.m
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateWeekdayView.h"

@interface FDateWeekdayView ()

@property (nonatomic, strong) UILabel   *labelTip;
@property (nonatomic, strong) UILabel   *labelDay;
@property (nonatomic, strong) UILabel   *labelPrice;

@end

@implementation FDateWeekdayView

+ (NSInteger)getItemHeight
{
    return 55;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _labelTip = [[UILabel alloc] initWithFont:kCurNormalFontOfSize(12) andText:@"上班"];
        [_labelTip setOrigin:CGPointMake(0, 2)];
        [_labelTip setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_labelTip];
        
        _labelDay = [[UILabel alloc] initWithFont:kCurNormalFontOfSize(14) andText:@"33"];
        [_labelDay setOrigin:CGPointMake(0, _labelTip.bottom)];
        [_labelDay setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_labelDay];
        
        _labelPrice = [[UILabel alloc] initWithFont:kCurNormalFontOfSize(12) andText:@"33"];
        [_labelPrice setOrigin:CGPointMake(0, _labelDay.bottom)];
        [_labelPrice setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_labelPrice];
    }
    return self;
}

- (void)setupSubview
{
    [_labelTip setWidth:self.width];
    [_labelDay setWidth:self.width];
    [_labelPrice setWidth:self.width];
}

- (void)setFDateItem:(FDateItem *)fDateItem
{
    _fDateItem = fDateItem;
    
    if (!IsStrEmpty([fDateItem holidayText])) {
        [_labelTip setText:[fDateItem holidayText]];
        [_labelTip setHidden:NO];
    }else{
        [_labelTip setHidden:YES];
    }
    
    if ([fDateItem day] > 0){
        [_labelDay setText:[[NSString alloc] initWithFormat:@"%ld",(long)[fDateItem day]]];
        [_labelDay setHidden:NO];
    }else{
        [_labelDay setHidden:YES];
    }
    
    if ([fDateItem price] > 0) {
        [_labelPrice setText:[[NSString alloc] initWithFormat:@"%@%ld",kFRMBSymbol,(long)[fDateItem price]]];
        [_labelPrice setHidden:NO];
    }else{
        [_labelPrice setHidden:YES];
    }
    
    [self setClipsToBounds:NO];
    [self.layer setCornerRadius:0];
    [self setViewColor:fDateItem];
}

- (void)setViewColor:(FDateItem *)fDateItem
{
    if ([fDateItem choiceStatus] == eFDateItemSelected)
    {
        [_labelTip setTextColor:[UIColor whiteColor]];
        [_labelDay setTextColor:[UIColor whiteColor]];
        [_labelPrice setTextColor:[UIColor whiteColor]];
        [self setClipsToBounds:YES];
        [self.layer setCornerRadius:2.0];
        [self setBackgroundColor:[UIColor flightThemeSideColor]];
    }
    else if ([fDateItem choiceStatus] == eFDateItemDisabled)
    {
        [_labelTip setTextColor:[UIColor flighte5e5e5]];
        [_labelDay setTextColor:[UIColor flighte5e5e5]];
        [_labelPrice setTextColor:[UIColor flighte5e5e5]];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [_labelTip setTextColor:[UIColor flightThemeColor]];
        [_labelDay setTextColor:[UIColor blackColor]];
        [_labelPrice setTextColor:[UIColor flight666666]];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        eFDateItemOptionStatus optionStatus = [fDateItem optionStatus];
        if ((optionStatus & eFDateItemOptionHoliday) != 0) {
            [_labelTip setTextColor:[UIColor flightThemeSideColor]];
            [self setBackgroundColor:[UIColor flightThemeSideHightColor]];
        }
        if ((optionStatus & eFDateItemOptionLowest) != 0) {
            [_labelTip setTextColor:[UIColor flightThemeSideColor]];
            [_labelPrice setTextColor:[UIColor flightThemeSideColor]];
        }
    }
}

@end















