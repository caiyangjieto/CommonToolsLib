//
//  FRefreshControl.h
//  Flight
//
//  Created by caiyangjieto on 16/3/3.
//  Copyright © 2016年 just. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRefreshControl : UIControl

@property (nonatomic, strong) NSString *startText;       // 未达到触发刷新时的文案
@property (nonatomic, strong) NSString *hintText;       // 达到触发刷新时的文案
@property (nonatomic, strong) NSString *loadingText;    // 刷新中...文案

- (id)initInScrollView:(UIScrollView *)scrollView;

- (void)beginRefreshing;

- (void)endRefreshing;

@end
