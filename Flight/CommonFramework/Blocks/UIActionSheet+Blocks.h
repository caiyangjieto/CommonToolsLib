//
//  UIActionSheet+Blocks.h
//  Flight
//
//  Created by qitmac000224 on 16/6/22.
//  Copyright © 2016年 just. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Blocks) <UIActionSheetDelegate>

-(void)handlerClickedButton:(void (^)(NSInteger btnIndex))aBlock;

@end
