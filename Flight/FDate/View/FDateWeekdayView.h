//
//  FDateWeekdayView.h
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDateItem.h"

@interface FDateWeekdayView : UIButton

@property (nonatomic, strong)  FDateItem  *fDateItem;

+ (NSInteger)getItemHeight;
- (void)setupSubview;

@end
