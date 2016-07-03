//
//  NaviNameVC.m
//
//  Created by caiyangjieto on 11/20/12.
//  Copyright (c) 2012 qinisky. All rights reserved.
//

#import "NaviNameVC.h"
#import "FNaviBarItem.h"

// ==================================================================
// 布局参数
// ==================================================================
#define kNaviNameNaivBarHeight				64

@interface NaviNameVC ()

@property (nonatomic, retain) FNaviBar *naviBarHead;     // 导航栏

@end

@implementation NaviNameVC

- (instancetype)init
{
	return [self initWithName:nil];
}

- (instancetype)initWithName:(NSString *)vcNameInit
{
	if((self = [super init]))
	{
        NSString *vcName = !IsStrEmpty(vcNameInit)?vcNameInit:[[self class] description];
        [self setVcName:vcName];
        
		_naviBarHead = [[FNaviBar alloc] initWithFrame:CGRectZero];
        
        return self;
	}
	
	return nil;
}

- (void)setBlurDarkBackImage
{
    UIImage *imageBack = [[VCController getPreviousWithVC:self].view snapshotImage];
    UIImageView *imageViewBack = [[UIImageView alloc] initWithImage:[imageBack imageByBlurDark]];
    [imageViewBack setFrame:self.view.frame];
    [self.view addSubview:imageViewBack];
}



- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [FlightNetTask cancelNetRequestsWithTarget:self];
}

- (void)goBack
{
    [VCController popWithAnimation:[VCAnimationClassic defaultAnimation]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor flightThemeColor]];
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    [layer setFrame:self.view.frame];
    [layer setColors:@[(__bridge id)[UIColor colorWithHex:0x005a91 alpha:1.0].CGColor,
                       (__bridge id)[UIColor colorWithHex:0x78c8c0 alpha:1.0].CGColor,
                       (__bridge id)[UIColor colorWithHex:0xdcfee8 alpha:1.0].CGColor]];
    [layer setStartPoint:CGPointMake(0, 0)];
    [layer setEndPoint:CGPointMake(0, 1)];
    [self.view.layer addSublayer:layer];
    
    
    
    CGRect vcViewFrame = [[self view] frame];
    [_naviBarHead setFrame:CGRectMake(0, 0, vcViewFrame.size.width, kNaviNameNaivBarHeight)];
    
    [self setupNaviBarDefaultSubs:_naviBarHead];
    [self.view addSubview:_naviBarHead];
}

- (void)setupNaviBarDefaultSubs:(FNaviBar *)viewParent
{
    FNaviBarItem *leftItem = [[FNaviBarItem alloc] initTextItem:kCustomerFontBack font:kCustomerFontOfSize(24) target:self action:@selector(goBack)];
    [viewParent setLeftBarItem:leftItem];
}

- (FNaviBar *)naviBar
{
	return _naviBarHead;
}

@end
