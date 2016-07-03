//
//  VCController.m
//  Qinisky
//
//  Created by caiyangjieto on 15/12/28.
//  Copyright © 2015年 qinisky. All rights reserved.
//

#import "VCController+Flight.h"
#import "VCManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation VCController (Flight)

+ (void)pushVC:(UIViewController *)viewController animated:(VCTranstAnimation)animated
{
    if ([viewController isKindOfClass:[NaviNameVC class]])
    {
        NaviNameVC *baseViewController = (NaviNameVC *)viewController;
        
        if (IsStrEmpty(baseViewController.vcName))
        {
            baseViewController.vcName = [[viewController class] description];
        }
    }
    
    switch (animated) {
        case VCTranstNOAnimation:
        {
            [[VCManager getInstance] pushViewController:viewController animated:NO];
        }
            break;
        case VCTranstLeftRightAnimation:
        {
            [[VCManager getInstance] pushViewController:viewController animated:YES];
        }
            break;
        case VCTranstTopBottomAnimation:
        {
            [[VCManager getInstance] presentViewController:viewController animated:YES completion:nil];
        }
            break;
    };
}

+ (void)popVCAnimated:(VCTranstAnimation)animated
{
    switch (animated) {
        case VCTranstNOAnimation:
        {
            [[VCManager getInstance] popViewControllerAnimated:NO];
        }
            break;
            
        case VCTranstLeftRightAnimation:
        {
            [[VCManager getInstance] popViewControllerAnimated:YES];
        }
            break;
        case VCTranstTopBottomAnimation:
        {
            [[VCManager getInstance] dismissViewControllerAnimated:YES completion:nil];
        }
            break;
    };
    
    
}

+ (void)popToVCWithName:(NSString *)name animated:(BOOL)animated
{
    UIViewController *targetVC = nil;
    for (UIViewController *viewController in [[VCManager getInstance] viewControllers])
    {
        if ([viewController isKindOfClass:[NaviNameVC class]])
        {
            NaviNameVC *baseViewController = (NaviNameVC *)viewController;
            if ([baseViewController.vcName isEqualToString:name])
            {
                targetVC = baseViewController;
                break;
            }
        }
        else if ([viewController.className isEqualToString:name])
        {
            targetVC = viewController;
            break;
        }
    }
    
    if (targetVC) {
        [[VCManager getInstance] popToViewController:targetVC animated:animated];
    }
}

+ (UIViewController *)getRootVC
{
    return [[[VCManager getInstance] viewControllers] firstObject];
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = [[VCManager getInstance] visibleViewController];
    return result;
}

+ (UIViewController *)getPreviousVC
{
    return [VCController getPreviousWithVC:[VCController getCurrentVC]];
}

+ (UIViewController *)getPreviousWithVC:(UIViewController *)currentVC
{
    NSArray *viewControllers = [[VCManager getInstance] viewControllers];
    NSUInteger index = [viewControllers indexOfObject:currentVC];
    
    //present出来的 不在数组中 index值非常大
    if (index > 50)
    {
        index = [viewControllers count];
    }
    
    if (index == 0)
    {
        return nil;
    }
    
    return [viewControllers objectAtIndexSafe:index-1];
}

@end
