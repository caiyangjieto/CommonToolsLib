//
//  NetToolUtility.h
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetToolUtility : NSObject

+ (NSString *)Encode:(NSString *)content key:(NSString *)key;
+ (NSString *)Decode:(NSString *)content key:(NSString *)key;

@end
