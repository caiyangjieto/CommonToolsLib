//
//  UIViewController+Property.h
//  Pods
//
//  Created by caiyangjieto on 16/2/22.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Property)

/// Whether the interactive pop gesture is disabled when contained in a navigation
/// stack.
@property (nonatomic, assign) BOOL fd_interactivePopDisabled;

@property (nonatomic, strong) NSString *vcName;

@end
