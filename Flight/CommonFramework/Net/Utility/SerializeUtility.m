//
//  SerializeUtility.m
//  Qinisky
//
//  Created by caiyangjieto on 15/12/28.
//  Copyright © 2015年 qinisky. All rights reserved.
//

#import "SerializeUtility.h"
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

@implementation SerializeUtility

+ (NSObject *)serializeObject:(NSObject *)objEntity
{
    // NSNumber NSString NSDictionary 基本类型
    if( objEntity == nil ||
       [objEntity isKindOfClass:[NSNumber class]] ||
       [objEntity isKindOfClass:[NSString class]] )
    {
        return objEntity;
    }
    else if ([objEntity isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSDictionary *objDict = (NSDictionary *)objEntity;
        for (id key in [objDict allKeys])
        {
            id value = [objDict objectForKey:key];
            id childObj = [SerializeUtility serializeObject:value];
            [dict setObjectSafe:childObj forKey:key];
        }
        
        return  dict;

    }
    // array
    else if([objEntity isKindOfClass:[NSArray class]])
    {
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        
        NSArray *objEntityArray = (NSArray *)objEntity;
        for (id item in objEntityArray)
        {
            id childObj = [SerializeUtility serializeObject:item];
            [mutableArray addObject:childObj];
        }
        
        return  mutableArray;
    }
    // NSObject
    else
    {
        id childObj = [SerializeUtility serializeSimpleObject:objEntity];
        
        return childObj;
    }
    
}

+ (NSObject *)serializeSimpleObject:(NSObject *)objEntity
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    // 获取property
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([objEntity class], &propertyCount);
    for(unsigned int i = 0; i < propertyCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        // 获取对象
        Ivar iVar = class_getInstanceVariable([objEntity class], [propertyName UTF8String]);
        if(iVar == nil)
        {
            // 采用另外一种方法尝试获取
            iVar = class_getInstanceVariable([objEntity class], [[[NSString alloc] initWithFormat:@"_%@", propertyName] UTF8String]);
        }
        
        // 赋值
        if(iVar != nil)
        {
            id propertyValue = object_getIvar(objEntity, iVar);
            
            // 如果是自动解析的对象，属性名称会被重定义，比如 passengers__FTTSInterAutoFillPassenger
            // 这时候为了正确的组装成json，需要恢复属性的名称
            if ([propertyValue isKindOfClass:[NSArray class]] || [propertyValue isKindOfClass:[NSDictionary class]])
            {
                NSArray *arrayPropertyNames = [propertyName componentsSeparatedByString:@"__"];
                propertyName = [arrayPropertyNames firstObject];
            }
            id childObj = [SerializeUtility serializeObject:propertyValue];
            
            // 插入Dictionary中
            if(childObj != nil)
            {
                [dictionary setObject:childObj forKey:propertyName];
            }
        }
    }
    
    free(properties);
    
    return dictionary;
}

+ (void)parseJsonObject:(NSDictionary *)dictionaryJson withObject:(NSObject *)objEntity
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([objEntity class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = property_getAttributes(property);
        if(propName && propType)
        {
            //获取真实的属性名
            NSString *propertyNameOrigin = [NSString stringWithUTF8String:propName];
            NSArray *names = [propertyNameOrigin componentsSeparatedByString:@"__"];
            NSString *propertyName = [names objectAtIndex:0];
            
            //获取真实的属性类型
            NSString *propertyType = [self getType:propType];
            
            //获取属性的值
            id jsonEntity = nil;
            if (dictionaryJson && [dictionaryJson isKindOfClass:[NSDictionary class]]) {
                jsonEntity = [dictionaryJson objectForKey:propertyName];
            }
            
            // NSNull
            if([propertyType isEqualToString:[NSNull className]] ||
               [jsonEntity isKindOfClass:[NSNull class]] || jsonEntity == nil)
            {
                continue;
            }
            // NSNumber NSString 基本类型
            else if([propertyType isEqualToString:[NSNumber className]] ||
                    [propertyType isEqualToString:[NSString className]])
            {
                [objEntity setValue:jsonEntity forKey:propertyName];
            }
            // array
            else if([propertyType isEqualToString:[NSArray className]] ||
                    [propertyType isEqualToString:[NSMutableArray className]])
            {
                //小于2 无数组元素类型 不解析
                if ([names count] >= 2)
                {
                    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
                    
                    for (id item in jsonEntity)
                    {
                        Class objCls = NSClassFromString([names objectAtIndex:1]);
                        id childObj = [[objCls alloc] init];
                        
                        [SerializeUtility parseJsonObject:item withObject:childObj];
                        
                        [mutableArray addObject:childObj];
                    }
                    
                    [objEntity setValue:mutableArray forKey:propertyNameOrigin];
                }
            }
            // NSDictionary
            else if([propertyType isEqualToString:[NSDictionary className]] ||
                    [propertyType isEqualToString:[NSMutableDictionary className]])
            {
                NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
                
                for (id key in [jsonEntity allKeys])
                {
                    id val = [jsonEntity objectForKey:key];
                    
                    //小于2 无字典元素类型 不解析
                    if ([names count] >= 2)
                    {
                        Class objCls = NSClassFromString([names objectAtIndex:1]);
                        id childObj = [[objCls alloc] init];
                        
                        [SerializeUtility parseJsonObject:val withObject:childObj];
                        val = childObj;
                    }
                    
                    [mutableDict setValue:val forKey:key];
                }
                
                [objEntity setValue:mutableDict forKey:propertyNameOrigin];
                
            }
            // NSObject
            else if (!IsStrEmpty(propertyType))
            {
                Class objCls = NSClassFromString(propertyType);
                id childObj = [[objCls alloc] init];
                
                [SerializeUtility parseJsonObject:jsonEntity withObject:childObj];
                
                [objEntity setValue:childObj forKey:propertyName];
            }
        }
    }
    free(properties);
}


+ (NSString *)getType:(const char *)propType
{
    NSString *propertyType = [NSString stringWithUTF8String:propType];
    NSArray *propertyTypeArray = [propertyType componentsSeparatedByString:@"\""];
    
    if ([propertyTypeArray count] > 1)
    {
        return [propertyTypeArray objectAtIndex:1];
    }
    return nil;
}

@end
