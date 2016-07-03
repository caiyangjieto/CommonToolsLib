//
//  FDateVC.m
//  Flight
//
//  Created by qitmac000224 on 16/6/14.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FDateVC.h"
#import "FDateVM.h"
#import "FDateWeekCell.h"
#import "FDatePriceResult.h"


#define kTableViewWidthMargin       15


@interface FDateVC () <UITableViewDataSource, UITableViewDelegate, FDateWeekCellDelgt, NetworkPtc>

//view
@property (nonatomic, strong) UIView                        *weekdayView;
@property (nonatomic, strong) UITableView                   *tableView;

//model
@property (nonatomic, strong) FDateVM                       *fDateVM;

@end

@implementation FDateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect parentFrame = [self.view frame];
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = parentFrame.size.height;
    
    // =======================================================================
    // 向下返回
    // =======================================================================
    FNaviBarItem *rightItem = [[FNaviBarItem alloc] initTextItem:kCustomerFontBackX font:kCustomerFontOfSize(24) target:self action:@selector(goBack)];
    [[self naviBar] setLeftBarItem:nil];
    [[self naviBar] setRightBarItem:rightItem];
    [[self naviBar] setTitle:@"价格日历"];
    
    spaceYStart += [self naviBar].frame.size.height;
    
    
    // =======================================================================
    // 顶部周几栏
    // =======================================================================
    _weekdayView = [[UIView alloc] initWithFrame:CGRectMake(kTableViewWidthMargin, spaceYStart, parentFrame.size.width-kTableViewWidthMargin*2, 50)];
    [_weekdayView setBackgroundColor:[UIColor clearColor]];
    [self setupSubWeekdayView];
    [self.view addSubview:_weekdayView];
    
    spaceYStart += _weekdayView.frame.size.height;
    
    
    
    // =======================================================================
    // 搜索结果
    // =======================================================================
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [_tableView setFrame:CGRectMake(kTableViewWidthMargin, spaceYStart, parentFrame.size.width-kTableViewWidthMargin*2, spaceYEnd - spaceYStart)];
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initDataModel];
        [self startRequstData];
    });

}

- (void)initDataModel
{
    _fDateVM = [[FDateVM alloc] init];
    [_fDateVM setDateLogic:_dateLogic];
    [_fDateVM setupDateDataModel];
    
    [_tableView reloadData];
    [_tableView scrollToRow:0 inSection:_fDateVM.indexSecton atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)goBack
{
    [VCController popWithAnimation:[VCAnimationBottom defaultAnimation]];
}

#pragma mark - 布局

- (void)setupSubWeekdayView
{
    NSArray *weekdayKey = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    
    NSInteger titleWidth = _weekdayView.width / 7;
    NSInteger spaceXStart = 0;
    
    for (NSString *key in weekdayKey)
    {
        UILabel *labelWeek = [[UILabel alloc] initWithFont:kCurNormalFontOfSize(10) andText:key];
        [labelWeek sizeToFit];
        [labelWeek setTextAlignment:NSTextAlignmentCenter];
        [labelWeek setBackgroundColor:[UIColor clearColor]];
        [labelWeek setFrame:CGRectMake(spaceXStart, (_weekdayView.height-labelWeek.height)/2, titleWidth, labelWeek.height)];
        
        if ([key isEqualToString:@"日"] || [key isEqualToString:@"六"]){
            [labelWeek setTextColor:[UIColor flightThemeSideColor]];
        }else{
            [labelWeek setTextColor:[UIColor flightThemeColor]];
        }
        
        [_weekdayView addSubview:labelWeek];
        spaceXStart += titleWidth;
    }
    
}

#pragma mark - 上行数据

- (BOOL)startRequstData
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObjectSafe:_depCity forKey:@"dep"];
    [dict setObjectSafe:_arrCity forKey:@"arr"];
    
    NSTimeInterval timeInterval = [[_dateLogic maxValidDate] timeIntervalSinceReferenceDate] - [[_dateLogic minValidDate] timeIntervalSinceReferenceDate];
    NSInteger daysInterval = timeInterval/kFPerDaySeconds;
    
    [dict setObjectSafe:@(daysInterval) forKey:@"days"];
    
    return [FlightNetTask postSearch:dataWithPriceInterface
                            forParam:dict
                            forCache:NO
                           withDelgt:self
                          withResult:[FDatePriceResult class]
                         withCusInfo:dataWithPriceInterface];
}

#pragma mark - 下行数据
- (void)getSearchNetBack:(id)searchResult forInfo:(id)customInfo
{
    if ([dataWithPriceInterface isEqualToString:customInfo])
    {
        NSNumber *code = [[searchResult bstatus] code];
        if (code && [code integerValue] == 0)
        {
            FDatePriceResult *fDatePriceResult = (FDatePriceResult *)searchResult;
            [_fDateVM setArrayPrices:[fDatePriceResult lowPrices]];
            [_fDateVM setupDateDataModel];
            [_tableView reloadData];
        }
    }
}

#pragma mark - tableViewDelgt

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fDateVM arraySectonData] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_fDateVM arraySectonData] objectAtIndexSafe:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FDateWeekCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect parentFrame = [tableView frame];
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    NSString *reusedIdentifier = @"FDateWeekCell";
    FDateWeekCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (cell == nil)
    {
        cell = [[FDateWeekCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell setFrame:CGRectMake(0, 0, parentFrame.size.width, 0)];
        [cell setupSubView];
        [cell setDelegate:self];
    }
    
    [cell setupCellSubViews:[[[_fDateVM arraySectonData] objectAtIndexSafe:section] objectAtIndexSafe:row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *labelSectionLabel = [[UILabel alloc] init];
    [labelSectionLabel setTextColor:[UIColor whiteColor]];
    [labelSectionLabel setText:[[_fDateVM arrayTitleText] objectAtIndexSafe:section]];
    [labelSectionLabel sizeToFit];
    
    return labelSectionLabel;
}

#pragma mark - FDateWeekCellDelgt

- (void)onClickCellItem:(FDateItem *)fDateItem
{
    if (_delegate && [_delegate respondsToSelector:@selector(fDateVCDepDate:arrDate:)])
    {
        NSDate *depDate = [NSDate dateWithYear:[fDateItem year] month:[fDateItem month] day:[fDateItem day]];
        [_delegate fDateVCDepDate:depDate arrDate:nil];
    }
    
    [self goBack];
}

@end
