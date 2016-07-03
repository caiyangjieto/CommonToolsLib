//
//  UIActionSheet+Blocks.m
//  Flight
//
//  Created by qitmac000224 on 16/6/22.
//  Copyright © 2016年 just. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import <objc/runtime.h>

static NSString *UIActionSheet_Key_Clicked = @"com.ActionSheet.just.BUTTONS";

@implementation UIActionSheet (Blocks) 

-(void)handlerClickedButton:(void (^)(NSInteger btnIndex))aBlock{
    [self setDelegate:self];
    objc_setAssociatedObject(self, (__bridge const void *)UIActionSheet_Key_Clicked, aBlock, OBJC_ASSOCIATION_COPY);
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    void (^block)(NSInteger btnIndex) = objc_getAssociatedObject(self, (__bridge const void *)UIActionSheet_Key_Clicked);
    
    if (block) block(buttonIndex);
}

@end
