//
//  UITableViewCell+Utility.h
//  Flight
//
//  Created by qitmac000224 on 16/6/13.
//  Copyright © 2016年 just. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Utility)

@property (nonatomic, assign) CGFloat bottomLineWidth;                


- (void)setBGViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath;

- (void)setSelectedViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath;

- (void)setBGViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath withLineColor:(UIColor *)lineColor;

- (void)setSelectedViewInTableView:(UITableView *)tableView AtIndexPath:(NSIndexPath *)indexPath withLineColor:(UIColor *)lineColor;

@end
