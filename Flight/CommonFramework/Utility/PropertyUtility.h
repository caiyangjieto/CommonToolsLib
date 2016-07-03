//
//  PropertyUtility.h
//  awd
//
//  Created by caiyangjieto on 15/5/15.
//  Copyright (c) 2015年 qinisky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyUtility : NSObject

+ (BOOL)isEqualObject:(id)host andCustomer:(id)customer withRelation:(NSDictionary*)relation;

+ (void)copySameProperty:(NSObject *)obj from:(NSObject *)origin ;
+ (void)copyArray:(NSMutableArray *)obj from:(NSArray *)origin ;

@end
