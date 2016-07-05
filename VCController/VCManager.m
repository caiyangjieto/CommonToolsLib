//
//  VCManager.m
//  Flight
//
//  Created by caiyangjieto on 16/6/13.
//  Copyright © 2016年 just. All rights reserved.
//

#import "VCManager.h"

@implementation VCManager

// 全局数据控制器
static VCManager *globalVCController = nil;

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        globalVCController = [[super allocWithZone:NULL] init];
        [globalVCController.view setBackgroundColor:[UIColor blueColor]];
        [globalVCController setNavigationBarHidden:YES animated:NO];
        
    });
    
    return globalVCController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
