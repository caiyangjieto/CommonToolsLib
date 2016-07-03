//
//  FCitySelectItemInfo.h
//  Flight
//
//  Created by qitmac000010 on 14/11/11.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//
//  迁移时间 2015-10-23 15:00

#import <Foundation/Foundation.h>
#import "FCityVCModel.h"

@interface FCitySelectItemInfo : NSObject

@property (nonatomic, strong) NSString *sectionTitle;       // 所属的Title
@property (nonatomic, strong) NSString *searchName;         // 搜索名称
@property (nonatomic, strong) NSString *displayName;        // 显示名称
@property (nonatomic, strong) NSString *recommendCity;      // 推荐城市
@property (nonatomic, strong) NSNumber *isInter;            // 是否是国际城市
@property (nonatomic, strong) NSString *country;            // 国家名
@property (nonatomic, strong) NSString *ext;


- (FCitySelectItemInfo *)initWithFCityCellInfo:(FCityCellInfo *)fCityItem;

@end
