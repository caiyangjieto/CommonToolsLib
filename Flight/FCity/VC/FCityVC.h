//
//  FCityVC.h
//
//  Created by caiyangjieto on 16-1-24.
//

#import "FSearchBar.h"

//顶部tab选择序号
typedef NS_ENUM(NSInteger, FCityVCTabType) {
    FCityVCTabTypeDomesticCity      = 0,
    FCityVCTabTypeInternationalCity = 1,
};

//区域块
typedef NS_ENUM(NSInteger, FCityVCSectionType) {
    FCityVCSectionAllCity       = 0,
    FCityVCSectionGPS           = 1<<0,
    FCityVCSectionHistory       = 1<<1,
    FCityVCSectionHotCity       = 1<<2,
    FCityVCSectionNormalCity    = 1<<3,
};

//类型
typedef NS_ENUM(NSInteger, FCityType){
    eFCityInAndOutType = 0,
    eFCityInType,
};

typedef NS_ENUM(NSInteger, FCityHotType)
{
    eFCityHotDeptType = 0,
    eFCityHotArrivalType,
};


@protocol FCityVCDelgt <NSObject>

- (void)fCityVCReturnCity:(NSString *)city nation:(NSString *)nation isInterCity:(BOOL)isInterCity andInfo:(id)delgtInfo;

@end

@interface FCityVC : NaviNameVC <UITableViewDataSource,UITableViewDelegate,FSearchBarDelgt,CLLocationManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) NSString *naviBarTitle;					// 导航栏标题
@property (nonatomic, strong) NSString *curCityName;					// 当前选中城市
@property (nonatomic, assign) FCityVCTabType curCityType;               // 当前类型（0:国内 1:国际）
@property (nonatomic, assign) FCityType fCityType;						// 能够切换国内国外城市
@property (nonatomic, assign) FCityHotType fCityHotType;                // 热门城市类型
@property (nonatomic, assign) FCityVCSectionType fCityVCSectionType;    // 配置显示区域

@property (nonatomic, weak)   id<FCityVCDelgt> delegate;
@property (nonatomic, strong) id delgtInfo;                             // 回调函数参数

//判重
@property (nonatomic, strong) NSString *otherCityName;                  // 判重城市名称


@end
