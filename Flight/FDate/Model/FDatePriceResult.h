//
//  FDatePriceResult.h
//  Flight
//
//  Created by qitmac000224 on 16/6/20.
//  Copyright © 2016年 just. All rights reserved.
//

#import "NetToolResult.h"

@class FDatePriceItem;
@interface FDatePriceResult : NetToolResult

@property (nonatomic, strong,getter = lowPrices)   NSArray   QiniskyArray(lowPrices,FDatePriceItem);

@end

@interface FDatePriceItem : NSObject

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSNumber *price;

@end