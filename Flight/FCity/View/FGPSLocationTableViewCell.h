//
//  FGPSLocationTableViewCell.h
//  Flight
//
//  Created by songyangyang on 15-4-27.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//
//  迁移时间 2015-10-23 15:00
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GPSButtonPressType)
{
    GPSButtonPressTypeCity = 1,
    GPSButtonPressTypeRetry = 2,
};

typedef void(^CallBackBlock)(GPSButtonPressType);

@interface FGPSLocationTableViewCell : UITableViewCell

@property (nonatomic, copy) CallBackBlock callBack;

- (void)setupLocateInfo:(NSString *)locateCity state:(FGPSLocationStatus)locateState;

@end


