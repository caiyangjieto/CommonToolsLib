//
//  UIViewController+Property.m
//  Pods
//
//  Created by caiyangjieto on 16/2/22.
//
//

#import "UIViewController+Property.h"
#import <objc/runtime.h>

@implementation UIViewController (Property)

- (BOOL)fd_interactivePopDisabled
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_interactivePopDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self, @selector(fd_interactivePopDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setVcName:(NSString *)vcName
{
    objc_setAssociatedObject(self, @selector(vcName), vcName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)vcName
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
