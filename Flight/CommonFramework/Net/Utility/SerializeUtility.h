//
//  SerializeUtility.h
//  Qinisky
//
//  Created by caiyangjieto on 15/12/28.
//  Copyright © 2015年 qinisky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QiniskyArray(key,type)    <type *> *key##__##type
#define QiniskyDict(key,type)     *key##__##type

@interface SerializeUtility : NSObject

+ (NSObject *)serializeObject:(NSObject *)objEntity;

+ (void)parseJsonObject:(NSDictionary *)dictionaryJson withObject:(NSObject *)objEntity;

@end
