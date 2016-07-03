//
//  UITableViewCell+Utility.m
//  Flight
//
//  Created by qitmac000224 on 16/6/13.
//  Copyright © 2016年 just. All rights reserved.
//

#import "UITableViewCell+Utility.h"
#import <objc/runtime.h>

#define kDottedLineHMargin          10
#define kFilterLineHMargin          15
#define kExpandBGHMargin            10
#define kDefaultBottomHMargin       15

@implementation UITableViewCell (Utility)

- (void)setBottomLineWidth:(CGFloat)bottomLineWidth
{
    objc_setAssociatedObject(self, @selector(bottomLineWidth), @(bottomLineWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)bottomLineWidth
{
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}




- (void)setBGViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath
{
    [self setBGViewInTableView:tableView
                    AtIndexPath:indexPath
                  withLineColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
}

- (void)setSelectedViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedViewInTableView:tableView
                          AtIndexPath:indexPath
                        withLineColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
}

- (void)setBGViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath withLineColor:(UIColor *)lineColor
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    
    CGFloat scale = (NSInteger)[[UIScreen mainScreen] scale];
    if (scale <= 0)
    {
        scale = 1;
    }
    // 适配iPhone6 +
    else if (scale > 2)
    {
        scale = 2;
    }
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:[indexPath section]] > 1)
    {
        // first cell check
        if (indexPath.row == 0)
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor whiteColor]];
            
            // 设置cell的BackGroundView下横线
            LineView *bottomLine = [[LineView alloc] initWithFrame:CGRectMake(kDefaultBottomHMargin,
                                                                              self.frame.size.height - 1/scale,
                                                                              self.frame.size.width - kDefaultBottomHMargin,
                                                                              1/scale)];
            [bottomLine setArrayColor:[NSArray arrayWithObjects:
                                       lineColor,
                                       nil]];
            [bottomLine setIsDotted:NO];
            if ([self isKindOfClass:[UITableViewCell class]])
            {
                CGFloat bottomLineWidth = [self bottomLineWidth];
                
                if (bottomLineWidth >= 0)
                {
                    [bottomLine setFrame:CGRectMake(self.frame.size.width - bottomLineWidth,
                                                    self.frame.size.height - 1/scale,
                                                    bottomLineWidth,
                                                    1/scale)];
                }
            }
            [view addSubview:bottomLine];
        }
        // last cell check
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor whiteColor]];
        }
        // middle cells
        else
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor whiteColor]];
            
            // 设置cell的BackGroundView下横线
            LineView *bottomLine = [[LineView alloc] initWithFrame:CGRectMake(kDefaultBottomHMargin,
                                                                              self.frame.size.height - 1/scale,
                                                                              self.frame.size.width - kDefaultBottomHMargin,
                                                                              1/scale)];
            [bottomLine setArrayColor:[NSArray arrayWithObjects:
                                       lineColor,
                                       nil]];
            [bottomLine setIsDotted:NO];
            if ([self isKindOfClass:[UITableViewCell class]])
            {
                CGFloat bottomLineWidth =  [self bottomLineWidth];
                
                if (bottomLineWidth >= 0)
                {
                    [bottomLine setFrame:CGRectMake(self.frame.size.width - bottomLineWidth,
                                                    self.frame.size.height - 1/scale,
                                                    bottomLineWidth,
                                                    1/scale)];
                }
            }
            [view addSubview:bottomLine];
        }
    }
    // only one
    else
    {
        // 设置cell背景色
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    
    [self setBackgroundView:view];
}

- (void)setSelectedViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath withLineColor:(UIColor *)lineColor
{
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    
    CGFloat scale = (NSInteger)[[UIScreen mainScreen] scale];
    if (scale <= 0)
    {
        scale = 1;
    }
    // 适配iPhone6 +
    else if (scale > 2)
    {
        scale = 2;
    }
    
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:[indexPath section]] > 1)
    {
        // first cell check
        if (indexPath.row == 0)
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
            
            // 设置cell的BackGroundView下横线
            LineView *bottomLine = [[LineView alloc] initDottedWithFrame:CGRectMake(kDefaultBottomHMargin,
                                                                                    self.frame.size.height - 1/scale,
                                                                                    self.frame.size.width - kDefaultBottomHMargin,
                                                                                    1/scale)];
            [bottomLine setArrayColor:[NSArray arrayWithObjects:
                                       lineColor,
                                       lineColor,
                                       nil]];
            [bottomLine setIsDotted:NO];
            
            {
                CGFloat bottomLineWidth = [self bottomLineWidth];
                
                if (bottomLineWidth >= 0)
                {
                    [bottomLine setFrame:CGRectMake(self.frame.size.width - bottomLineWidth,
                                                    self.frame.size.height - 1/scale,
                                                    bottomLineWidth,
                                                    1/scale)];
                }
            }
            [view addSubview:bottomLine];
        }
        // last cell check
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1)
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
            
            // 设置cell的BackGroundView下横线
            LineView *bottomLine = [[LineView alloc] initDottedWithFrame:CGRectMake(0,
                                                                                    self.frame.size.height - 1/scale,
                                                                                    self.frame.size.width,
                                                                                    1/scale)];
            [bottomLine setArrayColor:[NSArray arrayWithObjects:
                                       lineColor,
                                       lineColor,
                                       nil]];
            [bottomLine setIsDotted:NO];
            [view addSubview:bottomLine];
        }
        // middle cells
        else
        {
            // 设置cell背景色
            [view setBackgroundColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
        }
    }
    // only one
    else
    {
        // 设置cell背景色
        [view setBackgroundColor:[UIColor colorWithRGB:0xe5e5e5 alpha:1.0f]];
    }
    
    [self setSelectedBackgroundView:view];
}

@end
