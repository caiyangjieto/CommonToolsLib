//
//  NetToolManager.m
//  NetToolKit
//
//  Created by caiyangjieto on 15/6/29.
//  Copyright (c) 2015年 qinisky.com. All rights reserved.
//

#import "NetToolManager.h"
#import "NetToolUtility.h"
#import "NetToolCache.h"
#import "NetToolDelegate.h"
#import "NetToolTask.h"

NSInteger const maxQueueSize = 100;

@interface NetToolManager ()

@property (nonatomic, strong)  NSMutableArray *runningConnectionQueue;
@property (nonatomic, strong)  NSMutableArray *waitingConnectionQueue;
@property (nonatomic, strong)  NSMutableArray *runningDelegateQueue;
@property (nonatomic, strong)  NSMutableArray *waitingDelegateQueue;

@end

@implementation NetToolManager

+ (NetToolManager *)getInstance
{
    static NetToolManager *sharedNetToolManagerInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedNetToolManagerInstance = [[super allocWithZone:NULL] init];
        sharedNetToolManagerInstance.runningConnectionQueue = [NSMutableArray array];
        sharedNetToolManagerInstance.waitingConnectionQueue = [NSMutableArray array];
        sharedNetToolManagerInstance.runningDelegateQueue = [NSMutableArray array];
        sharedNetToolManagerInstance.waitingDelegateQueue = [NSMutableArray array];

    });
    
    return sharedNetToolManagerInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - 接口功能函数
//添加connection
- (void)addConnection:(NetToolDownLoader *)connection andDelegate:(id)delegate
{
    @synchronized(self)
    {
        if (connection != nil)
        {
            [_waitingConnectionQueue addObject:connection];
            
            if (delegate == nil)
            {
                [_waitingDelegateQueue addObject:[[NSNull alloc] init]];
            }
            else
            {
                [_waitingDelegateQueue addObject:delegate];
            }
        }
    }
    
    [self refreshRunningQueue];
}

// 完成网络请求
- (void)finishConnection:(NetToolDownLoader *)connection result:(NSData *)result
{
    @synchronized(self){
        
        if(!_runningConnectionQueue || !_runningDelegateQueue)
            return;
        
        NSInteger count = [_runningConnectionQueue count];
        for(NSInteger i = 0; i < count; i++)
        {
            NetToolDownLoader *urlConnection = [_runningConnectionQueue objectAtIndexSafe:i];
            if(connection != urlConnection)
                continue;
            
            NetToolDelegate *netToolDelegate = [_runningDelegateQueue objectAtIndexSafe:i];
            [NetToolTask searchReturnData:netToolDelegate result:result];
            break;
        }
        
    }
    
    [self removeConnection:connection];
}

// 删除connection
- (void)removeConnection:(NetToolDownLoader *)connection
{
    @synchronized(self)
    {
        [self removeConnection:connection
               arrayConnection:_runningConnectionQueue
                 arrayDelegate:_runningDelegateQueue];
        [self removeConnection:connection
               arrayConnection:_waitingConnectionQueue
                 arrayDelegate:_waitingDelegateQueue];
    }
    
    [self refreshRunningQueue];
}

- (void)removeService:(NSString *)service
{
    @synchronized(self)
    {
        NSInteger countRunning = [_runningDelegateQueue count];
        for(NSInteger i = 0; i < countRunning; i++)
        {
            NetToolDelegate *netToolDelegate = [_runningDelegateQueue objectAtIndexSafe:i];
            if(![netToolDelegate.service isEqualToString:service])
                continue;
            
            NetToolDownLoader *connection = [_runningConnectionQueue objectAtIndexSafe:i];
            [self removeConnection:connection
                   arrayConnection:_runningConnectionQueue
                     arrayDelegate:_runningDelegateQueue];
        }
        
        NSInteger countWaiting = [_waitingDelegateQueue count];
        for(NSInteger i = 0; i < countWaiting; i++)
        {
            NetToolDelegate *netToolDelegate = [_waitingDelegateQueue objectAtIndexSafe:i];
            if(![netToolDelegate.service isEqualToString:service])
                continue;
            
            NetToolDownLoader *connection = [_waitingConnectionQueue objectAtIndexSafe:i];
            [self removeConnection:connection
                   arrayConnection:_waitingConnectionQueue
                     arrayDelegate:_waitingDelegateQueue];
        }
        
    }
    
    [self refreshRunningQueue];
}

- (void)removeTarget:(id)target
{
    @synchronized(self)
    {
        NSInteger countRunning = [_runningDelegateQueue count];
        for(NSInteger i = 0; i < countRunning; i++)
        {
            NetToolDelegate *netToolDelegate = [_runningDelegateQueue objectAtIndexSafe:i];
            if(netToolDelegate.delegate != target)
                continue;
            
            NetToolDownLoader *connection = [_runningConnectionQueue objectAtIndexSafe:i];
            [self removeConnection:connection
                   arrayConnection:_runningConnectionQueue
                     arrayDelegate:_runningDelegateQueue];
        }
        
        NSInteger countWaiting = [_waitingDelegateQueue count];
        for(NSInteger i = 0; i < countWaiting; i++)
        {
            NetToolDelegate *netToolDelegate = [_waitingDelegateQueue objectAtIndexSafe:i];
            if(netToolDelegate.delegate != target)
                continue;
            
            NetToolDownLoader *connection = [_waitingConnectionQueue objectAtIndexSafe:i];
            [self removeConnection:connection
                   arrayConnection:_waitingConnectionQueue
                     arrayDelegate:_waitingDelegateQueue];
        }
        
    }
    
    [self refreshRunningQueue];
}

#pragma mark - 辅助函数

- (void)refreshRunningQueue
{
    @synchronized(self) {
        NSInteger availableCount = maxQueueSize - _runningConnectionQueue.count;
        
        while (availableCount > 0)
        {
            if (_waitingConnectionQueue.count)
            {
                NetToolDownLoader *itemConnect = _waitingConnectionQueue[0];
                NetToolDownLoader *itemDelegate = _waitingDelegateQueue[0];
                if (itemConnect && itemDelegate)
                {
                    [_runningConnectionQueue addObject:itemConnect];
                    [_runningDelegateQueue addObject:itemDelegate];
                    [_waitingConnectionQueue removeObject:itemConnect];
                    [_waitingDelegateQueue removeObject:itemDelegate];
                    
                    [itemConnect start];
                }
            }
            
            availableCount--;
        }
    }
}

// 取消代理回调
- (void)cancelNetCallBackWithDelegate:(id)delegate
{
    if((delegate != nil) && ([delegate isKindOfClass:[NetToolDelegate class]]))
    {
        [delegate setDelegate:nil];
    }
}

- (void)removeConnection:(NetToolDownLoader *)connection
         arrayConnection:(NSMutableArray *)arrayConnection
           arrayDelegate:(NSMutableArray *)arrayDelegate
{
    if(!arrayConnection || !arrayDelegate)
    {
        return;
    }
    
    NSMutableArray *arrayConnectRemove = [[NSMutableArray alloc] init];
    NSMutableArray *arrayDelegateRemove = [[NSMutableArray alloc] init];
    
    NSInteger count = [arrayConnection count];
    for(NSInteger i = 0; i < count; i++)
    {
        NetToolDownLoader *urlConnection = [arrayConnection objectAtIndex:i];
        if(connection == urlConnection)
        {
            [urlConnection cancel];
            
            id delegate = [arrayDelegate objectAtIndex:i];
            [self cancelNetCallBackWithDelegate:delegate];
            
            [arrayConnectRemove addObject:urlConnection];
            [arrayDelegateRemove addObject:delegate];
        }
    }
    
    [arrayDelegate removeObjectsInArray:arrayDelegateRemove];
    [arrayConnection removeObjectsInArray:arrayConnectRemove];
    
    [arrayDelegateRemove removeAllObjects];
    [arrayConnectRemove removeAllObjects];

}

// 销毁
- (void)destroy
{
    _runningConnectionQueue = nil;
    _runningDelegateQueue = nil;
    _waitingConnectionQueue = nil;
    _waitingDelegateQueue = nil;
}

@end
