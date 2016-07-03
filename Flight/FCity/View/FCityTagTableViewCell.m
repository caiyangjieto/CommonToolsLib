//
//  FCityTagTableViewCell.m
//
//  Created by caiyangjieto on 16-4-27.
//  Copyright (c) 2016年 just. All rights reserved.
//

#import "FCityTagTableViewCell.h"
#import "FReuseQueue.h"

#define kButtonSpace 15
#define kIndexViewWidth 30

@interface FCityTagTableViewCell ()

@property (nonatomic, strong) FReuseQueue *arrayButton;

@end

@implementation FCityTagTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self.contentView setBackgroundColor:[UIColor colorWithRGB:0xefeff4 alpha:1.0]];
        [self setBackgroundColor:[UIColor colorWithRGB:0xefeff4 alpha:1.0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        _arrayButton = [[FReuseQueue alloc] init];
    }
    
    return self;
}

- (void)setCityInfoArray:(NSArray *)cityInfoArray
{
    if ([cityInfoArray count] <= 0) {
        return;
    }
    _cityInfoArray = cityInfoArray;
    [self setNeedsLayout];
    
}
- (void)setButtonTotal:(NSInteger)buttonTotal
{
    if (buttonTotal <= 0) {
        return;
    }
    _buttonTotal = buttonTotal;
    [self setNeedsLayout];
}
- (void)setIsHasIndexBar:(BOOL)isHasIndexBar
{
    _isHasIndexBar = isHasIndexBar;
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    NSInteger buttonCount = [_cityInfoArray count];
    if (_buttonTotal <= 0 || buttonCount <= 0)
        return;
    
    CGFloat buttonWidth = 0;
    if (_isHasIndexBar)
        buttonWidth = (kScreenWidth - kButtonSpace *(_buttonTotal + 1)- kIndexViewWidth)/_buttonTotal ;
    else
        buttonWidth = (kScreenWidth - kButtonSpace *(_buttonTotal + 1))/_buttonTotal;
    
    CGFloat buttonHeight = 32;
    
    [_arrayButton setQueueInitState];
    
    for (int i = 0; i < buttonCount; i ++ )
    {
        FCityTagInfo *cityInfo = [_cityInfoArray objectAtIndexSafe:i];
        UIButton *button = [_arrayButton dequeueItem];
        if (!button)
        {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageFromColor:[UIColor flightThemeSideColor]] forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageFromColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
            [button setClipsToBounds:YES];
            
            [[button titleLabel] setFont:kCurNormalFontOfSize(14)];
            [[button titleLabel] setNumberOfLines:0];
            [[button titleLabel] setTextAlignment:NSTextAlignmentCenter];
            [[button titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
            
            [[button layer] setBorderColor:[UIColor whiteColor].CGColor];
            [[button layer] setBorderWidth:0.5];
            [[button layer] setCornerRadius:4.0f];

            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
            
            [_arrayButton addUsingQueue:button];
        }
        
        [button setTag:i];
        [button setTitle:[cityInfo displayText] forState:UIControlStateNormal];
        [button setSelected:cityInfo.isSelected];
        
        [button setFrame:CGRectMake(kButtonSpace+ i*(kButtonSpace + buttonWidth), (self.frame.size.height - buttonHeight)/2, buttonWidth, buttonHeight)];
        
    }
    
}

- (void)buttonAction:(id)sender
{
    NSInteger tag = [(UIButton *)sender tag];
    NSInteger index = tag;
    
    FCityTagInfo *cityInfo = [_cityInfoArray objectAtIndexSafe:index];
    
    if (_selectTagCityBlock)
    {
        _selectTagCityBlock(cityInfo.indexPath,cityInfo.indexLine);
    }
}

@end


@implementation FCityTagInfo

- (void)setDisplayText:(NSString *)displayText
{
    if (!IsStrEmpty(displayText))
    {
        if ([displayText rangeOfString:@"\n"].location != NSNotFound)
        {
            _displayText = displayText;
        }
        else if ([displayText rangeOfString:@"（"].location != NSNotFound)
        {
            _displayText = [self getFinalCityNameForSeparate:@"（" Source:displayText];
        }
        else
        {
            _displayText = displayText;
        }
    }
    else
    {
        _displayText = @"";
    }
}

- (NSString *)getFinalCityNameForSeparate:(NSString *)separate Source:(NSString *)source
{
    NSArray *stringArray = [source componentsSeparatedByString:separate];
    return [NSString stringWithFormat:@"%@\n%@%@",[stringArray objectAtIndexSafe:0],separate,[stringArray objectAtIndexSafe:1]];
}

@end