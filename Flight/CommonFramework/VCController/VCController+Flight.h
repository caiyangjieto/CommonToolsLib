//
//  VCController.h
//  Qinisky
//
//  Created by caiyangjieto on 15/12/28.
//  Copyright © 2015年 qinisky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VCTranstAnimation
{
    VCTranstNOAnimation = 0,
    VCTranstLeftRightAnimation ,
    VCTranstTopBottomAnimation ,
}VCTranstAnimation;

@interface VCController (Flight)

+ (void)pushVC:(UIViewController *)viewController animated:(VCTranstAnimation)animated;
+ (void)popVCAnimated:(VCTranstAnimation)animated;
+ (void)popToVCWithName:(NSString *)name animated:(BOOL)animated;

+ (UIViewController *)getRootVC;
+ (UIViewController *)getCurrentVC;
+ (UIViewController *)getPreviousVC;
+ (UIViewController *)getPreviousWithVC:(UIViewController *)currentVC;

@end
