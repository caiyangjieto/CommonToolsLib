//
//  PropertyUtility.m
//  awd
//
//  Created by caiyangjieto on 15/5/15.
//  Copyright (c) 2015年 qinisky. All rights reserved.
//

#import "PropertyUtility.h"
#import <objc/runtime.h>

@implementation PropertyUtility

+ (BOOL)isEqualObject:(id)host andCustomer:(id)customer withRelation:(NSDictionary*)relation
{
    
    //String
    if ([host isKindOfClass:([NSString class])])
    {
        NSString *valueHost = (NSString *)host;
        NSString *valueCustomer = (NSString *)customer;
        
        return ((![valueHost isEqualToString:valueCustomer])?NO:YES);
    }
    //number
    else if ([host isKindOfClass:([NSNumber class])])
    {
        NSNumber *valueHost = (NSNumber *)host;
        NSNumber *valueCustomer = (NSNumber *)customer;
        
        return (([valueHost intValue] != [valueCustomer intValue])?NO:YES);
    }
    //nil
    else if (host == nil)
    {
        return ((customer != nil)?NO:YES);
    }
    
    NSArray *allKeys = [relation allKeys];
    
    //没有对应关系，则所有属性对应
    if ([allKeys count] == 0)
        allKeys = [self getClassAllProperty:host];
    
    for (NSString *keyHost in allKeys)
    {
        
        id propertyValue = [host valueForKeyPath:keyHost];
        
        //拿不到对应关系，则使用相同的属性名
        NSString *keyCustomer = [relation objectForKey:keyHost];
        if (keyCustomer == nil)
            keyCustomer = keyHost;
        
        
        //array
        if ([propertyValue isKindOfClass:([NSArray class])] ||
            [propertyValue isKindOfClass:([NSMutableArray class])])
        {
            NSArray *valueHost = (NSArray *)propertyValue;
            NSArray *valueCustomer = [customer valueForKeyPath:keyCustomer];
            
            //数组元素个数不对
            if ([valueHost count] != [valueCustomer count])
                return NO;
            
            for (int i=0; i < [valueHost count]; i++)
            {
                id hostCld = [valueHost objectAtIndex:i];
                id customerCld = [valueCustomer objectAtIndex:i];
                
                if (![self isEqualObject:hostCld andCustomer:customerCld withRelation:nil])
                    return NO;
                
            }
            
        }
        //自定义对象、基础类型
        else
        {
            id valueCustomer = [customer valueForKeyPath:keyCustomer];
            
            if (![self isEqualObject:propertyValue andCustomer:valueCustomer withRelation:nil])
                return NO;
        }
        
    }
    
    
    return YES;
}

+ (void)copySameProperty:(NSObject *)obj from:(NSObject *)origin
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = property_getAttributes(property);
        if(propName && propType)
        {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            
            id propertyValue = [origin valueForKey:propertyName];
            if (propertyValue)
            {
                [obj setValue:propertyValue forKey:propertyName];
            }
        }
    }
    free(properties);
}

+ (void)copyArray:(NSMutableArray *)obj from:(NSArray *)origin
{
    for (NSObject *item in origin)
    {
        Class objCls = NSClassFromString([item className]);
        id childObj = [[objCls alloc] init];
        
        [PropertyUtility copySameProperty:childObj from:item];
        [obj addObject:childObj];
    }
}

#pragma mark - 内部方法
+ (NSArray *)getClassAllProperty:(id)klass
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([klass class], &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);//获取属性名字
        NSString *propertyName = [NSString stringWithUTF8String:name];

        [array addObject:propertyName];
    }
    
    return array;
}


@end
