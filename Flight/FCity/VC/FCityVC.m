//
//  FCityVC.m
//
//  Created by mt on 13-1-24.
//  

#import "FCityVC.h"
#import "FUserLocationResult.h"
#import "FCitySelectItemInfo.h"
#import "FGPSLocationTableViewCell.h"
#import "FCityTagTableViewCell.h"
#import "FCityVCListVM.h"
#import "FCityVCSearchVM.h"
#import "FCityVCModel.h"
#import "FIndexTableView.h"
#import "FSegControl.h"
#import "FCitySearchResult.h"

// 控件尺寸
#define	kCitySearchBarHeight						44
#define kCityListCellHeight							45
#define kCitySearchResultCellHeight					45
#define	kCityTableHeaderHeight						27
#define	kFCityCheckImageWidth						20
#define	kFCityCheckImageHeight						20
#define kFCityTabBarHeight                          40
#define	kFCityTipViewWidth                          63
#define	kFCityTipViewHeight                         63

// 间距
#define kCityListCellHMargin						50
#define kCityListSearchHMargin						15
#define kCityListHeaderHMargin						15
#define kCityListCityCellHMargin					10


// 控件字体
#define kFCityGPSCityTextFont						kCurNormalFontOfSize(14)
#define kFCityRetryButtonTitleFont					kCurNormalFontOfSize(14)
#define kFCityListCityNameFont						kCurNormalFontOfSize(14)
#define kFCityListCitySubNameFont					kCurNormalFontOfSize(12)
#define kFCitySectionHeaderTitleLabelFont			kCurNormalFontOfSize(14)
#define kFCitySearchResultEmptyHintLabelFont		kCurNormalFontOfSize(16)

//根据屏幕 设定布局个数
#define isIPhone6PlusScreen ((kScreenWidth - 414) < 5 ? YES:NO)

static NSString *GPSLocationTabelViewCellIdentifier = @"GPSLocationTabelViewCellIdentifier";
static NSString *TagCityTableViewCellIdentifier     = @"TagCityTableViewCellIdentifier";
static NSString *NormalCityTableViewCellIdentifier  = @"NormalCityTableViewCellIdentifier";

static NSString *SearchCityTableViewCellIdentifier  = @"SearchCityTableViewCellIdentifier";
static NSString *NOCityTableViewCellIdentifier      = @"NOCityTableViewCellIdentifier";


// 控件Tag值
enum  {
    kFCityListCityCheckImageViewTag = 101,
    kFCityListCityNameLabelTag,
    kFCityListCitySubNameLabelTag,
    kFCitySearchResultEmptyHintLabelTag,
    
    KFCityShowInterCityNoticeTipTag,
};

// 搜索框状态
typedef enum
{
    eFCityVCSearchBarNormal,
    eFCityVCSearchBarStartEdit,
    eFCityVCSearchBarEditing,
    eFCityVCSearchBarLoading,
    eFCityVCSearchBarNetBack,
    eFCityVCSearchBarFinish,
}FCityVCSearchBarStatus;

@interface FCityVC() <FCityDataQueryDelgt,FIndexTableViewDelgt,UIAlertViewDelegate,FSegControlDelgt>

//View
@property (nonatomic, strong) FSearchBar                 *searchBar;				// 搜索框
@property (nonatomic, strong) UIView                    *viewMask;				// Mask视图
@property (nonatomic, strong) FIndexTableView           *tableViewCityList;		// 城市列表视图
@property (nonatomic, strong) FIndexTableView           *tableViewSearchList;	// 搜索结果列表
@property (nonatomic, strong) FSegControl               *typeTabControl;        // 国内国际选择

//搜索组件
@property (nonatomic, strong) CLLocationManager         *locationManager;		// 定位管理器
@property (nonatomic, strong) FUserLocationResult       *locationResult;		// 定位结果
@property (nonatomic, assign) FGPSLocationStatus        locationStatus;         // GPS定位状态 使用setter方法 涉及状态转换

//显示tab
@property (nonatomic, strong) FCityVCListVM     *fCityListDataSource;
@property (nonatomic, strong) FCityVCModel           *fCityListVCData;

//搜索tab
@property (nonatomic, strong) FCityVCSearchVM   *fSearchDataSource;
@property (nonatomic, strong) FCityVCModel           *fSearchListVCData;
@property (nonatomic, assign) FCityVCSearchBarStatus    fSearchBarStatus;       // 搜索框的状态
@property (nonatomic, strong) NSString                  *searchKeyText;         // 搜索关键字

@property (nonatomic, assign) NSInteger                 buttonTotal;            // 每行tag的个数
@property (nonatomic, strong) NSOperationQueue          *queueReadData;
@property (nonatomic, strong) FCitySelectItemInfo       *choosedSelectItemInfo;

@end

@implementation FCityVC

- (void)dealloc
{
    // 注销消息
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCityLocationNotification object:nil];
    
    [_queueReadData cancelAllOperations];
    _queueReadData = nil;
    
    if(_locationManager)
    {
        [_locationManager stopUpdatingLocation];
        [_locationManager setDelegate:nil];
    }
    
    [_searchBar setDelegate:nil];
    
    [_tableViewCityList setDelegate:nil];
    [_tableViewCityList setDataSource:nil];
    
    [_tableViewSearchList setDelegate:nil];
    [_tableViewSearchList setDataSource:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 注册定位消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStartLocation)
                                                 name:kCityLocationNotification object:nil];
    
    //根据屏幕展示个数
    _buttonTotal = isIPhone6PlusScreen?4:3;
    
    [self loadAllCityData];
    
    [self setupViewRootSubs:self.view];
    
    [self startLocation];
}

- (void)loadAllCityData
{
    //创建城市列表数据源
    _fCityListDataSource = [[FCityVCListVM alloc] initWithHotType:_fCityHotType cityName:_curCityName tagCount:_buttonTotal];
    [_fCityListDataSource setFCityVCSectionType:_fCityVCSectionType];
    
    //后台数据处理线程
    _queueReadData = [[NSOperationQueue alloc] init];
    [_queueReadData setMaxConcurrentOperationCount:1];
    
    @WeakObj(self)
    // 读国内数据库
    NSBlockOperation *operationLoadDomesticCache = [NSBlockOperation blockOperationWithBlock:^(){
        [selfWeak.fCityListDataSource loadDomesticDataToCache];
        dispatch_async(dispatch_get_main_queue(), ^{
            @StrongObj(self)
            if (selfStrong) {
                [selfStrong seutpCityListData];
            }
        });
    }];
    [_queueReadData addOperation:operationLoadDomesticCache];
    
    // 读国际数据库
    NSBlockOperation *operationLoadInterCache = [NSBlockOperation blockOperationWithBlock:^(){
        [selfWeak.fCityListDataSource loadInterDataToCache];
        dispatch_async(dispatch_get_main_queue(), ^{
            @StrongObj(self)
            if (selfStrong) {
                [selfStrong seutpCityListData];
            }
        });
    }];
    [_queueReadData addOperation:operationLoadInterCache];
}

- (void)goBack
{
    [VCController popWithAnimation:[VCAnimationBottom defaultAnimation]];
}

#pragma mark - 布局函数
// 创建Root View的子界面
- (void)setupViewRootSubs:(UIView *)viewParent
{
    // 父窗口属性
    CGRect parentFrame = [viewParent frame];
    
    // 子窗口高宽
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = parentFrame.size.height;
    
    // ====================================================================
    // FNaviBar // 创建FNaviBar子界面
    // ====================================================================
    [self setupNaviBarSubs:[self naviBar]];
    
    // 调整Y值
    spaceYStart += [[self naviBar] frame].size.height;
    
    // ====================================================================
    // ViewMask
    // ====================================================================
    _viewMask = [[UIView alloc] initWithFrame:CGRectZero];
    [_viewMask setFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, spaceYEnd - spaceYStart)];
    [_viewMask setBackgroundColor:[UIColor colorWithRGB:0x000000 alpha:0.6]];
    [_viewMask setHidden:YES];
    
    [self setupViewMaskSubs:_viewMask];
    [viewParent addSubview:_viewMask];
    
    // ====================================================================
    // tableViewSearchList
    // ====================================================================
    _tableViewSearchList = [[FIndexTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableViewSearchList setFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, spaceYEnd - spaceYStart)];
    [_tableViewSearchList setDataSource:self];
    [_tableViewSearchList setDelegate:self];
    [_tableViewSearchList setDelegateIndexView:self];
    [_tableViewSearchList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableViewSearchList setBackgroundColor:[UIColor clearColor]];
    [_tableViewSearchList setBackgroundView:nil];
    [_tableViewSearchList setHidden:YES];
    
    [viewParent addSubview:_tableViewSearchList];
    
    // =======================================================================
    // FlightTabControl
    // =======================================================================
    if(_fCityType == eFCityInAndOutType)
    {
        _typeTabControl = [[FSegControl alloc] initWithFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, kFCityTabBarHeight)];
        [_typeTabControl setDelegate:self];
        
        [_typeTabControl appendSegItemWithTitle:@"国内"];
        [_typeTabControl appendSegItemWithTitle:@"国际/港澳台"];
        [_typeTabControl setSelectedSegIndex:_curCityType];
        
        [viewParent addSubview:_typeTabControl];
        spaceYStart += _typeTabControl.frame.size.height;
    }
    
    // ====================================================================
    // tableViewCitylist
    // ====================================================================
    _tableViewCityList = [[FIndexTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableViewCityList setFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, spaceYEnd - spaceYStart)];
    [_tableViewCityList setDataSource:self];
    [_tableViewCityList setDelegate:self];
    [_tableViewCityList setDelegateIndexView:self];
    [_tableViewCityList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableViewCityList setBackgroundColor:[UIColor clearColor]];
    [_tableViewCityList setBackgroundView:nil];
    [viewParent addSubview:_tableViewCityList];
    
    // 调整顺序
    [viewParent bringSubviewToFront:_viewMask];
    [viewParent bringSubviewToFront:_tableViewSearchList];
}

#pragma mark - 界面布局辅助函数
// 创建viewMask的子视图
- (void)setupViewMaskSubs:(UIView *)viewParent
{
    UIButton *buttonTap = [[UIButton alloc] initWithFrame:[viewParent bounds]];
    [buttonTap setBackgroundColor:[UIColor clearColor]];
    [buttonTap addTarget:self action:@selector(searchCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    [viewParent addSubview:buttonTap];
}

// 创建NavigationBar的子界面
- (void)setupNaviBarSubs:(FNaviBar *)viewParent
{
    CGRect parentFrame = [viewParent frame];
    
    FNaviBarItem *rightItem = [[FNaviBarItem alloc] initTextItem:kCustomerFontBackX font:kCustomerFontOfSize(24) target:self action:@selector(goBack)];
    [[self naviBar] setRightBarItem:rightItem];
    
    [viewParent setTitle:!IsStrEmpty(_naviBarTitle) ? _naviBarTitle : @"选择城市"];
    
    // ====================================================================
    // searchBar
    // ====================================================================
    CGRect searchBarFrame = CGRectMake(0, parentFrame.size.height - kCitySearchBarHeight, parentFrame.size.width-viewParent.rightBarItem.frame.size.width, kCitySearchBarHeight);
    
    _searchBar = [[FSearchBar alloc] initWithFrame:searchBarFrame andButton:@"取消"];
    [_searchBar setPlaceHolder:@"北京/bj/beijing/pek/中国"];
    [_searchBar showBarButton:NO animated:NO];
    [_searchBar setReturnKeyType:UIReturnKeyDone];
    [_searchBar setDelegate:self];
    
    [viewParent addSubview:_searchBar];
}

// 初始化城市列表Cell的子视图
- (void)initCellCityListSubs:(UIView *)viewParent
{
    UILabel *imageView = [[UILabel alloc] initWithFont:kCustomerFontOfSize(20) andText:kCustomerFontSelectArrow];
    [imageView setTextColor:[UIColor flightThemeSideColor]];
    [imageView setTextAlignment:NSTextAlignmentCenter];
    [imageView setTag:kFCityListCityCheckImageViewTag];
    [viewParent addSubview:imageView];
    
    // 城市名
    UILabel *labelCityName = [[UILabel alloc] initWithFont:kFCityListCityNameFont andText:@""];
    [labelCityName setTag:kFCityListCityNameLabelTag];
    [viewParent addSubview:labelCityName];
    
    // 城市副名
    UILabel *labelCitySubName = [[UILabel alloc] initWithFont:kFCityListCitySubNameFont andText:@""];
    [labelCitySubName setTag:kFCityListCitySubNameLabelTag];
    [labelCitySubName setTextColor:[UIColor flightThemeColor]];
    [viewParent addSubview:labelCitySubName];
}

// 创建城市列表Cell的子视图
- (void)setupCellCityListSubs:(UIView *)viewParent inSize:(CGSize *)pViewSize cityItem:(FCityCellInfo *)fCityResult
{
    NSString *cityText = [fCityResult displayText];
    NSString *citySubText = [fCityResult displaySubText];
    BOOL isSelected = fCityResult.isSelected;
    
    NSInteger spaceXStart = 0;
    
    if (isSelected)
    {
        UILabel *imageView = (UILabel *)[viewParent viewWithTag:kFCityListCityCheckImageViewTag];
        [imageView setFrame:CGRectMake((kCityListCellHMargin - kFCityCheckImageWidth)/2, (NSInteger)((pViewSize->height - kFCityCheckImageHeight) / 2), kFCityCheckImageWidth, kFCityCheckImageHeight)];
        [imageView setHidden:NO];
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[viewParent viewWithTag:kFCityListCityCheckImageViewTag];
        [imageView setHidden:YES];
    }
    
    spaceXStart += kCityListCellHMargin;
    
    CGSize cityTextSize = [cityText sizeWithFontCompatible:kFCityListCityNameFont];
    CGSize subTextSize = [citySubText sizeWithFontCompatible:kFCityListCitySubNameFont];
    if(viewParent != nil)
    {
        UILabel *labelCityName = (UILabel *)[viewParent viewWithTag:kFCityListCityNameLabelTag];
        [labelCityName setFrame:CGRectMake(spaceXStart, (NSInteger)((pViewSize->height - cityTextSize.height) / 2),
                                           cityTextSize.width, cityTextSize.height)];
        [labelCityName setText:cityText];
        
        UILabel *labelSubName = (UILabel *)[viewParent viewWithTag:kFCityListCitySubNameLabelTag];
        [labelSubName setFrame:CGRectMake(labelCityName.right + kCityListCityCellHMargin,
                                          labelCityName.bottom - subTextSize.height,
                                          subTextSize.width, subTextSize.height)];
        [labelSubName setText:citySubText];
    }
}

// 创建Section的Header的子视图
- (void)setupCityHeaderSubs:(UIView *)viewParent title:(NSString *)title logo:(NSString *)logo
{
    if (IsStrEmpty(title))
        return;
    
    // 父窗口尺寸
    CGRect parentFrame = [viewParent frame];
    NSInteger spaceXStart = 0;
    
    spaceXStart += kCityListHeaderHMargin;
    
    {
        CGSize titleSize = [logo sizeWithFontCompatible:kCustomerFontOfSize(20)];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFont:kCustomerFontOfSize(20) andText:logo];
        [labelTitle setFrame:CGRectMake(spaceXStart, (NSInteger)(parentFrame.size.height - titleSize.height) / 2,
                                        titleSize.width, titleSize.height)];
        [labelTitle setTextColor:[UIColor flightThemeSideColor]];
        
        spaceXStart = labelTitle.right+5;
        
        [viewParent addSubview:labelTitle];
    }
    
    {
        CGSize titleSize = [title sizeWithFontCompatible:kFCitySectionHeaderTitleLabelFont];
        
        UILabel *labelTitle = [[UILabel alloc] initWithFont:kFCitySectionHeaderTitleLabelFont andText:title];
        [labelTitle setFrame:CGRectMake(spaceXStart, (NSInteger)(parentFrame.size.height - titleSize.height) / 2,
                                        titleSize.width, titleSize.height)];
        [labelTitle setTextColor:[UIColor blackColor]];
        
        [viewParent addSubview:labelTitle];
    }
    
}

// 创建搜索结果Cell的子视图
- (void)setupCellSearchResultSubs:(UIView *)viewParent inSize:(CGSize *)pViewSize citySearchResult:(FCityCellInfo *)fCityResult
{
    NSString *cityText = [fCityResult displayText];
    NSString *citySubText = [fCityResult displaySubText];
    
    NSInteger spaceXStart = kCityListSearchHMargin;
    
    CGSize cityTextSize = [cityText sizeWithFontCompatible:kFCityListCityNameFont];
    if(viewParent != nil)
    {
        UILabel *labelCityName = (UILabel *)[viewParent viewWithTag:kFCityListCityNameLabelTag];
        [labelCityName setFrame:CGRectMake(spaceXStart, (NSInteger)((pViewSize->height - cityTextSize.height) / 2),
                                           cityTextSize.width, cityTextSize.height)];
        [labelCityName setText:cityText];
        
        UILabel *labelSubName = (UILabel *)[viewParent viewWithTag:kFCityListCitySubNameLabelTag];
        if (!IsStrEmpty(citySubText))
        {
            CGSize subTextSize = [citySubText sizeWithFontCompatible:kFCityListCitySubNameFont];
            [labelSubName setFrame:CGRectMake(labelCityName.right + kCityListCityCellHMargin,
                                              labelCityName.bottom - subTextSize.height,
                                              subTextSize.width, subTextSize.height)];
            [labelSubName setHidden:NO];
            [labelSubName setText:citySubText];
        }
        else
        {
            [labelSubName setHidden:YES];
        }
        
    }
    
    UIImageView *imageView = (UIImageView *)[viewParent viewWithTag:kFCityListCityCheckImageViewTag];
    [imageView setHidden:YES];
}

// 初始化无结果cell的子视图
- (void)initCellEmptySubs:(UIView *)viewParent
{
    // =======================================================================
    // Hint Label
    // =======================================================================
    UILabel *labelHint = [[UILabel alloc] initWithFont:kCurNormalFontOfSize(16) andText:@""];
    [labelHint setTag:kFCitySearchResultEmptyHintLabelTag];
    [viewParent addSubview:labelHint];
}

// 创建无结果cell的子视图
- (void)setupCellEmptySubs:(UIView *)viewParent inSize:(CGSize *)pViewSize
{
    // =======================================================================
    // Hint Label
    // =======================================================================
    NSString *hintText = @"无结果";
    CGSize hintTextSize = [hintText sizeWithFontCompatible:kFCitySearchResultEmptyHintLabelFont];
    
    // 创建Label
    if(viewParent != nil)
    {
        UILabel *labelHint = (UILabel *)[viewParent viewWithTag:kFCitySearchResultEmptyHintLabelTag];
        [labelHint setFrame:CGRectMake((NSInteger)(pViewSize->width - hintTextSize.width) / 2,
                                       (NSInteger)(pViewSize->height - hintTextSize.height) / 2,
                                       hintTextSize.width, hintTextSize.height)];
        [labelHint setText:hintText];
    }
}

#pragma mark - 根据状态分发任务

- (void)seutpCityListData
{
    _fCityListVCData = [_fCityListDataSource getCityListTableData:_curCityType];
    [self seutpCityListTableView];
}

- (void)seutpCityListTableView
{
    switch (_curCityType)
    {
        case FCityVCTabTypeInternationalCity:
        {
            if (!_fCityListVCData)
            {
                [_tableViewCityList setHidden:YES];
                //[_loadingView setHidden:NO];
                return;
            }
            
            [self showInterCityNotice:nil];
            [_tableViewCityList setHidden:NO];
//            [self setErrorViewHidden:YES];
            [_tableViewCityList reloadData];
        }
            break;
        case FCityVCTabTypeDomesticCity:
        {
            if (!_fCityListVCData)
            {
                [_tableViewCityList setHidden:YES];
                return;
            }
            
            [_tableViewCityList setHidden:NO];
//            [self setErrorViewHidden:YES];
            [_tableViewCityList reloadData];
        }
            break;
    }

}

- (void)setupLocationStatus:(FGPSLocationStatus)locationStatus
{
    [_tableViewCityList reloadData];
    _locationStatus = locationStatus;
}

- (void)setupSearchBarStatus:(FCityVCSearchBarStatus)fSearchBarStatus
{
    if (!_fSearchDataSource)
    {
        _fSearchDataSource = [[FCityVCSearchVM alloc] initWithHotCityType:_fCityHotType];
        [_fSearchDataSource setDelegate:self];
    }
    
    switch (fSearchBarStatus)
    {
        case eFCityVCSearchBarNormal:
        {
            [_searchBar resignFirstResponder];
            [self endSearchAnimation];
            
            // 隐藏Mask
            [_viewMask setHidden:YES];
            [_tableViewSearchList setHidden:YES];
            
            // 清空搜索框
            [_searchBar setText:@""];
            
            // 取消搜索
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [_searchBar showIndicatorView:NO];
        }
            break;
        case eFCityVCSearchBarStartEdit:
        {
            //进入编辑状态
            if(_fSearchBarStatus != eFCityVCSearchBarStartEdit)
            {
                [_viewMask setHidden:NO];
                [self startSearchAnimation];
            }
        }
            break;
        case eFCityVCSearchBarEditing:
        {
            _fSearchListVCData = [_fSearchDataSource getCityListTableData];
            
            [_searchBar showIndicatorView:YES];
            
            if(IsStrEmpty(_searchKeyText))
            {
                [_searchBar showIndicatorView:NO];
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                
                if(_fSearchDataSource != nil)
                    _fSearchDataSource = nil;
                
                [_tableViewSearchList reloadData];
                [_tableViewSearchList setHidden:YES];
            }
            else
            {
                [self readyQueryCityKey:_searchKeyText];
            }
        }
            break;
        case eFCityVCSearchBarLoading:
        {
             [_searchBar showIndicatorView:YES];
        }
            break;
        case eFCityVCSearchBarNetBack:
        {
            _fSearchListVCData = [_fSearchDataSource getCityListTableData];
            
            [_tableViewSearchList setHidden:NO];
            [_tableViewSearchList reloadData];
            
            [_searchBar showIndicatorView:NO];
        }
            break;
        case eFCityVCSearchBarFinish:
        {
            [_searchBar resignFirstResponder];
        }
            break;
    }
    
    _fSearchBarStatus = fSearchBarStatus;
}

#pragma mark 网络请求回调
- (void)getSearch:(NSString *)serviceType forResult:(id)searchResult forInfo:(id)customInfo
{
//    [self stopNormalLoadingAnimation];
//    if ([serviceType isEqualToString:KFURLCitySuggest])
//    {
//        [self loadFCityListSuggestBack:searchResult];
//    }
//    else if ([serviceType isEqualToString:KFURLLoadLocationCity])
//    {
//        //定位城市信息
//        [self loadLocationCityBack:searchResult];
//    }
    
}

#pragma mark - 事件处理函数
- (void)changeSegValue:(NSInteger)indexSelected;
{
    _curCityType = indexSelected;
    [self seutpCityListData];
}

- (void)showInterCityNotice:(FCitySelectItemInfo *)fCitySelectItemInfo
{
//    // 国际第一次需要展示
//    if ([GetLocalData(kFlightInterAlertKey) boolValue] == NO)
//    {
//    
//        _choosedSelectItemInfo = fCitySelectItemInfo;
//        
//        [UIAlertView showAlertView:nil message:@"国际航班起落时间均是当地时间，请确认您的行程时间，以免耽误您的出行" delgt:self cancelTitle:@"下次再提示" otherTilte:nil andTag:KFCityShowInterCityNoticeTipTag];
//        SaveLocalData(@YES, kFlightInterAlertKey);
//        
//        return;
//    }
    
    [self chooseCity:fCitySelectItemInfo];
}

// 选择城市
- (void)chooseCity:(FCitySelectItemInfo *)fCitySelectItemInfo
{
    if (!fCitySelectItemInfo)
        return;
    
    // 单选需要校验 是否与另外一个城市相同
    if(!IsStrEmpty(_otherCityName) && [_otherCityName isEqualToString:[fCitySelectItemInfo searchName]])
    {
        [UIAlertView showAlertView:nil message:@"出发城市和到达城市不能相同哦" delgt:nil cancelTitle:@"确定" otherTilte:nil];
        return;
    }
    
    BOOL isChinaCity = [self isChinaCity:fCitySelectItemInfo];
    BOOL isInterCity = [self isInterCity:fCitySelectItemInfo];
    
    if (isChinaCity)
        [_fCityListDataSource saveInHistory:fCitySelectItemInfo];
    
    if (isInterCity)
        [_fCityListDataSource saveOutHistory:fCitySelectItemInfo];
    
    [self fCityVCReturnCity:[fCitySelectItemInfo searchName] nation:[fCitySelectItemInfo country] isInterCity:isInterCity];
}

- (BOOL)isInterCity:(FCitySelectItemInfo *)fCitySelectItemInfo
{
    NSString *country = [fCitySelectItemInfo country];
    FCityNationType fCityNationType = [FCity checkCountryNationType:country];
    if (fCityNationType==FCityInterType || fCityNationType==FCitySpecialType)
        return YES;
    else if ([fCitySelectItemInfo isInter] && [[fCitySelectItemInfo isInter] boolValue])
        return YES;
    
    return NO;
}

- (BOOL)isChinaCity:(FCitySelectItemInfo *)fCitySelectItemInfo
{
    NSString *country = [fCitySelectItemInfo country];
    FCityNationType fCityNationType = [FCity checkCountryNationType:country];
    if (fCityNationType==FCityDomesticType || fCityNationType==FCitySpecialType)
        return YES;
    else if ([fCitySelectItemInfo isInter] && [[fCitySelectItemInfo isInter] boolValue] == NO)
        return YES;
    
    return NO;
}

- (void)fCityVCReturnCity:(NSString *)city nation:(NSString *)nation isInterCity:(BOOL)isInterCity
{
    if (_delegate && [_delegate respondsToSelector:@selector(fCityVCReturnCity:nation:isInterCity:andInfo:)])
    {
        [_delegate fCityVCReturnCity:city nation:nil isInterCity:isInterCity andInfo:_delgtInfo];
    }
    
    [self goBack];
}

#pragma mark - 搜索相关
// 关键字搜索
- (void)readyQueryCityKey:(NSString *)newkeyword
{
    // 如果有网络搜索取消
    [FlightNetTask cancelNetRequestsWithSearch:citySearchInterface];
    
    // 取消延迟加载函数
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 延迟请求搜索关键字提示数据
    [self performSelector:@selector(startQueryCityData:) withObject:newkeyword afterDelay:0.5];
}

- (void)startQueryCityData:(NSString *)newkeyword
{
    [_fSearchDataSource startSearchSuggestCity:newkeyword];
}

- (void)queryCityDataBack:(BOOL)isResult
{
    if (isResult)
    {
        [self setupSearchBarStatus:eFCityVCSearchBarNetBack];
    }
    else
    {
        [self loadFCityListSuggest:_searchKeyText];
    }
}

- (void)loadFCityListSuggest:(NSString *)queryWord
{
#warning caiyangjieto
//    if (IsStrEmpty(queryWord))
//        return;
//    
//    // 组织Json数据
//    NSMutableDictionary *dictionaryJson = [[NSMutableDictionary alloc] init];
//    [dictionaryJson setObjectSafe:queryWord forKey:@"queryword"];
//    
//    // suggest是否只是国内
//    if(_fCityType == eFCityInType)
//    {
//        [dictionaryJson setObjectSafe:@1 forKey:@"onlyShowDomestic"];
//    }
//    else
//    {
//        [dictionaryJson setObjectSafe:@0 forKey:@"onlyShowDomestic"];
//    }
//    
//    NetConnection *netConnection = [FSearchNetworkTask postSearch:KFURLCitySuggest
//                                                      forParamDic:dictionaryJson
//                                                           forRes:NO
//                                                        withDelgt:self
//                                                       withResult:[[FCitySearchSuggestResult alloc] init] withInfo:nil];
//    if(netConnection != nil)
//    {
//        [_searchBar showIndicatorView:YES];
//    }
}

- (void)loadFCityListSuggestBack:(id)result
{
    FCitySearchResult *searchResult = (FCitySearchResult *)result;
    NSNumber *returnCode = [[searchResult bstatus] code];
    
    // 获取数据成功
    if(returnCode != nil && [returnCode intValue] == 0)
    {
        NSMutableArray *arraySearchResultTmp = [[NSMutableArray alloc] init];
        
        // 城市列表赋值
        NSArray *arrayCity = [searchResult cities];
        for(FSearchCity *fCity in arrayCity)
        {
            // 保存搜索结果
            FCityCellInfo *fCityCellInfo = [[FCityCellInfo alloc] init];
            [fCityCellInfo setDisplayText:[fCity displayName]];
            [fCityCellInfo setRecommendCity:[fCity realName]];
            [fCityCellInfo setSearchName:[fCity realName]];
            [fCityCellInfo setCountry:[fCity country]];
            [fCityCellInfo setIsDataFromNet:YES];
            [arraySearchResultTmp addObject:fCityCellInfo];
        }
        
        [_fSearchDataSource setArraySearchResult:arraySearchResultTmp];
    }
    else
    {
        [_fSearchDataSource setArraySearchResult:nil];
    }
    
    [self setupSearchBarStatus:eFCityVCSearchBarNetBack];
    
    // 国家搜索
    FSearchCountry *fCountry = [searchResult countrys];
    if(fCountry && !IsStrEmpty([fCountry countryName]))
    {
        [self startQueryCountryKey:[fCountry countryName] arrayHotCity:[fCountry cities]];
        [self setupSearchBarStatus:eFCityVCSearchBarLoading];
    }
}

// 仅搜索国家
- (void)startQueryCountryKey:(NSString *)countryName arrayHotCity:(NSArray *)citys
{
    [_fSearchDataSource startSearchSuggestCountry:countryName arrayHotCity:citys];
}

- (void)queryCountryDataBack:(BOOL)isResult
{
    if (isResult)
    {
        [self setupSearchBarStatus:eFCityVCSearchBarNetBack];
    }
}

#pragma mark - UITableViewDataSource
// =======================================================================
// UITableViewDataSource
// =======================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _tableViewCityList)
    {
        return [_fCityListVCData.arraySectionCount count];
        
    }
    else if(tableView == _tableViewSearchList)
    {
        return [_fSearchListVCData.arraySectionCount count];
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 城市列表
    if(tableView == _tableViewCityList)
    {
        return [[_fCityListVCData.arraySectionCount objectAtIndexSafe:section] integerValue];
    }
    // 搜索结果列表
    else if(tableView == _tableViewSearchList)
    {
        return [[_fSearchListVCData.arraySectionCount objectAtIndexSafe:section] integerValue];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    // 城市列表
    if(tableView == _tableViewCityList)
    {
        //自定义 tagcell 的个数
        NSInteger defCellCount = [_fCityListVCData.arrayDefCellData count];
        NSInteger tagCellCount = [_fCityListVCData.arrayTagCellData count];
        NSInteger cityCellCount = [_fCityListVCData.arrayCityCellData count];
        
        // 自定义cell ==》GPS
        if (section < defCellCount)
        {
            return [self getGPSLocationCell:tableView];
        }
        //TagCell
        else if ((section - defCellCount) < tagCellCount)
        {
            section = section - defCellCount;
            
            NSArray *array = [_fCityListVCData.arrayTagCellData objectAtIndexSafe:section];
            if(row < [array count])
            {
                BOOL hasIndexBar = NO;
                if (!IsArrEmpty(_fCityListVCData.arrayIndexName))
                    hasIndexBar = YES;
                
                NSArray *cityInfo = [array objectAtIndexSafe:row];
                [self setupTagCellIndex:cityInfo indexPath:indexPath];
                
                return [self getTagInfoListCell:tableView cityInfo:cityInfo indexBar:hasIndexBar];
            }
        }
        //减掉Tag
        else if ((section - defCellCount - tagCellCount) < cityCellCount)
        {
            section = section - defCellCount - tagCellCount;
            
            NSArray *array = [_fCityListVCData.arrayCityCellData objectAtIndexSafe:section];
            if(row < [array count])
            {
                FCityCellInfo *cityFItem = [array objectAtIndexSafe:row];
                return [self getCityInfoListCell:tableView cityItem:cityFItem];
            }
        }
    }
    // 搜索结果列表
    else if(tableView == _tableViewSearchList)
    {
        if (section < [_fSearchListVCData.arrayCityCellData count])
        {
            NSArray *sectionArray = [_fSearchListVCData.arrayCityCellData objectAtIndexSafe:section];
            FCityCellInfo *fCityCellInfo = [sectionArray objectAtIndexSafe:row];
            return [self getSearchCityCell:tableView citySearchResult:fCityCellInfo];
        }
        // 没有搜索结果
        else
        {
            return [self getEmptyCell:tableView];
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (FGPSLocationTableViewCell *)getGPSLocationCell:(UITableView *)tableView
{
    FGPSLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GPSLocationTabelViewCellIdentifier];
    
    if(!cell)
        cell = [[FGPSLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GPSLocationTabelViewCellIdentifier];
    
    CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, kCityListCellHeight);
    [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    [cell setupLocateInfo:_locationResult.addrDetail.cityName state:_locationStatus];
    [cell setCallBack:^(GPSButtonPressType type){
        [self handleLocate:type];
    }];
    
    return cell;
}

- (FCityTagTableViewCell *)getTagInfoListCell:(UITableView *)tableView cityInfo:(NSArray *)cityInfo indexBar:(BOOL)hasIndexBar
{
    FCityTagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TagCityTableViewCellIdentifier];
    
    if (!cell)
    {
        cell = [[FCityTagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TagCityTableViewCellIdentifier];
        [cell setButtonTotal:_buttonTotal];
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, kCityListCellHeight);
    [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    
    [cell setIsHasIndexBar:hasIndexBar];
    [cell setCityInfoArray:cityInfo];
    [cell setSelectTagCityBlock:^(NSIndexPath *indexPath, NSInteger index){
        [self tableView:_tableViewCityList didSelectRowAtIndexPath:indexPath index:index];
    }];
    
    return cell;
}

- (UITableViewCell *)getCityInfoListCell:(UITableView *)tableView cityItem:(FCityCellInfo *)cityItem
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NormalCityTableViewCellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NormalCityTableViewCellIdentifier];
        [cell setBottomLineWidth:(tableView.frame.size.width - kCityListCellHMargin)];
        [self initCellCityListSubs:[cell contentView]];
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, kCityListCellHeight);
    [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    
    [self setupCellCityListSubs:[cell contentView] inSize:&contentViewSize cityItem:cityItem];
    
    return cell;
}

- (UITableViewCell *)getSearchCityCell:(UITableView *)tableView citySearchResult:(FCityCellInfo *)fCityResult
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCityTableViewCellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCityTableViewCellIdentifier];
        [cell setBottomLineWidth:(tableView.frame.size.width - kCityListSearchHMargin)];
        [self initCellCityListSubs:[cell contentView]];
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, kCitySearchResultCellHeight);
    [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    [self setupCellSearchResultSubs:[cell contentView] inSize:&contentViewSize citySearchResult:fCityResult];
    
    return cell;
}

- (UITableViewCell *)getEmptyCell:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NOCityTableViewCellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:NOCityTableViewCellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initCellEmptySubs:[cell contentView]];
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, kCitySearchResultCellHeight);
    [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    [self setupCellEmptySubs:[cell contentView] inSize:&contentViewSize];
    
    return cell;
}

#pragma mark - UITableViewDelegate
// =======================================================================
// UITableViewDelegate
// =======================================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableViewCityList)
    {
        return kCityListCellHeight;
    }
    else if(tableView == _tableViewSearchList)
    {
        return kCitySearchResultCellHeight;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = @"";
    if(tableView == _tableViewCityList)
        sectionTitle = [_fCityListVCData.arraySectionName objectAtIndexSafe:section];
    else if(tableView == _tableViewSearchList)
        sectionTitle = [_fSearchListVCData.arraySectionName objectAtIndexSafe:section];
    
    if (IsStrEmpty(sectionTitle))
        return 0;
    
    return kCityTableHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 父窗口属性
    CGRect parentFrame = [tableView frame];
    
    // 创建根View
    UIView *viewHeader = [[UIView alloc] initWithFrame:CGRectZero];
    [viewHeader setFrame:CGRectMake(0, 0, parentFrame.size.width, kCityTableHeaderHeight)];
    [viewHeader setBackgroundColor:[UIColor colorWithHex:0xefeff4 alpha:1.0f]];
    
    NSString *sectionTitle = @"";
    NSString *sectionLogo = @"";
    if(tableView == _tableViewCityList){
        sectionTitle = [_fCityListVCData.arraySectionName objectAtIndexSafe:section];
        sectionLogo = [_fCityListVCData.arraySectionLogo objectAtIndexSafe:section];
    }else if(tableView == _tableViewSearchList){
        sectionTitle = [_fSearchListVCData.arraySectionName objectAtIndexSafe:section];
        sectionLogo = [_fSearchListVCData.arraySectionLogo objectAtIndexSafe:section];
    }
    
    [self setupCityHeaderSubs:viewHeader title:sectionTitle logo:sectionLogo];
    return viewHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if(tableView == _tableViewCityList)
    {
        //自定义 tagcell 的个数
        NSInteger defCellCount = [_fCityListVCData.arrayDefCellData count];
        NSInteger tagCellCount = [_fCityListVCData.arrayTagCellData count];
        if (section >= defCellCount + tagCellCount)
        {
            section = section - defCellCount - tagCellCount;
            
            NSArray *array = [_fCityListVCData.arrayCityCellData objectAtIndexSafe:section];
            if(row < [array count])
            {
                NSArray *sectionArray = [_fCityListVCData.arrayCityCellData objectAtIndexSafe:section];
                FCityCellInfo *cityFItem = [sectionArray objectAtIndexSafe:row];
                FCitySelectItemInfo *fCitySelectItemInfo = [[FCitySelectItemInfo alloc] initWithFCityCellInfo:cityFItem];
                [self chooseCity:fCitySelectItemInfo];
            }
        }
        
    }
    else if(tableView == _tableViewSearchList)
    {
        NSInteger searchResultCount = [_fSearchListVCData.arrayCityCellData count];
        if(searchResultCount > 0)
        {
            NSArray *array = [_fSearchListVCData.arrayCityCellData objectAtIndexSafe:section];
            FCityCellInfo *cityFItem = [array objectAtIndexSafe:row];
            FCitySelectItemInfo *fCitySelectItemInfo = [[FCitySelectItemInfo alloc] initWithFCityCellInfo:cityFItem];
            
            [fCitySelectItemInfo setDisplayName:fCitySelectItemInfo.searchName];
            if ([self isInterCity:fCitySelectItemInfo])
            {
                [self showInterCityNotice:fCitySelectItemInfo];
            }
            else
            {
                [self chooseCity:fCitySelectItemInfo];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    if (tableView == _tableViewCityList)
    {
        // GPS + 历史 +热门推荐
        if (section < [_fCityListVCData.arrayDefCellData count] + [_fCityListVCData.arrayTagCellData count])
        {
            [cell.contentView setBackgroundColor:[UIColor colorWithHex:0xefeff4 alpha:1.0]];
            [cell setBackgroundColor:[UIColor colorWithHex:0xefeff4 alpha:1.0]];
            return;
        }
        else
        {
            [cell setBGViewInTableView:tableView AtIndexPath:indexPath];
            [cell setSelectedViewInTableView:tableView AtIndexPath:indexPath];
            return;
        }
    }
    else if (tableView == _tableViewSearchList)
    {
        [cell setBGViewInTableView:tableView AtIndexPath:indexPath];
        [cell setSelectedViewInTableView:tableView AtIndexPath:indexPath];
    }
}

#pragma mark - tableView自定义索引的处理

- (NSArray *)customSectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(tableView == _tableViewCityList)
    {
        if(!IsArrEmpty(_fCityListVCData.arrayIndexName))
        {
            return _fCityListVCData.arrayIndexName;
        }
    }
    else if (tableView == _tableViewSearchList)
    {
        if(!IsArrEmpty(_fSearchListVCData.arrayIndexName))
        {
            return _fSearchListVCData.arrayIndexName;
        }
    }
    
    return nil;
}

//响应点击索引时的委托方法
- (void)tapDownSection:(UITableView *)tableView indexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSIndexPath *selectIndexPath = [self safeIndexPath:tableView indexSection:index];
    if (selectIndexPath)
        [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//由于索引和section并不是一定会对应  存在section的cell为0的情况
- (NSIndexPath *)safeIndexPath:(UITableView *)tableView indexSection:(NSInteger)indexSection
{
    NSInteger sectionCounts = [tableView numberOfSections];
    for (NSInteger i = indexSection ; i < sectionCounts; i++)
    {
        NSInteger count = [tableView numberOfRowsInSection:i];
        if (count > 0)
            return [NSIndexPath indexPathForRow:0 inSection:i];
        
    }
    return nil;
}

#pragma mark - tableView自定义cell点击回调
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index
{
    NSInteger section = indexPath.section - [_fCityListVCData.arrayDefCellData count];
    NSInteger row = indexPath.row;
    
    NSArray *array = [_fCityListVCData.arrayTagCellData objectAtIndexSafe:section];
    NSArray *cityInfo = [array objectAtIndexSafe:row];
    FCityTagInfo *fCityTagInfo = [cityInfo objectAtIndexSafe:index];
    FCitySelectItemInfo *fCitySelectItemInfo = [[FCitySelectItemInfo alloc] init];
    [fCitySelectItemInfo setSearchName:fCityTagInfo.searchName];
    [fCitySelectItemInfo setDisplayName:fCityTagInfo.displayText];
    [fCitySelectItemInfo setExt:fCityTagInfo.ext];
    
    if (_curCityType == FCityVCTabTypeDomesticCity)
    {
        BOOL isInterCity = [FCity checkInterCity:[fCitySelectItemInfo searchName]];
        fCitySelectItemInfo.isInter = @(isInterCity) ;
    }
    else
    {
        fCitySelectItemInfo.isInter = @YES;
    }
    
    [self chooseCity:fCitySelectItemInfo];
    return;
}

- (void)setupTagCellIndex:(NSArray *)array indexPath:(NSIndexPath *)indexPath
{
    for (FCityTagInfo *city in array)
        [city setIndexPath:indexPath];
}

- (void)handleLocate:(GPSButtonPressType)type
{
    switch (type)
    {
        case GPSButtonPressTypeCity:
        {
            // 使用定位获取到的城市
            NSString *city = _locationResult.addrDetail.cityName;
            if(!IsStrEmpty(city))
            {
                FCitySelectItemInfo *fCitySelectItemInfo = [[FCitySelectItemInfo alloc] init];
                [fCitySelectItemInfo setSearchName:city];
                [fCitySelectItemInfo setDisplayName:city];
                [self chooseCity:fCitySelectItemInfo];
                return;
            }
        }
            break;
            
        case GPSButtonPressTypeRetry:
        {
            [self startLocation];
        }
            break;
    }
}

#pragma mark - 定位相关
// 开启定位
- (void)startLocation
{
    // 定位服务不可用
    if(![CLLocationManager locationServicesEnabled])
    {
        [self setupLocationStatus:eFGPSLocationStatusLocateEnable];
        return;
    }
    
    // 定位服务可用
    CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
    if(locationStatus == kCLAuthorizationStatusAuthorizedAlways ||
       locationStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
       locationStatus == kCLAuthorizationStatusNotDetermined)
    {
        if(_locationManager == nil)
            _locationManager = [[CLLocationManager alloc] init];
        
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
        
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        
        [self setupLocationStatus:eFGPSLocationStatusLocating];
        return;
    }
    
    // 去哪儿定位服务未开启
    [self setupLocationStatus:eFGPSLocationStatusLocateEnable];
}

// 重新定位
- (void)refreshStartLocation
{
    if([[VCController getTopVC] isEqual:self])
    {
        [self startLocation];
    }
}

// 定位城市请求
- (void)loadLocationCity:(CLLocation *)location
{
#warning caiyangjieto
//    NSMutableDictionary *dictionaryJson = [[NSMutableDictionary alloc] init];
//    CLLocationCoordinate2D coordinate = [location coordinate];
//    // 纬度
//    NSString *latitude = [[NSString alloc] initWithFormat:@"%f", coordinate.latitude];
//    if(!IsStrEmpty(latitude))
//        [dictionaryJson setObject:latitude forKey:@"latitude"];
//    // 经度
//    NSString *longitude = [[NSString alloc] initWithFormat:@"%f", coordinate.longitude];
//    if(!IsStrEmpty(longitude))
//        [dictionaryJson setObject:longitude forKey:@"longitude"];
//    
//    // 转换坐标类型(0:gps转为google坐标, 1:不转换, 2:baidu坐标系转为google坐标系)
//    NSNumber *coordConvert = [NSNumber numberWithInteger:1];
//    if(coordConvert != nil)
//        [dictionaryJson setObject:coordConvert forKey:@"coordConvert"];
//    
//    NetConnection *netConnection = [FSearchNetworkTask postSearch:KFURLLoadLocationCity
//                                                      forParamDic:dictionaryJson
//                                                           forRes:NO
//                                                        withDelgt:self
//                                                       withResult:[[FUserLocationResult alloc] init] withInfo:nil];
//    if(netConnection == nil)
//    {
//        [self setupLocationStatus:eFGPSLocationStatusLocateFailed];
//    }
}

// 获取定位的城市返回
- (void)loadLocationCityBack:(FUserLocationResult *)userLocationResult
{
    if(!userLocationResult)
    {
        [self setupLocationStatus:eFGPSLocationStatusLocateFailed];
        return;
    }
    
    NSNumber *returnCode = [[userLocationResult bstatus] code];
    // 获取定位的城市成功
    if(returnCode != nil && [returnCode intValue] == 0)
    {
        _locationResult = userLocationResult;
        [self setupLocationStatus:eFGPSLocationStatusLocateSuccess];
        return;
    }
    
    [self setupLocationStatus:eFGPSLocationStatusLocateFailed];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    // 时间是否在有效范围
    if(locationAge > 5.0)
        return;
    // 经纬度是否有效果
    if(newLocation.horizontalAccuracy < 0)
        return;
    
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
    
    // 定位城市请求
    [self loadLocationCity:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
    
    [self setupLocationStatus:eFGPSLocationStatusLocateFailed];
}

#pragma mark - 搜索框动画函数
// 搜索开始时动画
- (void)startSearchAnimation
{
    [_searchBar showBarButton:YES animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^(void){
            [_searchBar setFrame:CGRectMake(0, _searchBar.top, self.naviBar.width, _searchBar.height)];
        }
        completion:^(BOOL finish){
        }
    ];
}

// 搜索结束时动画
- (void)endSearchAnimation
{
    // 隐藏按钮
    [_searchBar showBarButton:NO animated:YES];
    
    [UIView animateWithDuration:0.3 animations:^(void){
            [_searchBar setFrame:CGRectMake(self.naviBar.leftBarItem.frame.size.width, _searchBar.frame.origin.y, self.naviBar.frame.size.width - self.naviBar.leftBarItem.frame.size.width, _searchBar.frame.size.height)];
        }
        completion:^(BOOL finish){
        }
    ];
    
}

#pragma mark - SearchBarDelgt
- (void)searchBar:(FSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchKeyText = searchText;
    [self setupSearchBarStatus:eFCityVCSearchBarEditing];
}

- (void)searchBarTextDidBeginEditing:(FSearchBar *)searchBar
{
    [self setupSearchBarStatus:eFCityVCSearchBarStartEdit];
}

- (void)searchBarTextDidEndEditing:(FSearchBar *)searchBar
{
    [self setupSearchBarStatus:eFCityVCSearchBarFinish];
}

- (void)searchBarBarButtonClicked:(FSearchBar *)searchBar
{
    [self searchCancel:nil];
}

// 取消搜索
- (void)searchCancel:(id)sender
{
    [self setupSearchBarStatus:eFCityVCSearchBarNormal];
}

#pragma mark - UIScrollViewDelegate
// =======================================================================
// ScrollViewDelegate 代理函数
// =======================================================================
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == _tableViewSearchList)
    {
        [self setupSearchBarStatus:eFCityVCSearchBarFinish];
    }
}

// =======================================================================
#pragma mark - UIAlertViewDelegate
// =======================================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger alertViewTag = [alertView tag];
    
    if (alertViewTag == KFCityShowInterCityNoticeTipTag)
    {
        [self chooseCity:_choosedSelectItemInfo];
    }
}

@end
