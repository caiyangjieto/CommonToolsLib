//
//  NetToolResult.m
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import "NetToolResult.h"

@implementation NetToolResult

//解析全局数据
- (void)parseAllNetResult:(NSDictionary *)jsonDictionary
{
    
    _bstatus = [[GlobalNetResult alloc] init];
    
    NSDictionary *dictionaryMeta = [jsonDictionary objectForKey:@"bstatus"];
    if(dictionaryMeta != nil && ![dictionaryMeta isKindOfClass:[NSNull class]])
    {
        [SerializeUtility parseJsonObject:dictionaryMeta withObject:_bstatus];
    }

    NSDictionary *dictionaryData = [jsonDictionary objectForKey:@"data"];
    if(dictionaryData != nil && ![dictionaryData isKindOfClass:[NSNull class]])
    {
        [SerializeUtility parseJsonObject:dictionaryData withObject:self];
    }
}

@end
