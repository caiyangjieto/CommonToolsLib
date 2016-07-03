//
//  FDateRangeHandle.h
//  Flight
//
//  Created by qitmac000224 on 16/6/17.
//  Copyright © 2016年 just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FDateItem.h"

@interface FDateRangeHandle : NSObject

@property (nonatomic, strong, readonly) NSMutableArray        *arrayDate;//FDateItem
@property (nonatomic, strong, readonly) NSMutableDictionary   *dictDate;//"yyyy-MM-dd":FDateItem

- (void)handleMinDate:(NSDate *)minVDate maxDate:(NSDate *)maxDate;

@end
