//
//  FCityTagTableViewCell.h
//  Flight
//
//  Created by songyangyang on 15-4-27.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//
//  迁移时间 2015-10-23 15:00
#import <UIKit/UIKit.h>

typedef void(^SelectTagCityCallBackBlock)(NSIndexPath *, NSInteger);

@interface FCityTagTableViewCell : UITableViewCell

@property (nonatomic, copy)   SelectTagCityCallBackBlock selectTagCityBlock;
@property (nonatomic, assign) BOOL isHasIndexBar;
@property (nonatomic, strong) NSArray *cityInfoArray;//其中对象为 FCityTagInfo

@property (nonatomic, assign) NSInteger buttonTotal;

@end


// 数据model
@interface FCityTagInfo : NSObject

@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger indexLine;
@property (nonatomic, strong) NSString *ext;

@end