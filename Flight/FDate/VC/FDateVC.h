//
//  FDateVC.h
//  Flight
//
//  Created by qitmac000224 on 16/6/14.
//  Copyright © 2016年 just. All rights reserved.
//

#import "NaviNameVC.h"
#import "FDateLogic.h"

@protocol FDateVCDelgt <NSObject>

- (void)fDateVCDepDate:(NSDate *)depDate arrDate:(NSDate *)arrDate;

@end

@interface FDateVC : NaviNameVC

@property (nonatomic, strong) NSString      *depCity;
@property (nonatomic, strong) NSString      *arrCity;
@property (nonatomic, strong) FDateLogic    *dateLogic;
@property (nonatomic, assign) BOOL          needArrDate;

@property (nonatomic, weak) id<FDateVCDelgt> delegate;

@end
