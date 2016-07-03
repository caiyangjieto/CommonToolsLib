//
//  FCityVCListDataSource.h
//  Flight
//
//  Created by qitmac000224 on 15/7/8.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//
//  迁移时间 2015-10-23 15:00

#import <Foundation/Foundation.h>
#import "FCityVC.h"
#import "FDBManager.h"
#import "FCityVCModel.h"
#import "FCityTagTableViewCell.h"
#import "FCitySelectItemInfo.h"

@interface FCityVCListVM : NSObject

@property (nonatomic, assign) FCityVCSectionType    fCityVCSectionType;    // 配置显示区域

// 根据热门城市类型和每行的显示个数来初始化
- (id)initWithHotType:(FCityHotType)fCityHotType cityName:(NSString *)curCityName tagCount:(NSInteger)tagCount;


- (void)loadDomesticDataToCache;
- (void)loadInterDataToCache;

// 得到对应tab的list数据
- (FCityVCModel *)getCityListTableData:(FCityVCTabType)fCityVCTabType;


- (void)saveInHistory:(FCitySelectItemInfo *)fCitySelectItemInfo;
- (void)saveOutHistory:(FCitySelectItemInfo *)fCitySelectItemInfo;

@end
