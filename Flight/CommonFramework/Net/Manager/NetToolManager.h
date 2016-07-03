//
//  NetToolManager.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetToolDownLoader.h"

@interface NetToolManager : NSObject

+ (NetToolManager *)getInstance;

//添加connection
- (void)addConnection:(NetToolDownLoader *)connection andDelegate:(id)delegate;

// 完成
- (void)finishConnection:(NetToolDownLoader *)connection result:(NSData *)result;

// 删除
- (void)removeConnection:(NetToolDownLoader *)connection;
- (void)removeService:(NSString *)service;
- (void)removeTarget:(id)target;

// 销毁
- (void)destroy;

@end
