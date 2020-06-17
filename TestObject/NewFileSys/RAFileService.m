//
//  RAFileService.m
//  TestObject
//
//  Created by 冯驰伟 on 2018/12/31.
//  Copyright © 2018 冯驰伟. All rights reserved.
//

#import "RAFileService.h"
#import "RASysType.h"
#import "RALocalFileSystem.h"

@implementation RAFileService

- (id<IRAFileSystem>) createFileSystem:(RASysType) type
{
    switch (type) {
        case SYS_TYPE_LOCAL:
            return [RALocalFileSystem new];
            break;

        default:
            break;
    }
    
    return nil;
}


@end
