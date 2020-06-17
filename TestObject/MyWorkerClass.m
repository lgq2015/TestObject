//
//  MyWorkerClass.m
//  TestObject
//
//  Created by 冯驰伟 on 2020/4/23.
//  Copyright © 2020 冯驰伟. All rights reserved.
//

#define kMsg1 100
#define kMsg2 101

#import "MyWorkerClass.h"

@implementation MyWorkerClass

- (void)launchThreadWithPort:(NSPort *)port {
    @autoreleasepool {
            //1. 保存主线程传入的
            self.remotePort = port;
            //2. 设置子线程名字
            [[NSThread currentThread] setName:@"MyWorkerClassThread"];
            //3. 创建自己
            self.myPort = [NSPort port];
            _myPort.delegate = self;
        
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(action:) userInfo:nil repeats:NO];
        
            //4. 将自己的port添加到runloop//作用1、防止runloop执行完毕之后推出//作用2、接收主线程发送过来的port消息
            [[NSRunLoop currentRunLoop] addPort:_myPort forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
}

-(void) action:(NSTimer*) temp
{
    [self sendPortMessage];
}

- (void)sendPortMessage {
    NSMutableArray *array  =[[NSMutableArray alloc]initWithArray:@[[@"1" dataUsingEncoding:NSUTF8StringEncoding], [@"2" dataUsingEncoding:NSUTF8StringEncoding]]];
    //fengchiwei 这是错的，线程间的数据一定要编码为Data这种字节流，不能是NSString这些内置类型。
    //NSMutableArray *array  =[[NSMutableArray alloc]initWithArray:@[@"1", @"2"]];
        //发送消息到主线程，操作1
    [self.remotePort sendBeforeDate:[NSDate date]
                             msgid:kMsg1
                        components:array
                               from:self.myPort
                          reserved:0];
}

#pragma mark - NSPortDelegate/**
- (void)handlePortMessage:(id)message
{
    NSLog(@"接收到父线程的消息...\n");
    
    uint64_t roomId = 123456789;
    NSMutableString* roomName = [NSMutableString stringWithFormat:@"%09llu", roomId];
    [roomName insertString:@"-" atIndex:3];
    [roomName insertString:@"-" atIndex:7];
    roomName = [NSMutableString stringWithFormat:@"房间 %@", roomName];
    
    NSLog(roomName);
    
}

@end
