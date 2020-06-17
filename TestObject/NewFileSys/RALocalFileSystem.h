//
//  RAFileSystem.h
//  TestObject
//
//  Created by 冯驰伟 on 2018/12/31.
//  Copyright © 2018 冯驰伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRAFileSystem.h"

@protocol IRAFile;


NS_ASSUME_NONNULL_BEGIN

@interface RALocalFileSystem : NSObject<IRAFileSystem>

- (id<IRAFile>) openFile:(NSString*) path;

@end

NS_ASSUME_NONNULL_END
