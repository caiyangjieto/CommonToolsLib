//
//  FDateLogic.h
//  Flight
//
//  Created by qitmac000224 on 16/6/14.
//  Copyright © 2016年 just. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDateLogic : NSObject

@property (nonatomic, strong) NSDate *minValidDate;	// 最小有效日期
@property (nonatomic, strong) NSDate *maxValidDate;	// 最大有效日期
@property (nonatomic, strong) NSDate *minSelectDate;// 最小选中日期
@property (nonatomic, strong) NSDate *maxSelectDate;// 最大选中日期

@end
