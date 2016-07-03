//
//  FDateWeekCell.h
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import "FBaseCell.h"
#import "FDateItem.h"

@protocol FDateWeekCellDelgt <NSObject>

- (void)onClickCellItem:(FDateItem *)fDateItem;

@end

@interface FDateWeekCell : FBaseCell

@property (nonatomic, weak)  id<FDateWeekCellDelgt> delegate;

+ (NSInteger)getCellHeight;

- (void)setupSubView;
- (void)setupCellSubViews:(NSArray *)arrayWeeks;

@end
