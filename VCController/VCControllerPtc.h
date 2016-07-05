//
//  VCControllerPtc.h
//  Pods
//
//  Created by caiyangjieto on 16/1/6.
//
//

#import <Foundation/Foundation.h>

@protocol VCControllerPtc <NSObject>

@optional

/**
 *  如果fd_interactivePopDisabled是YES时，会调用 VC 的 goBack 进行处理，通常行为是进行弹框提示
 */
- (void)goBack;

@end
