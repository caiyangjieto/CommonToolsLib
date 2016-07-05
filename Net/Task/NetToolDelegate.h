//
//  NetToolDelegate.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetToolResult.h"
#import "NetworkPtc.h"

@interface NetToolDelegate : NSObject

@property(nonatomic,assign) BOOL needCache;//返回结果是否需要缓存
@property(nonatomic,strong) NSString *service;

@property(nonatomic,weak) id<NetworkPtc> delegate;
@property(nonatomic,weak) id customInfo;
@property(nonatomic,strong) NetToolResult *netToolResult;	// 结果数据

@end
