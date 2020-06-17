//
//  RAFile.h
//  TestObject
//
//  Created by 冯驰伟 on 2019/1/1.
//  Copyright © 2019 冯驰伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRAFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface RAFile : NSObject<IRAFile>

-(instancetype) init:(NSString*) path;

@end

NS_ASSUME_NONNULL_END
