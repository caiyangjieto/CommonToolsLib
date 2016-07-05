//
//  NetworkPtc.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

@protocol NetworkPtc <NSObject>

@optional

// 获取网络请求回调
- (void)getSearchNetBack:(id)searchResult forInfo:(id)customInfo;

@end
