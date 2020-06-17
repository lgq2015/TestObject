//
//  MyWorkerClass.h
//  TestObject
//
//  Created by 冯驰伟 on 2020/4/23.
//  Copyright © 2020 冯驰伟. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyWorkerClass:NSObject<NSPortDelegate>

@property(nonatomic, strong) NSPort *remotePort;
@property(nonatomic, strong) NSPort *myPort;

- (void)launchThreadWithPort:(NSPort *)port;
@end

NS_ASSUME_NONNULL_END
