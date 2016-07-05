//
//  NetToolResult.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalNetResult.h"

@interface NetToolResult : NSObject

@property(nonatomic,strong) GlobalNetResult     *bstatus;

//解析全局数据
- (void)parseAllNetResult:(NSDictionary *)jsonDictionary;

@end
