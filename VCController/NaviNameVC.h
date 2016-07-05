//
//  NaviNameVC.h
//
//  Created by caiyangjieto on 11/20/12.
//  Copyright (c) 2012 qinisky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FNaviBar.h"
#import "VCControllerPtc.h"
#import "BaseNameVC.h"

@interface NaviNameVC : BaseNameVC <VCControllerPtc>

- (FNaviBar *)naviBar;

- (instancetype)init;
- (instancetype)initWithName:(NSString *)vcNameInit;

- (void)setBlurDarkBackImage;

@end
