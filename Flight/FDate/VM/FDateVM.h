//
//  FDateVM.h
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDateItem.h"
#import "FDateLogic.h"

@interface FDateVM : NSObject

//输入
@property (nonatomic, strong) FDateLogic *dateLogic;
@property (nonatomic, strong) NSArray    *arrayPrices;

//输出
@property (nonatomic, strong, readonly) NSMutableArray *arrayTitleText;
@property (nonatomic, strong, readonly) NSMutableArray *arraySectonData;
@property (nonatomic, assign, readonly) NSInteger      indexSecton;

//构造
- (void)setupDateDataModel;

@end
