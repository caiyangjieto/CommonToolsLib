//
//  FRefreshControl.m
//  Flight
//
//  Created by caiyangjieto on 16/3/3.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FRefreshControl.h"

#define kTotalViewHeightMin                     55
#define kTriggerPointPos                        60
#define kCamelBottomMargin						45
#define kTextBottomMargin						20
#define	kLoadCamelImageViewWidth				34
#define	kLoadCamelImageViewHeight				25

// 控件字体
#define	kLoadHintLabelFont						kCurNormalFontOfSize(15)

@interface FRefreshControl ()

@property (nonatomic, strong) UILabel		*labelStat;		// 加载状态Label

@property (nonatomic, assign) BOOL			refreshing;		// 正在刷新
@property (nonatomic, assign) BOOL			canRefresh;		// 是否还能够触发刷新

@property (nonatomic, weak) UIScrollView	*scrollView;	// RefreshControl所在的ScrollView

@end

@implementation FRefreshControl

- (id)initInScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:CGRectMake(0, scrollView.contentOffset.y, scrollView.frame.size.width, -scrollView.contentOffset.y)];
    if (self)
    {
        // 默认提示文案
        _startText = @"下拉可以刷新";
        _hintText = @"松开即可刷新";
        _loadingText = @"努力加载中...";
        
        // 设置RefreshControl所在的ScrollView
        _scrollView = scrollView;
        
        // 设置RefreshControl的位置
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [scrollView addSubview:self];
        [scrollView sendSubviewToBack:self];
        
        // 状态文字 Label
        _labelStat = [[UILabel alloc] initWithFont:kLoadHintLabelFont
                                           andText:_startText];
        CGSize statSize = [_startText sizeWithFontCompatible:kLoadHintLabelFont];
        [_labelStat setFrame:CGRectMake(0,
                                        self.frame.size.height - kTextBottomMargin - _labelStat.frame.size.height,
                                        scrollView.frame.size.width,
                                        statSize.height)];
        [_labelStat setTextColor:[UIColor flightThemeColor]];
        [_labelStat setTextAlignment:NSTextAlignmentCenter];
        [_labelStat setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self addSubview:_labelStat];
        
        [[self layer] setMasksToBounds:YES];
        
        [self setBackgroundColor:[UIColor colorWithRGB:0xefeff4 alpha:1.0]];
        
        _refreshing = NO;
        _canRefresh = YES;
    }
    
    return self;
}

- (void)dealloc
{
    _scrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGFloat offset = [[change objectForKey:@"new"] CGPointValue].y;
    CGFloat oldOffset = [[change objectForKey:@"old"] CGPointValue].y;
    
    if (offset >= -kTotalViewHeightMin)
    {
        [self setFrame:CGRectMake(0, -kTotalViewHeightMin, self.scrollView.frame.size.width, kTotalViewHeightMin)];
    }
    else
    {
        [self setFrame:CGRectMake(0, offset, self.scrollView.frame.size.width, -offset)];
    }
    
    CGSize statSize = [_startText sizeWithFontCompatible:kLoadHintLabelFont];
    [_labelStat setFrame:CGRectMake((_scrollView.frame.size.width - statSize.width)/2,
                                    self.frame.size.height - kTextBottomMargin - _labelStat.frame.size.height,
                                    statSize.width,
                                    statSize.height)];
    
    if (_refreshing)
    {
        if (offset >= -kTriggerPointPos && !self.scrollView.dragging)
        {
            [self.scrollView setContentInset:UIEdgeInsetsMake(kTriggerPointPos, 0, 0, 0)];
        }
        
        return;
    }
    else
    {
        if (!_canRefresh)
        {
            if (offset < 0)
            {
                _canRefresh = YES;
            }
            else
            {
                return;
            }
        }
    }
    
    BOOL triggered = NO;
    
    if ((oldOffset < -kTriggerPointPos && !self.scrollView.tracking))
    {
        triggered = YES;
    }
    
    if (!triggered)
    {
        if ((offset < 0) && (offset > -kTriggerPointPos))
        {
            // 下拉可以刷新
            [_labelStat setText:_startText];
        }
        else if ((offset < -kTriggerPointPos))
        {
            // 松开即可刷新
            [_labelStat setText:_hintText];
        }
    }
    else
    {
        // 松开即可刷新
        [_labelStat setText:_loadingText];
        
        _refreshing = YES;
        _canRefresh = NO;
        
        [self.scrollView setContentOffset:CGPointMake(0, -kTriggerPointPos)];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)beginRefreshing
{
    if (!_refreshing)
    {
        // 松开即可刷新
        [_labelStat setText:_loadingText];
        
        [UIView animateWithDuration:0.4
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^ {
                             [self.scrollView setContentOffset:CGPointMake(0, -kTriggerPointPos) animated:NO];
                         }
                         completion:^ (BOOL finished) {
                         }];
        
        _refreshing = YES;
        _canRefresh = NO;
    }
}

- (void)endRefreshing
{
    _refreshing = NO;
    
    // 松开即可刷新
    [_labelStat setText:_startText];
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView animateWithDuration:0.4
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^ {
                         [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^ (BOOL finished) {
                         
                         if (finished && !_refreshing)
                         {
                             [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                         }
                     }];
}

- (void)endRefreshingWithScroll:(BOOL)isScroll
{
    _refreshing = NO;
    
    // 松开即可刷新
    [_labelStat setText:_startText];
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView animateWithDuration:0.4
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^ {
                         [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^ (BOOL finished) {
                         
                         if (finished && !_refreshing)
                         {
                             if (isScroll)
                             {
                                 [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                             }
                             else
                             {
                                 // 为了防止RefreshControl悬在空中
                                 if(self.scrollView.contentOffset.y < 0)
                                 {
                                     [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:NO];
                                 }
                             }
                         }
                     }];
}

- (void)endRefreshingWithoutScrollToTop
{
    _refreshing = NO;
    
    // 松开即可刷新
    [_labelStat setText:_startText];
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView animateWithDuration:0.4
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^ {
                         [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^ (BOOL finished) {
                         
                         if (finished && !_refreshing)
                         {
                             // 为了防止RefreshControl悬在空中
                             if(self.scrollView.contentOffset.y < 0)
                             {
                                 [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:NO];
                             }
                             
                         }
                     }];
}

- (void)endRefreshingWithText:(NSString *)errorText
{
    [_labelStat setText:errorText];
    
    _refreshing = NO;
    
    // 还原
    [UIView animateWithDuration:0.4
                          delay:2.0f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^ {
                         [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                     }
                     completion:^ (BOOL finished) {
                         
                         if (finished)
                         {
                             [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
                         }
                     }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil)
    {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
    else
    {
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    
    [super willMoveToSuperview:newSuperview];
}

@end
