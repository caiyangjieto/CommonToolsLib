//
//  FDateWeekCell.m
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateWeekCell.h"
#import "FDateWeekdayView.h"

@interface FDateWeekCell ()

@property (nonatomic, strong) FDateWeekdayView *sunday;
@property (nonatomic, strong) FDateWeekdayView *monday;
@property (nonatomic, strong) FDateWeekdayView *tueday;
@property (nonatomic, strong) FDateWeekdayView *thrday;
@property (nonatomic, strong) FDateWeekdayView *thuday;
@property (nonatomic, strong) FDateWeekdayView *friday;
@property (nonatomic, strong) FDateWeekdayView *satday;

@end

@implementation FDateWeekCell

+ (NSInteger)getCellHeight
{
    return [FDateWeekdayView getItemHeight];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        _sunday = [[FDateWeekdayView alloc] init];
        [_sunday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_sunday];
        
        _monday = [[FDateWeekdayView alloc] init];
        [_monday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_monday];
        
        _tueday = [[FDateWeekdayView alloc] init];
        [_tueday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_tueday];
        
        _thrday = [[FDateWeekdayView alloc] init];
        [_thrday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_thrday];
        
        _thuday = [[FDateWeekdayView alloc] init];
        [_thuday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_thuday];
        
        _friday = [[FDateWeekdayView alloc] init];
        [_friday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_friday];
        
        _satday = [[FDateWeekdayView alloc] init];
        [_satday addTarget:self action:@selector(onClickCellItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_satday];
        
    }
    
    return self;
}

- (void)setupSubView
{
    NSInteger widthItem = self.width/7;
    NSInteger heightItem = [FDateWeekCell getCellHeight];
    [self setHeight:heightItem];
    
    [_sunday setFrame:CGRectMake(0, 0, widthItem, heightItem)];
    [_monday setFrame:CGRectMake(_sunday.right, 0, widthItem, heightItem)];
    [_tueday setFrame:CGRectMake(_monday.right, 0, widthItem, heightItem)];
    [_thrday setFrame:CGRectMake(_tueday.right, 0, widthItem, heightItem)];
    [_thuday setFrame:CGRectMake(_thrday.right, 0, widthItem, heightItem)];
    [_friday setFrame:CGRectMake(_thuday.right, 0, widthItem, heightItem)];
    [_satday setFrame:CGRectMake(_friday.right, 0, self.width-_friday.right, heightItem)];
    
    [_sunday setupSubview];
    [_monday setupSubview];
    [_tueday setupSubview];
    [_thrday setupSubview];
    [_thuday setupSubview];
    [_friday setupSubview];
    [_satday setupSubview];
}

- (void)setupCellSubViews:(NSArray *)arrayWeeks
{
    [_sunday setFDateItem:[arrayWeeks objectAtIndexSafe:0]];
    [_monday setFDateItem:[arrayWeeks objectAtIndexSafe:1]];
    [_tueday setFDateItem:[arrayWeeks objectAtIndexSafe:2]];
    [_thrday setFDateItem:[arrayWeeks objectAtIndexSafe:3]];
    [_thuday setFDateItem:[arrayWeeks objectAtIndexSafe:4]];
    [_friday setFDateItem:[arrayWeeks objectAtIndexSafe:5]];
    [_satday setFDateItem:[arrayWeeks objectAtIndexSafe:6]];
}

- (void)onClickCellItem:(FDateWeekdayView *)fDateWeekdayView
{
    if (_delegate && [_delegate respondsToSelector:@selector(onClickCellItem:)])
    {
        [_delegate onClickCellItem:[fDateWeekdayView fDateItem]];
    }
}

@end
