//
//  FCityListVCData.h
//  Flight
//
//  Created by qitmac000224 on 15/7/13.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//  迁移时间 2015-10-23 15:00

#import <Foundation/Foundation.h>

@interface FCityVCModel : NSObject

@property (nonatomic, strong) NSMutableArray *arrayIndexName;               // 右侧城市索引（热门A-Z）
@property (nonatomic, strong) NSMutableArray *arraySectionName;             // 每个section上的文案
@property (nonatomic, strong) NSMutableArray *arraySectionLogo;             // 每个section上的logo
@property (nonatomic, strong) NSMutableArray *arraySectionCount;            // 每个section里面的个数
@property (nonatomic, strong) NSMutableArray *arrayDefCellData;             // 定位cell数组
@property (nonatomic, strong) NSMutableArray *arrayTagCellData;             // tag标签cell数组   FCityTagInfo
@property (nonatomic, strong) NSMutableArray *arrayCityCellData;            // 普通城市cell数组   FCityCellInfo

@end




@interface FCityCellInfo : NSObject

@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSString *displaySubText;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) NSString *recommendCity;
@property (nonatomic, strong) NSString *airportCode;
@property (nonatomic, strong) NSString *sectionTitle;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isDataFromNet;           // 数据来源于网络

@end