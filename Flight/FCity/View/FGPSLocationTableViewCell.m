//
//  FGPSLocationTableViewCell.m
//  Flight
//
//  Created by songyangyang on 15-4-27.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//

#import "FGPSLocationTableViewCell.h"

#define kLocationInfoLeftMargin 15
#define kLocateRetryButtonWidth 60
#define kLocateRetryButtonHeight  32
#define kLocateCityLabelHeight 32

#define kLocateCityBaseTag          100
#define kLocateCitySuccessButtonTag 101
#define kLocateCityRetryButtonTag   102

@interface FGPSLocationTableViewCell ()
@property (nonatomic, strong) UIButton *locateCityButton;
@property (nonatomic, strong) UILabel *locateHintLabel;
@property (nonatomic, strong) UIActivityIndicatorView *locateIndicatorView;
@property (nonatomic, strong) UIButton *locateRetryButton;
@end

@implementation FGPSLocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initAllSubviews];
        
        [self.contentView setBackgroundColor:[UIColor colorWithHex:0xefeff4 alpha:1.0]];
        [self setBackgroundColor:[UIColor colorWithHex:0xefeff4 alpha:1.0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return self;
}

- (void)initAllSubviews
{
    if (!_locateCityButton) {//定位城市名称
        _locateCityButton = [[UIButton alloc] init];
        [_locateCityButton setBackgroundColor:[UIColor clearColor]];
        [_locateCityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_locateCityButton setTitleColor:[UIColor flightThemeColor] forState:UIControlStateSelected];
        [_locateCityButton setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_locateCityButton setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        [_locateCityButton setBackgroundImage:[UIImage imageFromColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        
        
        [_locateCityButton setClipsToBounds:YES];
        
        [[_locateCityButton titleLabel] setTextAlignment:NSTextAlignmentCenter];
        [[_locateCityButton titleLabel] setFont:kCurNormalFontOfSize(14)];
        [[_locateCityButton layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[_locateCityButton layer] setBorderWidth:0.5];
        [[_locateCityButton layer] setCornerRadius:4.0f];
        
        [_locateCityButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_locateCityButton setTag:kLocateCitySuccessButtonTag];
        
        [self.contentView addSubview:_locateCityButton];
    }
    
    if (!_locateHintLabel) {//定位过程的提示信息
        _locateHintLabel = [[UILabel alloc] init];
        [_locateHintLabel setBackgroundColor:[UIColor clearColor]];
        [_locateHintLabel setTextAlignment:NSTextAlignmentCenter];
        [_locateHintLabel setTextColor:[UIColor blackColor]];
        [_locateHintLabel setFont:kCurNormalFontOfSize(14)];
        
        [self.contentView addSubview:_locateHintLabel];
    }
    
    if (!_locateIndicatorView) {//加载菊花
        _locateIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_locateIndicatorView setBackgroundColor:[UIColor clearColor]];
        [_locateIndicatorView setHidesWhenStopped:YES];
        
        [self.contentView addSubview:_locateIndicatorView];
    }
    
    if (!_locateRetryButton) {//重试按钮
        _locateRetryButton = [[UIButton alloc] init];
        [_locateRetryButton setBackgroundColor:[UIColor flightThemeSideColor]];
        [_locateRetryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_locateRetryButton setTitle:@"重试" forState:UIControlStateNormal];
        [[_locateRetryButton titleLabel] setFont:kCurNormalFontOfSize(14)];
        [_locateRetryButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_locateRetryButton setTag:kLocateCityRetryButtonTag];
        
        [self.contentView addSubview:_locateRetryButton];
    }
}

- (void)buttonAction:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    if (_callBack) {
        _callBack(tag- kLocateCityBaseTag);
    }
}

- (void)setupLocateInfo:(NSString *)locateCity state:(FGPSLocationStatus)locateState
{
    // 文案
    NSString *locationText = @"";
    
    if(locateState == eFGPSLocationStatusLocating)
    {
        [_locateCityButton setHidden:YES];
        [_locateHintLabel setHidden:NO];
        [_locateIndicatorView setHidden:NO];
        [_locateRetryButton setHidden:YES];
        
        locationText = @"正在获取您的当前城市";
        
        CGSize locationTextSize = [locationText sizeWithFontCompatible:[_locateHintLabel font] constrainedToSize:CGSizeMake(kScreenWidth - kLocationInfoLeftMargin * 2, 30)];
        
        [_locateHintLabel setFrame:CGRectMake(kLocationInfoLeftMargin, (self.frame.size.height - locationTextSize.height)/2, locationTextSize.width, locationTextSize.height)];
        [_locateHintLabel setText:locationText];
        
        [_locateIndicatorView setFrame:CGRectMake(_locateHintLabel.right + 5, (self.frame.size.height - _locateIndicatorView.frame.size.height)/2, _locateIndicatorView.frame.size.width, _locateIndicatorView.frame.size.height)];
        
        [_locateIndicatorView startAnimating];
    }
    else if (locateState == eFGPSLocationStatusLocateSuccess)
    {
        if (!IsStrEmpty(locateCity))
        {
            [_locateCityButton setHidden:NO];
            [_locateHintLabel setHidden:YES];
            [_locateIndicatorView setHidden:YES];
            [_locateRetryButton setHidden:YES];
            
            [_locateIndicatorView stopAnimating];
            [_locateCityButton setTitle:locateCity forState:UIControlStateNormal];
            
            CGSize locateCitySize = [locateCity sizeWithFontCompatible:[[_locateCityButton titleLabel] font] constrainedToSize:CGSizeMake(MAXFLOAT, kLocateCityLabelHeight)];
            CGFloat width = (self.frame.size.width - 15*4 - 28)/3;
            [_locateCityButton setFrame:CGRectMake(kLocationInfoLeftMargin, (self.frame.size.height - kLocateCityLabelHeight)/2, locateCitySize.width > width ? locateCitySize.width : width, kLocateCityLabelHeight)];
        }
    }
    else if(locateState == eFGPSLocationStatusLocateFailed)
    {
        [_locateCityButton setHidden:YES];
        [_locateHintLabel setHidden:NO];
        [_locateIndicatorView setHidden:YES];
        [_locateRetryButton setHidden:NO];
        
        locationText = @"网络请求失败，请检查网络";
        
        CGSize locationTextSize = [locationText sizeWithFontCompatible:[_locateHintLabel font] constrainedToSize:CGSizeMake(kScreenWidth - kLocationInfoLeftMargin * 2, 30)];
        
        [_locateHintLabel setFrame:CGRectMake(kLocationInfoLeftMargin, (self.frame.size.height - locationTextSize.height)/2, locationTextSize.width, locationTextSize.height)];
        [_locateHintLabel setText:locationText];
        
        [_locateRetryButton setFrame:CGRectMake(_locateHintLabel.right + 5, (self.frame.size.height - kLocateRetryButtonHeight)/2, kLocateRetryButtonWidth, kLocateRetryButtonHeight)];
    }
    else if(locateState == eFGPSLocationStatusLocateEnable)
    {
        [_locateCityButton setHidden:YES];
        [_locateHintLabel setHidden:NO];
        [_locateIndicatorView setHidden:YES];
        [_locateRetryButton setHidden:YES];
        
        locationText = @"定位失败，请在系统设置中打开“定位服务”";
        
        CGSize locationTextSize = [locationText sizeWithFontCompatible:[_locateHintLabel font] constrainedToSize:CGSizeMake(kScreenWidth - kLocationInfoLeftMargin * 2, 30)];
        
        [_locateHintLabel setFrame:CGRectMake(kLocationInfoLeftMargin, (self.frame.size.height - locationTextSize.height)/2, locationTextSize.width, locationTextSize.height)];
        
        [_locateHintLabel setText:locationText];
    }
}

@end
